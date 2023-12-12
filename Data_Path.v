`timescale 1ns / 100ps
module Data_Path (
    output[31:0] aluResult,
    input[31:0] Intruction,
    input RegDst,
    input RegWrite,
    input ALUSrc,
    input[3:0] ALUcontrol,
    input MemWrite,
    input MemRead,
    input MemToReg,
    input Clk
    );
    wire [4:0] WR;
    wire [31:0] WD, RD1, RD2, signExtended, ALUinB, readData;
        
    mux_2to1 #(.nBit(5)) 
    regDstMux(
        .out(WR),
        .in0(Intruction[20:16]),
        .in1(Intruction[15:11]),
        .sel(RegDst)    
    );
    
    Registers registers (
        .ReadAddress1(Intruction[25:21]),
        .ReadAddress2(Intruction[20:16]),
        .RegWrite(RegWrite),
        .WriteAddress(WR),
        .WriteData(WD),
        .ReadData1(RD1),
        .ReadData2(RD2),
        .Clk(Clk)
    );
    
    SignExtend signExtend (
        .in(Intruction[15:0]),
        .out(signExtended)
    );
    
    mux_2to1 #(.nBit(32)) aluInB (
        .out(ALUinB),
        .in0(RD2),
        .in1(signExtended),
        .sel(ALUSrc)
    );
    
    ALU alu (
        .Result(aluResult),
        .A(RD1),
        .B(ALUinB),
        .ALUcontrol(ALUcontrol)
    );
        
    Memory mem (
        .Address(aluResult),
        .WriteData(RD2),
        .ReadData(readData),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .Clk(Clk)
    );
    
    mux_2to1 #(.nBit(32)) muxMemToReg (
        .out(WD),
        .in1(readData),
        .in0(aluResult),
        .sel(MemToReg)
    );
endmodule

module mux_2to1 
    #(parameter nBit = 32)(
    output [0:nBit-1] out,
    input [0:nBit-1] in0,
    input [0:nBit-1] in1,
    input sel
    );
    assign out = sel ? in1 : in0;
endmodule

module Registers (
    output reg[31:0] ReadData1,
    output reg[31:0] ReadData2,
    input Clk,
    input RegWrite,
    input[4:0] WriteAddress,
    input[31:0] WriteData,
    input[4:0] ReadAddress1,
    input[4:0] ReadAddress2
    );
    reg[31:0] mem[0:31];
    
    initial begin 
        for(integer i = 0; i < 7; i = i + 1) 
            mem[i] = i;
//        $monitor("#Register: reg[0] = %0d", mem[0]);
//        $monitor("#Register: reg[1] = %0d", mem[1]);
//        $monitor("#Register: reg[2] = %0d", mem[2]);
//        $monitor("#Register: reg[3] = %0d", mem[3]);
//        $monitor("#Register: reg[4] = %0d", mem[4]);
//        $monitor("#Register: reg[5] = %0d", mem[5]);
//        $monitor("#Register: reg[6] = %0d", mem[6]);
    end
    
    //initial $monitor("RegWrite = %b, WriteAddress = %d, WriteAddress = %d", RegWrite, WriteAddress, WriteAddress);
    
    always @ (posedge Clk)
        if(RegWrite) begin
            mem[WriteAddress] <= WriteData;
            $display("#Register@write: reg[%0d]: %0d", WriteAddress, WriteData);
        end   
    
    always @ (*) begin
        ReadData1 <= mem[ReadAddress1];
        ReadData2 <= mem[ReadAddress2];
    end 
endmodule

module ALU (
    output reg[31:0] Result,
    input[31:0] A,
    input[31:0] B,
    input[3:0] ALUcontrol
    );
    parameter aluAdd = 4'b0101;
    
    //initial $monitor("ALU# A = %d, B = %d, result = %d", ALUcontrol, A, B, Result);
    
    always @(*) 
        case(ALUcontrol)
            aluAdd: Result = A + B;
            default: Result = 32'bz;
        endcase
endmodule

module SignExtend (
    output[31:0] out,
    input[15:0] in
);
    //assign out[31:0] = {16{in[15]}, in[15:0]}; // error???
    assign out[15:0] = in;
    assign out[31:16] = in[15] ? 16'hffff : 16'h0;
endmodule

module Memory (
    input[31:0] Address,
    input[31:0] WriteData,
    output reg[31:0] ReadData,
    input MemWrite,
    input MemRead,
    input Clk
    );
    reg [31:0] mem[63:0];
    
//    initial begin
//        $monitor("#change: mem[0]: %2d", mem[0]);
//        $monitor("#change: mem[1]: %2d", mem[1]);
//        $monitor("#change: mem[2]: %2d", mem[2]);
//        $monitor("#change: mem[3]: %2d", mem[3]);
//        $monitor("#change: mem[4]: %2d", mem[4]);
//        $monitor("#change: mem[5]: %2d", mem[5]);
//        $monitor("#change: mem[6]: %2d", mem[6]);
//    end
      
    always @ (posedge Clk)
        if(MemWrite) begin
            mem[Address] <= WriteData;
            $display("#Memory@write: mem[%0d]: %0d", Address, WriteData);
        end
    always @ (*) // MemRead or Address
        if(MemRead) begin
            ReadData <= mem[Address];
            #1 $display("#Memory@read: mem[%0d]: %0d", Address, ReadData);
        end
endmodule