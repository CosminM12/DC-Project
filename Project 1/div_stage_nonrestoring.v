module div_stage_nonrestoring (input [7:0] R_in, input [7:0] D,
                               input Ctrl,
                               output [7:0] R_out, output Q_bit);

    wire [8:0] c;

    //Carry-in tied to Ctrl (Ctrl=1(Subtract), Cin=1(for 2's compl); Ctrl=0(Add), Cin=0)
    buf g_cin(c[0], Ctrl);

    cas_cell c0(.A(R_in[0]), .B(D[0]), .Cin(c[0]), .Ctrl(Ctrl), .Sum(R_out[0]), .Cout(c[1]));
    cas_cell c1(.A(R_in[1]), .B(D[1]), .Cin(c[1]), .Ctrl(Ctrl), .Sum(R_out[1]), .Cout(c[2]));
    cas_cell c2(.A(R_in[2]), .B(D[2]), .Cin(c[2]), .Ctrl(Ctrl), .Sum(R_out[2]), .Cout(c[3]));
    cas_cell c3(.A(R_in[3]), .B(D[3]), .Cin(c[3]), .Ctrl(Ctrl), .Sum(R_out[3]), .Cout(c[4]));
    cas_cell c4(.A(R_in[4]), .B(D[4]), .Cin(c[4]), .Ctrl(Ctrl), .Sum(R_out[4]), .Cout(c[5]));
    cas_cell c5(.A(R_in[5]), .B(D[5]), .Cin(c[5]), .Ctrl(Ctrl), .Sum(R_out[5]), .Cout(c[6]));
    cas_cell c6(.A(R_in[6]), .B(D[6]), .Cin(c[6]), .Ctrl(Ctrl), .Sum(R_out[6]), .Cout(c[7]));
    cas_cell c7(.A(R_in[7]), .B(D[7]), .Cin(c[7]), .Ctrl(Ctrl), .Sum(R_out[7]), .Cout(c[8]));

    //New quotient bit is NOT of final carry-out (sign of the result)
    not g_q(Q_bit, c[8]);

endmodule