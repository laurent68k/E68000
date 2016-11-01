//
//  Core.h
//  E68000
//
//  Created by Laurent on 24/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MC68000Global.h"


@interface CoreMMU : NSObject {

	unsigned short	regSR;						//	SR (Included CCR)
	long			regPC;						//	Program Counter
	long			OLD_PC;

	//	A revoir
	int ROMStart, ROMEnd, ReadStart, ReadEnd;
	int ProtectedStart, ProtectedEnd, InvalidStart, InvalidEnd;
	bool ROMMap, ReadMap, ProtectedMap, InvalidMap;

	unsigned char memory[ MEMSIZE ];
	
	//	 fixme types
	bool exceptions;					//	Sould be true. If false, when excpetion occured program will halt
	long * writeEA;
	bool bpWrite;
	long * readEA;
	bool bpRead;

	unsigned short	TOSVersion;
	unsigned long	TOSAddress;
	unsigned int	TOSSize;
	unsigned short	TOSLanguage;
	unsigned long	CARTRIDGEAddress;

	unsigned long STRamEnd;
	unsigned long STRamEnd_BusErr;

}

@property(readonly) unsigned short TOSVersion;
@property(readonly) unsigned short TOSLanguage;

// memory map types (bit flags which may be combined with OR logic)
typedef enum e_maptype {Invalid=0x01, Protected=0x02, Read=0x04, Rom=0x10} maptype;

-(int) memoryMapCheck:(maptype) mapt:(int) loc:(int) bytes;
-(int) mem_put:(long) data:(int) loc:(long) size;
-(int) mem_req:(int) loc:(long) size:(long *) result;
-(int) mem_request:(long *)loc:(long) size:(long *) result;

-(void) exceptionHandler:(int) clas:(long) loc:(int) r_w;

-(bool) LoadTOS:(NSString *) filename;
-(void) LoadROMCartridge:(NSString *) romHighName:(NSString *)romLowName;

@end
