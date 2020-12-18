module reg32 (clk, resetn, D, byteenable, Q);
input clk, resetn;
input [3:0] byteenable;
input [31:0] D;
output reg [31:0] Q;

always @(posedge clk)
if (!resetn)
  Q <= 32'b0;
else

begin
// Enable writing to each byte separately
	if (byteenable[0]) Q[7:0] <= D[7:0];
	if (byteenable[1]) Q[15:8] <= D[15:8];
	if (byteenable[2]) Q[23:16] <= D[23:16];
	if (byteenable[3]) Q[31:24] <= D[31:24];
end

endmodule

module reg32_avalon_interface (clk, resetn, writedata, readdata, write, read,
byteenable, chipselect, Q_export);

// signals for connecting to the Avalon fabric
input clk, resetn, read, write, chipselect;
input [3:0] byteenable;
input [31:0] writedata;
output [31:0] readdata;
// signal for exporting register contents outside of the embedded system
output [31:0] Q_export;
wire [3:0] local_byteenable;
wire [31:0] to_reg, from_reg;

assign to_reg = writedata;
assign local_byteenable = (chipselect & write) ? byteenable : 4'd0;

reg32 U1 ( .clk(clk), .resetn(resetn), .D(to_reg),
.byteenable(local_byteenable), .Q(from_reg) );

assign readdata = from_reg;
assign Q_export = from_reg;
endmodule