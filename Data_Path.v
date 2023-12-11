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
    
    //initial $monitor("Data_Path: MemRead = %b, in015 = %d ALUSrc = %b, signExtended = %d, RD1 = %2d, ALUinB = %2d", MemRead, Intruction[15:0], ALUSrc, signExtended, RD1, ALUinB);
    
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
    
    //initial $monitor("aluResult = %d", aluResult);
    
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
    #(parameter nBit = 1)(
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
    
    reg [4:0] regWriteAddress;
    
    initial for(integer i = 0; i < 10; i = i + 1) begin
        mem[i] = i;
    end
    
    initial begin
    $monitor("reg0 = %d", mem[0]);
    $monitor("reg1 = %d", mem[1]);
    $monitor("reg2 = %d", mem[2]);
    $monitor("reg3 = %d", mem[3]);
    $monitor("reg4 = %d", mem[4]);
    $monitor("reg5 = %d", mem[5]);
    $monitor("reg6 = %d", mem[6]);
    $monitor("reg7 = %d", mem[7]);
    $monitor("reg8 = %d", mem[8]);
    $monitor("reg9 = %d", mem[9]);
    end
    
//    integer debugTime = 0;
//    initial forever #1 debugTime = debugTime + 1;
    
    //initial $monitor("RegWrite = %b, WriteAddress = %d, regWriteAddress = %d", RegWrite, WriteAddress, regWriteAddress);
    
    always @ (posedge Clk) begin
        if(RegWrite) begin
            //$display("write begin");
            mem[regWriteAddress] <= WriteData;
            $display("write reg%d: %d", regWriteAddress, WriteData);
        end    
        begin
            ReadData1 <= mem[ReadAddress1]; 
            ReadData2 <= mem[ReadAddress2];
        end
        #1regWriteAddress = WriteAddress;
        //$display("reg clk");
    end
endmodule

module ALU (
    output reg[31:0] Result,
    input[31:0] A,
    input[31:0] B,
    input[3:0] ALUcontrol
    );
    parameter aluAdd = 4'b0101;
    
    //initial $monitor("ALUcontrol = %d, A = %d, B = %d, result = %d", ALUcontrol, A, B, Result);
    
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
    input Clk
    );
    reg [31:0] mem[63:0];
    
//    initial for(integer i = 0; i < 32; i = i + 1)
//        $monitor("mem%2d = %2d", mem[i]);
    
//      initial begin
//        $monitor("mem2 = %d", mem[2]);  
//        $monitor("Addr = %d", Address);
//      end
      
    always @ (posedge Clk) begin
        if(MemRead) begin
            $display("read mem at %d", Address);
            ReadData <= mem[Address];
        end
        if(MemWrite) begin
            $display("write mem%d: %d", Address, WriteData);
            mem[Address] <= WriteData;
        end
    end
endmodule