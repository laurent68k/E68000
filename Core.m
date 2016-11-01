//
//  Core.m
//  E68000
//
//  Created by Laurent on 24/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Core.h"

//---------------------------------------------------------------------------
// Change this depending on architecture
// This code assumes long is 32 bits and short is 16 bits

typedef unsigned long DWORD;
typedef unsigned short WORD;
typedef signed long LONG;
typedef signed short SHORT;

@implementation Core

//---------------------------------------------------------------------------
// Overload of Init
- (id)init {
    self = [super init];
    
    return self;
}
//---------------------------------------------------------------------------
- (void)dealloc {
	
    [super dealloc];
}

/**************************** int to_2s_comp () ****************************

   name       : int to_2s_comp (number, size, result)
   parameters : long number : the number to be converted to 2's compliment
                long size : the size of the operation
                long *result : the result of the conversion
   function   : to_2s_comp() converts a number to 2's compliment notation.


****************************************************************************/
-(int) to_2s_comp:(long) number:(long) size:(long *)result {

	if (size == LONG_MASK) {
		if (number < 0)
			*result = ~number - 1;
		else
			*result = number;
	}
		
	if (size == WORD_MASK) {
		if (number < 0)
			*result = (~(number & WORD_MASK) & WORD_MASK) - 1;
		else
			*result = number;
	}
	if (size == BYTE_MASK) {
		if (number < 0)
			*result = (~(number & BYTE_MASK) & BYTE_MASK) - 1;
		else
			*result = number;
	}

	return SUCCESS;
}
/**************************** int from_2s_comp () **************************

   name       : int from_2s_comp (number, size, result)
   parameters : long number : the number to be converted to 2's compliment
                long size : the size of the operation
                long *result : the result of the conversion
   function   : from_2s_comp() converts a number from 2's compliment 
                  notation to the "C" language format so that operations
                  may be performed on it.


****************************************************************************/
-(int) from_2s_comp:(long) number:(long) size:(long *)result {

	if (size == LONG_MASK) {
		if (number & 0x80000000) {
			*result = ~number + 1;
			*result = -*result;
		}
		else {
			*result = number;
		}
	}
	if (size == WORD_MASK) {
		if (number & 0x8000) {
			*result = (~number + 1) & WORD_MASK;
			*result = -*result;
			}
		else {
			*result = number;
		}
	}
	if (size == BYTE_MASK) {
		if (number & 0x80) {
			*result = (~number + 1) & BYTE_MASK;
			*result = -*result;
		}
		else {
			*result = number;
		}
	}
	return SUCCESS;
}
/**************************** int sign_extend () ***************************

   name       : int sign_extend (number, size_from, result)
   parameters : int number : the number to sign extended
                long size_from : the size of the source
                long *result : the result of the sign extension
   function   : sign_extend() sign-extends a number from byte to word or
                  from word to long.


****************************************************************************/
-(long) sign_extend:(int) number:(long) size_from {

	long result = number & size_from;
	
	if ((size_from == WORD_MASK) && (number & 0x8000)) {
		result |= 0xffff0000;
	}
	
	if ((size_from == BYTE_MASK) && (number & 0x80)) {
		result |= 0xff00;
	}
		
	return result;
}
/**************************** int value_of() *******************************

   name       : int value_of (EA, EV, size)
   parameters : long *EA : the location of the data to be evaluated
                long *EV : the location of the result
                long size : the appropriate size mask
   function   : value_of() returns the value of the location referenced
                  regardless of whether it is a virtual memory location
                  or a 68000 register location.  The "C" language stores
                  the bytes in an integer in the reverse-order that we
                  store the bytes in virtual memory, so this function
                  provides a general way of finding the value at a
                  location.

****************************************************************************/
-(void) value_of:(long *)EA: (long *)EV:(long) size {

  // if EA is register
  //if ( ( (int)EA >= (int)&self->regD[0] ) && ( (int)EA < (int)&self->regInstruction ) )
  //  *EV = *EA & size;
	if( (EA == (long *)&self->regSR) || 
	   (EA == &self->regD[0]) || (EA == &self->regD[1]) || ( EA == &self->regD[2]) || ( EA == &self->regD[3]) || 
	   (EA == &self->regD[4]) || (EA == &self->regD[5]) || ( EA == &self->regD[6]) || ( EA == &self->regD[7]) || 
	   (EA == &self->regA[0]) || (EA == &self->regA[1]) || ( EA == &self->regA[2]) || ( EA == &self->regA[3]) || 
	   (EA == &self->regA[4]) || (EA == &self->regA[5]) || ( EA == &self->regA[6]) || ( EA == &self->regA[7]) || 
	   (EA == &self->regA[8]) || 
	   (EA == (long *)&self->regInstruction) || (EA == (long *)&self->regEV1) || (EA == (long *)&self->regEV2) || 
	   (EA == &self->regPC) ||
	   (EA == self->regEA1) || (EA == self->regEA2) || (EA == &self->regResult)) {
		
		*EV = *EA & size;
	}		
	else {          // else EA is memory
		[self mem_req: (int)((int)EA - (int)&self->memory[0]): size: EV ];
	}
}
/**************************** int decode_size() ****************************

   name       : int decode_size (result)
   parameters : long *result : the appropriate mask for the decoded size
   function   : decodes the size field in the instruction being processed
                  and returns a mask to be used in instruction execution.
                  For example, if the size field was "01" then the mask
                  returned is WORD_MASK.

****************************************************************************/
-(int) decode_size:(long *)result {

	int	bits;

	/* the size field is always in bits 6 and 7 of the instruction word */
	bits = (self->regInstruction >> 6) & 0x0003;

	switch (bits) {
		case 0 : *result = BYTE_MASK;
			 break;
		case 1 : *result = WORD_MASK;
			 break;
		case 2 : *result = LONG_MASK;
			 break;
		default : *result = 0;
	}

	if (*result != 0)       // ck 1-06-2006
	   return SUCCESS;
	else
	   return FAILURE;
}



/**************************** int eff_addr() *******************************

   name       : int eff_addr (size, mask, add_times)
   parameters : long size : the appropriate size mask
                int mask : the effective address modes mask to be used
                int add_times : tells whether to increment the cycle counter
                      (there are times when we don't want to)
   function   : eff_addr() decodes the effective address field in the current
                  instruction, returns a pointer to the effective address
                  either in EA1 or EA2, and returns the value at that
                  location in EV1 or EV2.

****************************************************************************/
-(int) eff_addr:(long) size:(int) mask:(int) add_times {

  bool  legal = false;
  int	error = SUCCESS, mode, reg, addr, move_operation;
  int	bwinc, linc;
  long	ext, inc_size, ind_reg, disp;

  if (( ((self->regInstruction & 0xf000) == 0x1000) || ((self->regInstruction & 0xf000) == 0x2000) ||((self->regInstruction & 0xf000) == 0x3000)
      ) && (mask == DATA_ALT_ADDR) ) {
    move_operation = true;    // move destination address
  }
  else {
    move_operation = false;   // other effective address or move source address
  }

  if (move_operation)
    addr = (self->regInstruction >> 6) & 0x003f;
  else
    addr = self->regInstruction & 0x003f;
  bwinc = linc = 0;
  if (move_operation) {		// reg and mode are reversed in MOVE dest EA
    reg = (addr & MODE_MASK) >> 3;
    mode = addr & REG_MASK;
  } else {
    mode = (addr & MODE_MASK) >> 3;
    reg = addr & REG_MASK;
  }

  switch (mode) {               // switch on effective address mode
    case 0 :                                    // Dn
      if (mask & bit_1) {
        if (move_operation) { // choose EA2 in case of MOVE dest effective address
          self->regEA2 = &self->regD[reg];
          [self value_of: self->regEA2: &self->regEV2: size];
        } 
        else {
          self->regEA1 = &self->regD[reg];
          [self value_of: self->regEA1: &self->regEV1: size];
        }
        bwinc = linc = 0;
	legal = true;
      }
      break;
    case 1 :                                    // An
      if (mask & bit_2 && size != BYTE_MASK) {
	reg = [self a_reg: reg];
        if (move_operation) { // choose EA2 in case of MOVE dest effective address
          self->regEA2 = &self->regA[reg];
          [self value_of: self->regEA2: &self->regEV2: size];
        } 
        else {
          self->regEA1 = &self->regA[reg];
          [self value_of: self->regEA1: &self->regEV1: size];
        }
	bwinc = linc = 0;
	legal = true;
      }
      break;
    case 2 :                                    // [An]
      if (mask & bit_3) {
	reg = [self a_reg: reg];

        if (move_operation) { // choose EA2 in case of MOVE dest effective address
          self->regEA2 = (long *) &memory[self->regA[reg]];
          error = [self mem_req: self->regA[reg]: size: &self->regEV2];
        } 
        else {
          self->regEA1 = (long *) &memory[self->regA[reg]];
          error = [self mem_req: self->regA[reg]: size: &self->regEV1];
        }
	bwinc = 4;
	linc = 8;
	legal = true;
      }
      break;
    case 3 :                                    // [An]+
      if (mask & bit_4) {
	if (size == BYTE_MASK)
          if (reg == 7)                    // if stack operation on byte
            inc_size = 2;                  // force even address  ck 4-19-2002
          else
	    inc_size = 1;
	else if (size == WORD_MASK)
	  inc_size = 2;
	else
          inc_size = 4;
	reg = [self a_reg: reg];               // set reg to 8 if Supervisor Stack

        if (move_operation) { // choose EA2 in case of MOVE dest effective address
          self->regEA2 = (long *) &memory[self->regA[reg]];
          error = [self mem_req: self->regA[reg]: size: &self->regEV2];
        } 
        else {
          self->regEA1 = (long *) &memory[self->regA[reg]];
          error = [self mem_req: self->regA[reg]: size: &self->regEV1];
        }
	self->regA[reg] = self->regA[reg] + inc_size;
	bwinc = 4;
	linc = 8;
	legal = true;
      }
      break;
    case 4 :                                    // -[An]
      if (mask & bit_5) {
	if (size == BYTE_MASK)
          if (reg == 7)                    // if stack operation on byte
            inc_size = 2;                  // force even address  ck 4-19-2002
          else
	    inc_size = 1;
	else if (size == WORD_MASK)
	  inc_size = 2;
	else
          inc_size = 4;
	reg = [self a_reg: reg];                  // set reg to 8 if Supervisor Stack
	self->regA[reg] = self->regA[reg] - inc_size;

        if (move_operation) { // choose EA2 in case of MOVE dest effective address
          self->regEA2 = (long *) &memory[self->regA[reg]];
          error = [self mem_req: self->regA[reg]: size: &self->regEV2];
        } 
        else {
          self->regEA1 = (long *) &memory[self->regA[reg]];
          error = [self mem_req: self->regA[reg]: size: &self->regEV1];
        }
	bwinc = 6;
	linc = 10;
        legal = true;
      }
      break;
    case 5 :                                    // d[An]
      if (mask & bit_6)	{
	reg = [self a_reg: reg];
		  [self mem_request: &self->regPC: (long) WORD_MASK: &ext];
		  [self from_2s_comp: ext: (long) WORD_MASK: &ext];
	//value = (long *) &memory[self->regA[reg] + ext];
        if (move_operation) { // choose EA2 in case of MOVE dest effective address
          self->regEA2 = (long *) &memory[self->regA[reg] + ext];
          error = [self mem_req: self->regA[reg] + ext: size: &self->regEV2];
        } 
        else {
          self->regEA1 = (long *) &memory[self->regA[reg] + ext];
          error = [self mem_req: self->regA[reg] + ext: size: &self->regEV1];
        }
	bwinc = 8;
	linc = 12;
	legal = true;
      }
      break;
    case 6 :                                    // d[An, Xi]
      if (mask & bit_7) {
	reg = [self a_reg: reg];
	
	// fetch extension word
	[self mem_request: &self->regPC: (long) WORD_MASK: &ext];
	disp = ext & 0xff;
	
	disp = [self sign_extend: disp: BYTE_MASK];
		  [self from_2s_comp: disp: (long) WORD_MASK: &disp];
	
	// get index register value
	if (ext & 0x8000)
	  ind_reg = self->regA[[self a_reg: (ext & 0x7000) >> 12]];
	else
	  ind_reg = self->regD[(ext & 0x7000) >> 12];
	// get correct length for index register
	if (!(ext & 0x0800)) {
	  ind_reg = [self sign_extend: ind_reg: WORD_MASK];
	 [self  from_2s_comp: ind_reg: (long) LONG_MASK: &ind_reg];
	}
        if (move_operation) { // choose EA2 in case of MOVE dest effective address
          self->regEA2 = (long *) &memory[self->regA[reg] + disp + ind_reg];
          error = [self mem_req: self->regA[reg] + disp + ind_reg: size: &self->regEV2];
        } 
        else {
          self->regEA1 = (long *) &memory[self->regA[reg] + disp + ind_reg];
          error = [self mem_req: self->regA[reg] + disp + ind_reg: size: &self->regEV1];
        }
	bwinc = 10;
	linc = 14;
	legal = true;
      }
      break;
    case 7 :                    // Abs.W  Abs.L  d[PC]  d[PC, Xi]
      switch (reg) {
	case 0 :                                // Abs.W
          if (mask & bit_8) {
			  [self mem_request: &self->regPC: (long) WORD_MASK: &ext];  // get address from instruction
            if (ext >= 0x8000)          // if address is negative word  ck 1-11-2008
              ext = 0xFFFF0000 | ext;   // sign extend (corrected ck 6-23-2009)
            if (move_operation) { // choose EA2 in case of MOVE dest effective address
              self->regEA2 = (long *) &memory[ext];              // get effective address
              
              error = [self mem_req: ext: size: &self->regEV2];         // read data
            } else {
              self->regEA1 = (long *) &memory[ext];
              error = [self mem_req: ext: size: &self->regEV1];
            }
	    bwinc = 8;
	    linc = 12;
	    legal = true;
	  }
	  break;
	case 1 :                                // Abs.L
          if (mask & bit_9) {
			  [self mem_request: &self->regPC: LONG_MASK: &ext];         //ck 8-23-02 WORD_MASK TO LONG
            if (move_operation) { // choose EA2 in case of MOVE dest effective address
              self->regEA2 = (long *) &memory[ext & ADDRMASK];
              error = [self mem_req: ext: size: &self->regEV2];
            } 
            else {
              self->regEA1 = (long *) &memory[ext & ADDRMASK];
              error = [self mem_req: ext: size: &self->regEV1];
            }
            bwinc = 12;
	    linc = 16;
	    legal = true;
	  }
	  break;
	case 2 :                                // d[PC]
          if (mask & bit_10) {
			  [self mem_request: &self->regPC: (long) WORD_MASK: &ext];
			  [self  from_2s_comp: ext: (long) WORD_MASK: &ext];
	    //value = (long *) &memory[self->regPC + ext - 2];
            if (move_operation) { // choose EA2 in case of MOVE dest effective address
              self->regEA2 = (long *) &memory[self->regPC + ext - 2];
              error = [self mem_req: self->regPC + ext - 2: size: &self->regEV2];
            } 
            else {
              self->regEA1 = (long *) &memory[self->regPC + ext - 2];
              error = [self mem_req: self->regPC + ext - 2: size: &self->regEV1];
            }
	    bwinc = 8;
	    linc = 12;
	    legal = true;
	  }
	  break;
	case 3 :                                // d[PC, Xi]
          if (mask & bit_11) {
	    // fetch extension word
			  [self mem_request: &self->regPC: (long) WORD_MASK: &ext];
	    disp = ext & 0xff;
			  disp = [self sign_extend: disp: BYTE_MASK];
			  [self  from_2s_comp: disp: (long) WORD_MASK: &disp];
	    // get index register value
	    if (ext & 0x8000)
	      ind_reg = self->regA[[self a_reg: (ext & 0x7000) >> 12]];
	    else
	      ind_reg = self->regD[(ext & 0x7000) >> 12];
	    // get correct length for index register
	    if (!(ext & 0x0800)) {
	      ind_reg = [self sign_extend: ind_reg: WORD_MASK];
	     [self  from_2s_comp: ind_reg: (long) LONG_MASK: &ind_reg];
	    }
	    ext = ext & 0x00ff;
	    //value = (long *) (&memory[self->regPC - 2 + disp + ind_reg]);
            if (move_operation) { // choose EA2 in case of MOVE dest effective address
              self->regEA2 = (long *) &memory[self->regPC - 2 + disp + ind_reg];
              error = [self mem_req: self->regPC - 2 + disp + ind_reg: size: &self->regEV2];
            } 
            else {
              self->regEA1 = (long *) &memory[self->regPC - 2 + disp + ind_reg];
              error = [self mem_req: self->regPC - 2 + disp + ind_reg: size: &self->regEV1];
            }
	    bwinc = 10;
	    linc = 14;
	    legal = true;
	  }
	  break;
	case 4 :                                // Imm
          if (mask & bit_12) {
	    if ((size == BYTE_MASK) || (size == WORD_MASK))
			[self mem_request: &self->regPC: (long) WORD_MASK: &ext];
	    else
			[self mem_request: &self->regPC: LONG_MASK: &ext];
	    global_temp = ext;
	    //value = &global_temp;
            if (move_operation) { // choose EA2 in case of MOVE dest effective address
              self->regEA2 = (long *) &global_temp;
              [self value_of: self->regEA2: &self->regEV2: size];
            } 
            else {
              self->regEA1 = (long *) &global_temp;
              [self value_of: self->regEA1: &self->regEV1: size];
            }
	    bwinc = 4;
	    linc = 8;
	    legal = true;
	  }
	  break;
      }
      break;
  }   	  // switch

  if (legal) {          // if legal instruction
    if (add_times) {
      if (size != LONG_MASK)
	[self CPUAddCycles: bwinc];
      else
	[self CPUAddCycles: linc];
    }
  } 
  else {
    return BAD_INST;    // ILLEGAL instruction
  }
  
  return error;         // return error code

}

/**************************** int eff_addr_noread() ***************************
 Same as eff_addr above but does not read from address. Used by LEA & PEA
 
 name       : int eff_addr_noread (size, mask, add_times)
 parameters : long size : the appropriate size mask
 int mask : the effective address modes mask to be used
 int add_times : tells whether to increment the cycle counter
 (there are times when we don't want to)
 description: decodes the effective address field in the current
 instruction, returns a pointer to the effective address
 either in EA1 or EA2.
 
 ****************************************************************************/


-(int) eff_addr_noread:(long) size:(int) mask:(int) add_times {
	
	int	mode, reg, legal, addr, move_operation;
	int	bwinc, linc;
	long	ext, /*temp_ext,*/ inc_size, ind_reg, *value, disp;
	
	if (( ((self->regInstruction & 0xf000) == 0x1000) ||
		 ((self->regInstruction & 0xf000) == 0x2000) ||
		 ((self->regInstruction & 0xf000) == 0x3000)
		 ) && (mask == DATA_ALT_ADDR) )
		move_operation = true;
	else
		move_operation = false;
	
	if (move_operation)
		addr = (self->regInstruction >> 6) & 0x003f;
	else
		addr = self->regInstruction & 0x003f;
	legal = false;
	bwinc = linc = 0;
	if (move_operation) {		/* reg and mode are reversed in MOVE dest EA */
		reg = (addr & MODE_MASK) >> 3;
		mode = addr & REG_MASK;
	} else {
		mode = (addr & MODE_MASK) >> 3;
		reg = addr & REG_MASK;
	}
	
	switch (mode) {               // switch on effective address mode
		case 0 :                                    // Dn
			if (mask & bit_1) {
				value = &self->regD[reg];
				bwinc = linc = 0;
				legal = true;
			}
			break;
		case 1 :                                    // An
			if (mask & bit_2) {
				reg = [self a_reg: reg];
				value = &self->regA[reg];
				bwinc = linc = 0;
				legal = true;
			}
			break;
		case 2 :                                    // [An]
			if (mask & bit_3) {
				reg = [self a_reg: reg];
				value = (long *) &self->memory[ self->regA[reg]];
				bwinc = 4;
				linc = 8;
				legal = true;
			}
			break;
		case 3 :                                    // [An]+
			if (mask & bit_4) {
				if (size == BYTE_MASK)
					if (reg == 7)                    // if stack operation on byte
						inc_size = 2;                  // force even address  ck 4-19-2002
					else
						inc_size = 1;
					else if (size == WORD_MASK)
						inc_size = 2;
					else
						inc_size = 4;
				reg = [self a_reg: reg];               // set reg to 8 if Supervisor Stack
				value = (long *) &self->memory[ self->regA[reg]];
				self->regA[reg] = self->regA[reg] + inc_size;
				bwinc = 4;
				linc = 8;
				legal = true;
			}
			break;
		case 4 :                                    // -[An]
			if (mask & bit_5) {
				if (size == BYTE_MASK)
					if (reg == 7)                    // if stack operation on byte
						inc_size = 2;                  // force even address  ck 4-19-2002
					else
						inc_size = 1;
					else if (size == WORD_MASK)
						inc_size = 2;
					else
						inc_size = 4;
				reg = [self a_reg: reg];                  // set reg to 8 if Supervisor Stack
				self->regA[reg] = self->regA[reg] - inc_size;
				value = (long *) &self->memory[ self->regA[reg]];
				bwinc = 6;
				linc = 10;
				legal = true;
			}
			break;
		case 5 :                                    // d[An]
			if (mask & bit_6)	{
				reg = [self a_reg: reg];
				[self mem_request: &self->regPC: (long) WORD_MASK: &ext ];
				[self from_2s_comp: ext: (long) WORD_MASK: &ext];
				value = (long *) &memory[self->regA[reg] + ext];
				bwinc = 8;
				linc = 12;
				legal = true;
			}
			break;
		case 6 :                                    // d[An, Xi]
			if (mask & bit_7) {
				reg = [self a_reg: reg];
				// fetch extension word
				[self mem_request: &self->regPC: (long) WORD_MASK: &ext ];
				disp = ext & 0xff;
				disp = [self sign_extend: disp: BYTE_MASK];
				[self from_2s_comp:disp: (long) WORD_MASK: &disp];
				// get index register value
				if (ext & 0x8000)
					ind_reg = self->regA[ [self a_reg: (ext & 0x7000) >> 12] ];
				else
					ind_reg = self->regD[(ext & 0x7000) >> 12];
				// get correct length for index register
				if (!(ext & 0x0800)) {
					ind_reg = [self sign_extend: ind_reg: WORD_MASK];
					[self from_2s_comp: ind_reg: (long) LONG_MASK: &ind_reg];
				}
				value = (long *) (&self->memory[self->regA[reg] + disp + ind_reg]);
				bwinc = 10;
				linc = 14;
				legal = true;
			}
			break;
		case 7 :                    // Abs.W  Abs.L  d[PC]  d[PC, Xi]
			switch (reg) {
				case 0 :                                // Abs.W
					if (mask & bit_8) {
						[self mem_request: &self->regPC: (long) WORD_MASK: &ext ];
						value = (long *) &self->memory[ext];
						bwinc = 8;
						linc = 12;
						legal = true;
					}
					break;
				case 1 :                                // Abs.L
					if (mask & bit_9) {
						[self mem_request: &self->regPC: LONG_MASK: &ext];         //ck 8-23-02 WORD_MASK TO LONG
						//mem_request (&self->regPC, LONG_MASK, &temp_ext);  //ck
						//ext = ext * 0xffff + temp_ext;            //ck
						//value = (long *) &memory[ext & ADDRMASK]; //ck 2-21-03
						value = (long *) &self->memory[ext];
						bwinc = 12;
						linc = 16;
						legal = true;
					}
					break;
				case 2 :                                // d[PC]
					if (mask & bit_10) {
						[self mem_request: &self->regPC: (long) WORD_MASK: &ext];
						[self from_2s_comp: ext: (long) WORD_MASK: &ext];
						value = (long *) &self->memory[self->regPC + ext - 2];
						bwinc = 8;
						linc = 12;
						legal = true;
					}
					break;
				case 3 :                                // d[PC, Xi]
					if (mask & bit_11) {
						// fetch extension word
						[self mem_request: &self->regPC: (long) WORD_MASK: &ext];
						disp = ext & 0xff;
						disp = [self sign_extend: disp: BYTE_MASK];
						[self from_2s_comp: disp: (long) WORD_MASK: &disp];
						// get index register value
						if (ext & 0x8000)
							ind_reg = self->regA[ [self a_reg: (ext & 0x7000) >> 12 ] ];
						else
							ind_reg = self->regD[(ext & 0x7000) >> 12];
						// get correct length for index register
						if (!(ext & 0x0800)) {
							ind_reg = [self sign_extend: ind_reg: WORD_MASK];
							[self from_2s_comp: ind_reg: (long) LONG_MASK: &ind_reg];
						}
						ext = ext & 0x00ff;
						value = (long *) (&self->memory[self->regPC - 2 + disp + ind_reg]);
						bwinc = 10;
						linc = 14;
						legal = true;
					}
					break;
				case 4 :                                // Imm
					if (mask & bit_12) {
						if ((size == BYTE_MASK) || (size == WORD_MASK))
							[self mem_request: &self->regPC: (long) WORD_MASK: &ext];
						else
							[self mem_request: &self->regPC: LONG_MASK: &ext];
						global_temp = ext;
						value = &global_temp;
						bwinc = 4;
						linc = 8;
						legal = true;
					}
					break;
			}
			break;
	}   	  // switch
	
	if (legal) {
		if (add_times) {
			if (size != LONG_MASK)
				[self CPUAddCycles: bwinc];
			else
				[self CPUAddCycles: linc];
		}
		if (move_operation) { // choose EA2 in case of MOVE dest effective address
			self->regEA2 = value;
		} else {
			self->regEA1 = value;
		}
		return SUCCESS;
	}
	else
		return FAILURE;       // return FAILURE if illegal addressing mode
	
}

/**************************** int eff_addr_code () *************************

   name       : int eff_addr_code (inst, start)
   parameters : int inst : the instruction word
                int start : the start bit of the effective address field
   function   : returns the number of the addressing mode contained in
                  the effective address field of the instruction.  This
                  number is used in calculating the execution time for
                  many functions.


****************************************************************************/
-(int) eff_addr_code:(int) inst:(int) start {

	int	mode, reg;

	inst = (inst >> start);
    if (start) {            // if checking destination address
		mode = inst & 0x07;
		reg = (inst >> 3) & 0x07;
    } 
    else {                // else, source address
		reg = inst & 0x07;
		mode = (inst >> 3) & 0x07;
    }

	if (mode != 7) return (mode);

	switch (reg) {
		case 0x00 : return (7);
		case 0x01 : return (8);
		case 0x02 : return (9);
		case 0x03 : return (10);
		case 0x04 : return (11);
	}

	return 12;
}
/**************************** int a_reg () *********************************

   name       : int a_reg (reg_num)
   parameters : int reg_num : the address register number to be processed
   function   : a_reg() allows both the SSP and USP to act as A[7].  It
                  returns the value '8' if the supervisor bit is set and
                  the reg_num input was '7'.  Otherwise, it returns the
                  reg_num without change.


****************************************************************************/
-(int) a_reg:(int) reg_num {

	return ((reg_num == 7) && (self->regSR & sbit)) ? 8 : reg_num;
}

/**************************** int put() ************************************

   name       : int put (dest, source, size)
   parameters : long *dest : the destination to move data to
                long source : the data to move
                long size : the appropriate size mask for the operation
   function   : put() performs the task of putting the result of some
                  operation into a destination location "according to
                  size".  This means that the bits of the destination
                  that are in excess to the size of the operation are not
                  affected.  This function provides a general-purpose
                  mechanism for putting the result of an operation in
                  the destination, no matter whether the destination is
                  a memory location or a 68000 register.  The data is
                  placed in the destination correctly and the rest of
                  the bits in a register are left alone.
   void        : Used only in exceptionHandler() in RUN.CPP. Return
                 values are ignored.

   Modified: Chuck Kelly
             Monroe County Community College
             http://www.monroeccc.edu/ckelly

****************************************************************************/

-(void) put:(long *)dest:(long) src:(long) size {

	// if dest is register
	//if( ( (int)dest >= (int)&self->regD[0] ) && ( (int)dest < (int)&self->regInstruction ) ) 
    //*dest = (source & size) | (*dest & ~size);
	
	if( (dest == (long *)&self->regSR) || 
		(dest == &self->regD[0]) || (dest == &self->regD[1]) || ( dest == &self->regD[2]) || ( dest == &self->regD[3]) || 
		(dest == &self->regD[4]) || (dest == &self->regD[5]) || ( dest == &self->regD[6]) || ( dest == &self->regD[7]) || 
		(dest == &self->regA[0]) || (dest == &self->regA[1]) || ( dest == &self->regA[2]) || ( dest == &self->regA[3]) || 
		(dest == &self->regA[4]) || (dest == &self->regA[5]) || ( dest == &self->regA[6]) || ( dest == &self->regA[7]) || 
		(dest == &self->regA[8]) || 
	    (dest == (long *)&self->regInstruction) || (dest == (long *)&self->regEV1) || (dest == (long *)&self->regEV2) || 
	    (dest == &self->regPC) ||
	    (dest == self->regEA1) || (dest == self->regEA2) || (dest == &self->regResult)) {

		*dest = (src & size) | (*dest & ~size);	
	}
	else {							// else dest is memory
		[self mem_put: src: (int) ((int)dest - (int)&memory[0]): size];
	}
}


/**************************** int cc_update() *****************************

   name       : int cc_update (x, n, z, v, c, source, dest, result, size, r)
   parameters : int x, n, z, v, c : the codes for actions that should be
                    taken to compute the different condition codes.
                long source : the source operand for the instruction
                long dest : the destination operand for the instruction
                long result : the result of the instruction
                long size : the size of the instruction
                int r : the shift count for shift and rotate instructions
   function   : updates the five condition codes according to the codes
                  passed as parameters.  each of the condition codes
                  has a number of ways it can be calculated, and the
                  appropriate method of computation is passed as the
                  parameter for that condition code.  The source, dest, and
                  result operands contain the source, destination, and
                  result of the instruction requesting updating the
                  condition codes.  Also, for shift and rotate instructions
                  the shift count needs to be passed.

                  The details of the different ways to calculate condition
                  codes are contained in Appendix A of the 68000
                  Programmer's Reference Manual.

****************************************************************************/


-(int) cc_update:(int) x:(int) n:(int) z:(int) v:(int) c:(long) source: (long) dest: (long) result: (long) size: (int) r {

	int		x_bit, n_bit, z_bit, v_bit, c_bit, mask;
	long	Rm, Dm, Sm;
	//long	count, temp1, temp2;
	long	m;

	/* assign the bits to their variables here */
	x_bit = self->regSR & xbit;
	n_bit = self->regSR & nbit;
	z_bit = self->regSR & zbit;
	v_bit = self->regSR & vbit;
	c_bit = self->regSR & cbit;

	source &= size;
	dest &= size;
	result &= size;

	if (size == BYTE_MASK)
				{
				m = 7;
			   Sm = source & 0x0080;
			   Rm = result & 0x0080;
			   Dm = dest & 0x0080;
				};
	if (size == WORD_MASK)
				{
				m = 15;
			   Sm = source & 0x8000;
			   Rm = result & 0x8000;
			   Dm = dest & 0x8000;
				};
	if (size == LONG_MASK)
				{
				m = 31;
			   Sm = source & 0x80000000;
			   Rm = result & 0x80000000;
			   Dm = dest & 0x80000000;
				};

	/* calculate each of the five condition codes according to the requested */
	/* method of calculation */
	switch (n) {
		case N_A : break; 			/* n_bit not affected */
		case ZER : n_bit = 0;
			   break;
		case GEN : n_bit = (Rm) ? true : false;
			   break;
		case UND : n_bit = !n_bit;		/* undefined result */
			   break;
		}
	switch (z) {
		case N_A : break;			/* z_bit not affected */
		case UND : z_bit = !z_bit;		/* z_bit undefined */
			   break;
		case GEN : z_bit = (result == 0) ? true : false;
			   break;
		case CASE_1 : z_bit = (z_bit && (result == 0)) ? true : false;
			  break;
		};
	switch (v) {
		case N_A : break;			/* v_bit not affected */
		case ZER : v_bit = 0;
			   break;
		case UND : v_bit = !v_bit;		/* v_bit not defined */
			   break;
		case CASE_1 : v_bit = ((Sm && Dm && !Rm) || (!Sm && !Dm && Rm)) ?
				true : false;
				  break;
		case CASE_2 : v_bit = ((!Sm && Dm && !Rm) || (Sm && !Dm && Rm)) ?
				true : false;
				  break;
		case CASE_3 : v_bit = (Dm && Rm) ? true : false;
				  break;
			case CASE_4 : mask = (~((unsigned)size >> r+1)) & size;   // ASL v bit  //CK 10-11-2007
						  if (r>m & source)         // CK 1-25-2008
							v_bit = true;
						  else
							v_bit = (((mask & source) == 0) || ((mask & ~source) == 0)) ? false : true;
						  break;
		};
	switch (c) {
		case N_A :    break;			/* c_bit not affected */
		case UND :    c_bit = !c_bit;    	/* c_bit undefined  */
				  break;
		case ZER :    c_bit = 0;
				  break;
		case CASE_1 : c_bit = x_bit;
				  break;
		case CASE_2 : r %= 32;                  // LSR, ROR, ROXR   CK 1-25-2008
						  r %= (m+1);
						  c_bit = ((dest >> (r-1)) & 1) ? true : false;
				  break;
		case CASE_3 : c_bit = ((dest >> (m-r+1)) & 1) ? true : false;
				  break;
		case CASE_4 : c_bit = (Dm || Rm) ? true : false;
				  break;
		case CASE_5 : c_bit = ((Sm && Dm) || (!Rm && Dm) || (Sm && !Rm)) ?
				true : false;
				  break;
		case CASE_6 : c_bit = ((Sm && !Dm) || (Rm && !Dm) || (Sm && Rm)) ?
				true : false;
				  break;
		case CASE_7 : if (r > m)                // ASR      CK 1-25-2008
							r = m+1;
						  c_bit = ((dest >> (r-1)) & 1) ? true : false;
				  break;
		};
	switch (x) {
		case N_A : break;     		/* X condition code not affected */
		case GEN : x_bit = c_bit;		/* general case */
			   break;
		};

	/* set SR according to results */
	self->regSR = self->regSR & 0xffe0;							/* clear the condition codes */
	if (x_bit) self->regSR = self->regSR | xbit;
	if (n_bit) self->regSR = self->regSR | nbit;
	if (z_bit) self->regSR = self->regSR | zbit;
	if (v_bit) self->regSR = self->regSR | vbit;
	if (c_bit) self->regSR = self->regSR | cbit;

	return SUCCESS;
}




/**************************** int check_condition() ************************

   name       : int check_condition (condition)
   parameters : int condition : the condition to be checked
   function   : check_condition() checks for the truth of a certain
                  condition and returns the result.  The possible conditions
                  are encoded in DEF.H and can be seen in the switch()
                  statement below.

                  ck 4-8-2002 fixed bug with COND_HI
                  ck 4-26-2002 fixed bug with COND_GT, COND_VS
****************************************************************************/


-(int) check_condition:(int) condition {

	int	result;

	result = false;
	switch (condition)
	{
		case COND_T : result = 1;				/* true */
			   break;
		case COND_F : result = 0;				/* false */
			   break;
		case COND_HI : result = !(self->regSR & cbit) && !(self->regSR & zbit);	/* high */
			   break;
		case COND_LS : result = (self->regSR & cbit) || (self->regSR & zbit);	/* low or same */
			   break;
		case COND_CC : result = !(self->regSR & cbit);		/* carry clear */
			   break;
		case COND_CS : result = (self->regSR & cbit);		/* carry set */
			   break;
		case COND_NE : result = !(self->regSR & zbit);		/* not equal */
			   break;
		case COND_EQ : result = (self->regSR & zbit);		/* equal */
			   break;
		case COND_VC : result = !(self->regSR & vbit);		/* overflow clear */
			   break;
		case COND_VS : result = (self->regSR & vbit);		/* overflow set */
			   break;
		case COND_PL : result = !(self->regSR & nbit);		/* plus */
			   break;
		case COND_MI : result = (self->regSR & nbit);        /* minus */
			   break;
		case COND_GE : result = ((self->regSR & nbit) && (self->regSR & vbit)) ||
			  (!(self->regSR & nbit) && !(self->regSR & vbit));      /* greater or equal */
			   break;
		case COND_LT : result = ((self->regSR & nbit) && !(self->regSR & vbit))    /* less than */
			  || (!(self->regSR & nbit) && (self->regSR & vbit));
			   break;
		case COND_GT : result = ((self->regSR & nbit) && (self->regSR & vbit) && !(self->regSR & zbit)) || (!(self->regSR & nbit) && !(self->regSR & vbit) && !(self->regSR & zbit)); /* greater than */
			   break;
		case COND_LE : result = ((self->regSR & nbit) && !(self->regSR & vbit)) || (!(self->regSR & nbit) && (self->regSR & vbit)) || (self->regSR & zbit);/* less or equal */
				break;
	}
	return result;
}
/**************************** int exceptionHandler () *****************************
 
 name       :	int exception (class, loc, r_w)
 parameters :	int class : class of exception to be taken
 long loc :		the address referenced in the case of an  address or bus error
 int r_w :		in the case of an address or bus error, this tells whether the reference was a read or write
 
 function   : initiates exception processing by pushing the appropriate
 exception stack frame on the system stack and turning
 supervisor mode on and trace mode off.
 
 
 ****************************************************************************/

-(void) exceptionHandler: (int) clas: (long) loc :(int) r_w {
	
	int	infoWord;
	
	// if SSP on odd address OR outside memory range
	if ( (self->regA[8] % 2) || (self->regA[8] < 0) || ((unsigned int)self->regA[8] > MEMSIZE) ){
		//Form1->Message->Lines->Add(str.sprintf("Error during Exception Handler: SSP odd or outside memory space "));
		//Form1->Message->Lines->Add(str.sprintf ("at location %4x", A[8]));
		trace = true;       // stop running programs
		sstep = false;
		return;
	}
	if ( (clas == 1) || (clas == 2)) {
		self->regA[8] -= 4;		/* create the stack frame for class 1 and 2 exceptions */
		[self put: (long *)&self->memory[ self->regA[8] ]: OLD_PC: LONG_MASK ];
		
		self->regA[8] -= 2;
		[self put: (long *)&self->memory[ self->regA[8] ]: (long) self->regSR: (long) WORD_MASK ];
	} 
	else {			/* class 0 exception (address or bus error) */
		[self CPUAddCycles: 50];         /* fifty clock cycles for the address or bus exception */
		
		self->regA[8] -= 4;		/* now create the exception stack frame */
		[self put: (long *)&self->memory[self->regA[8]]: OLD_PC+2: LONG_MASK ];   // OLD_PC+2 to match MECB
		
		self->regA[8] -= 2;
		[self put: (long *)&self->memory[self->regA[8]]: (long) self->regSR: (long) WORD_MASK];
		
		self->regA[8] -= 2;
		[self put: (long *)&self->memory[self->regA[8]]: (long) self->regInstruction: (long) WORD_MASK];
		
		self->regA[8] -= 4;
		[self put: (long *)&self->memory[self->regA[8]]: loc: LONG_MASK ];
		
		self->regA[8] -= 2;
		
		if (loc == OLD_PC+2)        // if address exception reading instruction
			infoWord = 0x6;           // function code 110 Supervisor Program
		else                        // else data access error
			infoWord = 0x5;           // function code 101 Supervisor Data
			
		if (r_w == READ)
			infoWord |= 0x10;
			
		[self put: (long *)&self->memory[self->regA[8]]: (long)infoWord: (long) WORD_MASK];	/* push information word */
	}
	self->regSR = self->regSR | sbit;			/* force processor into supervisor state */
	self->regSR = self->regSR & ~tbit;			/* turn off trace mode */
	trace_bit = false;
}
//---------------------------------------------------------
-(void) irqHandler {

  [self exceptionHandler: 2: 0: READ];
  
  self->regSR &= 0xF8FF;						// clear irq priority bits
  if (regIrq & 0x40) {							// if IRQ 7
    self->regSR = self->regSR | 0x700;	        // set priority level
    [self mem_req: 0x7C: LONG_MASK: &self->regPC];
    regIrq &= 0x3F;								// clear irq request
  } 
  else if (regIrq & 0x20) {						// if IRQ 6
    self->regSR = self->regSR | 0x600;	        // set priority level
    [self mem_req: 0x78: LONG_MASK: &self->regPC];
    regIrq &= 0x1F;								// clear irq request
  }
  else if (regIrq & 0x10) {						// if IRQ 5
    self->regSR = self->regSR | 0x500;	        // set priority level
    [self mem_req: 0x74: LONG_MASK: &self->regPC];
    regIrq &= 0x0F;								// clear irq request
  } 
  else if (regIrq & 0x08) {						// if IRQ 4
    self->regSR = self->regSR | 0x400;	        // set priority level
    [self mem_req: 0x70: LONG_MASK: &self->regPC];
    regIrq &= 0x07;                // clear irq request
  } 
  else if (regIrq & 0x04) {      // if IRQ 3
    self->regSR = self->regSR | 0x300;	        // set priority level
    [self mem_req: 0x6C: LONG_MASK: &self->regPC];
    regIrq &= 0x03;                // clear irq request
  } 
  else if (regIrq & 0x02) {      // if IRQ 2
    self->regSR = self->regSR | 0x200;	        // set priority level
    [self mem_req: 0x68: LONG_MASK: &self->regPC];
    regIrq &= 0x01;                // clear irq request
  } 
  else if (regIrq & 0x01) {      // if IRQ 1
    self->regSR = self->regSR | 0x100;	        // set priority level
    [self mem_req: 0x64: LONG_MASK: &self->regPC];
    regIrq &= 0x00;                // clear irq request
  }
  [self CPUAddCycles: 34];
}
//---------------------------------------------------------------------------
-(void) CPUAddCycles:(int) ticks {
	
	self->cycles = self->cycles + ticks;
}
//---------------------------------------------------------------------------
//
// DIVU
// Unsigned division
//
-(unsigned int) getDivu68kCycles: (unsigned long) dividend: (unsigned short) divisor {

	unsigned mcycles;
	unsigned long hdivisor;
	int i;

	if( divisor == 0)
		return 0;

	// Overflow
	if( (dividend >> 16) >= (unsigned short)divisor)
		return (mcycles = 5) * 2;

	mcycles = 38;
	hdivisor = ((unsigned short) divisor) << 16;

	for( i = 0; i < 15; i++)
	{
		unsigned short temp;
		temp = dividend;

		dividend <<= 1;

		// If carry from shift
		if( (unsigned long) temp < 0)
		{
			dividend -= hdivisor;
		}

		else
		{
			mcycles += 2;
			if( dividend >= hdivisor)
			{
				dividend -= hdivisor;
				mcycles--;
			}
		}
	}

	return mcycles * 2;
}
//---------------------------------------------------------------------------
//
// DIVS
// Signed division
//
-(unsigned int) getDivs68kCycles: (signed long) dividend:(signed short) divisor {

	unsigned mcycles;
	unsigned aquot;
	int i;

	if( (signed short) divisor == 0)
		return 0;

	mcycles = 6;

	if( dividend < 0)
		mcycles++;

	// Check for absolute overflow
	if( ((unsigned long) abs( dividend) >> 16) >= (unsigned long) abs( divisor))
	{
		return (mcycles + 2) * 2;
	}

	// Absolute quotient
	aquot = (unsigned long) abs( dividend) / (unsigned short) abs( divisor);

	mcycles += 55;

	if( divisor >= 0)
	{
		if( dividend >= 0)
			mcycles--;
		else
			mcycles++;
	}

	// Count 15 msbits in absolute of quotient

	for( i = 0; i < 15; i++)
	{
		if( (signed short) aquot >= 0)
			mcycles++;
		aquot <<= 1;
	}


	return mcycles * 2;
}
//---------------------------------------------------------------------------

// convert little endian to big endian and vice versa
/*
-(uint) flip:(uint *)n {

  const byte *b = (byte *) n;
  return b[0]<<24 | b[1]<<16 | b[2]<<8 | b[3];
}

-(uint) flip:(uint *) n {

  return [self flip: n];
}
*/
-(unsigned short) flip:(unsigned short *)n {

  const unsigned char *b = (unsigned char *) n;
  return b[0]<<8 | b[1];
}

/*-(unsigned short) flip:(unsigned short) value {

	return [self flip: value];
}*/


@end
