//
//  Core.m
//  E68000
//
//  Created by Laurent on 24/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CoreInstructions.h"

//int		offsets[] =	{ 0, 15, 16, 18, 20, 53, 57, 60, 61, 65, 68, 69, 73, 80, 83, 86, 87 };

/* the following two arrays specify the execution times of the MOVE
	instruction, for BYTE_MASK/WORD_MASK operands and for long operands */

int	move_bw_times [12][9] = {
            4,    4,    8,    8,    8,   12,   14,   12,   16 ,
            4,    4,    8,    8,    8,   12,   14,   12,   16 ,
            8,    8,   12,   12,   12,   16,   18,   16,   20 ,
            8,    8,   12,   12,   12,   16,   18,   16,   20 ,
           10,   10,   14,   14,   14,   18,   20,   18,   22 ,
           12,   12,   16,   16,   16,   20,   22,   20,   24 ,
           14,   14,   18,   18,   18,   22,   24,   22,   26 ,
           12,   12,   16,   16,   16,   20,   22,   20,   24 ,
           16,   16,   20,   20,   20,   24,   26,   24,   28 ,
           12,   12,   16,   16,   16,   20,   22,   20,   24 ,
           14,   14,   18,   18,   18,   22,   24,   22,   26 ,
            8,    8,   12,   12,   12,   16,   18,   16,   20   };


int	move_l_times [12][9] = {
            4,    4,   12,   12,   12,   16,   18,   16,   20 ,
            4,    4,   12,   12,   12,   16,   18,   16,   20 ,
           12,   12,   20,   20,   20,   24,   26,   24,   28 ,
           12,   12,   20,   20,   20,   24,   26,   24,   28 ,
           14,   14,   22,   22,   22,   26,   28,   26,   30 ,
           16,   16,   24,   24,   24,   28,   30,   28,   32 ,
           18,   18,   26,   26,   26,   30,   32,   30,   34 ,
           16,   16,   24,   24,   24,   28,   30,   28,   32 ,
           20,   20,   28,   28,   28,   32,   34,   32,   36 ,
           16,   16,   24,   24,   24,   28,   30,   28,   32 ,
           18,   18,   26,   26,   26,   30,   32,   30,   34 ,
           12,   12,   20,   20,   20,   24,   26,   24,   28   };


/* the following two arrays specify the instruction execution times
	for the MOVEM instruction for memory-to-reg and reg-to-memory cases */

int     movem_t_r_times[11] = {
        0,    0,    12,   12,    0,   16,   18,   16,   20,   16,   18  };

int     mover_t_m_times[11] = {
        0,    0,     8,    0,    8,   12,   14,   12,   16,    0,    0  };
		

@implementation CoreInstructions

//---------------------------------------------------------------------------
// Overload of Init
- (id)init
{
    self = [super init];
    
	self->bitfield = 1;
	[self InitInstructionsMap];
	
    return self;
}
//---------------------------------------------------------------------------
- (void)dealloc {
	
    [super dealloc];
}
//----------------------------------------------------------------------------
//	
//----------------------------------------------------------------------------

-(void) InitInstructionsMap {

	self->names[0] = @selector(EORI_TO_CCR);
	self->names[1] = @selector(EORI_TO_SR); 
	self->names[2] = @selector(ORI_TO_CCR); 
	self->names[3] = @selector(ORI_TO_SR);	
	self->names[4] = @selector(ANDI_TO_CCR);
	self->names[5] = @selector(ANDI_TO_SR); 
	self->names[6] = @selector(MOVEP); 
	self->names[7] = @selector(ANDI); 
	self->names[8] = @selector(ORI); 
	self->names[9] = @selector(SUBI); 
	self->names[10] = @selector(ADDI); 
	self->names[11] = @selector(BIT_OP); 
	self->names[12] = @selector(EORI); 
	self->names[13] = @selector(CMPI);
	self->names[14] = @selector(BIT_OP); 
	self->names[15] = @selector(MOVE); 
	self->names[16] = @selector(MOVEA); 
	self->names[17] = @selector(MOVE); 
	self->names[18] = @selector(MOVEA); 
	self->names[19] = @selector(MOVE);	
	self->names[20] = @selector(ILLEGAL); 
	self->names[21] = @selector(RESET); 
	self->names[22] = @selector(NOP);
	self->names[23] = @selector(STOP); 
	self->names[24] = @selector(RTE); 
	self->names[25] = @selector(RTS); 
	self->names[26] = @selector(TRAPV); 
	self->names[27] = @selector(RTR); 
	self->names[28] = @selector(LINK); 
	self->names[29] = @selector(UNLK); 
	self->names[30] = @selector(MOVE_USP); 
	self->names[31] = @selector(MOVE_USP);
	self->names[32] = @selector(SWAP); 
	self->names[33] = @selector(EXT); 
	self->names[34] = @selector(EXT); 
	self->names[35] = @selector(TRAP); 
	self->names[36] = @selector(MOVE_FR_SR); 
	self->names[37] = @selector(MOVE_TO_CCR); 
	self->names[38] = @selector(MOVE_TO_SR);
	self->names[39] = @selector(NBCD); 
	self->names[40] = @selector(PEA); 
	self->names[41] = @selector(TAS); 
	self->names[42] = @selector(JSR); 
	self->names[43] = @selector(JMP); 
	self->names[44] = @selector(MOVEM); 
	self->names[45] = @selector(MOVEM); 
	self->names[46] = @selector(CLR); 
	self->names[47] = @selector(NEGX); 
	self->names[48] = @selector(NEG); 
	self->names[49] = @selector(NOT);
	self->names[50] = @selector(TST); 
	self->names[51] = @selector(CHK); 
	self->names[52] = @selector(LEA); 
	self->names[53] = @selector(DBCC); 
	self->names[54] = @selector(SCC); 
	self->names[55] = @selector(SUBQ); 
	self->names[56] = @selector(ADDQ); 
	self->names[57] = @selector(BRA); 
	self->names[58] = @selector(BSR); 
	self->names[59] = @selector(BCC); 
	self->names[60] = @selector(MOVEQ);
	self->names[61] = @selector(SBCD);	
	self->names[62] = @selector(DIVU);
	self->names[63] = @selector(DIVS); 
	self->names[64] = @selector(OR); 
	self->names[65] = @selector(SUBA); 
	self->names[66] = @selector(SUBX); 
	self->names[67] = @selector(SUB); 
	self->names[68] = @selector(LINE1010); 
	self->names[69] = @selector(CMPA); 
	self->names[70] = @selector(CMPM);
	self->names[71] = @selector(CMP); 
	self->names[72] = @selector(EOR); 
	self->names[73] = @selector(EXG); 
	self->names[74] = @selector(EXG); 
	self->names[75] = @selector(EXG); 
	self->names[76] = @selector(ABCD); 
	self->names[77] = @selector(MULS); 
	self->names[78] = @selector(MULU); 
	self->names[79] = @selector(AND); 
	self->names[80] = @selector(ADDA); 
	self->names[81] = @selector(ADDX);
	self->names[82] = @selector(ADD); 
	self->names[83] = @selector(BIT_FIELD); 
	self->names[84] = @selector(SHIFT_ROT); 
	self->names[85] = @selector(SHIFT_ROT); 
	self->names[86] = @selector(LINE1111);
	
}			
//----------------------------------------------------------------------------
//	Instructions from CODE1.cpp
//----------------------------------------------------------------------------
-(int)	MOVE {
	long	size;		 	/* 'size' holds the instruction size */
	int		src, dst;			/* 'src' and 'dst' hold the addressing mode codes */
			 				/* for instruction execution time computation */

	/* MOVE has a different format for size field than all other instructions */
	/* so we can't use the 'decode_size' function */
	switch ( (self->regInstruction >> 12) & 0x03) {
	
		case 0x01 : size = BYTE_MASK;			/* bit pattern '01' */
					 break;
		case 0x03 : size = WORD_MASK;			/* bit pattern '10' */
					 break;
		case 0x02 : size = LONG_MASK;			/* bit pattern '11' */
					 break;
		default   : return (BAD_INST);		/* bad size field */
	}

	// the following gets the effective addresses for the source and destination operands
	int error = [self eff_addr: size: ALL_ADDR: YES ];
	if (error)              // if address error
	  return error;         // return error code

	error = [self eff_addr: size :  DATA_ALT_ADDR :  false];
	if (error)              // if address error
	  return error;         // return error code

	self->dest = self->regEV2;    				/* set 'self->dest' for use in 'cc_update' */

	[self put: self->regEA2: self->regEV1: size];	       		/* perform the move to '*EA2' */
	[self value_of: self->regEA2: &self->regEV2: size];		/* set 'EV2' for use in 'cc_update' */

	src = [self eff_addr_code: self->regInstruction: 0];		/* get the addressing mode codes */
	dst = [self eff_addr_code: self->regInstruction: 6];

	if (size == LONG_MASK)			/* use the codes in instruction time computation */
		[self CPUAddCycles: move_l_times[src][dst] ];
	else
		[self CPUAddCycles: move_bw_times[src][dst]];

	/* now update the condition codes */
	[self cc_update: N_A: GEN: GEN: ZER: ZER: self->regEV1: self->dest: self->regEV2: size: 0 ];

	/* return the value for 'success' */
	return SUCCESS;
}
//----------------------------------------------------------------------------
-(int)	MOVEP {

  int	address, Dx, disp, count, direction, reg;
  long	temp, size;

  if ((self->regInstruction & 0x100) == 0)      // ck v2.3
    return(BAD_INST);

  [self mem_request: &self->regPC: (long) WORD_MASK: &temp ];
  [self from_2s_comp: temp: (long) WORD_MASK: &temp];

  address = self->regA[ [self a_reg: self->regInstruction & 0x07] ] + temp;

  direction = self->regInstruction & 0x80;

  if (self->regInstruction & 0x40) {
    size = LONG_MASK;
    count = 4;
  } 
  else {
    size = WORD_MASK;
    count = 2;
  }

  reg = (self->regInstruction >> 9) & 0x07;
  Dx = self->regD[reg] & size;

  for (;count > 0; count--) {
  
    disp = 8 * (count - 1);
    if (direction)
      [self mem_put: (long)((Dx >> disp) & BYTE_MASK): address: (long) BYTE_MASK ];
    else {
      [self mem_req: address: (long) BYTE_MASK: &temp];
    
    switch  (count) {
	case 4 : self->regD[reg] = (self->regD[reg] & 0x00FFFFFF) | (temp * 0x1000000);
		 break;
	case 3 : self->regD[reg] = (self->regD[reg] & 0xFF00FFFF) | (temp * 0x10000);
		 break;
	case 2 : self->regD[reg] = (self->regD[reg] & 0xFFFF00FF) | (temp * 0x100);
		 break;
	case 1 : self->regD[reg] = (self->regD[reg] & 0xFFFFFF00) | (temp);
		 break;
      }
    }
    address += 2;
  }

  [self CPUAddCycles: ((size == LONG_MASK) ? 24 : 16) ];
  return SUCCESS;
}
//----------------------------------------------------------------------------
-(int)	MOVEA {

	long	size;
	int	src;

	if (self->regInstruction & 0x1000)
		size = WORD_MASK;
	else
		size = LONG_MASK;

	src = [self eff_addr_code: self->regInstruction: 0 ];
	if (size == WORD_MASK)
		[self CPUAddCycles: move_bw_times[src][2] ];
	else
		[self CPUAddCycles: move_l_times[src][2] ];

	int error = [self eff_addr: size: ALL_ADDR: false];
	if (error)              // if address error
	  return error;         // return error code

	if (size == WORD_MASK)
		self->regEV1 = [self sign_extend: (int)self->regEV1: (long) WORD_MASK ];

	self->regA[ [self a_reg: (self->regInstruction >> 9) & 0x07] ] = self->regEV1;

	return SUCCESS;
}
//----------------------------------------------------------------------------
-(int)	MOVE_FR_SR {

  int error = [self eff_addr: (long)WORD_MASK: DATA_ALT_ADDR: YES ];
  
  if (error)              // if address error
    return error;         // return error code

  [self put: self->regEA1: (long) self->regSR: (long) WORD_MASK ];
  [self CPUAddCycles: (self->regInstruction & 0x0030) ? 8 : 6 ];
  
  return SUCCESS;
}
//----------------------------------------------------------------------------
-(int)	MOVE_TO_CCR {

	int error = [self eff_addr: (long)WORD_MASK: DATA_ADDR: true ];
	if (error)              // if address error
		return error;         // return error code

	[self put: (long *)&self->regSR: self->regEV1: (long) BYTE_MASK];
	[self CPUAddCycles: 12];

	return SUCCESS;
}
//----------------------------------------------------------------------------
-(int) MOVE_TO_SR {

  if (! (self->regSR & sbit))
    return (NO_PRIVILEGE);

	int error = [self eff_addr: (long)WORD_MASK: DATA_ADDR: true];
  if (error)              // if address error
    return error;         // return error code

  [self put: (long *)&self->regSR: self->regEV1: (long) WORD_MASK ];
  
  [self CPUAddCycles: 12];
  return SUCCESS;
}
//------------------------------------------------------------------
// ck April 15, 2002 Fixed bug in MOVEM.L (A7)+/Dn-Dn
// CK 5-1-2007 bug fix when destination An is included in register list
-(int)	MOVEM {
	
  int	direction, addr_modes_mask, counter, addr_mode;
  int	displacement, address, total_displacement;
  long	size, mask_list, temp;
	
	uint  saveAn = self->regA[ [self a_reg: self->regInstruction & 0x7] ];		// save possible destination (CK 5-1-2007)

  [self mem_request: &self->regPC: (long) WORD_MASK: &mask_list ];

  if (self->regInstruction & 0x0040)
    size = LONG_MASK;
  else
    size = WORD_MASK;

  if ((direction = (self->regInstruction & 0x0400)) != 0)
    addr_modes_mask = CONTROL_ADDR | bit_4;
  else
    addr_modes_mask = CONT_ALT_ADDR | bit_5;

  int error = [self eff_addr: size: addr_modes_mask: false ];
  if (error)										// if address error
    return error;									// return error code

  address = (long) ( (long)self->regEA1 - (long)&self->memory[0]);
  total_displacement = address;

  if ((self->regInstruction & 0x0038) != 0x20) {
    if (size == WORD_MASK)
      displacement = 2;
    else
      displacement = 4;
  } else {
    if (size == WORD_MASK)
      displacement = -2;
    else
      displacement = -4;
  }

  addr_mode = [self eff_addr_code: self->regInstruction: 0 ];

  if (direction)
    [self CPUAddCycles: movem_t_r_times[addr_mode] ];			// memory to registers
  else
    [self CPUAddCycles: mover_t_m_times[addr_mode] ];			// registers to memory

  for (counter = 0; counter < 16; counter++) {
    
	if (mask_list & (1 << counter)) {
		if (size == LONG_MASK)
			[self CPUAddCycles: 8];
		else
			[self CPUAddCycles: 4];
	
		if (direction) {								// if memory to registers
			if (size == WORD_MASK) {						// if size is WORD_MASK then sign-extend
			  [self mem_req: address: (long) WORD_MASK: &temp ];
			  temp = [self sign_extend: (int) temp: WORD_MASK ];   // ck 8-10-2005
			} 
			else											// ck added this mem_req
			  [self mem_req: address: (long) LONG_MASK: &temp ];
	  
			if (counter < 8)
			  self->regD[counter] = temp;
			else
				self->regA[ [self a_reg: counter - 8] ] = temp;
		}	
		else {										// else, registers to memory
			if ((self->regInstruction & 0x38) == 0x20) {					// if -(An)
			  if (counter < 8)
					if ( (self->regInstruction & 0x7) == (7 - counter))		// if writing destination An (CK 5-1-2007)
						[self mem_put: saveAn: address: size];
					else
						[self mem_put: self->regA[ [self a_reg: 7 - counter] ]: address: size];
			  else
				[self mem_put: self->regD[15 - counter]: address: size];
			} 
			else {
			  if (counter < 8)
				[self mem_put: self->regD[counter]: address: size ];
			  else
				[self mem_put: self->regA[ [self a_reg: counter - 8] ]: address: size];
			}
      }
      address += displacement;
    }
  }
  //address -= displacement;    // CK 5-1-2007
  total_displacement = address - total_displacement;

  // if pre-decrement or post-increment modes then change the value of the address register appropriately
  if ( ((self->regInstruction & 0x38) == 0x20) || ( (self->regInstruction & 0x38) == 0x18) )
  {
    self->regA[[self a_reg: self->regInstruction & 0x7]] = saveAn;      // restore incase it was also destination
    self->regA[[self a_reg: self->regInstruction & 0x7]] += total_displacement;
  }
  
  return SUCCESS;
}
//----------------------------------------------------------------------------
-(int)	MOVE_USP {
	
	int	reg;

	if (!(self->regSR & sbit))
		return (NO_PRIVILEGE);		/* supervisor state not on */

	reg = self->regInstruction & 0x7;
	if (reg == 7)
		reg = 8;

	if (self->regInstruction & 0x8)
		self->regA[reg] = self->regA[7];
	else
		self->regA[7] = self->regA[reg];

	[self CPUAddCycles: 4];

	return SUCCESS;
}
//----------------------------------------------------------------------------
-(int)	MOVEQ {
	
	int	reg;

	reg = (self->regInstruction >> 9) & 0x7;
	self->source = self->regInstruction & 0xff;
	self->dest = self->regD[reg];

	/* the data register is sign extended to a longword */
	self->regD[reg] = [self sign_extend: (int)self->source: (long) BYTE_MASK ];
	self->regD[reg] = [self sign_extend: (int)self->regD[reg]: (long) WORD_MASK ];

	[self cc_update: N_A: GEN: GEN: ZER: ZER: self->source: self->dest: self->regD[reg]: LONG_MASK: 0 ];
	[self CPUAddCycles: 4];

	return SUCCESS;
}
//----------------------------------------------------------------------------
//	Instructions from CODE2.cpp
//----------------------------------------------------------------------------
-(int) EXG {
	
	long	temp_reg;
	int		Rx, Ry;
	
	Rx = (self->regInstruction >> 9) & 0x07;
	Ry = self->regInstruction & 0x07;
	switch( (self->regInstruction >> 3) & 0x1f ) {
			
		case 0x08: temp_reg = self->regD[Rx];
			self->regD[Rx] = self->regD[Ry];
			self->regD[Ry] = temp_reg;
			break;
			
		case 0x09: temp_reg = self->regA[ [self a_reg: Rx] ];
			self->regA[ [self a_reg: Rx] ] = self->regA[ [self a_reg: Ry] ];
			self->regA[ [self a_reg: Ry] ] = temp_reg;
			break;
			
		case 0x11: temp_reg = self->regD[ Rx ];
			self->regD[ Rx ] = self->regA[ [self a_reg: Ry] ];
			self->regA[ [self a_reg: Ry] ] = temp_reg;
			break;
			
		default  : return (BAD_INST);		//	bad op_mode field
	}
	
	[self CPUAddCycles: 6];

	return SUCCESS;
}
//------------------------------------------------------------------------
//  LEA
//  ck. Changed size to BYTE_MASK to prevent address error when effective
//      address was odd and eff_addr called value_of.
-(int) LEA {

	int		reg;
	//long	size;
	
	reg = (self->regInstruction >> 9) & 0x07;
	
	if ( [self eff_addr_noread: BYTE_MASK: CONTROL_ADDR: false] )
		return (BAD_INST);		// bad instruction format
	
	// perform the LEA operation
	self->regA[ [self a_reg: reg] ] = (long)((long)self->regEA1 - (long)&self->memory[0]);
	
	if ((self->regInstruction & 0x003F) == 0x0038) {				// if Abs.W   ck 2.9.3
		self->regA[ [self a_reg: reg] ] = [self sign_extend: (int)self->regA[ [self a_reg: reg] ]: WORD_MASK ];
	}
	
	switch ( [self eff_addr_code: self->regInstruction : 0]) {
		case 0x02 : [self CPUAddCycles: 4];
			break;
		case 0x05 : [self CPUAddCycles: 8];
			break;
		case 0x06 : [self CPUAddCycles: 12];
			break;
		case 0x07 : [self CPUAddCycles: 8];
			break;
		case 0x08 : [self CPUAddCycles: 12];
			break;
		case 0x09 : [self CPUAddCycles: 8];
			break;
		case 0x0a : [self CPUAddCycles: 12];
			break;
	}
	return SUCCESS;
}
//----------------------------------------------------------------------------
-(int) PEA {
	
	long ea;
	
	if ([self eff_addr_noread:LONG_MASK: CONTROL_ADDR: false] ) {
		return (BAD_INST);		// bad instruction format
	}
	
	// push the longword address computed by the
	// effective address routine onto the stack
	
	self->regA[ [self a_reg: 7] ] -= 4;
	
	ea = ((long)self->regEA1 - (long)&memory[0]);
	if ((self->regInstruction & 0x003F) == 0x0038)  // if Abs.W  ck 2.9.3
		ea = [self sign_extend: (int)ea: WORD_MASK ];
	
	[self put: (long*)&self->memory[ self->regA[ [self a_reg:7] ]]: ea: LONG_MASK ];
	
	switch( [self eff_addr_code: self->regInstruction: 0]) {
		case 0x02 : [self CPUAddCycles: 12];
			break;
		case 0x05 : [self CPUAddCycles: 16];
			break;
		case 0x06 : [self CPUAddCycles: 20];
			break;
		case 0x07 : [self CPUAddCycles: 16];
			break;
		case 0x08 : [self CPUAddCycles: 20];
			break;
		case 0x09 : [self CPUAddCycles: 16];
			break;
		case 0x0a : [self CPUAddCycles: 20];
			break;
	}
	return SUCCESS;
}
//----------------------------------------------------------------------------
-(int) LINK {
	
	int	reg;
	long	temp, displacement;

	reg = self->regInstruction & 0x07;
	
	[self mem_request: &self->regPC: (long) WORD_MASK: &temp];
	[self from_2s_comp:temp: (long) WORD_MASK: &displacement];
	
	// perform the LINK operation
	self->regA[ [self a_reg: 7] ] -= 4;
	
	[self put:(long *)&self->memory[ self->regA[ [self a_reg:7] ] ]: self->regA[ reg ]: LONG_MASK ];
	
	self->regA[reg] = self->regA[ [self a_reg: 7] ];
	self->regA[[self a_reg: 7] ] = self->regA[ [self a_reg: 7] ] + displacement;
	
	[self CPUAddCycles: 16];
	
	return SUCCESS;	
}
//----------------------------------------------------------------------------
-(int) UNLK {
	
	int	reg;
	
	reg = self->regInstruction & 0x07;
	
	self->regA[ [self a_reg: 7] ] = self->regA[ reg ];
	
	[self mem_req: (int) self->regA[ [self a_reg: 7] ]: LONG_MASK: &self->regA[reg] ];
	
	self->regA[ [self a_reg: 7] ] += 4;
	
	[self CPUAddCycles: 12];
	
	return SUCCESS;	
}
//----------------------------------------------------------------------------
//	Instructions from CODE3.cpp
//----------------------------------------------------------------------------
-(int) ADD {

	int	addr_modes_mask; 							/* holds mask for use in 'eff_addr()' */
	int	reg;		 								/* holds data register number */
	long	size;		 								/* holds instruction size */
	int     error;

	/* compute addressing modes mask from appropriate bit in instruction WORD_MASK */
	addr_modes_mask = (self->regInstruction & 0x0100) ? MEM_ALT_ADDR : ALL_ADDR;

	/* the following statement decodes the instruction size using */
	/* decode_size(), then decodes the effective address using eff_addr() */
	if ([self decode_size: &size]) 							// if size is bad then return 'bad instruction'
	return (BAD_INST);

	error = [self eff_addr: size: addr_modes_mask: true];
	if (error)											// if address error
		return error;										// return error code

	reg = (self->regInstruction >> 9) & 0x0007;			/* get data register number */

	/* now perform the addition according to instruction format */
	/* instruction bit 8 'on' means data register to effective-address */
	/* instruction bit 8 'off' means effective-a	ddress to data register */
	if (self->regInstruction & 0x0100) {
	  self->source = self->regD[reg];
	  self->dest = self->regEV1;
		
	  [self put: self->regEA1: self->source + self->dest: size];	/* use 'put' to deposit result */
	  [self value_of: self->regEA1: &self->regResult: size];		/* set 'result' for use in 'cc_update' */
	}
	else {
	  self->source = self->regEV1;							/* get self->source. 'EV1' was set in 'eff_addr()' */
	  self->dest = self->regD[reg];							/* get destination */
	  [self put: &self->regD[reg]: self->source + self->dest: size];
		self->regResult = self->regD[reg];					/* set 'result' for use in 'cc_update()' */
	}

  /* update the condition codes */
  [self cc_update: GEN: GEN: GEN: CASE_1: CASE_5: self->source: self->dest: self->regResult: size: 0 ];

  /* now update the cycle counter appropriately depending on the instruction */
  /* size and the instruction format */
  if (self->regInstruction & 0x0100) {          // if (<ea>)+(<Dn>) --> <ea>
    [self CPUAddCycles: (size == LONG_MASK) ? 12 : 8];
  } else {
    if (size == LONG_MASK) {
      if ( (!(self->regInstruction & 0x0030)) || ((self->regInstruction & 0x003f) == 0x003c) )
        [self CPUAddCycles: 8];
      else
        [self CPUAddCycles: 6];
    } else {
      [self CPUAddCycles: 4];
    }
  }

  /* return 'success' */
  return SUCCESS;

}
//----------------------------------------------------------------------------
-(int) ADDA
{
  long	size;
  int	reg;

  if (self->regInstruction & 0x0100)
          size = LONG_MASK;
  else
          size = WORD_MASK;

	int error = [self eff_addr: size: ALL_ADDR: true];
  if (error)              // if address error
    return error;         // return error code


  reg = (self->regInstruction >> 9) & 0x0007;

  if (size == WORD_MASK)                          // ck 1/22/2003
	  self->regEV1 = [self sign_extend: (int)self->regEV1: WORD_MASK];

	self->source = self->regEV1;
	self->dest = self->regA[[self a_reg: reg]];

  [self put: &self->regA[[self a_reg: reg]]: self->source + self->dest: LONG_MASK]; // always uses 32bits of Areg


  if (size == LONG_MASK) {
          if ( (!(self->regInstruction & 0x0030)) || ((self->regInstruction & 0x003f) == 0x003c) )
                  [self CPUAddCycles: 8];
          else
                  [self CPUAddCycles: 6];
          }
  else
          [self CPUAddCycles: 8];

  return SUCCESS;

}


//--------------------------------------------------------------------------
-(int) ADDI
{
	long	size;

	if ([self decode_size: &size])
		return (BAD_INST);			// bad instruction format

	[self mem_request: &self->regPC: size: &self->source];

	int error = [self eff_addr: size: DATA_ALT_ADDR: true];
	if (error)              // if address error
		return error;         // return error code

	self->dest = self->regEV1;
	
	[self put: self->regEA1: self->source + self->dest: size];
	[self value_of: self->regEA1: &self->regResult: size];
  [self cc_update: GEN: GEN: GEN: CASE_1: CASE_5: self->source: self->dest: self->regResult: size: 0];

  if (self->regInstruction & 0x0038) {
    [self CPUAddCycles: (size == LONG_MASK) ? 20 : 12];
  } else {
    [self CPUAddCycles: (size == LONG_MASK) ? 16 : 8];
  }
  return SUCCESS;
}
//----------------------------------------------------------------------------
-(int) ADDQ
{
  long	size;

  if ([self decode_size: &size])
          return (BAD_INST);			/* bad size format */

  if ((self->regInstruction & 0x38) == 0x8)		/* if address reg direct, operation is long */
          size = LONG_MASK;

	int error = [self eff_addr: size: ALTERABLE_ADDR: true];
  if (error)              // if address error
    return error;         // return error code

  self->source = ((self->regInstruction >> 9) & 0x07);
  if (self->source == 0) 			/* if self->source is '0', that corresponds to '8' */
          self->source = 8;

   self->dest = self->regEV1;
	
	[self put: self->regEA1: self->source + self->dest: size];
	[self value_of: self->regEA1: &self->regResult: size];

  if (!((self->regInstruction & 0x38) == 0x8))   /* if address reg direct, cc's not affected */
	  [self cc_update: GEN: GEN: GEN: CASE_1: CASE_5: self->source: self->dest: self->regResult: size: 0];

  switch (self->regInstruction & 0x0038) {
          case 0x0  : [self CPUAddCycles: (size == LONG_MASK) ? 8 : 4];
                      break;
          case 0x8  : [self CPUAddCycles: 8];        // CK 12-17-2005
                      break;
          default   : [self CPUAddCycles: (size == LONG_MASK) ? 12 : 8];
                      break;
          }

  return SUCCESS;
}
//----------------------------------------------------------------------------
-(int) ADDX
{
  long	size;
  int	Rx, Ry;

  if ([self decode_size: &size] ) 
	  return (BAD_INST);

  Rx = (self->regInstruction >> 9) & 0x0007;
  Ry = self->regInstruction & 0x0007;

  /* perform the ADDX operation */
	if (self->regInstruction & 0x0008) {
		Rx = [self a_reg: Rx];
		Ry = [self a_reg: Ry];
          if (size == BYTE_MASK) {
                  self->regA[Rx]--;
             self->regA[Ry]--;
             }
          if (size == WORD_MASK) {
                  self->regA[Rx] -= 2;
                  self->regA[Ry] -= 2;
             }
          if (size == LONG_MASK) {
                  self->regA[Rx] -= 4;
                  self->regA[Ry] -= 4;
             }
			  
			  
	  [self mem_req: (int) self->regA[Ry]: size: &self->source];
	  [self mem_req: (int) self->regA[Rx]: size: &self->dest];
      [self put: (long *)&memory[self->regA[[self a_reg: Rx]]]: self->source + self->dest + ((self->regSR & xbit) >> 4): size];
	  [self mem_req: (int) self->regA[Rx]: size: &self->regResult];
          }
  else
          {
          self->source = self->regD[Ry] & size;
          self->dest = self->regD[Rx] & size;
          [self put: &self->regD[Rx]: self->source + self->dest + ((self->regSR & xbit) >> 4): size];
          self->regResult = self->regD[Rx] & size;
          }

  [self cc_update: GEN: GEN: CASE_1: CASE_1: CASE_5: self->source: self->dest: self->regResult: size: 0];

  if (size == LONG_MASK)
     [self CPUAddCycles: (self->regInstruction & 0x0008) ? 30 : 8 ];
  else
     [self CPUAddCycles: (self->regInstruction & 0x0008) ? 18 : 4 ];

  return SUCCESS;

}
//----------------------------------------------------------------------------
-(int) SUB
{
	int	addr_modes_mask, reg;
	long	size;

	addr_modes_mask = (self->regInstruction & 0x0100) ? MEM_ALT_ADDR : ALL_ADDR;

	if ([self decode_size: &size])
		return (BAD_INST);	// bad instruction format

	int error = [self eff_addr: size: addr_modes_mask: true ];
	if (error)              // if address error
		return error;         // return error code

	reg = (self->regInstruction >> 9) & 0x0007;

	if (self->regInstruction & 0x0100) {
		self->source = self->regD[reg] & size;
		self->dest = self->regEV1 & size;
		[self put: self->regEA1: self->dest - self->source: size];
		[self value_of: self->regEA1: &self->regResult: size];
	}
	else  {
		self->source = self->regEV1 & size;
		self->dest = self->regD[reg] & size;
		[self put: &self->regD[reg]: self->dest - self->source: size];
		self->regResult = self->regD[reg] & size;
	}

	[self cc_update: GEN: GEN: GEN: CASE_2: CASE_6: self->source: self->dest: self->regResult: size: 0 ];

	if (self->regInstruction & 0x0100) {
		[self CPUAddCycles: (size == LONG_MASK) ? 12 : 8];
	}
	else {
		if (size == LONG_MASK) {
			  if ( (!(self->regInstruction & 0x0030)) || ((self->regInstruction & 0x003f) == 0x003c) )
					  [self CPUAddCycles: 8];
			  else
					  [self CPUAddCycles: 6];
		}
		else {
			  [self CPUAddCycles: 4];
		}
	}

	return SUCCESS;

}
//----------------------------------------------------------------------------
-(int)	SUBA {

  long	size;
  int	reg;

  if (self->regInstruction & 0x0100)
          size = LONG_MASK;
  else
          size = WORD_MASK;

  int error = [self eff_addr: size: ALL_ADDR: true];
  if (error)              // if address error
    return error;         // return error code

  reg = (self->regInstruction >> 9) & 0x0007;

  if (size == WORD_MASK)                          // ck 1/22/2003
          self->regEV1 = [self sign_extend: (int)self->regEV1: WORD_MASK ];

  self->source = self->regEV1;
  self->dest = self->regA[[self a_reg: reg]];

	  [self put: &self->regA[ [self a_reg: reg] ]: self->dest - self->source: LONG_MASK]; // always uses 32bits of Areg

  if (size == LONG_MASK) {
          if ( (!(self->regInstruction & 0x0030)) || ((self->regInstruction & 0x003f) == 0x003c) )
                  [self CPUAddCycles: 8];
          else
                  [self CPUAddCycles: 6];
          }
  else
          [self CPUAddCycles: 8];

  return SUCCESS;

}
//----------------------------------------------------------------------------
-(int) SUBI {

	long	size;

	if ([self decode_size: &size] )
		return (BAD_INST);		     // bad instruction format

	[self mem_request: &self->regPC: size: &self->source];

	int error = [self eff_addr: size: DATA_ALT_ADDR: true];
	if (error)              // if address error
		return error;         // return error code

	self->dest = self->regEV1;

		  [self put: self->regEA1: self->dest - self->source: size];
		  [self value_of: self->regEA1: &self->regResult: size];

		  [self cc_update: GEN: GEN: GEN: CASE_2: CASE_6: self->source: self->dest: self->regResult: size: 0];

	if (self->regInstruction & 0x0038) {
		[self CPUAddCycles: (size == LONG_MASK) ? 20 : 12];
	}
	else {
		[self CPUAddCycles: (size == LONG_MASK) ? 16 : 8];
	}

	return SUCCESS;

}
//----------------------------------------------------------------------------
-(int) SUBQ {

  long	size;

  if ([self decode_size: &size])
    return (BAD_INST);								/* bad size format */

  if ((self->regInstruction & 0x38) == 0x8)			/* if address reg direct, operation is long */
          size = LONG_MASK;

  int error = [self eff_addr: size: ALTERABLE_ADDR: true];
  if (error)										// if address error
    return error;									// return error code

	self->source = ((self->regInstruction >> 9) & 0x07);
  if (self->source == 0) 									/* if self->source is '0', that corresponds to '8' */
          self->source = 8;

  self->dest = self->regEV1;
	
  [self put: self->regEA1: self->dest - self->source: size];
  [self value_of: self->regEA1: &self->regResult: size];

  if (!((self->regInstruction & 0x38) == 0x8))		/* if address reg direct, cc's not affected */
  [self cc_update: GEN: GEN: GEN: CASE_2: CASE_6: self->source: self->dest: self->regResult: size: 0];

  switch (self->regInstruction & 0x0038) {
          case 0x0  : [self CPUAddCycles: (size == LONG_MASK) ? 8 : 4];
                      break;
          case 0x8  : [self CPUAddCycles: 8];      // CK 12-17-2005
                      break;
          default   : [self CPUAddCycles: (size == LONG_MASK) ? 12 : 8];
                      break;
          }

  return SUCCESS;
}
//----------------------------------------------------------------------------
-(int)SUBX {

	long	size;
	int		Rx, Ry;

	if ([self decode_size: &size])
	return (BAD_INST);

	Ry = (self->regInstruction >> 9) & 0x0007;
	Rx = self->regInstruction & 0x0007;

	/* perform the SUBX operation */
	if (self->regInstruction & 0x0008) {
		Rx = [self a_reg: Rx];
		Ry = [self a_reg: Ry];
		if (size == LONG_MASK)
			  {
			  self->regA[Rx] -= 4;
			  self->regA[Ry] -= 4;
			  }
		else if (size == WORD_MASK)
			  {
			  self->regA[Rx] -= 2;
			  self->regA[Ry] -= 2;
			  }
		else
			  {
			  self->regA[Rx]--;
			  self->regA[Ry]--;
		}
		
		[self mem_req: (int) self->regA[Rx]: size: &self->source];
		[self mem_req: (int) self->regA[Ry]: size: &self->dest];
		[self put: (long *)&memory[self->regA[Ry]]: self->dest - self->source - ((self->regSR & xbit)>> 4): size ];
		[self mem_req: (int) self->regA[Ry]: size: &self->regResult];
	}
	else {
		self->source = self->regD[Rx] & size;
		self->dest = self->regD[Ry] & size;
		[self put: &self->regD[Ry]: self->dest - self->source - ((self->regSR & xbit) >> 4): size];
		self->regResult = self->regD[Ry] & size;
    }

  [self cc_update: GEN: GEN: CASE_1: CASE_2: CASE_6: self->source: self->dest: self->regResult: size: 0];

  if (size == LONG_MASK)
     [self CPUAddCycles: (self->regInstruction & 0x0008) ? 30 : 8];
  else
     [self CPUAddCycles: (self->regInstruction & 0x0008) ? 18 : 4];

  return SUCCESS;

}
//----------------------------------------------------------------------------
//	Instructions from CODE4.cpp
//----------------------------------------------------------------------------
-(int) DIVS {
  int	reg;											//, overflow;
  long	remainder;


		  int error = [self eff_addr: (long)WORD_MASK: DATA_ADDR: true];
  if (error)											// if address error
    return error;										// return error code

  reg = (self->regInstruction >> 9) & 0x0007;

		  [self from_2s_comp: self->regEV1 & WORD_MASK: (long) WORD_MASK: &self->source];
	[self from_2s_comp: self->regD[reg]: LONG_MASK: &self->dest];

  if (self->source == 0)
    return (DIV_BY_ZERO);								// initiate exception processing

  self->regResult = (self->dest / self->source);
  if (self->regResult > 32767 || self->regResult < -32768)				// if overflow
    self->regSR |= vbit;
  else {
    self->regSR &= ~vbit;
    self->regResult &= 0xffff;
    remainder = (self->dest % self->source) & 0xffff;
    self->regD[reg] = self->regResult = self->regResult | (remainder * 0x10000);
    [self cc_update: N_A: GEN: GEN: N_A: ZER: self->source: self->dest: self->regResult: (long) WORD_MASK: 0];
    if ( ( (self->source < 0) && (self->dest > 0) ) || ( (self->source >= 0) && (self->dest < 0) ) )    // ck 8-10-2005
      self->regSR |= nbit;
    else
      self->regSR &= ~nbit;
  }
  
  [self CPUAddCycles: [self getDivs68kCycles: (unsigned long) self->dest: (unsigned short) self->source] ];
  return SUCCESS;
}


//------------------------------------------------
// DIVU <ea>,Dn
// Destination / Source --> Destination
// Size = Word
// Divide the destination operand by the source operand and store the result
// in the destination. The destination operand is a long operand (32 bits) and
// the source operand is a word (16 bit) operand. The operation is performed
// using unsigned arithmetic. The result is a 32-bit result such that:
//   1. The quotient is in the lower word (least significant 16 bits)
//   2. The remainder is in the upper word (most significant 16 bits)
// Two special condition may arise:
//   1. Division by zero causes a trap
//   2. Overflow may be detected and set before completion of the instruction.
//      If overflow is detected, the condition is flagged but the operands
//      are unaffected.
-(int) DIVU
{
  int reg;

	int error = [self eff_addr: (long)WORD_MASK: DATA_ADDR: true];
  if (error)              // if address error
    return error;         // return error code

  reg = (self->regInstruction >> 9) & 0x0007;

  self->source = self->regEV1 & WORD_MASK;
  self->dest = self->regD[reg];

  if (self->source == 0)
    return (DIV_BY_ZERO);		// initiate exception processing

  if ( ((unsigned)self->dest / self->source) > WORD_MASK)
    self->regSR |= vbit; 		        // check for overflow
  else {
    self->regSR &= ~vbit;
    
  self->regD[reg] = self->regResult =(((unsigned)self->dest / self->source) & 0xffff) |
                      (((unsigned)self->dest % self->source) * 0x10000);
	  [self cc_update: N_A: GEN: GEN: N_A: ZER: self->source: self->dest: self->regResult: (long) WORD_MASK: 0];
  }

	[self CPUAddCycles: [self getDivu68kCycles: (unsigned long)self->dest: (unsigned short)self->source]];
  return SUCCESS;
}


//------------------------------------------------
-(int) MULS {
	int	reg;

	int error = [self eff_addr: (long)WORD_MASK: DATA_ADDR: true];
  if (error)              // if address error
    return error;         // return error code

  reg = (self->regInstruction >> 9) & 0x0007;

				 [self from_2s_comp: self->regEV1 & WORD_MASK: (long) WORD_MASK: &self->source];
				 [self from_2s_comp: self->regD[reg] & WORD_MASK: (long) WORD_MASK: &self->dest];

  self->regD[reg] = self->regResult = self->source * self->dest;

	[self cc_update: N_A: GEN: GEN: CASE_9: ZER: self->source: self->dest: self->regResult: (long) LONG_MASK: 0];  // ck 8-10-2005

  // timing 38 + 2n clocks where n is
  // concatanate the <ea> with a zero as the LSB; n is the resultant number of
  // 10 or 01 patterns in the 17-bit self->source
  int s17 = self->source & 0x0FFFF;
  int n = 0, m = 0;
  for (int i=0; i<16; i++) {
    if ((s17 & 1) != m) {
      n++;
      i++;
      s17 = s17 >> 1;
      m = s17 & 1;
    }
    s17 = s17 >> 1;
  }
  [self CPUAddCycles: 38 + (2*n)];

  return SUCCESS;

}
//------------------------------------------------
-(int) MULU
{
  int	reg;

	int error = [self eff_addr: (long)WORD_MASK: DATA_ADDR: true];
  if (error)              // if address error
    return error;         // return error code

  reg = (self->regInstruction >> 9) & 0x0007;

  self->source = self->regEV1 & WORD_MASK;
  self->dest = self->regD[reg] & WORD_MASK;

  self->regD[reg] = self->regResult = self->source * self->dest;

	[self cc_update: N_A: GEN: GEN: ZER: ZER: self->source: self->dest: self->regResult: LONG_MASK: 0];

  // timing 38 + 2n clocks where n is
  // the number of ones in the self->source
  int s17 = self->source & 0x0FFFF;
  int n = 0;
  for (int i=0; i<16; i++) {
    if ((s17 & 1))
      n++;
    s17 = s17 >> 1;
  }
  [self CPUAddCycles: 38 + (2*n)];

  return SUCCESS;

}
//------------------------------------------------
-(int) NEG
{
long	size;

if ([self decode_size: &size])
  return (BAD_INST);	 // bad instruction format

	int error = [self eff_addr: size: DATA_ALT_ADDR: true];
if (error)              // if address error
  return error;         // return error code

self->source = self->dest = self->regEV1 & size;

/* perform the NEG operation */
	[self put: self->regEA1: -self->dest: size];
	[self value_of: self->regEA1: &self->regResult: size];

 [self cc_update: GEN: GEN: GEN: CASE_3: CASE_4: self->source: self->dest: self->regResult: size: 0];

if (self->regInstruction & 0x0030)
	[self CPUAddCycles: (size == LONG_MASK) ? 12 : 8];
else 
	[self CPUAddCycles: (size == LONG_MASK) ? 6 : 4];

return SUCCESS;

}
//------------------------------------------------
-(int) NEGX {
	
	long	size;

	if ([self decode_size: &size])
		return (BAD_INST);  	// bad instruction format

	int error = [self eff_addr: size: DATA_ALT_ADDR: true];
	if (error)              // if address error
		return error;         // return error code

	self->dest = self->dest = self->regEV1 & size;

/* perform the NEGX operation */
	[self put: self->regEA1: -self->dest - ((self->regSR & xbit) >> 4): size];
	[self value_of: self->regEA1: &self->regResult: size];

	[self cc_update: GEN: GEN: CASE_1: CASE_3: CASE_4: self->source: self->dest: self->regResult: size: 0];

if (self->regInstruction & 0x0030) {
	[self CPUAddCycles: (size == LONG_MASK) ? 12 : 8];
	}
else {
	[self CPUAddCycles: (size == LONG_MASK) ? 6 : 4];
	}

return SUCCESS;

}
//------------------------------------------------
-(int) CMP {
long	size;
int	reg;

if ([self decode_size: &size])
  return (BAD_INST);	// bad instruction format

	int error = [self eff_addr: size: ALL_ADDR: true];
if (error)              // if address error
  return error;         // return error code

reg = (self->regInstruction >> 9) & 0x0007;

self->source = self->regEV1 & size;
self->dest = self->regD[reg] & size;

	[self put: &self->regResult: self->dest - self->source: size];

/* now set the condition codes */
	[self cc_update: N_A: GEN: GEN: CASE_2: CASE_6: self->source: self->dest: self->regResult: size: 0];

[self CPUAddCycles:  (size == LONG_MASK) ? 6 : 4];

return SUCCESS;

}

//------------------------------------------------
-(int)	CMPA
{
	long	size;
	int	reg;

	if (self->regInstruction & 0x0100)
		size = LONG_MASK;
	else
		size = WORD_MASK;

	int error = [self eff_addr: size: ALL_ADDR: true];
	if (error)              // if address error
	  return error;         // return error code

	reg = [self a_reg: (self->regInstruction >> 9) & 0x0007];

	if (size == WORD_MASK)
		self->regEV1 = [self sign_extend: (int)self->regEV1: WORD_MASK ];

	self->source = self->regEV1;
	self->dest = self->regA[reg];
	[self put: &self->regResult: self->dest - self->source: LONG_MASK];

	/* now set the condition codes according to the self->regResult */
	[self cc_update: N_A: GEN: GEN: CASE_2: CASE_6: self->source: self->dest: self->regResult: LONG_MASK: 0];

	[self CPUAddCycles: 6];

	return SUCCESS;
}

//------------------------------------------------
-(int) CMPI
{
	long	size;

	if ([self decode_size: &size])
		return (BAD_INST);	   // bad instruction format

	[self mem_request: &self->regPC: size: &self->source];

	int error = [self eff_addr: size: DATA_ALT_ADDR: true];
	if (error)              // if address error
		return error;         // return error code

	self->dest = self->regEV1 & size;

	[self put: &self->regResult: self->dest - self->source: size];

	[self cc_update: N_A: GEN: GEN: CASE_2: CASE_6: self->source: self->dest: self->regResult: size: 0];

	if (self->regInstruction & 0x0038) {
		[self CPUAddCycles: (size == LONG_MASK) ? 12 : 8];
	}
	else {
		[self CPUAddCycles: (size == LONG_MASK) ? 14 : 8];
	}

	return SUCCESS;
}


//------------------------------------------------
-(int) CMPM
{
	long	size;
	int	Rx, Ry;


	if ([self decode_size: &size]) 
	  return (BAD_INST);

	Rx = [self a_reg: (self->regInstruction >> 9) & 0x07 ];
	Ry = [self a_reg: self->regInstruction & 0x07 ];

	[self mem_req: (int) self->regA[Ry]: size: &self->source];
	[self mem_req: (int) self->regA[Rx]: size: &self->dest];

	[self put: &self->regResult: self->dest - self->source: size];

	if (size == BYTE_MASK) {
		self->regA[Rx]++;
		self->regA[Ry]++;
	}
	if (size == WORD_MASK) {
		self->regA[Rx] += 2;
		self->regA[Ry] += 2;
	}
	if (size == LONG_MASK) {
		self->regA[Rx] += 4;
		self->regA[Ry] += 4;
	}

	/* now set the condition codes according to the result */
	[self cc_update: N_A: GEN: GEN: CASE_2: CASE_6: self->source: self->dest: self->regResult: size: 0 ];

	[self CPUAddCycles: (size == LONG_MASK) ? 20 : 12 ];

	return SUCCESS;
}



//------------------------------------------------
-(int) TST
{
	long	size;

	if ([self decode_size: &size] )
		return (BAD_INST);    // bad instruction format

	int error = [self eff_addr: size: DATA_ALT_ADDR: true ];
	if (error)              // if address error
		return error;         // return error code

	[self value_of: self->regEA1: &self->dest: size];

	/* test the self->dest operand and set the condition codes accordingly */
	[self cc_update: N_A: GEN: GEN: ZER: ZER: self->source: self->dest: self->dest: size: 0];

	if (self->regInstruction & 0x0030) {
		[self CPUAddCycles: (size == LONG_MASK) ? 4 : 4];
	}
	else {
		[self CPUAddCycles: (size == LONG_MASK) ? 4 : 4];
	}

	return SUCCESS;
}


//------------------------------------------------
-(int) CLR
{
	long	size;

	if ([self decode_size: &size])
		return (BAD_INST);							// bad instruction format

	int error = [self eff_addr: size: DATA_ALT_ADDR: true ];
	if (error)										// if address error
		return error;								// return error code

	self->source = self->dest = self->regEV1 & size;

	/* perform the CLR operation */
	[self put: self->regEA1: (long) 0: size];
	[self value_of: self->regEA1: &self->regResult: size ];

	[self cc_update: N_A: ZER: GEN: ZER: ZER: self->source: self->dest: self->regResult: size: 0];

	if (self->regInstruction & 0x0030) {
		[self CPUAddCycles: (size == LONG_MASK) ? 12 : 8];
	}
	else {
		[self CPUAddCycles: (size == LONG_MASK) ? 6 : 4];
	}

	return SUCCESS;

}
//------------------------------------------------
-(int) EXT
{
	long	size;
	int	reg;

	reg = self->regInstruction & 0x07;

	if (self->regInstruction & 0x0040)
		size = LONG_MASK;
	else
		size = WORD_MASK;

	self->source = self->dest = self->regD[reg] & size;

	if (size == WORD_MASK)
		self->regD[reg] = (self->regD[reg]&~WORD_MASK) | (self->regD[reg] & BYTE_MASK) | (0xff00 * ((self->regD[reg]>>7) & 0x01));
	else
		self->regD[reg] = (self->regD[reg] & WORD_MASK) | (0xffff0000 * ((self->regD[reg] >> 15) & 0x01));

	[self cc_update: N_A: GEN: GEN: ZER: ZER: self->source: self->dest: self->regD[reg]: size: 0];

	[self CPUAddCycles: 4];

	return SUCCESS;
}
//----------------------------------------------------------------------------
//	Instructions from CODE5.cpp
//----------------------------------------------------------------------------
-(int)	ABCD {

	int		Rx, Ry, carry, temp_result;

	Rx = (self->regInstruction >> 9) & 0x0007;
	Ry = self->regInstruction & 0x0007;

  if (self->regInstruction & 0x0008)	// Rx & Ry are address registers used in predecrement mode
  {
    Rx = [self a_reg: Rx];
    Ry = [self a_reg: Ry];
    self->regA[Rx]--;
    self->regA[Ry]--;
    
	  [self mem_req: (int)self->regA[Ry]: BYTE_MASK: &self->source ];	// cause bus error on bad access
	  [self mem_req: (int)self->regA[Rx]: BYTE_MASK: &self->dest ];

  }
  else		// Rx & Ry are data registers
  {
    self->source = self->regD[Ry] & BYTE_MASK;
    self->dest = self->regD[Rx] & BYTE_MASK;
  }

  // perform the ABCD operation
self->regResult = ((self->regSR & xbit) >> 4) + (self->source & 0xf) + (self->dest & 0xf);
  if (self->regResult > 9)
  {
    self->regResult = self->regResult - 10;
    carry = 1;
  }
  else
    carry = 0;
  temp_result = ((self->source >> 4) & 0xf) + ((self->dest >> 4) & 0xf) + carry;
  if (temp_result > 9)
  {
    temp_result = temp_result - 10;
    carry = 1;
  }
  else
    carry = 0;

  self->regResult = self->regResult + (temp_result << 4);

  if (self->regInstruction & 0x0008)
    [self put: (long *)&memory[self->regA[Rx]]: self->regResult: (long) BYTE_MASK];
  else
    [self put: &self->regD[Rx]: self->regResult: (long) BYTE_MASK];
    
  if (carry)
    self->regSR = self->regSR | cbit;
  else
    self->regSR = self->regSR & ~cbit;

  [self cc_update: GEN: UND: CASE_1: UND: N_A: self->source: self->dest: self->regResult: (long) BYTE_MASK: 0];

  [self CPUAddCycles: ( (self->regInstruction & 0x0008) ? 18 : 6) ];

  return SUCCESS;
}
//-------------------------------------------------------
// perform the SUB operation
-(int) 	SBCD {

  int	Rx, Ry, borrow, temp_result;

  Rx = (self->regInstruction >> 9) & 0x0007;
  Ry = self->regInstruction & 0x0007;

  if (self->regInstruction & 0x0008) //Rx & Ry are address registers used in predecrement mode
  {
    Rx = [self a_reg: Rx];
    Ry = [self a_reg: Ry];
    self->regA[Rx]--;
    self->regA[Ry]--;

    [self mem_req: (int)self->regA[Ry]: BYTE_MASK: &self->source];		// cause bus error on bad access
    [self mem_req: (int)self->regA[Rx]: BYTE_MASK: &self->dest];

  }
  else
  {		        // Rx & Ry are data registers
    self->source = self->regD[Ry];
    self->dest = self->regD[Rx];
  }

  // perform the SBCD operation
  self->regResult = (self->dest & 0xf) - (self->source & 0xf) - ((self->regSR & xbit) >> 4);
  if (self->regResult < 0)
  {
    self->regResult = self->regResult + 10;
    borrow = 1;
  }
  else
    borrow = 0;
  temp_result = ((self->dest >> 4) & 0xf) - ((self->source >> 4) & 0xf) - borrow;
  if (temp_result < 0)
  {
    temp_result = temp_result + 10;
    borrow = 1;
  }
  else
    borrow = 0;
  self->regResult = self->regResult + (temp_result << 4);

  if (self->regInstruction & 0x0008)
    [self put: (long *)&memory[self->regA[Rx]]: self->regResult: (long) BYTE_MASK ];
  else
    [self put: &self->regD[Rx]: self->regResult: (long) BYTE_MASK ];

  if (borrow)
    self->regSR = self->regSR | cbit;
  else
    self->regSR = self->regSR & ~cbit;

  [self cc_update: GEN: UND: CASE_1: UND: N_A: self->source: self->dest: self->regResult: (long) BYTE_MASK: 0];

  [self CPUAddCycles: ( (self->regInstruction & 0x0008) ? 18 : 6) ];

  return SUCCESS;
}
//-------------------------------------------------------
// perform the NBCD operation
-(int) 	NBCD {

	int	borrow, temp_result;
	
	int error = [self eff_addr: (long)BYTE_MASK: DATA_ALT_ADDR: true];
	if (error)													// if address error
	return error;												// return error code

	self->dest = self->regEV1 & BYTE_MASK;

	self->regResult = 10 - (self->dest & 0xf) - ((self->regSR & xbit) >> 4);
	if (self->regResult < 10) {
		borrow = 1;
	}
	else {														// self->dest was 0 so 0-0 result should be 0 ck 8-10-2005
		borrow = 0;
		self->regResult = 0;
	}

	temp_result = 10 - ((self->dest >> 4) & 0xf) - borrow;
	if (temp_result < 10) {
		borrow = 1;
	}
	else {														// self->dest was 0 so 0-0 result should be 0 ck 8-10-2005
		borrow = 0;
		temp_result = 0;
	}

	self->regResult = self->regResult + (temp_result << 4);

	if (borrow)
		self->regSR = self->regSR | cbit;
	else
		self->regSR = self->regSR & ~cbit;

	[self put: self->regEA1: self->regResult: (long) BYTE_MASK];
	[self cc_update: GEN: UND: CASE_1: UND: N_A: self->source: self->dest: self->regResult: (long) BYTE_MASK: 0];

	[self CPUAddCycles: (self->regInstruction & 0x0030) ? 8 : 6 ];

	return SUCCESS;
}
//----------------------------------------------------------------------------
//	Instructions from CODE6.cpp
//----------------------------------------------------------------------------
-(int) 	AND {
		
	int	addr_modes_mask, reg;
	long	size;

	addr_modes_mask = (self->regInstruction & 0x0100) ? MEM_ALT_ADDR : DATA_ADDR;

	if ([self decode_size: &size])
	  return (BAD_INST);	// bad instruction format

		int error = [self eff_addr: size: addr_modes_mask: true];
	if (error)              // if address error
	  return error;         // return error code

	reg = (self->regInstruction >> 9) & 0x0007;

	if (self->regInstruction & 0x0100)
		{
		self->source = self->regD[reg] & size;
		self->dest = self->regEV1 & size;
		[self put: self->regEA1: self->dest & self->source: size];
		[self value_of: self->regEA1: &self->regResult: size];
		}
	else
		{
		self->source = self->regEV1 & size;
		self->dest = self->regD[reg] & size;
		[self put: &self->regD[reg]: self->dest & self->source: size];
		self->regResult = self->regD[reg] & size;
		}

	[self cc_update: N_A: GEN: GEN: ZER: ZER: self->source: self->dest: self->regResult: size: 0];

	if (self->regInstruction & 0x0100) 
		[self CPUAddCycles: (size == LONG_MASK) ? 12 : 8];
	else {
		if (size == LONG_MASK) {
			if ( (!(self->regInstruction & 0x0030)) || ((self->regInstruction & 0x003f) == 0x003c) )
				[self CPUAddCycles: 8];
			else
				[self CPUAddCycles: 6];
			}
		else {
			[self CPUAddCycles: 4];
			}
		}

	return SUCCESS;

}
//----------------------------------------------------------------------------
-(int) 	ANDI
{
	long	size;

	if ([self decode_size: &size])
	  return (BAD_INST);			/* bad instruction format */

	[self mem_request: &self->regPC: size: &self->source];

	int error = [self eff_addr: size: DATA_ALT_ADDR: true];
	if (error)              // if address error
	  return error;         // return error code

	self->dest = self->regEV1 & size;

	[self put: self->regEA1: self->source & self->dest: size];
	[self value_of: self->regEA1: &self->regResult: size];

	[self cc_update: N_A: GEN: GEN: ZER: ZER: self->source: self->dest: self->regResult: size: 0];

	if (self->regInstruction & 0x0038)
		[self CPUAddCycles: (size == LONG_MASK) ? 20 : 12];
	else
		[self CPUAddCycles: (size == LONG_MASK) ? 16 : 8];

	return SUCCESS;

}
//----------------------------------------------------------------------------
-(int)	ANDI_TO_CCR
{
	long	temp;

	[self mem_request: &self->regPC: (long) WORD_MASK: &temp];

	self->regSR &= temp | 0xff00;

	[self CPUAddCycles: 20];

	return SUCCESS;

}
//----------------------------------------------------------------------------
-(int)	ANDI_TO_SR
{
	long	temp;

	if (!(self->regSR & sbit))
		return (NO_PRIVILEGE);

	[self mem_request: &self->regPC: (long) WORD_MASK: &temp];
	self->regSR &= temp;

	[self CPUAddCycles: 20];

	return SUCCESS;

}
//----------------------------------------------------------------------------
-(int) 	OR
{
	long	size;
	int	mask, reg;

	mask = (self->regInstruction & 0x0100) ? MEM_ALT_ADDR : DATA_ADDR;

	if ([self decode_size: &size])
	  return (BAD_INST);	// bad instruction format

		int error = [self eff_addr: size: mask: true];
	if (error)              // if address error
	  return error;         // return error code

	reg = (self->regInstruction >> 9) & 0x0007;

	if (self->regInstruction & 0x0100)
		{
		 self->source = self->regD[reg] & size;
		self->dest = self->regEV1 & size;
		[self put: self->regEA1: self->source | self->dest: size];
		[self value_of: self->regEA1: &self->regResult: size];
		}
	else
		{
		self->source = self->regEV1 & size;
		self->dest = self->regD[reg] & size;
			[self put: &self->regD[reg]: self->source | self->dest: size];
		self->regResult = self->regD[reg] & size;
		}

	[self cc_update: N_A: GEN: GEN: ZER: ZER: self->source: self->dest: self->regResult: size: 0];

	if (self->regInstruction & 0x0100) 
		[self CPUAddCycles: (size == LONG_MASK) ? 12 : 8];
	else {
		if (size == LONG_MASK) {
			if ( (!(self->regInstruction & 0x0030)) || ((self->regInstruction & 0x003f) == 0x003c) )
				[self CPUAddCycles: 8];
			else
				[self CPUAddCycles: 6];
			}
		else 
			[self CPUAddCycles: 4];
		}

	return SUCCESS;

}
//---------------------------------------------------------------------------
-(int) ORI
{
  long	size;
  int error;


  if ([self decode_size: &size])
    return (BAD_INST);			// bad instruction format

	  [self mem_request: &self->regPC: size: &self->source];

  error = [self eff_addr: size: DATA_ALT_ADDR: true];
  if (error)
    return (error);			// return error code

  self->dest = self->regEV1 & size;

   [self put: self->regEA1: self->source | self->dest: size];
   [self value_of: self->regEA1: &self->regResult: size];

  [self cc_update: N_A: GEN: GEN: ZER: ZER: self->source: self->dest: self->regResult: size: 0];

  if (self->regInstruction & 0x0038) {
          [self CPUAddCycles: (size == LONG_MASK) ? 20 : 12];
          }
  else {
          [self CPUAddCycles: (size == LONG_MASK) ? 16 : 8];
          }

  return SUCCESS;

}
//----------------------------------------------------------------------------
-(int) ORI_TO_CCR
{
	long	temp;

	[self mem_request: &self->regPC: (long) WORD_MASK: &temp];

	self->regSR |= temp;

	[self CPUAddCycles: 20];

	return SUCCESS;

}
//----------------------------------------------------------------------------
-(int) ORI_TO_SR
{
	long	temp;

	if (!(self->regSR & sbit))
		return (NO_PRIVILEGE);

	[self mem_request: &self->regPC: (long) WORD_MASK: &temp];
	self->regSR |= temp;

	[self CPUAddCycles: 20];

	return SUCCESS;

}
//----------------------------------------------------------------------------
-(int) EOR
{
	long	size;
	int	reg;


	if ([self decode_size: &size])
	  return (BAD_INST);	// bad instruction format

	int error = [self eff_addr: size: DATA_ALT_ADDR: true];
	if (error)              // if address error
	  return error;         // return error code

	reg = (self->regInstruction >> 9) & 0x0007;

	self->source = self->regD[reg] & size;
	self->dest = self->regEV1 & size;

	[self put: self->regEA1: self->regEV1 ^ self->regD[reg]: size];
	[self value_of: self->regEA1: &self->regResult: size];

	[self cc_update: N_A: GEN: GEN: ZER: ZER: self->source: self->dest: self->regResult: size: 0];

	if (self->regInstruction & 0x0038)
		[self CPUAddCycles: (size == LONG_MASK) ? 12 : 8];
	else
		[self CPUAddCycles: (size == LONG_MASK) ? 8 : 4];

	return SUCCESS;

}
//----------------------------------------------------------------------------
-(int) EORI
{
	long	size;

	if ([self decode_size: &size])
	  return (BAD_INST);	       // bad instruction format

	[self mem_request: &self->regPC: size: &self->source];

	int error = [self eff_addr: size: DATA_ALT_ADDR: true ];
	if (error)              // if address error
	  return error;         // return error code

	self->dest = self->regEV1 & size;

	[self put: self->regEA1: self->source ^ self->dest: size];
	 [self value_of: self->regEA1: &self->regResult: size];

	[self cc_update: N_A: GEN: GEN: ZER: ZER: self->source: self->dest: self->regResult: size: 0];

	if (self->regInstruction & 0x0038) {
		[self CPUAddCycles: (size == LONG_MASK) ? 20 : 12];
		}
	else {
		[self CPUAddCycles: (size == LONG_MASK) ? 16 : 8];
		}

	return SUCCESS;

}
//----------------------------------------------------------------------------
-(int) 	EORI_TO_CCR
{
	long	temp;

	[self mem_request: &self->regPC: (long) WORD_MASK: &temp];

	self->regSR ^= temp;

	[self CPUAddCycles: 20];

	return SUCCESS;
}
//----------------------------------------------------------------------------
-(int) 	EORI_TO_SR
{
	long	temp;

	if (!(self->regSR & sbit))
		return (NO_PRIVILEGE);

	[self mem_request: &self->regPC: (long) WORD_MASK: &temp];
	self->regSR ^= temp;

	[self CPUAddCycles: 20];

	return SUCCESS;
}
//----------------------------------------------------------------------------
-(int) 	NOT
{
	long	size;

	if ([self decode_size: &size])
	  return (BAD_INST);	// bad instruction format

	int error = [self eff_addr: size: DATA_ALT_ADDR: true ];
	if (error)              // if address error
	  return error;         // return error code

	self->source = self->dest = self->regEV1 & size;

	/* perform the NOT operation */
	[self put: self->regEA1: ~self->dest: size];
	[self value_of: self->regEA1: &self->regResult: size];

	[self cc_update: N_A: GEN: GEN: ZER: ZER: self->source: self->dest: self->regResult: size: 0];

	if (self->regInstruction & 0x0030) {
		[self CPUAddCycles: (size == LONG_MASK) ? 12 : 8];
		}
	else {
		[self CPUAddCycles: (size == LONG_MASK) ? 6 : 4];
		}

	return SUCCESS;

}
//----------------------------------------------------------------------------
//	Instructions from CODE7.cpp
//----------------------------------------------------------------------------

-(int) 	SHIFT_ROT
{
  long	size;
  int	reg, shift_count, shift_result, shift_size, type, counter;
  int	direction, temp_bit, temp_bit_2;

  if ((self->regInstruction & 0xc0) == 0xc0) {
	  int error = [self eff_addr: (long)WORD_MASK: MEM_ALT_ADDR: true];
    if (error)              // if address error
      return error;         // return error code

    size = WORD_MASK;
    shift_count = 1;
    self->source = self->dest = self->regEV1 & size;
    type = (self->regInstruction & 0x600) >> 9;
    [self CPUAddCycles: 8];
  } else {
    if ([self decode_size: &size])
      return (BAD_INST);                // bad instruction format
    if (self->regInstruction & 0x20)
       shift_count = (unsigned int)((self->regD[ (self->regInstruction >> 9) & 0x7] ) & size) % 64;
    else {
      shift_count = (self->regInstruction >> 9) & 0x7;
      if (shift_count == 0)
	shift_count = 8;
    }
    reg = self->regInstruction & 7;
    self->source = self->dest = self->regD[reg] & size;
    type = (self->regInstruction & 0x18) >> 3;
    self->regEA1 = &self->regD[reg];
		[self value_of: self->regEA1: &self->regEV1: size];
    if (size == LONG_MASK)
      [self CPUAddCycles: 8 + 2 * shift_count];
    else
      [self CPUAddCycles: 6 + 2 * shift_count];
  }
  direction = self->regInstruction & 0x100;
  if (size == LONG_MASK)
    shift_size = 31;
  else if (size == WORD_MASK)
    shift_size = 15;
  else
    shift_size = 7;

  if (shift_count == 0)	{               // if shift count is 0
    if (type == 2)                      // if ROXL or ROXR
      [self cc_update: N_A: GEN: GEN: ZER: CASE_1: self->source: self->dest: self->regEV1: size: shift_count];
    else                                // all others
      [self cc_update: N_A: GEN: GEN: ZER: ZER: self->source: self->dest: self->regEV1: size: shift_count];
  }
  else                                  // else shift count NOT zero
    switch (type) {
      case 0 :                          // do an arithmetic shift
	if (direction) {		// do a shift left
          if (shift_count >= 32)        // 68000 does modulo 64 shift, c++ does modulo 32
            shift_result = 0;
          else
            shift_result = (self->regEV1 & size) << shift_count;
	  [self put: self->regEA1: shift_result: size];
	  [self value_of: self->regEA1: &self->regEV1: size];
	  [self cc_update: GEN: GEN: GEN: CASE_4: CASE_3: self->source: self->dest: self->regEV1: size: shift_count];
	} else {                        // do a shift right
	  // do the shift replicating the most significant bit
	  if ((self->regEV1 >> shift_size) & 1)
	    temp_bit = 1;
	  else
	    temp_bit = 0;
	  for (counter = 1; counter <= shift_count; counter++) {
	    [self put: self->regEA1: (self->regEV1 & size) >> 1: size];
	    [self value_of: self->regEA1: &self->regEV1: size];
	    if (temp_bit)
	      [self put: self->regEA1: self->regEV1 | (1 << shift_size): size];
	    else
	      [self put: self->regEA1: self->regEV1 & (~(1 << shift_size)): size];
	    [self value_of: self->regEA1: &self->regEV1: size];
	  }
	  [self cc_update: GEN: GEN: GEN: ZER: CASE_7: self->source: self->dest: self->regEV1: size: shift_count];
	}
        break;
      case 1 :                          // do a logical shift
	if (direction) {		// do a shift left
          if (shift_count >= 32)        // 68000 does modulo 64 shift, c++ does modulo 32
            shift_result = 0;
          else
            shift_result = self->regEV1 << shift_count;
	  [self put: self->regEA1: shift_result: size];
	  [self value_of: self->regEA1: &self->regEV1: size];
	  [self cc_update: GEN: GEN: GEN: ZER: CASE_3:self->source: self->dest: self->regEV1: size: shift_count];
	} else {		        // do a shift right
          if (shift_count >= 32)        // 68000 does modulo 64 shift, c++ does modulo 32
            shift_result = 0;
          else
            shift_result = (unsigned)(self->regEV1 & size) >> shift_count;
	  [self put: self->regEA1: shift_result: size];
	  [self value_of: self->regEA1: &self->regEV1: size];
	  [self cc_update: GEN: GEN: GEN: ZER: CASE_2:self->source: self->dest: self->regEV1: size: shift_count];
	}
        break;
      case 2 :                          // do a rotate with extend
	if (direction) {		// do a rotate left
	  for (counter = 1; counter <= shift_count; counter++) {
	    temp_bit = (self->regEV1 >> shift_size) & 1;
	    temp_bit_2 = (self->regSR & xbit) >> 4;
	    [self put: self->regEA1: (self->regEV1 & size) << 1: size];
	    [self value_of: self->regEA1: &self->regEV1: size];
	    if (temp_bit_2)
	      [self put: self->regEA1: self->regEV1 | 1: size];
	    else
	      [self put: self->regEA1: self->regEV1 & ~1: size];
	    [self value_of: self->regEA1: &self->regEV1: size];
	    if (temp_bit)
	      self->regSR = self->regSR | xbit;
	    else
	      self->regSR = self->regSR & ~xbit;
	  }
	  [self cc_update: GEN: GEN: GEN: ZER: CASE_3: self->source: self->dest: self->regEV1: size: shift_count];
	} else {                        // do a rotate right
	  for (counter = 1; counter <= shift_count; counter++) {
	    temp_bit = self->regEV1 & 1;
	    temp_bit_2 = (self->regSR & xbit) >> 4;
	    [self put: self->regEA1: (self->regEV1 & size) >> 1: size];
	    [self value_of: self->regEA1: &self->regEV1: size];
	    if (temp_bit_2)
	      [self put: self->regEA1: self->regEV1 | (1 << shift_size): size];
	    else
	      [self put: self->regEA1: self->regEV1 & (~(1 << shift_size)): size];
		  [self value_of: self->regEA1: &self->regEV1: size];
	    if (temp_bit)
	      self->regSR = self->regSR | xbit;
	    else
	      self->regSR = self->regSR & ~xbit;
	  }
	  [self put: self->regEA1: self->regEV1: size];
	  [self cc_update: GEN: GEN: GEN: ZER: CASE_2: self->source: self->dest: self->regEV1: size: shift_count];
	}
        break;
      case 3 : 	                        // do a rotate
	if (direction) {		// do a rotate left
	  for (counter = 1; counter <= shift_count; counter++) {
	    temp_bit = (self->regEV1 >> shift_size) & 1;
	    [self put: self->regEA1: (self->regEV1 & size) << 1: size];
	    [self value_of: self->regEA1: &self->regEV1: size];
	    if (temp_bit)
	      [self put: self->regEA1: self->regEV1 | 1: size];
	    else
	      [self put: self->regEA1: self->regEV1 & ~1: size];
	    [self value_of: self->regEA1: &self->regEV1: size];
	  }
	  [self cc_update: N_A: GEN: GEN: ZER: CASE_3: self->source: self->dest: self->regEV1: size: shift_count];
	} else {		        // do a rotate right
	  for (counter = 1; counter <= shift_count; counter++) {
	    temp_bit = self->regEV1 & 1;
	    [self put: self->regEA1: (self->regEV1 & size) >> 1: size];
	    [self value_of: self->regEA1: &self->regEV1: size];
	    if (temp_bit)
	      [self put: self->regEA1: self->regEV1 | (1 << shift_size): size];
	    else
	      [self put: self->regEA1: self->regEV1 & (~(1 << shift_size)): size];
	    [self value_of: self->regEA1: &self->regEV1: size];
	  }
	  [self cc_update: N_A: GEN: GEN: ZER: CASE_2: self->source: self->dest: self->regEV1: size: shift_count];
	}
        break;
    }

  return SUCCESS;
}


//-------------------------------------------------------------------------
-(int) 	SWAP
{
	long	reg;

	reg = self->regInstruction & 0x07;

	/* perform the SWAP operation */
	self->regD[reg] = ((self->regD[reg] & WORD_MASK) * 0x10000) | ((self->regD[reg] & 0xffff0000) / 0x10000);

	[self cc_update: N_A: GEN: GEN: ZER: ZER: self->source: self->dest: self->regD[reg]: LONG_MASK: 0];

	[self CPUAddCycles: 4];

	return SUCCESS;

}

//----------------------------------------------------------------------------
// BIT_OP (BCHG, BCLR, BSET, BTST)
-(int) 	BIT_OP
{
  int	mem_reg;
  long	size, bit_no;

  if (self->regInstruction & 0x100)
    bit_no = self->regD[(self->regInstruction >> 9) & 0x07];
  else	{
	  [self mem_request:  &self->regPC: (long) WORD_MASK: &bit_no];
    bit_no = bit_no & 0xff;
  }

  mem_reg = (self->regInstruction & 0x38);

  if (mem_reg) {
    bit_no = bit_no % 8;
    size = BYTE_MASK;
  } else {
    bit_no = bit_no % 32;
    size = LONG_MASK;
  }

	int error = [self eff_addr: size: DATA_ADDR: true];
  if (error)              // if address error
    return error;         // return error code


  if ((self->regEV1 >> bit_no) & 1)
    self->regSR = self->regSR & (~zbit);
  else
    self->regSR = self->regSR | zbit;

  switch ((self->regInstruction >> 6) & 0x3) {
    case 0 : 			/* perform a bit test operation */
      if (mem_reg)
	[self CPUAddCycles: 4];
      else
	[self CPUAddCycles: 6];
      break;
    case 1 : 			/* perform a bit change operation */
      if ((self->regEV1 >> bit_no) & 1)
	[self put: self->regEA1: *self->regEA1 & (~(1 << bit_no)): size];
      else
	[self put: self->regEA1: *self->regEA1 | (1 << bit_no): size];
	[self CPUAddCycles: 8];
      break;
    case 2 : /* perform a bit clear operation */
      [self put: self->regEA1: *self->regEA1 & (~(1 << bit_no)): size];
      if (mem_reg)
	[self CPUAddCycles: 8];
      else
	[self CPUAddCycles: 10];
      break;
    case 3 : /* perform a bit set operation */
      [self put: self->regEA1: *self->regEA1 | (1 << bit_no): size];
      [self CPUAddCycles: 8];
      break;
  }

  if (mem_reg)
    [self CPUAddCycles: 4];

  return SUCCESS;
}
//--------------------------------------------------------------------------
-(int) 	TAS
{
  int error = [self eff_addr: (long)BYTE_MASK: DATA_ALT_ADDR: true];
  if (error)              // if address error
    return error;         // return error code

  /* perform the TAS operation */
  /* first set the condition codes according to *EA1 */
  [self cc_update: N_A: GEN: GEN: ZER: ZER: self->source: self->dest: *self->regEA1: (long) BYTE_MASK: 0];

  /* then set the high order bit of the *self->regEA1 byte */
  [self put: self->regEA1: self->regEV1 | 0x80: (long) BYTE_MASK];

  [self CPUAddCycles: (self->regInstruction & 0x30) ? 10 : 4];

  return SUCCESS;
}

//--------------------------------------------------------------------------
// Simulates the bit field instructions. This code is patterned after the
// 68020 simulator code used in the UAE (Unix Amiga Emulator)
#define BFTST 0
#define BFEXTU  1
#define BFCHG  2
#define BFEXTS  3
#define BFCLR  4
#define BFFF0  5
#define BFSET  6
#define BFINS  7
-(int)	BIT_FIELD
{
  long	extra, bf0, bf1, bf2, bf3, bf4;
  int width, destAddr, error = SUCCESS;
  int x_bit, n_bit, z_bit, v_bit, c_bit;
  uint offset, tmp;
  int countCycles;

  if (!bitfield)                        // if bit field instructions not enabled
    return (BAD_INST);                  // bad instruction format

  [self mem_request: &self->regPC: (long) WORD_MASK: &extra];
  if (extra & 0x800)
    offset = self->regD[(extra >> 6) & 0x07];
  else
    offset = (extra >> 6) & 0x1f;

  if (extra & 0x20)
    width = ((self->regD[(extra & 7)] -1) & 0x1f) + 1;
  else
    width = ((extra - 1) & 0x1f) + 1;

  if ((self->regInstruction & 0x0038) == 0) {    // if Mode 000
    tmp = self->regD[self->regInstruction & 7] << (offset & 0x1f);
    countCycles = 7;
  } else {
	  error = [self eff_addr: (long)BYTE_MASK: CONTROL_ADDR: true];
    if (error)              // if address error
      return error;         // return error code
    destAddr = (long) ( (long)self->regEA1 - (long)&memory[0]);  // destination address
    destAddr += (offset >> 3) | (offset & 0x80000000 ? ~0x1fffffff : 0);  // add offset
    error = [self mem_req:  destAddr: (long) BYTE_MASK: &bf0];  // get 5 bytes from memory
    if (error)
      return error;
    error = [self mem_req:  destAddr+1: (long) BYTE_MASK: &bf1];
    if (error)
      return error;
    error = [self mem_req:  destAddr+2: (long) BYTE_MASK: &bf2];
    if (error)
      return error;
    error = [self mem_req:  destAddr+3: (long) BYTE_MASK: &bf3];
    if (error)
      return error;
    error = [self mem_req:  destAddr+4: (long) BYTE_MASK: &bf4];
    if (error)
      return error;
    bf0 = bf0 << 24 | bf1 << 16 | bf2 << 8 | bf3;
    tmp = (bf0 << (offset & 7)) | (bf4 >> (8 - (offset & 7))); // 32 bits of potential data
    if (((offset & 7) + width) > 32)
      countCycles = 16;
    else
      countCycles = 12;
  }
  tmp >>= (32 - width);                         // width determines how many bits to use
  x_bit = self->regSR & xbit;                            // set condition codes
  n_bit = (tmp & (1 << (width-1)) ? 1 : 0);
  z_bit = (tmp == 0);
  v_bit = 0;
  c_bit = 0;

  switch ((self->regInstruction >> 8) & 0x7) {
    case BFTST:
      break;
    case BFEXTU:
      self->regD[(extra >> 12) & 7] = tmp;
      if (countCycles == 7)
        countCycles = 8;
      else if (countCycles == 12)
        countCycles = 13;
      else
        countCycles = 18;
      break;
    case BFCHG:
      tmp = ~tmp;
      if (countCycles == 7)
        countCycles = 12;
      else if (countCycles == 12)
        countCycles = 16;
      else
        countCycles = 24;
      break;
    case BFEXTS:
      if (n_bit)
        tmp |= width == 32 ? 0 : (-1 << width);
      self->regD[(extra >> 12) & 7] = tmp;
      if (countCycles == 7)
        countCycles = 8;
      else if (countCycles == 12)
        countCycles = 13;
      else
        countCycles = 18;
      break;
    case BFCLR:
      tmp = 0;
      if (countCycles == 7)
        countCycles = 12;
      else if (countCycles == 12)
        countCycles = 16;
      else
        countCycles = 24;
      break;
    case BFFF0:
      { uint mask = 1 << (width-1);
        while (mask) {
          if (tmp & mask)
            break;
          mask >>= 1;
          offset++;
        }
      }
      self->regD[(extra >> 12) & 7] = offset;
      if (countCycles == 7)
        countCycles = 18;
      else if (countCycles == 12)
        countCycles = 24;
      else
        countCycles = 32;
      break;
    case BFSET:
      tmp = 0xffffffff;
      if (countCycles == 7)
        countCycles = 12;
      else if (countCycles == 12)
        countCycles = 16;
      else
        countCycles = 24;
      break;
    case BFINS:
      tmp = self->regD[(extra >> 12) & 7];
      n_bit = (tmp & (1 << (width - 1)) ? 1 : 0);
      z_bit = (tmp == 0) ? 1 : 0;
      if (countCycles == 7)
        countCycles = 10;
      else if (countCycles == 12)
        countCycles = 15;
      else
        countCycles = 21;
      break;
  }
  [self CPUAddCycles: countCycles];
  
  // set SR according to results
  self->regSR = self->regSR & 0xffe0;		 		// clear the condition codes
  if (x_bit) self->regSR = self->regSR | xbit;
  if (n_bit) self->regSR = self->regSR | nbit;
  if (z_bit) self->regSR = self->regSR | zbit;
  if (v_bit) self->regSR = self->regSR | vbit;
  if (c_bit) self->regSR = self->regSR | cbit;

  switch ((self->regInstruction >> 8) & 0x7) {
  
    case BFCHG: 
    case BFCLR: 
    case BFSET: 
    case BFINS:
      tmp <<= (32 - width);
      if ((self->regInstruction & 0x0038) == 0) {               // if ea is data register
        self->regD[self->regInstruction & 7] = (self->regD[self->regInstruction & 7] & ((offset & 0x1f) == 0 ? 0 :
          (0xffffffff << (32 - (offset & 0x1f))))) |
          (tmp >> (offset & 0x1f)) |
          (((offset & 0x1f) + width) >= 32 ? 0 :
          (self->regD[self->regInstruction & 7] & ((uint)0xffffffff >> ((offset & 0x1f) + width))));
      } else {
        bf0 = (bf0 & (0xff000000 << (8 - (offset & 7)))) |
          (tmp >> (offset & 7)) |
          (((offset & 7) + width) >= 32 ? 0 :
           (bf0 & ((uint)0xffffffff >> ((offset & 7) + width))));
        [self mem_put: bf0 >> 24: destAddr:   (long)BYTE_MASK];
        [self mem_put: bf0 >> 16: destAddr+1: (long)BYTE_MASK];
        [self mem_put: bf0 >> 8:  destAddr+2: (long)BYTE_MASK];
        [self mem_put: bf0:       destAddr+3: (long)BYTE_MASK];
        if (((offset & 7) + width) > 32) {
          bf4 = (bf4 & (0xff >> (width - 32 + (offset & 7)))) |
                (tmp << (8 - (offset & 7)));
          [self mem_put: bf1: destAddr+4: (long)BYTE_MASK];
        }
      }
  }
  return error;
}
//----------------------------------------------------------------------------
//	Instructions from CODE8.cpp
//----------------------------------------------------------------------------
// Branch on Condition Code (not just Carry Clear)
-(int) BCC
{
  long	displacement;
  int	condition;

  displacement = self->regInstruction & 0xff;
  if (displacement == 0) {
    [self mem_request: &self->regPC: (long) WORD_MASK: &displacement];
    [self from_2s_comp: displacement: (long) WORD_MASK: &displacement];
  } else
    [self from_2s_comp: displacement: (long) BYTE_MASK: &displacement];

  condition = (self->regInstruction >> 8) & 0x0f;

  // perform the BCC operation
	if ( [self check_condition: condition])
    self->regPC = OLD_PC + displacement + 2;
  // displacement is relative to the end of the instruction word

	if ([self check_condition: condition])
    [self CPUAddCycles: 10];
  else
    [self CPUAddCycles: (self->regInstruction & 0xff != 0) ? 8 : 12];

  return SUCCESS;
}
//-------------------------------------------------------------------------
// DBcc
// ck. Fixed bug, DBcc did not exit loop and was modifying the upper word
//     of the data register.
-(int) DBCC
{
  long	displacement;
  int	reg;

	[self mem_request: &self->regPC: (long) WORD_MASK: &displacement];
  [self from_2s_comp: displacement: (long) WORD_MASK: &displacement];
  reg = self->regInstruction & 0x07;

  // perform the DBCC operation
	if ([self check_condition: (self->regInstruction >> 8) & 0x0f ])
    [self CPUAddCycles: 12];
  else {
    self->regD[reg] = (self->regD[reg] & ~WORD_MASK) | ((self->regD[reg] - 1) & 0xFFFF);
    if ((self->regD[reg] & 0xffff) == 0xFFFF)
      [self CPUAddCycles: 14];
    else {
      [self CPUAddCycles: 10];
      // displacement is relative to the end of the instruction word
      self->regPC = OLD_PC + displacement + 2;
    }
  }

  return SUCCESS;
}
//----------------------------------------------------------------------------
-(int)	SCC
{
  int	condition;

  int error = [self eff_addr: (long)BYTE_MASK: DATA_ALT_ADDR: true ];
  if (error)              // if address error
    return error;         // return error code

  /* perform the SCC operation */
  condition = (self->regInstruction >> 8) & 0x0f;
	if ([self check_condition: condition])
    [self put: self->regEA1: (long) BYTE_MASK: (long) BYTE_MASK];
  else
    [self put: self->regEA1: (long) 0: (long) BYTE_MASK];

  if (self->regInstruction & 0x0030 == 0)
	  [self CPUAddCycles: [self check_condition: condition] ? 6 : 4];
  else
    [self CPUAddCycles: 8];

  return SUCCESS;
}
//-------------------------------------------------------------------------
// BRA
-(int) BRA
{
  long	displacement;

  displacement = self->regInstruction & 0xff;
  if (displacement == 0) {
    [self mem_request: &self->regPC: (long) WORD_MASK: &displacement];
    [self from_2s_comp: displacement: (long) WORD_MASK: &displacement];
  } 
  else
    [self from_2s_comp: displacement: (long) BYTE_MASK: &displacement];

  // perform the BRA operation
  self->regPC = OLD_PC + displacement + 2;
  // displacement is relative to the end of the instructin word

  [self CPUAddCycles: 10];
  return SUCCESS;
}
//----------------------------------------------------------------------------
-(int)	BSR
{
  long	displacement;

  displacement = self->regInstruction & 0xff;
  if (displacement == 0) {
    [self mem_request: &self->regPC: (long) WORD_MASK: &displacement];
    [self from_2s_comp: displacement: (long) WORD_MASK: &displacement];
  } 
  else
    [self from_2s_comp: displacement: (long) BYTE_MASK: &displacement];

  // perform the BSR operation
  self->regA[[self a_reg: 7]] -= 4;
  [self put: (long *) &memory[self->regA[[self a_reg: 7]]]: self->regPC: LONG_MASK];

  // set address to stop program execution if user selects "Step Over"
  //if (sstep && stepToAddr == 0) {  // if "Step Over" mode
  //  trace = false;              // do not trace through subroutine
  //  stepToAddr = self->regPC;
  //}

  self->regPC = OLD_PC + displacement + 2;
  // displacement is relative to the end of the instruction word

  [self CPUAddCycles: 18];
  
  return SUCCESS;
}
//----------------------------------------------------------------------------
-(int)	JMP
{
	int error = [self eff_addr: (long)WORD_MASK: CONTROL_ADDR: false];
  if (error)              // if address error
    return error;         // return error code

  /* perform the JMP operation */
  self->regPC = (int) ((int)self->regEA1 - (int)&memory[0]);

switch ([self eff_addr_code: self->regInstruction: 0]) {
	case 0x02 : [self CPUAddCycles: 8];
	            break;
	case 0x05 : [self CPUAddCycles: 10];
	            break;
	case 0x06 : [self CPUAddCycles: 14];
	            break;
	case 0x07 : [self CPUAddCycles: 10];
	            break;
	case 0x08 : [self CPUAddCycles: 12];
	            break;
	case 0x09 : [self CPUAddCycles: 10];
	            break;
	case 0x0a : [self CPUAddCycles: 14];
	            break;
	default   : break;
	}

  return SUCCESS;
}
//----------------------------------------------------------------------------
-(int)	JSR
{
	int error = [self eff_addr: (long)WORD_MASK: CONTROL_ADDR: false];
  if (error)              // if address error
    return error;         // return error code

  // push the longword address immediately following PC on the system stack
  // then change the PC
  self->regA[[self a_reg: 7]] -= 4;
  [self put: (long *)&self->memory[self->regA[[self a_reg:7]]]: self->regPC: LONG_MASK];

  // set address to stop program execution if user selects "Step Over"
  //if (sstep && stepToAddr == 0) {  // if "Step Over" mode
  //  trace = false;              // do not trace through subroutine
  //  stepToAddr = self->regPC;
  //}

  self->regPC = (int) ((int)self->regEA1 - (int)&memory[0]);

	switch ([self eff_addr_code: self->regInstruction: 0]) {
	case 0x02 : [self CPUAddCycles: 16];
	            break;
	case 0x05 : [self CPUAddCycles: 18];
	            break;
	case 0x06 : [self CPUAddCycles: 22];
	            break;
	case 0x07 : [self CPUAddCycles: 18];
	            break;
	case 0x08 : [self CPUAddCycles: 20];
	            break;
	case 0x09 : [self CPUAddCycles: 18];
	            break;
	case 0x0a : [self CPUAddCycles: 22];
	            break;
	default   : break;
	}

  return SUCCESS;
}

//----------------------------------------------------------------------------
-(int)	RTE {
	
	long	temp;

	if (!(self->regSR & sbit))
		return (NO_PRIVILEGE);

	[self mem_request: &self->regA[8]: (long) WORD_MASK: &temp];
	self->regSR = temp & WORD_MASK;
	[self mem_request: &self->regA[8]: LONG_MASK: &self->regPC];

	[self CPUAddCycles: 20];

	return SUCCESS;

}
//----------------------------------------------------------------------------
-(int)	RTR
{
	long	temp;

	[self mem_request: &self->regA[[self a_reg: 7]]: (long) BYTE_MASK: &temp];
	self->regSR = (self->regSR & 0xff00) | (temp & 0xff);

	[self mem_request: &self->regA[[self a_reg: 7]]: LONG_MASK: &self->regPC];

	[self CPUAddCycles: 20];

	return SUCCESS;

}
//----------------------------------------------------------------------------
-(int)	RTS
{

	[self mem_request: &self->regA[[self a_reg: 7]]: LONG_MASK: &self->regPC];

	[self CPUAddCycles: 16];

	return SUCCESS;

}
//----------------------------------------------------------------------------
-(int)	NOP
{

	[self CPUAddCycles: 4];

	return SUCCESS;
}
//----------------------------------------------------------------------------
//	Instructions from CODE9.cpp
//----------------------------------------------------------------------------
-(int)	CHK
{
  int	reg;

  reg = (self->regInstruction >> 9) & 0x07;

  int error = [self eff_addr: (long)WORD_MASK: DATA_ADDR: true];
  if (error)              // if address error
    return error;         // return error code

  [self from_2s_comp: self->regEV1: (long) WORD_MASK: &self->source];
  self->dest = self->regD[reg] & WORD_MASK;

  [self cc_update: N_A: GEN: UND: UND: UND: self->source: self->regD[reg]: self->regD[reg]: WORD_MASK: 0];

  /* perform the CHK operation */
  if ((self->dest < 0) || (self->dest > self->source))
	return(CHK_EXCEPTION);

  [self CPUAddCycles: 10];

  return SUCCESS;

}
//-----------------------------------------------------
-(int)	ILLEGAL
{

	return (BAD_INST);

}
//----------------------------------------------------------------------------
-(int)	RESET
{

	if (!(self->regSR & sbit))
		return (NO_PRIVILEGE);

	/* assert the reset line to reset external devices */

	[self CPUAddCycles: 132];

	return SUCCESS;

}
//-----------------------------------------------------------
//  STOP
-(int)	STOP
{
	long	temp;
	int	tr_on;

	[self CPUAddCycles: 4];

	[self mem_request: &self->regPC: (long) WORD_MASK: &temp];

	if (!(self->regSR & sbit))
		return (NO_PRIVILEGE);

	if (self->regSR & tbit)
		tr_on = true;
	else
		tr_on = false;

	self->regSR = temp & WORD_MASK;
	if (tr_on)
		self->regSR = self->regSR | tbit;

	if (!(self->regSR & sbit))
		return (NO_PRIVILEGE);

	if (tr_on)
		return (TRACE_EXCEPTION);

	return (STOP_TRAP);
}
//----------------------------------------------------------------------------
-(int) TRAPV
{
	if (self->regSR & vbit)
		return (TRAPV_TRAP);

	[self CPUAddCycles: 4];

	return SUCCESS;
}
//----------------------------------------------------------------------------
-(int) LINE1010
{
  return LINE_1010;		//	return this code to lunch LINE A exception code
}
//----------------------------------------------------------------------------

-(int) LINE1111
{
  return LINE_1111;		//	return this code to lunch LINE F exception code
}
//----------------------------------------------------------------------------
-(int) TRAP
{
	int	vectorNumber;
	
  vectorNumber = ( self->regInstruction & 0x0F );

  return TRAP_TRAP;		//	return this code to lunch TRAP #x exception code
}



@end
