module subtractor_8bit (input [7:0] A, input [7:0] B, output [7:0] Diff, output overflow);

    wire [7:0] B_not;
    wire [8:0] C; //Carry chain

    //Get B negated (1's complement of B)
    not g_n0(B_not[0], B[0]);
    not g_n1(B_not[1], B[1]);
    not g_n2(B_not[2], B[2]);
    not g_n3(B_not[3], B[3]);
    not g_n4(B_not[4], B[4]);
    not g_n5(B_not[5], B[5]);
    not g_n6(B_not[6], B[6]);
    not g_n7(B_not[7], B[7]);

    //Make the +1 addition for the 2's complement 
    supply1 vcc;
    buf g_cin(c[0], vcc); //c[0] is always set to 1

    //Add A + (~B) + 1
    full_adder fa0(.A(A[0]), .B(B_not[0]), .Cin(c[0]), .Sum(Diff[0]), .Cout(c[1]));
    full_adder fa1(.A(A[1]), .B(B_not[1]), .Cin(c[1]), .Sum(Diff[1]), .Cout(c[2]));
    full_adder fa2(.A(A[2]), .B(B_not[2]), .Cin(c[2]), .Sum(Diff[2]), .Cout(c[3]));
    full_adder fa3(.A(A[3]), .B(B_not[3]), .Cin(c[3]), .Sum(Diff[3]), .Cout(c[4]));
    full_adder fa4(.A(A[4]), .B(B_not[4]), .Cin(c[4]), .Sum(Diff[4]), .Cout(c[5]));
    full_adder fa5(.A(A[5]), .B(B_not[5]), .Cin(c[5]), .Sum(Diff[5]), .Cout(c[6]));
    full_adder fa6(.A(A[6]), .B(B_not[6]), .Cin(c[6]), .Sum(Diff[6]), .Cout(c[7]));
    full_adder fa7(.A(A[7]), .B(B_not[7]), .Cin(c[7]), .Sum(Diff[7]), .Cout(c[8]));

    xor g_overflow(overflow, c[7], c[8]);


endmodule