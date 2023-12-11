`timescale 1ns / 100ps
module ControlUnit(
    output reg RegDst,
    output reg MemRead,
    output reg MemWrite,
    output reg MemToReg,
    output reg[3:0] ALUcontrol,
    output reg ALUSrc,
    output reg RegWrite,
    input [5:0] Op,
    input Clk
    );
    parameter   addOp = 6'b001,
                lwOp = 6'b010,
                swOp = 6'b101;
    parameter   aluAdd = 4'b0101; 
              
    always @ (posedge Clk)
    case(Op)
        addOp : begin
            RegDst = 1'b1;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUcontrol = aluAdd;
            ALUSrc = 1'b0;
            RegWrite = 1'b1;
        end
        lwOp : begin
            RegDst = 1'b0;
            MemRead = 1'b1;
            MemWrite = 1'b0;
            MemToReg = 1'b1;
            ALUcontrol = aluAdd;
            ALUSrc = 1'b1;
            RegWrite = 1'b1;
        end
        swOp : begin
            RegDst = 1'bx;
            MemRead = 1'b0;
            MemWrite = 1'b1;
            MemToReg = 1'bx;
            ALUcontrol = aluAdd;
            ALUSrc = 1'b1;
            RegWrite = 1'b0;
        end
        default begin
            RegDst = 1'b0;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUcontrol = aluAdd;
            ALUSrc = 1'b0;
            RegWrite = 1'b0;
        end
    endcase
endmodule
