//
//  Wnd68000.h
//  E68000
//
//  Created by Laurent on 06/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AtariST.h"

@interface Wnd68000 : NSWindowController {

	//	GUI buttons and others
	IBOutlet NSButton		*btStart;
	IBOutlet NSButton		*btFetchRun;	
	IBOutlet NSTextField	*tfLog;
	IBOutlet NSButton		*cbCartdridge;
	
	//	specifics processor registers
	IBOutlet NSTextField	*tfD0;
	IBOutlet NSTextField	*tfD1;
	IBOutlet NSTextField	*tfD2;
	IBOutlet NSTextField	*tfD3;
	IBOutlet NSTextField	*tfD4;
	IBOutlet NSTextField	*tfD5;
	IBOutlet NSTextField	*tfD6;
	IBOutlet NSTextField	*tfD7;

	IBOutlet NSTextField	*tfA0;
	IBOutlet NSTextField	*tfA1;
	IBOutlet NSTextField	*tfA2;
	IBOutlet NSTextField	*tfA3;
	IBOutlet NSTextField	*tfA4;
	IBOutlet NSTextField	*tfA5;
	IBOutlet NSTextField	*tfA6;

	IBOutlet NSTextField	*tfSR_BIN;
	IBOutlet NSTextField	*tfSR_HEX;

	IBOutlet NSTextField	*tfUSP;
	IBOutlet NSTextField	*tfSSP;
	IBOutlet NSTextField	*tfPC;
	IBOutlet NSTextField	*tfPCOLD;

	IBOutlet NSTextField	*tfRI;
	
	IBOutlet NSTextField	*tfInstText;
	
	AtariST					*atariST;
}

//	Methodes GUI binded to IB
- (IBAction) btStartClick:(id)sender;
- (IBAction) btFetchRunClick:(id)sender;

@end
