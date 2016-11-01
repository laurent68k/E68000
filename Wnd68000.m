//
//  Wnd68000.m
//  E68000
//
//  Created by Laurent on 06/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Wnd68000.h"


@implementation Wnd68000

-(id) init {
	
	self = [super init];
		
	return self;
}
//---------------------------------------------------------------------------
-(void) dealloc {
		
    [super dealloc];
}
//---------------------------------------------------------------------------
- (void)awakeFromNib
{
	//	Méthode surchargée appellée lorsque l'initialisation du NIB file est fait et opérationnelle.
	self->atariST = [[AtariST alloc] init];
	
	[[self window] setTitle:@"68000 Emulator"];

	[self->tfLog setStringValue:@""];
	[self->btFetchRun setEnabled:false];
	
	//NSRunInformationalAlertPanel(@" Laurent", @"I proud to present to you my first MacOSX application", @"OK", NULL, NULL);
}
//---------------------------------------------------------------------------
- (void)windowWillClose:(NSNotification *)note {
	
	//[self->atariST release];

	[NSApp terminate: self ];
}
//---------------------------------------------------------------------------
-(void) AddLogMessage: (NSString *)message {
	
	[self->tfLog setStringValue: [NSString stringWithFormat:@"%@\n%@", message, [self->tfLog stringValue] ]];
}
//---------------------------------------------------------------------------
-(void) RegistersInspector {
	
	unsigned long d0,d1,d2,d3,d4,d5,d6,d7,a0,a1,a2,a3,a4,a5,a6,usp,ssp,pc,pcold;
	unsigned short ri, sr;
	
	[self->atariST CPURegistersInspector: &d0: &d1: &d2: &d3: &d4: &d5: &d6: &d7: &a0: &a1: &a2: &a3: &a4: &a5: &a6: &usp: &ssp: &pc: &pcold: &ri: &sr];
	
	[self->tfD0 setStringValue:[NSString stringWithFormat:@"0x%08X", d0]];
	[self->tfD1 setStringValue:[NSString stringWithFormat:@"0x%08X", d1]];
	[self->tfD2 setStringValue:[NSString stringWithFormat:@"0x%08X", d2]];
	[self->tfD3 setStringValue:[NSString stringWithFormat:@"0x%08X", d3]];
	[self->tfD4 setStringValue:[NSString stringWithFormat:@"0x%08X", d4]];
	[self->tfD5 setStringValue:[NSString stringWithFormat:@"0x%08X", d5]];
	[self->tfD6 setStringValue:[NSString stringWithFormat:@"0x%08X", d6]];
	[self->tfD7 setStringValue:[NSString stringWithFormat:@"0x%08X", d7]];

	[self->tfA0 setStringValue:[NSString stringWithFormat:@"0x%08X", a0]];
	[self->tfA1 setStringValue:[NSString stringWithFormat:@"0x%08X", a1]];
	[self->tfA2 setStringValue:[NSString stringWithFormat:@"0x%08X", a2]];
	[self->tfA3 setStringValue:[NSString stringWithFormat:@"0x%08X", a3]];
	[self->tfA4 setStringValue:[NSString stringWithFormat:@"0x%08X", a4]];
	[self->tfA5 setStringValue:[NSString stringWithFormat:@"0x%08X", a5]];
	[self->tfA6 setStringValue:[NSString stringWithFormat:@"0x%08X", a6]];

	[self->tfUSP setStringValue:[NSString stringWithFormat:@"0x%08X", usp]];
	[self->tfSSP setStringValue:[NSString stringWithFormat:@"0x%08X", ssp]];
	[self->tfPC setStringValue:[NSString stringWithFormat:@"0x%08X", pc]];
	[self->tfPCOLD setStringValue:[NSString stringWithFormat:@"0x%08X", pcold]];

	[self->tfRI setStringValue:[NSString stringWithFormat:@"0x%04X", ri]];
	
	// T.S..I2I1I0...XNZVC
	[self->tfSR_HEX setStringValue:[NSString stringWithFormat:@"0x%04X", sr ]];
	NSString *description = [NSString stringWithFormat:@"%s.%s. .%s%s%s  ...%s %s%s%s%s",	(sr & 0x8000 ? "T" : "."),
																						(sr & 0x2000 ? "S" : "."),
																						(sr & 0x0400 ? "I2" : "."),
																						(sr & 0x0200 ? "I1" : "."),
																						(sr & 0x0400 ? "I0" : "."),
																						(sr & 0x0010 ? "X" : "."),
																						(sr & 0x0008 ? "N" : "."),
																						(sr & 0x0004 ? "Z" : "."),
																						(sr & 0x0002 ? "V" : "."),
																						(sr & 0x0001 ? "C" : ".") ];
	
	[self->tfSR_BIN setStringValue:[NSString stringWithFormat:@"%@", description ]];
	
	if( [self->atariST CPUInstructionText] != nil ) {
		[self->tfInstText setStringValue:[self->atariST CPUInstructionText]];
	}
}
//---------------------------------------------------------------------------
- (IBAction) btStartClick:(id)sender {

	[self AddLogMessage:@"Initializing CPU/Memory..."];
	
	int status = [self->cbCartdridge state];
	
	[self->atariST Reset: ( status == 1 ) ];
	[self RegistersInspector];
	
	[self AddLogMessage: [NSString stringWithFormat:@"TOS Version: 0x%X", [self->atariST TOSVersion]]];
	[self->btFetchRun setEnabled:true];
}
//---------------------------------------------------------------------------
- (IBAction) btFetchRunClick:(id)sender {

	[self->atariST RunStep];
	
	[self RegistersInspector];
}
//---------------------------------------------------------------------------

@end
