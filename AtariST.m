//
//  CPU.m
//  E68000
//
//  Created by Laurent on 25/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CPU.h"
#include "AtariST.h"

@implementation AtariST

-(id) init {

	self = [super init];
	
	self->cpu68000 = [[CPU alloc] init];
	
	return self;
}
//---------------------------------------------------------------------------
-(void) dealloc {
	
	[self->cpu68000 release];
	
    [super dealloc];
}
//---------------------------------------------------------------------------
-(NSString *)CPUInstructionText {
	
	return self->cpu68000.instructionText;
}
//---------------------------------------------------------------------------
-(void) CPURegistersInspector: (unsigned long *)d0: (unsigned long *)d1: (unsigned long *)d2: (unsigned long *)d3: (unsigned long *)d4: (unsigned long *)d5: (unsigned long *)d6: (unsigned long *)d7: (unsigned long *)a0: (unsigned long *)a1: (unsigned long *)a2: (unsigned long *)a3: (unsigned long *)a4: (unsigned long *)a5: (unsigned long *)a6: (unsigned long *)usp: (unsigned long *)ssp: (unsigned long *)pc: (unsigned long *)pcold: (unsigned short *)ri: (unsigned short *)sr {
	
	[self->cpu68000 CPURegistersInspector:d0 :d1 :d2 :d3 :d4 :d5 :d6 :d7 :a0 :a1 :a2 :a3 :a4 :a5 :a6 :usp :ssp :pc :pcold :ri :sr];
}
//---------------------------------------------------------------------------
-(void) Reset:(bool) cold withCartridgeRoms:(bool) withCartridge {

 	if (cold) {
		//STMemory_Clear(0x00000000,0x00400000);		// Clear First 4Mb
		//STMemory_Clear(0x00e00000,0x00ffffff);		// Clear Upper memory	
		
		//STMemory_WriteLong(4,0x00fc0020);				// Set reset vector
		//STMemory_WriteLong(0,0x0000f000);				// And reset stack pointer

		//Floppy_GetBootDrive();							// Find which device to boot from(A: or C:)
		//Cart_LoadImage();								// Load program into cartridge memory. Used for gemdos loading
		//TOS_LoadImage();								// Load TOS, writes into cartridge memory
		
		[self->cpu68000 TOSROMSInstall:@"tos102fr"];
		
		if( withCartridge ) {
			[self->cpu68000 LoadROMCartridge:@"ST4_4_HIGH":@"ST4_4_LOW"];
		}
		
		[self->cpu68000 mem_put:0x0000f000: 0x00: LONG_MASK ];	//	Initial SSP
		//[self->cpu68000 mem_put:0x00fc0020: 0x04: LONG_MASK ];	//	Inital PC
		[self->cpu68000 mem_put:0x00fc0030: 0x04: LONG_MASK ];	//	Inital PC
	}
	/*Int_Reset();										// Reset interrupts
	MFP_Reset();										// Setup MFP chip
	Video_Reset();										// Reset video
	if (bCold) {
		FDC_Reset();									// Reset FDC
		GemDOS_Reset();									// Reset GEM
	}
	PSG_Reset();										// Reset PSG
	Sound_Reset();										// Reset Sound
	IKBD_Reset(bCold);									// Keyboard	
	Screen_Reset();										// Reset screen
	M68000_Reset(bCold);								// Reset CPU

	// And VBL interrupt, MUST always be one interrupt ready to trigger
	Int_AddAbsoluteInterrupt(CYCLES_ENDLINE,INTERRUPT_VIDEO_ENDLINE);
	Int_AddAbsoluteInterrupt(CYCLES_HBL,INTERRUPT_VIDEO_HBL);
	Int_AddAbsoluteInterrupt(CYCLES_PER_FRAME,INTERRUPT_VIDEO_VBL);
	// And keyboard check for debugger
#ifdef USE_DEBUGGER
	Int_AddAbsoluteInterrupt(CYCLES_DEBUGGER,INTERRUPT_DEBUGGER);
#endif*/
}
//---------------------------------------------------------------------------
-(void) Reset:(bool) cartridge {

	[self Reset: true withCartridgeRoms: cartridge];
	[self->cpu68000 CPUStart];
}
//---------------------------------------------------------------------------
-(void) RunStep {

	[self->cpu68000 CPUExecInstruction];
}
//---------------------------------------------------------------------------
-(unsigned int) TOSVersion {
	
	return [self->cpu68000 TOSVersion];
}

@end
