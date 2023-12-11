`timescale 1ns / 100ps
module testBench(

    );
    reg [31:0] intruction;
    reg clk = 0;
    wire regDst, regWrite, ALUSrc, memWrite, memRead, memToReg; 
    wire [3:0] ALUcontrol;
    
    parameter   addOp = 6'b001,
                lwOp = 6'b010,
                swOp = 6'b101;
    
    initial forever #5 clk = ~clk;
    
    initial begin
        intruction = {addOp, 5'd0, 5'd1, 5'd2, 11'b0};
        #10 intruction = {lwOp, 5'd0, 5'd1, 16'd8};
        #10 intruction = {swOp, 5'd0, 5'd3, 16'd12};

    end
    
    Data_Path dataPath (
        .intruction(intruction),
        .regDst(regDst),
        .regWrite(regWrite),
        .ALUSrc(ALUSrc),
        .memWrite(memWrite),
        .memRead(memRead),
        .memToReg(memToReg),
        .clk(clk)
    );
    
    ControlUnit control (
        .RegDst(RegDst),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemToReg(MemToReg),
        .ALUcontrol(ALUcontrol),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .op(intruction[31:26]),
        .clk(clk)
    );
    
endmodule