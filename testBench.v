`timescale 1ns / 100ps
module testBench(

    );
    reg [31:0] intruction;
    wire[31:0] aluResult;
    reg clk = 0;
    wire regDst, regWrite, ALUSrc, memWrite, memRead, memToReg; 
    wire [3:0] ALUcontrol;
    reg[5:0] opcode;
    reg[4:0] rs, rt, rd;
    
    parameter   addOp = 6'b001,
                lwOp = 6'b010,
                swOp = 6'b100;
                
    initial forever #5 clk = ~clk;
    
    initial begin
        //$monitor("op =%2d, rs =%2d, rt =%2d, rd =%2d, aluResult =%2d", opcode, rs, rt, rd, aluResult);
        
        #10 // wait for initial
        rd = 5'd1;
        rs = 5'd2;
        rt = 5'd3;
        opcode = addOp;
        intruction = {opcode, rs, rt, rd, 11'b0};
        $display("#TestBench: add, rs = %0d, rt = %0d, rd = %0d", rs, rt, rd);
        
        #10
        rt = 5'd1;
        rs = 5'd2;     
        opcode = swOp;
        intruction = {opcode, rs, rt, 16'b0};
        $display("#TestBench: sw, rs = %0d, rt = %0d", rs, rt); 
        
        #10
        rt = 5'd1;
        rs = 5'd2;
        opcode = lwOp;
        intruction = {opcode, rs, rt, 16'b0};
        $display("#TestBench: lw, rs = %0d, rt = %0d", rs, rt);   
        
        #10
        rd = 5'd1;
        rs = 5'd0;
        rt = 5'd1;
        opcode = addOp;
        intruction = {opcode, rs, rt, rd, 11'b0};
        $display("#TestBench: add, rs = %0d, rt = %0d, rd = %0d", rs, rt, rd); 
           
        #15 $finish;
    end
    
    
    Data_Path dataPath (
        .aluResult(aluResult),
        .Intruction(intruction),
        .RegDst(regDst),
        .RegWrite(regWrite),
        .ALUSrc(ALUSrc),
        .ALUcontrol(ALUcontrol),
        .MemWrite(memWrite),
        .MemRead(memRead),
        .MemToReg(memToReg),
        .Clk(clk)
    );
    
    ControlUnit control (
        .RegDst(regDst),
        .MemRead(memRead),
        .MemWrite(memWrite),
        .MemToReg(memToReg),
        .ALUcontrol(ALUcontrol),
        .ALUSrc(ALUSrc),
        .RegWrite(regWrite),
        .Op(intruction[31:26]),
        .Clk(clk)
    );
endmodule