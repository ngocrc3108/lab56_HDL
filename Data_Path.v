`timescale 1ns / 100ps
module Data_Path(
    input[31:0] intruction,
    input regDst,
    input regWrite,
    input ALUSrc,
    input[3:0] ALUcontrol,
    input memWrite,
    input memRead,
    input memToReg,
    input clk
    );
    wire [4:0] WR;
    wire [31:0] WD, RD1, RD2, signExtended, ALUinB, aluResult, readData;
    
    mux_2to1 #(.nBit(5)) 
    regDstMux(
        .out(WR),
        .in0(intruction[20:16]),
        .in1(intruction[15:11]),
        .sel(regDst)    
    );
    
    Registers registers (
        .ReadAddress1(intruction[25:21]),
        .ReadAddress2(intruction[20:16]),
        .WriteEn(regWrite),
        .WriteAddress(WR),
        .WriteData(WD),
        .ReadData1(RD1),
        .ReadData2(RD2),
        .clk(clk)
    );
    
    SignExtend signExtend (
        .in(intruction[15:0]),
        .out(signExtended)
    );
    
    mux_2to1 #(.nBit(32)) aluInB (
        .out(ALUinB),
        .in0(RD2),
        .in1(signExtended),
        .sel(ALUSrc)
    );
    
    ALU alu (
        .result(aluResult),
        .a(RD1),
        .b(ALUinB)
    );
    
    Memory mem (
        .Address(aluResult),
        .WriteData(RD2),
        .ReadData(readData),
        .MemRead(memRead),
        .MemWrite(memWrite),
        .clk(clk)
    );
    
    mux_2to1 #(.nBit(32)) muxMemToReg (
        .out(WD),
        .in1(readData),
        .in0(aluResult),
        .sel(memToReg)
    );
    
endmodule

module mux_2to1 
    #(parameter nBit = 1)(
    output [0:nBit-1] out,
    input [0:nBit-1] in0,
    input [0:nBit-1] in1,
    input sel
    );
    assign out = sel ? in1 : in0;
endmodule

module Registers(
    output reg[31:0] ReadData1,
    output reg[31:0] ReadData2,
    input clk,
    input WriteEn,
    input[4:0] WriteAddress,
    input[31:0] WriteData,
    input[4:0] ReadAddress1,
    input[4:0] ReadAddress2
    );
    reg[31:0] mem[0:31];
    
    always @ (posedge clk) begin
        if(WriteEn)
            mem[WriteAddress] <= WriteData;
        begin
            ReadData1 <= mem[ReadAddress1]; 
            ReadData2 <= mem[ReadAddress2];
        end
    end
endmodule

module ALU (
    output reg[31:0] result,
    input[31:0] a,
    input[31:0] b,
    input[3:0] ALUcontrol
    );
    parameter aluAdd = 4'b0101;
    always @(*) 
        case(ALUcontrol)
            aluAdd: result = a + b;
            default: result = 32'bz;
        endcase
endmodule

module SignExtend (
    output[31:0] out,
    input[15:0] in
);
    //assign out[31:0] = {16{in[15]}, in[15:0]};
    assign out[15:0] = in;
    assign out[31:16] = in[15] ? 16'hffff : 16'h0;
endmodule

module Memory (
    input[31:0] Address,
    input[31:0] WriteData,
    output reg[31:0] ReadData,
    input MemWrite,
    input MemRead,
    input clk
    );
    reg [7:0] mem[2047:0];
    always @ (posedge clk) begin
        if(MemRead)
            ReadData <= {mem[Address+3], mem[Address+2], mem[Address+1], mem[Address]};
        if(MemWrite)
            {mem[Address+3], mem[Address+2], mem[Address+1], mem[Address]} = WriteData;
    end
endmodule