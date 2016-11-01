//
//  Core.h
//  E68000
//
//  Created by Laurent on 24/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Core.h"

@interface CoreInstructions : Core {

	SEL		names[87];

	int		bitfield;
	long	source, dest;
}

-(void) InitInstructionsMap;

-(int) EXG;
-(int) LEA;
-(int) PEA;
-(int) LINK;
-(int) UNLK;
-(int) MOVE;
-(int) MOVEP;
-(int) MOVEA;
-(int) MOVE_FR_SR;
-(int) MOVE_TO_CCR;
-(int) MOVE_TO_SR;
-(int) MOVEM;
-(int) MOVE_USP;
-(int) MOVEQ;
-(int) ADD;
-(int) ADDA;
-(int) ADDI;
-(int) ADDQ;
-(int) ADDX;
-(int) SUB;
-(int) SUBA;
-(int) SUBI;
-(int) SUBQ;
-(int) SUBX;
-(int) DIVS;
-(int) DIVU;
-(int) MULS;
-(int) MULU;
-(int) NEG;
-(int) NEGX;
-(int) CMP;
-(int) CMPA;
-(int) CMPI;
-(int) CMPM;
-(int) TST;
-(int) CLR;
-(int) EXT;
-(int) ABCD;
-(int) SBCD;
-(int) NBCD;
-(int) AND;
-(int) ANDI;
-(int) ANDI_TO_CCR;
-(int) ANDI_TO_SR;
-(int) OR;
-(int) ORI;
-(int) ORI_TO_CCR;
-(int) ORI_TO_SR;
-(int) EOR;
-(int) EORI;
-(int) EORI_TO_CCR;
-(int) EORI_TO_SR;
-(int) NOT;
-(int) SHIFT_ROT;
-(int) SWAP;
-(int) BIT_OP;
-(int) TAS;
-(int) BCC;
-(int) DBCC;
-(int) SCC;
-(int) BRA;
-(int) BSR;
-(int) JMP;
-(int) JSR;
-(int) RTE;
-(int) RTR;
-(int) RTS;
-(int) NOP;
-(int) CHK;
-(int) ILLEGAL;
-(int) RESET;
-(int) STOP;
-(int) TRAP;
-(int) TRAPV;
-(int) LINE1010;        //CK v2.3
-(int) LINE1111;        //CK v2.3

@end
