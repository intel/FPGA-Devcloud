#!/bin/bash

function show_usage {
echo "Usage: 
    path/to/this/run.sh DESIGN OPTIONS
    path/to/this/run.sh clean

DESIGN:
    basic                 UREs with 3 loops
    tiling                UREs with every loop tiled twice
    stt-vectorize         Enable space-time transform and vectorization
    reorder               Move kk loop outer
    isolate               Isolate drainer, deserializer, or full I/O paths
    opt-input             Optimize input network: Mimimize host-device data transfer; buffer and scatter inputs
    opt-output            Optimize output network
    
OPTIONS: [isolate OPTIONS] [SIZE] ACTION 

isolate OPTIONS:
    drainer               For "isolate" design only. Isolate drainer.
    drainer-deserializer  For "isolate" design only. Isolate drainer and deserializer
    full-IO               For "isolate" design only. Isolate full I/O paths

SIZE:
    tiny | small | medium |large 
                          Tiny, small, medium or large systolic array and input sizes. No effect to the basic design.
    
ACTION:
    emulator              Emulate the design
    rtl                   Compile the design into .aocr and generate compiler reports without synthesis
    bits                  Synthesize the design into .aocx (bitstream)
    max-freq              Same as bits, in addition, target highest possible fequency
    use-bits              Offload the bitstream to an FPGA to run
    show-profile          Show dynamic profile (when a GUI to DevCloud is enabled)        

clean:                    Delete everything in the tutorials directory

Examples:
    /data/t2s/tutorials/fpga/matrix-multiply/run.sh basic emulator             # Emulate the basic desig
    /data/t2s/tutorials/fpga/matrix-multiply/run.sh isolate full-IO midium rtl # Isolate full I/O paths with medium array
                                                                               # size. Generate compiler reports
    /data/t2s/tutorials/fpga/matrix-multiply/run.sh opt-output large bits      # Generate a bistream for the output optimized design
                                                                               # with large array size
    /data/t2s/tutorials/fpga/matrix-multiply/run.sh opt-output large use-bits  # Offload to an FPGA the bistream for the output
                                                                               # optimized design with large array size"
}

if [ $0 != $BASH_SOURCE ]; then
   # This script is being sourced. It should be directly run instead.
   show_usage   
   return
fi 

if [ "$1" == "clean" ]; then
    set -x
    rm -rf $CODE_STORE_DIR/*
    set +x
    exit
fi

if [ "$1" != "basic" -a  "$1" != "tiling" -a  "$1" != "stt-vectorize" -a  "$1" != "reorder" -a \
     "$1" != "isolate" -a  "$1" != "opt-input" -a  "$1" != "opt-output"  -a  "$1" != "final" ]; then
    echo DESIGN $1 does not exist.
    show_usage
    exit
fi
DESIGN="$1"

ISOLATE_WHAT=""        
SIZES=""
sizes=""
EMULATOR=0
RTL=0
BITS=0
MAX_FREQ=0
USE_BITS=0
SHOW_PROFILE=0        
        
shift
for i in "$@"
do
    case "$i" in
        "drainer" | "drainer-deserializer" | "full-IO" )
            if [ "$DESIGN" != "isolate" ]; then
                echo OPTION $i applicable only to the isolate design.
                show_usage
                exit
            fi
            if [ "$ISOLATE_WHAT" != "" ]; then
                echo Conflicting options for the isolate design: $ISOLATE_WHAT, $i
                show_usage
                exit
            fi
            ISOLATE_WHAT="$i"
            ;;

        "emulator" )
            EMULATOR=1
            ;;

        "rtl" )
            RTL=1
            ;;
                
        "bits" )
            BITS=1
            ;;
         
        "max-freq" )
            MAX_FREQ=1
            ;;
	    
        "use-bits" )
            USE_BITS=1
            ;;
       
        "show-profile" )
            SHOW_PROFILE=1
            ;;

        "tiny" )
	    SIZES="-DTINY"
	    sizes="tiny"
            ;;
	
        "small" )
            SIZES="-DSMALL"
	    sizes="small"
            ;;
            
        "medium" )
            SIZES="-DMEDIUM"
	    sizes="medium"
            ;;

        "large" )
            SIZES="-DLARGE"
	    sizes="large"
            ;;
            
        *)
            echo Unknown option $i
            show_usage
            exit
            ;;
    esac
done    

if [ "$DESIGN" == "isolate" -a "$ISOLATE_WHAT" == "" ]; then
    echo Isolate: expect an option
    show_usage
    exit
fi

if [ "$SIZES" == "" ]; then
    # Use small size by default
    SIZES="-DSMALL"
fi

counter=0
if [ "$EMULATOR" != "0" ]; then
    ((counter=counter+1))
fi
if [ "$RTL" != "0" ]; then
    ((counter=counter+1))
fi
if [ "$BITS" != "0" ]; then
    ((counter=counter+1))
fi
if [ "$MAX_FREQ" != "0" ]; then
    ((counter=counter+1))
fi
if [ "$USE_BITS" != "0" ]; then
    ((counter=counter+1))
fi
if [ "$SHOW_PROFILE" != "0" ]; then
    ((counter=counter+1))
fi
if [ "$counter" != "1" ]; then
    echo Expect one and only one of the options: emulator, rtl, bits, max-freq, use-bits, and show-profile.
    show_usage
    exit
fi

if [ "$FPGA_MODEL" != "a10" -a "$FPGA_MODEL" != "s10" ]; then
    echo "Unexpected FPGA_MODEL. Source /data/t2s/setenv.sh before running this script"
    exit
fi

THIS_TUTORIAL_PATH="$( cd "$(dirname $(realpath "$BASH_SOURCE") )" >/dev/null 2>&1 ; pwd -P )" # The path to this script

# The specification file to compile/run
if [ "$DESIGN" == "isolate" ]; then
    SPEC_NAME=isolate-$ISOLATE_WHAT
else
    SPEC_NAME=main
fi    
SPEC=$THIS_TUTORIAL_PATH/$DESIGN/$SPEC_NAME.cpp

if  [ "$RTL" == "1" ]; then
    set -x
    cd $CODE_STORE_DIR
    rm -rf $CODE_STORE_DIR/*
    
    # Generate an OpenCL file
    g++ $SPEC $CXX_FLAGS $SIZES -DCOMPILE_ONLY -o ./a.out
    env BITSTREAM=$CODE_STORE_DIR/a.aocx PRAGMAUNROLL=1 ./a.out
    
    # Compile the OpenCL file and generate estimated performance
    aoc -rtl -report -board=$FPGA_BOARD ./a.cl
    cd -
    set +x
fi

if [ "$EMULATOR" == "1" ]; then
    set -x
    cd $CODE_STORE_DIR
    rm -rf $CODE_STORE_DIR/* 
    
    # Generate an OpenCL file, compile it into a bitstream and emulate.
    g++ $SPEC $CXX_FLAGS $SIZES -o ./a.out
    env INTEL_FPGA_OCL_PLATFORM_NAME="$EMULATOR_PLATFORM_NAME"  CL_CONTEXT_EMULATOR_DEVICE_INTELFPGA=1 \
        CL_CONFIG_CHANNEL_DEPTH_EMULATION_MODE=strict BITSTREAM=$CODE_STORE_DIR/a.aocx \
        PRAGMAUNROLL=1 AOC_OPTION="-march=emulator -board=$FPGA_BOARD" ./a.out
    cd -
    set +x
fi

if  [ "$BITS" == "1" -o "$MAX_FREQ" == "1" ]; then
    set -x
    cd $CODE_STORE_DIR
    rm -rf $CODE_STORE_DIR/*
    
    # Generate an OpenCL file
    g++ $SPEC $CXX_FLAGS $SIZES -DCOMPILE_ONLY -o ./a.out
    env BITSTREAM=$CODE_STORE_DIR/a.aocx DELAYUNROLL=1 ./a.out
    
    # Compile the OpenCL file into a bitstream
    FREQ_OPT=""
    if [ "$MAX_FREQ" == "1" ]; then
        FREQ_OPT="-fmax=500"
    fi	
    aoc -v -report -profile -g ./a.cl -o ./a.aocx -board=$FPGA_BOARD $FREQ_OPT
    
    # Convert signed to unsigned bitstream
    echo Converting signed to unsigned bitstream... Type `y` when prompted.
    source $AOCL_BOARD_PACKAGE_ROOT/linux64/libexec/sign_aocx.sh -H openssl_manager -i ./a.aocx -r NULL -k NULL -o ./a_unsigned.aocx 
    cd -
    set +x
fi

if  [ "$USE_BITS" == "1" ]; then
    set -x
    cd $CODE_STORE_DIR

    # Known issue: we have a bug in Halide OpenCL runtime on DevCloud. So we use a handwritten host file for now.
    if [ -f "$THIS_TUTORIAL_PATH/host-files/host-$DESIGN.cpp" ]; then
        HOST_FILE="$THIS_TUTORIAL_PATH/host-files/host-$DESIGN.cpp"
    else
        HOST_FILE="$THIS_TUTORIAL_PATH/host-files/host.cpp"
    fi
    g++ $HOST_FILE $SIZES -g -DLINUX -DALTERA_CL -fPIC \
        -I$INTELFPGAOCLSDKROOT/examples_aoc/common/inc \
        $INTELFPGAOCLSDKROOT/examples_aoc/common/src/AOCLUtils/opencl.cpp \
        $INTELFPGAOCLSDKROOT/examples_aoc/common/src/AOCLUtils/options.cpp \
        -I$INTELFPGAOCLSDKROOT/host/include $AOCL_LIBS -lelf -o ./host.out
       
     if [ -f "$CODE_STORE_DIR/a_unsigned.aocx" ]; then
         env BITSTREAM="$CODE_STORE_DIR/a_unsigned.aocx" ./host.out
     else
         if [ "$DESIGN" == "isolate" ]; then
             PREGEN_NAME="$THIS_TUTORIAL_PATH/bitstreams/$DESIGN-$ISOLATE_WHAT-$sizes-$FPGA_MODEL-unsigned"		 
	 else
	     PREGEN_NAME="$THIS_TUTORIAL_PATH/bitstreams/$DESIGN-$sizes-$FPGA_MODEL-unsigned"
	 fi
         PREGEN_BITS="$PREGEN_NAME.aocx"
         cp $PREGEN_BITS $CODE_STORE_DIR/a_unsigned.aocx
         cp $PREGEN_NAME.source $CODE_STORE_DIR/a.source

         if [ -f "$PREGEN_BITS" ]; then
	     env BITSTREAM="$PREGEN_BITS" ./host.out	
         else
             echo No bitstream found
	     cd -
	     set +x
	     exit
	 fi
     fi	 

    #In future, we should do the following instead.
    #env INTEL_FPGA_OCL_PLATFORM_NAME="$HW_RUN_PLATFORM_NAME" BITSTREAM=$CODE_STORE_DIR/a.aocx AOC_OPTION="-board=$FPGA_BOARD" $CODE_STORE_DIR/a.out
    cd -
    set +x
fi

if [ "$SHOW_PROFILE" == "1" ]; then  
    set -x
    cd $CODE_STORE_DIR    
    # To workaround a known issue in aoc, replace the source file name with its full path in the bitstream.
    # https://community.intel.com/t5/Intel-High-Level-Design/Profiling-data-missing-in-aocl-report-for-OpenCL-kernel/td-p/724236
    full_path=$(aocl binedit a.source print .acl.file.0)
    aocl binedit a_unsigned.aocx print .acl.profiler.xml > temp.txt
    sed "s+"a.cl"+"$full_path"+g" temp.txt > b.txt
    aocl binedit a_unsigned.aocx set .acl.profiler.xml  b.txt
    aocl report a_unsigned.aocx a.source profile.mon
    cd -
    set +x
fi
