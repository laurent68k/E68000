//
//  Disassemble.h
//  E68000
//
//  Created by Laurent on 12/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Disassemble : NSObject {

@protected
	
	char szSizeString[4];									// Size B,W or L
	char szParamString[256];								// Data
	char szConditionString[256];							// Condition code
	char szImmString[256];									// Immediate
	char szEffAddrString[256];								// Effective address
	char szUpperEffAddrString[256];							// Effective address, upper bits in OpCode (for MOVE instruction)
	char szRegString[256];									// MoveM register list
	
	NSString	*szOpString;									// Final disassembly
	NSString	*szOpData;										// Final disassembly
	
	unsigned short int OpCode;								// Opcode of instruction
	unsigned long DisPC;									// Disassembly Program Counter
	
}

@end
