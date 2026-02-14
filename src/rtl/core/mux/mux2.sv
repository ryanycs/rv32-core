module mux2 (
    input  logic [31:0]  in1,
    input  logic [31:0]  in2,
    input  logic         sel,
    output logic [31:0]  out
);

always_comb begin
    if (sel)
        out = in2;
    else
        out = in1;
end

endmodule
