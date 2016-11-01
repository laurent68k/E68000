//
//  Core.h
//  E68000
//
//  Created by Laurent on 24/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CoreMMU.h"

@interface Core : CoreMMU {

	//	Standards 68K registers 
	long	regA[9];					//	Adress register A0..A7 (A7 is USP) and A8 will be A7' (SSP)
	long	regD[8];					//	data register D0..D7

	int		regInstruction;				//	Keep current instruction 
	int		regIrq;

	//	Internal registers
	long	cycles;
	long	*regEA1, *regEA2;
	long	regEV1, regEV2;
	long	regResult;
	
	//	fixme type
	bool trace;
	bool sstep;
	bool trace_bit;
	long global_temp;
}

-(void) put:(long *)dest:(long) source:(long) size;
-(int) to_2s_comp:(long) number:(long) size:(long *)result;
-(int) from_2s_comp:(long) number:(long) size:(long *)result;
-(long) sign_extend:(int) number:(long) size_from;
-(int) eff_addr:(long) size:(int) mask:(int) add_times;
-(int) eff_addr_code:(int) inst:(int) start;
-(int) eff_addr_noread:(long) size:(int) mask:(int) add_times;
-(int) a_reg:(int) reg_num;
-(void) put:(long *)dest:(long) source:(long) size;
-(void) value_of:(long *)EA:(long *)EV:(long) size;
-(int) decode_size:(long *)result;
-(void) value_of:(long *)EA: (long *)EV:(long) size;

-(int) cc_update:(int) x:(int) n:(int) z:(int) v:(int) c:(long) source: (long) dest: (long) result: (long) size: (int) r;
-(int) check_condition:(int) condition;
-(void) exceptionHandler:(int) clas:(long) loc:(int) r_w;
-(void) irqHandler;

-(unsigned int) getDivu68kCycles: (unsigned long) dividend: (unsigned short) divisor;
-(unsigned int) getDivs68kCycles: (signed long) dividend:(signed short) divisor;

-(unsigned short) flip:(unsigned short *) n;
//-(unsigned short) flip:(unsigned short ) value;

-(void) CPUAddCycles:(int) ticks;

@end
