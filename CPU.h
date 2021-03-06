//
//  CPU.h
//  E68000
//
//  Created by Laurent on 25/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CoreInstructions.h"

@interface CPU : CoreInstructions {

	unsigned long	InstructionAddress;
	NSString		*instructionText;
	int irq;
}

@property(readonly) NSString *instructionText;

-(void) CPURegistersInspector: (unsigned long *)d0: (unsigned long *)d1: (unsigned long *)d2: (unsigned long *)d3: (unsigned long *)d4: (unsigned long *)d5: (unsigned long *)d6: (unsigned long *)d7: (unsigned long *)a0: (unsigned long *)a1: (unsigned long *)a2: (unsigned long *)a3: (unsigned long *)a4: (unsigned long *)a5: (unsigned long *)a6: (unsigned long *)usp: (unsigned long *)ssp: (unsigned long *)pc: (unsigned long *)pcold:(unsigned short *)ri: (unsigned short *)sr;
-(bool) TOSROMSInstall:(NSString *)tosfilename;
-(void) CPUStart;
-(int) CPUExecInstruction;

@end
