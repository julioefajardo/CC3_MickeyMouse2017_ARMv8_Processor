`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:20:34 04/15/2017 
// Design Name: 
// Module Name:    MM2017 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module MM2017(
    input clk,
	 input rst,
    output [63:0] PC_out
    );

	//=======================================================
//  REG/WIRE declarations
//=======================================================

	// ALU
	parameter ADDI		= 8'h91;
	parameter ADDSI   = 8'hb1;
	parameter SUBI   	= 8'hd1;
	parameter SUBSI   = 8'hf1;
	parameter ADD    	= 8'h8b;
	parameter ADDS   	= 8'hab;
	parameter SUB	 	= 8'hcb;
	parameter SUBS   	= 8'heb;
	parameter AND   	= 8'h8a;
	parameter ANDS   	= 8'hea;
	parameter ORR	 	= 8'haa;
	parameter EOR	 	= 8'hca;
	
	// SHIFT
	parameter SHIFT 	= 8'h9a;
	parameter LSLV		= 8'h18;
	parameter LSRV		= 8'h19;
	parameter ASRV		= 8'h1a;
	parameter RORV		= 8'h1b;
	
	// MOVES
	parameter MOVN		= 8'h92;
	parameter MOV		= 8'hd2;
	parameter MOVK		= 8'hf2;	
	
	// COMPARE AND BRANCH
	parameter CBZ		= 8'hb4;
	parameter CBNZ		= 8'hb5;
	
	// CONDITIONAL BRANCH
	parameter BRA		= 8'h54;
	parameter BEQ   	= 8'h00;
	parameter BNE 		= 8'h01;
	parameter BHS   	= 8'h02;
	parameter BLO	   = 8'h03;
	parameter BMI    	= 8'h04;
	parameter BPL   	= 8'h05;
	parameter BVS	 	= 8'h06;
	parameter BVC   	= 8'h07;
	parameter BHI   	= 8'h08;
	parameter BLS   	= 8'h09;
	parameter BGE	 	= 8'h0a;
	parameter BLT	 	= 8'h0b;
	parameter BGT	 	= 8'h0c;
	parameter BLE	 	= 8'h0d;
	
	// BRANCH
	parameter B		 	= 8'h14;
	parameter BL	 	= 8'h94;
	
	// MEMORY
	parameter MEMO	 	= 8'hf9;
	parameter STR	 	= 8'h20;
	parameter LDR	 	= 8'h21;
	
	parameter RET	 	= 8'hd6;

	reg [32:0]  MEM [0:128] ;														// Memory
	reg [63:0]  X [0:30];															// Register File
	reg [63:0]  PC = 64'b0;															// Program Counter 
	wire [63:0] XZR;																	// Zero register
	
	reg [63:0] WB = 64'b0;															// Write Back register
	reg [31:0] FIR = 32'b0;															// Instruction fetch register
	
	reg [7:0] OPCODE = 8'b0;
	reg [4:0] XT = 5'b0;
	reg [4:0] XN = 5'b0; 
	reg [4:0] XM = 5'b0;
	reg [31:0] IMM = 32'b0;
	reg [3:0] ZNCV = 4'b0;															// Condition flags
	
	reg [3:0] FLAGS = 4'b0;															// Condition flags Write Back
	reg FLAG_WB_REG = 1'b0;															// Registers Write Back 
	reg FLAG_WB_MEM = 1'b0;															// Memory Write Back
	reg FLAG_WB_OUT = 1'b0;															// Output Write Back

//=======================================================
//  Structural coding
//=======================================================
	
	assign PC_out = PC;
	assign XZR = 64'b0;
	
	initial begin
		PC <= 64'b0;																		// Program Counter Initialization	
		ZNCV <= 4'b0;																	// Conditional Flags Initialization
		$readmemh("program.mem",MEM,0,128);										// Memory Load 
		X[0] <= 64'b0;																	// Register Inizialization
		X[1] <= 64'b0;
		X[2] <= 64'b0;
		X[3] <= 64'b0;
		X[4] <= 64'b0;
		X[5] <= 64'b0;
		X[6] <= 64'b0;
		X[7] <= 64'b0;
		X[8] <= 64'b0;
		X[9] <= 64'b0;
		X[10] <= 64'b0;
		X[11] <= 64'b0;
		X[12] <= 64'b0;
		X[13] <= 64'b0;
		X[14] <= 64'b0;
		X[15] <= 64'b0;
		X[16] <= 64'b0;
		X[17] <= 64'b0;
		X[18] <= 64'b0;
		X[19] <= 64'b0;
		X[20] <= 64'b0;
		X[21] <= 64'b0;
		X[22] <= 64'b0;
		X[23] <= 64'b0;
		X[24] <= 64'b0;
		X[25] <= 64'b0;
		X[26] <= 64'b0;
		X[27] <= 64'b0;
		X[28] <= 64'b0;
		X[29] <= 64'b0;
		X[30] <= 64'b0;
	end

	always @ (posedge clk) begin
		if(rst) PC = 0;																// Reset
		else begin
			// FETCH
			FIR = MEM[PC];
			PC = PC + 64'd1;
			
			// DECODE
			if (FIR[31:24] == SHIFT) begin										// SHIFTS
				XT = FIR[4:0];
				XN = FIR[9:5];
				XM = FIR[20:16];
				IMM = 32'b0;
				case (FIR[11:10]) 
					2'b00: OPCODE = LSLV;
					2'b01: OPCODE = LSRV;
					2'b10: OPCODE = ASRV;
					2'b11: OPCODE = RORV;
				endcase
			end else if (FIR[31:24] == MEMO) begin								// MEMORY
				XT = FIR[4:0];
				XN = FIR[9:5];
				XM = 5'b0;
				IMM = 32'b0;
				if (FIR[22]) OPCODE = LDR;
				else OPCODE = STR;
			end else if (FIR[31:24] == BRA) begin								// CONDITIONAL BRANCHES
				XT = 5'b0;
				XN = 5'b0;
				XM = 5'b0;
				IMM = FIR[23:5];
				OPCODE = {4'b0,FIR[3:0]};
			end else begin																
				OPCODE = FIR[31:24];
				if ((OPCODE == B)||(OPCODE == BL)) begin						// BRANCHES
					XT = 5'b0;
					XN = 5'b0;
					XM = 5'b0;
					IMM = FIR[25:0];
				end else begin
					XT = FIR[4:0];
					if ((OPCODE == MOV)||(OPCODE == MOVN)||(OPCODE == MOVK)) begin					// MOVES
						XN = 5'b0;
						XM = 5'b0;
						IMM = FIR[20:5];
					end else if ((OPCODE == CBZ)||(OPCODE == CBNZ)) begin								// COMPARE AND BRANCH
						XN = 5'b0;
						XM = 5'b0;
						IMM = FIR[23:5];
					end else if ((OPCODE == ADDI)||(OPCODE == ADDSI)||(OPCODE == SUBI)||(OPCODE == SUBSI)) begin
						XN = FIR[9:5];
						XM = 5'b0;
						IMM = FIR[21:10];	
					end else begin																					// ALU
						XN = FIR[9:5];
						XM = FIR[20:16];
						IMM = 32'b0;
					end
				end
			end
			
			//EXECUTE
			case (OPCODE)
				ADDI: begin	
					WB = X[XN] + {52'b0,IMM[11:0]};
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b1;
					FLAG_WB_OUT = 1'b0;
					FLAGS = 4'b0;
				end
				ADDSI: begin	
					WB = X[XN] + {52'b0,IMM[11:0]};
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b1;
					FLAG_WB_OUT = 1'b0;
					FLAGS[3] = (WB == 64'b0)?1'b1:1'b0; 					// Z
					FLAGS[2] = (WB>64'h7fffffffffffffff)?1'b1:1'b0;		// N	
					FLAGS[1] = ((WB)>=65'hffffffffffffffff)?1'b1:1'b0;	// C
					FLAGS[0] = (((X[XN]>64'h7fffffffffffffff)&&(IMM>64'h7fffffffffffffff)&&(WB<=64'h7fffffffffffffff))||((X[XN]<=64'h7fffffffffffffff)&&(IMM<=64'h7fffffffffffffff)&&(WB>64'h7fffffffffffffff)))?1:0;
				end
				SUBI: begin	
					WB = X[XN] - {52'b0,IMM[11:0]};
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b1;
					FLAG_WB_OUT = 1'b0;
					FLAGS = 4'b0;
				end
				SUBSI: begin	
					WB = X[XN] - {52'b0,IMM[11:0]};
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b1;
					FLAG_WB_OUT = 1'b0;
					FLAGS[3] = (WB == 64'b0)?1'b1:1'b0; 					// Z
					FLAGS[2] = (WB>64'h7fffffffffffffff)?1'b1:1'b0;		// N	
					FLAGS[1] = (WB>=0)?1'b1:1'b0;								// C
					FLAGS[0] = (((X[XN]>64'h7fffffffffffffff)&&(IMM>64'h7fffffffffffffff)&&(WB<=64'h7fffffffffffffff))||((X[XN]<=64'h7fffffffffffffff)&&(IMM<=64'h7fffffffffffffff)&&(WB>64'h7fffffffffffffff)))?1:0;
				end
				ADD: begin	
					WB = X[XN] + X[XM];
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b1;
					FLAG_WB_OUT = 1'b0;
					FLAGS = 4'b0;
				end
				ADDS: begin	
					WB = X[XN] + X[XM];
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b1;
					FLAG_WB_OUT = 1'b0;
					FLAGS[3] = (WB == 64'b0)?1'b1:1'b0; 					// Z
					FLAGS[2] = (WB>64'h7fffffffffffffff)?1'b1:1'b0;		// N	
					FLAGS[1] = ((WB)>=65'hffffffffffffffff)?1'b1:1'b0;	// C
					FLAGS[0] = (((X[XN]>64'h7fffffffffffffff)&&(X[XM]>64'h7fffffffffffffff)&&(WB<=64'h7fffffffffffffff))||((X[XN]<=64'h7fffffffffffffff)&&(X[XM]<=64'h7fffffffffffffff)&&(WB>64'h7fffffffffffffff)))?1:0;
				end
				SUB: begin	
					WB = X[XN] - X[XM];
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b1;
					FLAG_WB_OUT = 1'b0;
					FLAGS = 4'b0;
				end
				SUBS: begin	
					WB = X[XN] - X[XM];
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b1;
					FLAG_WB_OUT = 1'b0;
					FLAGS[3] = (WB == 64'b0)?1'b1:1'b0; 					// Z
					FLAGS[2] = (WB>64'h7fffffffffffffff)?1'b1:1'b0;		// N	
					FLAGS[1] = (WB>=0)?1'b1:1'b0;								// C
					FLAGS[0] = (((X[XN]>64'h7fffffffffffffff)&&(X[XM]>64'h7fffffffffffffff)&&(WB<=64'h7fffffffffffffff))||((X[XN]<=64'h7fffffffffffffff)&&(X[XM]<=64'h7fffffffffffffff)&&(WB>64'h7fffffffffffffff)))?1:0;
				end
				AND: begin	
					WB = X[XN] & X[XM];
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b1;
					FLAG_WB_OUT = 1'b0;
					FLAGS = 4'b0;
				end
				ANDS: begin	
					WB = X[XN] & X[XM];
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b1;
					FLAG_WB_OUT = 1'b0;
					FLAGS[3] = (WB == 64'b0)?1'b1:1'b0; 					// Z
					FLAGS[2] = (WB>64'h7fffffffffffffff)?1'b1:1'b0;		// N	
					FLAGS[1] = 1'b0;												// C
					FLAGS[0] = 1'b0;												// V
				end
				ORR: begin	
					WB = X[XN] | X[XM];
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b1;
					FLAG_WB_OUT = 1'b0;
					FLAGS = 4'b0;
				end
				EOR: begin	
					WB = X[XN] ^ X[XM];
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b1;
					FLAG_WB_OUT = 1'b0;
					FLAGS = 4'b0;
				end
				LSLV: begin	
					WB = X[XN] << X[XM];
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b1;
					FLAG_WB_OUT = 1'b0;
					FLAGS = 4'b0;
				end
				LSRV: begin	
					WB = X[XN] >> X[XM];
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b1;
					FLAG_WB_OUT = 1'b0;
					FLAGS = 4'b0;
				end
				ASRV: begin	
					WB = X[XN] >>> X[XM];
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b1;
					FLAG_WB_OUT = 1'b0;
					FLAGS = 4'b0;
				end
				RORV: begin	//PENDIENTE	
					WB = X[XN] >>> X[XM];
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b1;
					FLAG_WB_OUT = 1'b0;
					FLAGS = 4'b0;
				end
				MOV: begin	
					WB = IMM[15:0];
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b1;
					FLAG_WB_OUT = 1'b0;
					FLAGS = 4'b0;
				end
				MOVN: begin	
					WB = ~IMM[15:0];
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b1;
					FLAG_WB_OUT = 1'b0;
					FLAGS = 4'b0;
				end
				MOVK: begin	
					WB = X[XT] | IMM[15:0];
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b1;
					FLAG_WB_OUT = 1'b0;
					FLAGS = 4'b0;
				end
				CBZ: begin	
					if (X[XT] == 0) PC = IMM;
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b0;
					FLAG_WB_OUT = 1'b0;
					FLAGS = 4'b0;
				end
				CBNZ: begin	
					if (X[XT] != 0) PC = IMM;
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b0;
					FLAG_WB_OUT = 1'b0;
					FLAGS = 4'b0;
				end
				LDR: begin	
					WB = MEM[X[XN]+IMM];
					FLAG_WB_MEM = 1'b1;
					FLAG_WB_REG = 1'b1;
					FLAG_WB_OUT = 1'b0;
					FLAGS = 4'b0;
				end
				STR: begin 
					WB = X[XT];
					FLAG_WB_MEM = 1'b1;
					FLAG_WB_REG = 1'b1;
					FLAG_WB_OUT = 1'b1;
					FLAGS = 4'b0;
				end
				B: begin	
					PC = IMM;
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b0;
					FLAG_WB_OUT = 1'b0;
					FLAGS = 4'b0;
				end
				BL: begin	
					X[30] = PC;
					PC = IMM;
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b0;
					FLAG_WB_OUT = 1'b0;
					FLAGS = 4'b0;
				end
				RET: begin	
					PC = X[30];
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b0;
					FLAG_WB_OUT = 1'b0;
					FLAGS = 4'b0;
				end
				BEQ: begin	
					if (ZNCV[3] == 1) PC = IMM;
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b0;
					FLAG_WB_OUT = 1'b0;
					FLAGS = 4'b0;
				end
				BNE: begin	
					if (ZNCV[3] == 0) PC = IMM;
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b0;
					FLAG_WB_OUT = 1'b0;
					FLAGS = 4'b0;
				end
				BHS: begin	
					if (ZNCV[1] == 1) PC = IMM;
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b0;
					FLAG_WB_OUT = 1'b0;
					FLAGS = 4'b0;
				end
				BLO: begin	
					if (ZNCV[1] == 0) PC = IMM;
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b0;
					FLAG_WB_OUT = 1'b0;
					FLAGS = 4'b0;
				end
				BMI: begin	
					if (ZNCV[2] == 1) PC = IMM;
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b0;
					FLAG_WB_OUT = 1'b0;
					FLAGS = 4'b0;
				end
				BPL: begin	
					if (ZNCV[2] == 0) PC = IMM;
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b0;
					FLAG_WB_OUT = 1'b0;
					FLAGS = 4'b0;
				end
				BVS: begin	
					if (ZNCV[0] == 1) PC = IMM;
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b0;
					FLAG_WB_OUT = 1'b0;
					FLAGS = 4'b0;
				end
				BVC: begin	
					if (ZNCV[0] == 0) PC = IMM;
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b0;
					FLAG_WB_OUT = 1'b0;
					FLAGS = 4'b0;
				end
				BHI: begin	
					if ((ZNCV[1] == 1)&&(ZNCV[3] == 0)) PC = IMM;
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b0;
					FLAG_WB_OUT = 1'b0;
					FLAGS = 4'b0;
				end
				BLS: begin	
					if ((ZNCV[1] == 0)&&(ZNCV[3] == 1)) PC = IMM;
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b0;
					FLAG_WB_OUT = 1'b0;
					FLAGS = 4'b0;
				end
				BGE: begin	
					if (ZNCV[2] == ZNCV[0]) PC = IMM;
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b0;
					FLAG_WB_OUT = 1'b0;
					FLAGS = 4'b0;
				end
				BLT: begin	
					if (ZNCV[2] != ZNCV[0]) PC = IMM;
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b0;
					FLAG_WB_OUT = 1'b0;
					FLAGS = 4'b0;
				end
				BGT: begin	
					if ((ZNCV[3] == 0)&&(ZNCV[2] == ZNCV[0])) PC = IMM;
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b0;
					FLAG_WB_OUT = 1'b0;
					FLAGS = 4'b0;
				end
				BLE: begin	
					if ((ZNCV[3] == 1)&&(ZNCV[2] != ZNCV[0])) PC = IMM;
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b0;
					FLAG_WB_OUT = 1'b0;
					FLAGS = 4'b0;
				end	
				// NOP!
				default: begin 
					FLAG_WB_MEM = 1'b0;
					FLAG_WB_REG = 1'b0;
					FLAG_WB_OUT = 1'b0;
					FLAGS = 4'b0;
					XT = 5'b0;
					XN = 5'b0; 
					XM = 5'b0;
					IMM = 32'b0;
				end

			endcase
			
			// WRITE BACK 
			if(FLAG_WB_REG) begin
				if(FLAG_WB_MEM) begin
					if (FLAG_WB_OUT) begin
						//if (XN == 8'h3f) begin 
						//	Port = WB;
						//	MEM[XN] = WB;
					end
					else MEM[X[XN]+IMM] = WB;
				end
				else begin
					X[XT] = WB;
					ZNCV = FLAGS;
				end
			end
			
		end
	end

endmodule
