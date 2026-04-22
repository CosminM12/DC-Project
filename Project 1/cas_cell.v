module cas_cell (input A, B, Cin, Ctrl /*0=add. 1=subtract*/, 
                 output Sum, Cout);

    wire BxorCtrl;

    xor g_bxor(BxorCtrl, B, Ctrl);

    full_adder fa_inst(.A(A), .B(BxorCtrl), .Cin(Cin), .Sum(Sum), .Cout(Cout));

endmodule