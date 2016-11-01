//
//  CPU.m
//  E68000
//
//  Created by Laurent on 25/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//	manque eff_addr, value_of, decode_size, put
//	type ? source, dest, size, bitfield, stepToAddr

#import "CPU.h"
#include "CPUInstructionsMap.h"

@implementation CPU

@synthesize instructionText;

-(id) init {

	self = [super init];
	
	self->regA[7]	= 0x00FF0000;					// user stack
	self->regA[8]	= 0x01000000;					// supervisor stack
	
	return self;
}
//---------------------------------------------------------------------------
-(void) dealloc {
	
    [super dealloc];
}
//---------------------------------------------------------------------------
-(bool) TOSROMSInstall:(NSString *)tosfilename {

	return [self LoadTOS: tosfilename];
}
//---------------------------------------------------------------------------
-(void) CPUStart {

	int i;
	for(i = 0; i < 8; i++ ) {
		
		self->regD[i] = 0x00;
	}

	for(i = 0; i <= 8; i++ ) {
		
		self->regA[i] = 0x00;
	}
	
	self->regInstruction	= 0x00;
	self->regSR		= 0x2000;						//	Set supervisor mode
	self->irq		= 0;
	self->cycles	= 0;
	self->OLD_PC	= -1;							// set different from 'PC' and 'cycles'
	
	self->InstructionAddress = 0x00;
	
	[self mem_req: 0x00000000 : LONG_MASK: &self->regA[ [self a_reg: 7] ] ];
	[self mem_req: 0x00000004 : LONG_MASK: &self->regPC];	 
}
//---------------------------------------------------------------------------
-(void) CPURegistersInspector: (unsigned long *)d0: (unsigned long *)d1: (unsigned long *)d2: (unsigned long *)d3: (unsigned long *)d4: (unsigned long *)d5: (unsigned long *)d6: (unsigned long *)d7: (unsigned long *)a0: (unsigned long *)a1: (unsigned long *)a2: (unsigned long *)a3: (unsigned long *)a4: (unsigned long *)a5: (unsigned long *)a6: (unsigned long *)usp: (unsigned long *)ssp: (unsigned long *)pc: (unsigned long *)pc_previous: (unsigned short *)ri: (unsigned short *)sr {
	
	*d0 = self->regD[ 0 ];
	*d1 = self->regD[ 1 ];
	*d2 = self->regD[ 2 ];
	*d3 = self->regD[ 3 ];
	*d4 = self->regD[ 4 ];
	*d5 = self->regD[ 5 ];
	*d6 = self->regD[ 6 ];
	*d7 = self->regD[ 7 ];

	*a0 = self->regA[ 0 ];
	*a1 = self->regA[ 1 ];
	*a2 = self->regA[ 2 ];
	*a3 = self->regA[ 3 ];
	*a4 = self->regA[ 4 ];
	*a5 = self->regA[ 5 ];
	*a6 = self->regA[ 6 ];
	
	*usp = self->regA[ 7 ];
	*ssp = self->regA[ 8 ];
	
	*sr = self->regSR;
	*pc = self->regPC;
	
	*pc_previous = self->InstructionAddress;
	
	*ri = self->regInstruction;
}

/**************************** int exec_inst() *****************************

   name       : int exec_inst ()
   parameters : NONE
   function   : executes a single instruction at the location pointed
                  to by PC.  it is called from runprog() and sets the
                  flag "errflg" if an illegal opcode is detected so
                  that runprog() terminates.  exec_inst() also takes
                  care of handling the different kinds of exceptions
                  that may occur.  If an instruction returns a different
                  return code than "SUCCESS" then the appropriate
                  exception is initiated, unless the "exceptions" flag
                  is turned off by the user in which case the exception
                  is not initiated and the program simply terminates and
                  informs the user that an exception condition has occurred.


****************************************************************************/
int start, finish, exec_result, i, intMask;
-(int) CPUExecInstruction {
	
	// Reset read and write flags so when breakpoints are tested for read/write
	// access, we know if this instruction caused a respective read/write.
	self->bpRead = false;
	self->bpWrite = false;

	long nextInstruction;
	
	self->InstructionAddress = self->regPC;							//	just to show the instruction address (PC will be updated to the next)
	
    exec_result = [self mem_request: &self->regPC: WORD_MASK: &nextInstruction ];
    if ( !(exec_result) ) {
    
		self->regInstruction = (int)nextInstruction;
		
		start = offsets[(self->regInstruction & FIRST_FOUR) >> 12];
		finish = offsets[((self->regInstruction & FIRST_FOUR) >> 12) + 1] - 1;

		for (i = start; i <= finish; i++) {
			if ( (self->regInstruction & ~inst_arr[i].mask) == inst_arr[i].val) {

				//[self tracedebug];
					  
				if ( self->regSR & tbit)							// if trace bit set
					trace_bit = YES;
				else
					trace_bit = NO;

				//exec_result = (*(names[i]))();					// run the 68000 instruction
				self->instructionText = [NSString stringWithFormat:@"%s", inst_arr[ i ].name];
				
				exec_result = (int)[self performSelector: names[ i ]];
				
				//------------------------ EXCEPTION PROCESSING ---------------------
				if (exceptions) {									// if exception processing enabled
                    
					self->OLD_PC = self->regPC;						// ck 2.9.2
					switch (exec_result) {							// these results prevent trace exception
	            
					  case BAD_INST : 
						[self CPUAddCycles: 34];					// Illegal instruction
						self->OLD_PC -= 2;							// ck 12-16-2005
						[self mem_req: 0x10: LONG_MASK: &self->regPC];
						[self exceptionHandler: 1: 0: READ ];
						break;
		                
					  case NO_PRIVILEGE : 
						[self CPUAddCycles: 34];					// Privileged violation
						[self mem_req: 0x20: LONG_MASK: &self->regPC];
						[self exceptionHandler: 1: 0: READ ];
						break;
					}
				
					intMask = 0xFF80 >> (7 - ((self->regSR & intmsk) >> 8)) | 0x40;
					if ( irq & intMask)								// if IRQ
					  [self irqHandler];							// process IRQ

					if (trace_bit) {								// if trace exception enabled
					  [self CPUAddCycles: 34];
					  [self mem_req: 0x24: LONG_MASK: &self->regPC];
					  [self exceptionHandler: 2: 0: READ];
					  self->OLD_PC = self->regPC;					//ck 2.9.2
					}
					
					switch (exec_result) {							// these results do not prevent trace exception

					  case SUCCESS  : 
						break;
						
					  case STOP_TRAP : 								// STOP instruction
						break;
	                
					  case TRAP_TRAP : 
						[self CPUAddCycles: 38];
						[self mem_req: 128 + ((self->regInstruction & 0x0f) * 4) : LONG_MASK: &self->regPC];
						[self exceptionHandler: 2: 0: READ];
						break;
	                
					  case DIV_BY_ZERO : 
						[self CPUAddCycles: 42];
						[self mem_req: 0x14: LONG_MASK: &self->regPC];
						[self exceptionHandler: 2: 0: READ];
						break;
		                
					  case CHK_EXCEPTION : 
						[self CPUAddCycles: 44];
						[self mem_req: 0x18: LONG_MASK: &self->regPC];
						[self exceptionHandler: 2: 0: READ];
						break;
                
					  case TRAPV_TRAP : 
						[self CPUAddCycles: 34];
						[self mem_req: 0x1C: LONG_MASK: &self->regPC];
						[self exceptionHandler: 2: 0: READ];
						break;
		                
					  case TRACE_EXCEPTION : 
						[self CPUAddCycles: 34];
						[self mem_req: 0x24: LONG_MASK: &self->regPC];
						[self exceptionHandler: 2: 0: READ];
						break;
		                
					  case LINE_1010 : 
						[self CPUAddCycles: 34];
						[self mem_req: 0x28: LONG_MASK: &self->regPC];
						[self exceptionHandler: 2: 0: READ];
						break;
		                
					  case LINE_1111 : 
						[self CPUAddCycles: 34];
						[self mem_req: 0x2C: LONG_MASK: &self->regPC];
						[self exceptionHandler: 2: 0: READ];
						break;
					}
				}				
				break;        // break out of for loop
			}
		} // end for
	} // end if
	return SUCCESS;
}

-(void) tracedebug {

	/*if (trace) {
	sprintf(buffer,"PC=%08X  Code=%04X  %s", PC-2, inst, inst_arr[i].name);
	Form1->Message->Lines->Add(buffer);

	if (logging)
	{
	  // ----- if logging memory -----
	  if (ElogFlag == INST_REG_MEM) {     // if logging memory
		int addr = logMemAddr;            // address to log
		int nRows = logMemBytes/16;       // how many rows to log

		fprintf(ElogFile,"\n");           // blank line
		// display memory by rows of 16 bytes
		for (int r=0; r<nRows; r++) {
		  if (addr < 0 || addr >= MEMSIZE)    // if invalid address
			fprintf(ElogFile,"%08X: Invalid Address",addr);
		  else                                // valid address
			fprintf(ElogFile,"%08X: ",addr);
		  // display 16 hex bytes of memory
		  for (int i=0; i<16; i++) {
			if (addr+i >= MEMSIZE)            // if invalid address
			  fprintf(ElogFile,"xx ");        // is this necessary?
			else
			  fprintf(ElogFile,"%02hX ",(unsigned char)memory[(addr+i) & ADDRMASK]);
		  }
		  // display 16 bytes as ASCII
		  for (int i=0; i<16; i++) {
			if (addr+i >= MEMSIZE)            // if invalid address
			  fprintf(ElogFile,"-");          // is this necessary?
			else {
			  if (memory[(addr+i) & ADDRMASK] >= ' ')    // if displayable char
				fprintf(ElogFile,"%hc",memory[(addr+i) & ADDRMASK]);
			  else
				fprintf(ElogFile,"-");
			}
		  }
		  addr += 16;
		  fprintf(ElogFile,"\n");         // new line
		}
	  }

	  // ----- if logging registers -----
	  if (ElogFlag == REGISTERS || ElogFlag == INST_REG_MEM) {
		fprintf(ElogFile,"\n");           // blank line
		// output registers to log file
		fprintf(ElogFile,"D0=%08lX D4=%08lX A0=%08lX A4=%08lX    T_S__INT___XNZVC\n",
						  D[0],D[4],A[0],A[4]);
		fprintf(ElogFile,"D1=%08lX D5=%08lX A1=%08lX A5=%08lX SR=",
						  D[1],D[5],A[1],A[5]);
		for (int j=0; j<16; j++) {        // display each bit of SR
		  if ((0x8000 >> j) & SR)
			fprintf(ElogFile,"1");
		  else
			fprintf(ElogFile,"0");
		}
		fprintf(ElogFile,"\nD2=%08lX D6=%08lX A2=%08lX A6=%08lX\n",
						  D[2],D[6],A[2],A[6]);
		fprintf(ElogFile,"D3=%08lX D7=%08lX A3=%08lX A7=%08lX SS=%08lX\n",
						  D[3],D[7],A[3],A[7],A[8]);
	  }

	  // ----- if logging instruction -----
	  if (ElogFlag) {
		if(Form1->lineToLog() == false) {  // output instruction to log file
		  fprintf(ElogFile, buffer); // if source not present output limited info
		  fprintf(ElogFile, "\n");
		}
		fflush(ElogFile);                  // write all bufferred data to file
	  }
	} // end if logging
	} // enf of trace
	*/
}

-(void) displayexceptions {
/*
switch (exec_result)
            {
              case SUCCESS  : break;
              case BAD_INST : halt = true;	// halt the program
                Form1->Message->Lines->Add(str.sprintf
                    ("Illegal instruction found at location %4x. Execution halted", OLD_PC));
                break;
              case NO_PRIVILEGE : halt = true;
                Form1->Message->Lines->Add(str.sprintf
                    ("supervisor privilege violation at location %4x. Execution halted", OLD_PC));
                break;
              case CHK_EXCEPTION : halt = true;
                Form1->Message->Lines->Add(str.sprintf
                    ("CHK exception occurred at location %4x. Execution halted", OLD_PC));
                break;
              case STOP_TRAP : halt = true;
                Form1->AutoTraceTimer->Enabled = false;
                Form1->Message->Lines->Add(str.sprintf
                    ("STOP instruction executed at location %4x. Execution halted", OLD_PC));
                Log->stopLogWithAnnounce();
                Form1->SetFocus();    // bring Form1 to top
                scrshow();            // update the screen
                Hardware->disable();
                break;
              case TRAP_TRAP : halt = true;
                Form1->Message->Lines->Add(str.sprintf
                    ("TRAP exception occurred at location %4x. Execution halted", OLD_PC));
                break;
              case TRAPV_TRAP : halt = true;
                Form1->Message->Lines->Add(str.sprintf
                    ("TRAPV exception occurred at location %4x. Execution halted", OLD_PC));
                break;
              case DIV_BY_ZERO : halt = true;
                Form1->Message->Lines->Add(str.sprintf
                    ("Divide by zero occurred at location %4x. Execution halted", OLD_PC));
                break;
              case ADDR_ERROR : halt = true;
                Form1->Message->Lines->Add("Execution halted");
                break;
              case BUS_ERROR : halt = true;
                Form1->Message->Lines->Add("Execution halted");
                break;
              case TRACE_EXCEPTION : halt = true;
                Form1->Message->Lines->Add(str.sprintf
                    ("Trace exception occurred at location %4x. Execution halted", OLD_PC));
                break;
              case LINE_1010 : halt = true;
                Form1->Message->Lines->Add(str.sprintf
                    ("Line 1010 Emulator exception occurred at location %4x. Execution halted", OLD_PC));
                break;
              case LINE_1111 : halt = true;
                Form1->Message->Lines->Add(str.sprintf
                    ("Line 1111 Emulator exception occurred at location %4x. Execution halted", OLD_PC));
                break;
              default: halt = true;
                Form1->Message->Lines->Add(str.sprintf
                    ("Unknown execution error %4x occurred at location %4x. Execution halted", exec_result, OLD_PC));
            }

            if (SR & tbit)
            {
              halt = true;
              Form1->Message->Lines->Add(str.sprintf
                  ("TRACE exception occurred at location %4x. Execution halted", OLD_PC));
            }
*/           
}

@end
