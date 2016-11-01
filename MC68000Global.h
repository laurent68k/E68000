/*
 *  MC68000Global.h
 *  E68000
 *
 *  Created by Laurent on 23/07/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef	__MC68000Global
#define __MC68000Global


//	Bit mask for Status Register (Include CCR)
//	bit15..Bit8 Supervisor byte of SR
//	bit7..Bit0	CCR byte of SR

#define cbit		0x0001
#define vbit		0x0002
#define zbit		0x0004
#define nbit		0x0008
#define xbit		0x0010
#define intmsk		0x0700       // three bits
#define sbit		0x2000
#define tbit		0x8000

// T.S..I2I1I0...XNZVC
#define	BIT_TRACE		15
#define	BIT_SUPERVISOR	13
#define	BIT_I2			10
#define	BIT_I1			9
#define	BIT_I0			8
#define	BIT_X			4
#define	BIT_N			3
#define	BIT_Z			2
#define	BIT_V			1
#define	BIT_C			0

//	these are the instruction return codes

#define  SUCCESS		0x0000
#define  BAD_INST		0x0001
#define  NO_PRIVILEGE	0x0002
#define  CHK_EXCEPTION	0x0003
//#define  ILLEGAL_TRAP		 0x0004
#define  STOP_TRAP		0x0005
#define  TRAPV_TRAP		0x0006
#define  TRAP_TRAP		0x0007
#define  DIV_BY_ZERO	0x0008
#define  USER_BREAK		0x0009
#define  BUS_ERROR      0x000A
#define  ADDR_ERROR     0x000B
#define  LINE_1010      0x000C
#define  LINE_1111      0x000D
#define  TRACE_EXCEPTION		0x000E
#define  ROM_MAP				0x000F
#define  FAILURE		0x1111		// general failure


// conditions for BCC, DBCC, and SCC

#define  COND_T   0x00
#define  COND_F   0x01
#define  COND_HI  0x02
#define  COND_LS  0x03
#define  COND_CC  0x04
#define  COND_CS  0x05
#define  COND_NE  0x06
#define  COND_EQ  0x07
#define  COND_VC  0x08
#define  COND_VS  0x09
#define  COND_PL  0x0a
#define  COND_MI  0x0b
#define  COND_GE  0x0c
#define  COND_LT  0x0d
#define  COND_GT  0x0e
#define  COND_LE  0x0f

#define BYTE_MASK 0xff         // byte mask
#define WORD_MASK 0xffff       // word mask
#define LONG_MASK 0xffffffff   // long mask

// misc
#define MEMSIZE		(unsigned int)0x01000000   // 16 Meg address space
#define ADDRMASK	(int)0x00ffffff

//////////////////////////////////
// DEBUG / Breakpoint definitions
//////////////////////////////////

#define MAX_BPOINTS  100
#define MAX_BP_EXPR  50
#define MAX_LB_NODES  10

// Define logical operator types
#define AND_OP  0
#define OR_OP  1

#define LPAREN  MAX_BPOINTS + OR_OP + 1
#define RPAREN  LPAREN + 1

// BPoint IDs are shared between PC/Reg and ADDR breakpoints.
// This constant is used to jump to the ADDR range.
// (It's ok to have unused breakPoints array elements .. see extern.h)
#define ADDR_ID_OFFSET  50

#define MAX_REG_ROWS  50
#define MAX_ADDR_ROWS  50
#define MAX_EXPR_ROWS  50

// Stored in fields of BPoint objects
#define PC_REG_TYPE  0
#define ADDR_TYPE  1

#define D0_TYPE_ID  0
#define D1_TYPE_ID  1
#define D2_TYPE_ID  2
#define D3_TYPE_ID  3
#define D4_TYPE_ID  4
#define D5_TYPE_ID  5
#define D6_TYPE_ID  6
#define D7_TYPE_ID  7
#define A0_TYPE_ID  8
#define A1_TYPE_ID  9
#define A2_TYPE_ID  10
#define A3_TYPE_ID  11
#define A4_TYPE_ID  12
#define A5_TYPE_ID  13
#define A6_TYPE_ID  14
#define A7_TYPE_ID  15
#define PC_TYPE_ID  16
#define DEFAULT_TYPE_ID  PC_TYPE_ID

#define EQUAL_OP  0         // 
#define NOT_EQUAL_OP  1     // !
#define GT_OP  2            // >
#define GT_EQUAL_OP  3      // >
#define LT_OP  4            // <
#define LT_EQUAL_OP  5      // <
#define NA_OP  6            // NA
#define DEFAULT_OP  EQUAL_OP

//#define BYTE_SIZE  0
#define WORD_SIZE  1
#define LONG_SIZE  2
#define DEFAULT_SIZE  LONG_SIZE

#define RW_TYPE  0
#define READ_TYPE  1
#define WRITE_TYPE  2
#define NA_TYPE  3
#define DEFAULT_TYPE  RW_TYPE

// these are the cases for condition code setting

#define N_A			 0
#define GEN		     1
#define ZER			 2
#define UND		     3
#define CASE_1		 4
#define CASE_2		 5
#define CASE_3		 6
#define CASE_4		 7
#define CASE_5		 8
#define CASE_6		 9
#define CASE_7		 10
#define CASE_8		 11
#define CASE_9		 12

// these are used in run.c

#define	MODE_MASK  		 0x0038
#define	REG_MASK   		 0x0007
#define	FIRST_FOUR 		 0xf000

#define	READ		 	 0xffff
#define	WRITE		 	 0x0000

// Possible addressing modes permitted by an instruction
// Each bit represents a different addressing mode.
// For example CONTROL_ADDR  0x07e4 which means the following addressing
// modes are permitted.
// Imm d[PC,Xi] d[PC] Abs.L Abs.W d[An,Xi] d[An] -[An] [An]+ [An] An Dn
//  0      1      1     1     1      1       1     0     0     1   0  0
#define DATA_ADDR              0x0ffd
#define MEMORY_ADDR		 0x0ffc
#define CONTROL_ADDR		 0x07e4
#define ALTERABLE_ADDR	 0x01ff
#define ALL_ADDR		 0x0fff
#define DATA_ALT_ADDR		 (DATA_ADDR & ALTERABLE_ADDR)
#define MEM_ALT_ADDR		 (MEMORY_ADDR & ALTERABLE_ADDR)
#define CONT_ALT_ADDR		 (CONTROL_ADDR & ALTERABLE_ADDR)

#define bit_1	         0x0001
#define bit_2		 0x0002
#define bit_3		 0x0004
#define bit_4		 0x0008
#define bit_5		 0x0010
#define bit_6		 0x0020
#define bit_7		 0x0040
#define bit_8		 0x0080
#define bit_9		 0x0100
#define bit_10	 0x0200
#define bit_11	 0x0400
#define bit_12	 0x0800

#endif
