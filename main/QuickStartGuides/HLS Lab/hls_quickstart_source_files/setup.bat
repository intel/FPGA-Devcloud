@ECHO OFF
:: This batch file initializes the Visual Studios environment.
TITLE setup
ECHO =================================================================
ECHO Initializing the Visual Studios x64 Command Prompt environment.
ECHO =================================================================
ECHO Running init_hls.bat script...
call "C:\intelFPGA_lite\18.1\hls\init_hls.bat"
ECHO =================================================================
ECHO Initializing InstallRoot pathway...
set "INSTALLROOT=%INSTALLROOT: =%"
ECHO Initializing Include pathway...
set "INCLUDE=%INSTALLROOT%include;%INCLUDE%"
ECHO Initializing LIB pathway...
set "LIB=%INSTALLROOT%host\windows64\lib;%LIB%"
ECHO Initializing _LINK_ pathway...
set "_LINK_=hls_emul.lib"
ECHO Setting quartus alias...
set quartus="C:\intelFPGA_lite\18.1\quartus\bin64\quartus"
set quartus_sh="C:\intelFPGA_lite\18.1\quartus\bin64\quartus_sh"
ECHO ==========================
ECHO Initialization Complete.
ECHO ==========================
:end
