module PWM_generator (PWM_ontime, PWM_out , clk , reset);

input clk, reset; // Port type declared
input [7:0] PWM_ontime; // 8-bit PWM input

output reg PWM_out; // 1 bit PWM output
wire [7:0] counter_out; // 8-bit counter


always @ (posedge clk)
begin
if (PWM_ontime > counter_out)
  PWM_out <= 1;
else
  PWM_out <= 0;
end
counter counter_inst(
.clk (clk),
.counter_out (counter_out),
.reset(reset)
);

endmodule

module counter(counter_out,clk,reset);

output [7:0] counter_out;
input clk, reset;
reg [7:0] counter_out;
always @(posedge clk)
if (reset)
  counter_out <= 8'b0;
else
  counter_out <= counter_out + 1;
endmodule