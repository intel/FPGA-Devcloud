always @ (S or X or Y) begin case (S):
	1’b0: M <= X;
	1’b1: M <= Y;
endcase end
