always @ (S or X or Y) begin 	// If any of the signals S, X or Y
								// change state, execute this code.
								// Note that signals to the left of an
								// equal sign in an always block
								// need to be declared of type reg so
								// declare M as:
								// output reg [2:0] M;
	if(S == 1)
		M <= Y;			//Note the non-blocking operator ‘<=’
	else
		M <= X;
end
