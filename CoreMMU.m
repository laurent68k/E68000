//
//  Core.m
//  E68000
//
//  Created by Laurent on 24/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CoreMMU.h"
//#import "MC68000Global.h"

@implementation CoreMMU

@synthesize TOSVersion;
@synthesize TOSLanguage;

#define BIN16(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p) ((a<<15)+(b<<14)+(c<<13)+(d<<12)+(e<<11)+(f<<10)+(g<<9)+(h<<8)+(i<<7)+(j<<6)+(k<<5)+(l<<4)+(m<<3)+(n<<2)+(o<<1)+(p))

// Illegal Opcode used to help emulation. eg. free entries are 8 to 15 inc'
#define	GEMDOS_OPCODE		8		// Free op-code to intercept GemDOS trap
#define	RUNOLDGEMDOS_OPCODE	9		// Free op-code to set PC to old GemDOS vector(if doesn't need to intercept)
#define	CONDRV_OPCODE		10		// Free op-code to intercept set up connected drives
#define	TIMERD_OPCODE		11		// Free op-code to prevent Timer D starting in GemDOS
#define	VDI_OPCODE			12		// Free op-code to call VDI handlers AFTER Trap#2
#define	LINEA_OPCODE		13		// Free op-code to call handlers AFTER Line-A

// Other Opcodes
#define RTS_OPCODE	BIN16(0,1,0,0,1,1,1,0,0,1,1,1,0,1,0,1)
#define NOP_OPCODE	BIN16(0,1,0,0,1,1,1,0,0,1,1,1,0,0,0,1)
#define BRAW_OPCODE	BIN16(0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0)

// Standard available ST memory configurations
enum {
	MEMORYSIZE_512,
	MEMORYSIZE_1024,
	MEMORYSIZE_2MB,
	MEMORYSIZE_4MB
};

// List of TOS settings for different memory size
typedef struct {
	unsigned long PhysTop;						// phys top
	unsigned long MemoryConfig;					// 512k configure 0x00=128k 0x01=512k 0x10=2Mb 11=reserved eg 0x1010 = 4Mb
	unsigned long MemoryEnd;					// Above this address causes a BusError
} MEMORY_INFO;

// Settings for differnt memory sizes
static MEMORY_INFO MemoryInfo[] = {
	0x80000,0x0000,0x00080000,		// MEMORYSIZE_512
	0x100000,0x0101,0x00100000,		// MEMORYSIZE_1024
	0x200000,0x0001,0x00200000,		// MEMORYSIZE_2MB
	0x400000,0x1010,0x00400000		// MEMORYSIZE_4MB
};

// Bit masks of connected drives(we support upto C,D,E,F)
unsigned int ConnectedDriveMaskList[] = {
	0x03,	// DRIVELIST_NONE	A,B,C
	0x07,	// DRIVELIST_C		A,B,C
	0x0F,	// DRIVELIST_CD		A,B,C,D
	0x1F,	// DRIVELIST_CDE	A,B,C,D,E
	0x3F,	// DRIVELIST_CDEF	A,B,C,D,E,F
};

//---------------------------------------------------------------------------
// Overload of Init
- (id)init {
    self = [super init];
    
   	self->ROMStart=0;
	self->ROMEnd=0;
	self->ReadStart=0;
	self->ReadEnd=0;
	self->ProtectedStart=0;
	self->ProtectedEnd=0;
	self->InvalidStart=0;
	self->InvalidEnd=0;
	
	self->ROMMap=NO;
	self->ReadMap=NO;
	self->ProtectedMap=NO;
	self->InvalidMap=NO;

	self->exceptions = YES;
	
	self->CARTRIDGEAddress = 0x00FA0000;
	
    for (int i=0; i<MEMSIZE; i++) {
      
      self->memory[ i ] = 0xFF;              // erase 68000 memory to $FF
	}
	
    return self;
}
//---------------------------------------------------------------------------
- (void)dealloc {
	
    [super dealloc];
}
//----------------------------------------------------------------------------
- (unsigned short int) Swap68000Int: (unsigned short int) integer68k {
	
	int integerX86 = ( ( integer68k >> 8 ) | (( integer68k & 0xFF) << 8 ) & 0xFFFF);
	
	return integerX86;
}
//----------------------------------------------------------------------------
/*
	Modify TOS Rom image to set default memory configuration, connected floppies and memory size
	and skip some TOS setup code which we don't support/need.
	As TOS Roms need to be modified we can only run images which are entered here.

	So, how do we find these addresses when we have no commented source code?
	Easy,
		Hdv_init: Scan start of TOS for table of move.l <addr>,$46A(a5), around 0x224 bytes in
		  and look at the first entry - that's the hdv_init address.
		Hdv_boot: Scan start of TOS for table of move.l <addr>,$47A(a5), and look for 5th entry
		  - that's the hdv_boot address. The function starts with link,movem,jsr.
		Boot from DMA bus: again scan at start of rom for tst.w $482, boot call will be just above it.
		Set connected drives: search for 'clr.w' and '$4c2' to find, may use (a5) in which case op-code
		 is only 4 bytes and also note this is only do on TOS's after 1.00
*/
-(void) TOS_FixRom {

	switch(TOSVersion) {
		/*
			TOS 1.00 settings
		*/
		case 0x0100:
			// hdv_init, initialize drives
			[self mem_put: RTS_OPCODE: 0xFC0D60: WORD_MASK ];			//RTS

			// FC1384	JSR $FC0AF8	hdv_boot, load boot sector
			[self mem_put: NOP_OPCODE: 0xFC1384: WORD_MASK ];			//NOP
			[self mem_put: NOP_OPCODE: 0xFC1384+2: WORD_MASK ];			//NOP
			[self mem_put: NOP_OPCODE: 0xFC1384+4: WORD_MASK ];			//NOP

			// FC03d6	JSR $FC04A8	Boot from DMA bus
			if ( NO /*bUseVDIRes*/) {
				[self mem_put: 0xa000: 0xFC03D6: WORD_MASK ];			//Init Line-A
				[self mem_put: 0xa0ff: 0xFC03D6+2: WORD_MASK ];			//Trap Line-A(to get structure)
			}
			else {
				[self mem_put: NOP_OPCODE: 0xFC03D6: WORD_MASK ];		//NOP
				[self mem_put: NOP_OPCODE: 0xFC03D6+2: WORD_MASK ];		//NOP
			}

			// Timer D(MFP init 0xFC21B4), set value before call Set Timer routine
			[self mem_put: TIMERD_OPCODE: 0xFC21F6: WORD_MASK ];

			// Modify assembler loaded into cartridge area
			//Cart_WriteHdvAddress(0x167A);
			break;

		/*
			TOS 1.02 settings
		*/
		case 0x0102:
			// hdv_init, initialize drives
			[self mem_put: RTS_OPCODE: 0xFC0F44: WORD_MASK ];			//RTS

			// FC1568	JSR $FC0C2E			hdv_boot, load boot sector
			[self mem_put: NOP_OPCODE: 0xFC1568: WORD_MASK];	//NOP
			[self mem_put: NOP_OPCODE: 0xFC1568+2: WORD_MASK];	//NOP
			[self mem_put: NOP_OPCODE: 0xFC1568+4: WORD_MASK];	//NOP

			// FC0472	BSR.W $FC0558		Boot from DMA bus
			if ( NO /*bUseVDIRes*/) {
				[self mem_put: 0xa000: 0xFC0472: WORD_MASK];	//Init Line-A
				[self mem_put: 0xa0ff: 0xFC0472+2: WORD_MASK];	//Trap Line-A(to get structure)
			}
			else {
				[self mem_put: NOP_OPCODE: 0xFC0472: WORD_MASK];	//NOP
				[self mem_put: NOP_OPCODE: 0xFC0472+2: WORD_MASK];	//NOP
			}

			// FC0302	CLR.L $4C2			Set connected drives
			[self mem_put: CONDRV_OPCODE: 0xFC0302: WORD_MASK];
			[self mem_put: NOP_OPCODE: 0xFC0302+2: WORD_MASK];	//NOP
			[self mem_put: NOP_OPCODE: 0xFC0302+4: WORD_MASK];	//NOP	

			// Timer D(MFP init 0xFC2408)
			[self mem_put: TIMERD_OPCODE: 0xFC2450: WORD_MASK];

			// Modify assembler loaded into cartridge area
			//Cart_WriteHdvAddress(0x16DA);
			break;

		/*
			TOS 1.04 settings
		*/
		case 0x0104:
			// hdv_init, initialize drives
			[self mem_put: RTS_OPCODE: 0xFC16BA: WORD_MASK];	//RTS

			// FC1CCE	JSR $FC0BD8			hdv_boot, load boot sector
			[self mem_put: NOP_OPCODE: 0xFC1CCE:   WORD_MASK];	//NOP
			[self mem_put: NOP_OPCODE: 0xFC1CCE + 2: WORD_MASK];	//NOP
			[self mem_put: NOP_OPCODE: 0xFC1CCE + 4: WORD_MASK];	//NOP

			// FC0466	BSR.W $FC054C		Boot from DMA bus
			if ( false /*bUseVDIRes*/) {
				[self mem_put: 0xa000: 0xFC0466: WORD_MASK];	//Init Line-A
				[self mem_put: 0xa0ff: 0xFC0466+2: WORD_MASK];	//Trap Line-A(to get structure)
			}
			else {
				[self mem_put: NOP_OPCODE: 0xFC0466: WORD_MASK];	//NOP
				[self mem_put: NOP_OPCODE: 0xFC0466+2: WORD_MASK];	//NOP
			}

			// FC02E6	CLR.L $4C2(A5)		Set connected drives
			[self mem_put: CONDRV_OPCODE: 0xFC02E6: WORD_MASK];
			[self mem_put: NOP_OPCODE: 0xFC02E6+2: WORD_MASK];	//NOP

			// Timer D(MFP init 0xFC34FC)
			[self mem_put: TIMERD_OPCODE: 0xFC3544: WORD_MASK];

			// Modify assembler loaded into cartridge area
			//Cart_WriteHdvAddress(0x181C);
			break;

		/*
			TOS 1.06 settings
		*/
//		case 0x0106:
//			// hdv_init, initialize drives
//			STMemory_WriteWord(0xE01892,RTS_OPCODE);	//RTS
//
//			// E01EA6	JSR $E00D74			hdv_boot, load boot sector
//			STMemory_WriteWord(0xE01EA6,NOP_OPCODE);	//NOP
//			STMemory_WriteWord(0xE01EA6+2,NOP_OPCODE);	//NOP
//			STMemory_WriteWord(0xE01EA6+4,NOP_OPCODE);	//NOP
//
//			// E00576	BSR.W $E0065C		Boot from DMA bus
//			if (bUseVDIRes) {
//				STMemory_WriteWord(0xE00576,0xa000);	//Init Line-A
//				STMemory_WriteWord(0xE00576+2,0xa0ff);	//Trap Line-A(to get structure)
//			}
//			else {
//				STMemory_WriteWord(0xE00576,NOP_OPCODE);	//NOP
//				STMemory_WriteWord(0xE00576+2,NOP_OPCODE);	//NOP
//			}
//
//			// E002DC	CLR.L $4C2(A5)		Set connected drives
//			STMemory_WriteWord(0xE002DC,CONDRV_OPCODE);
//			STMemory_WriteWord(0xE002DC+2,NOP_OPCODE);	//NOP
//
//			// Timer D(MFP init 0xE036BC)
//			STMemory_WriteWord(0xE03704,TIMERD_OPCODE);
//
//			// Modify assembler loaded into cartridge area
//			Cart_WriteHdvAddress(0x185C);
//			break;

		/*
			TOS 1.62 settings
		*/
//		case 0x0162:
//			// hdv_init, initialize drives
//			STMemory_WriteWord(0xE01892,RTS_OPCODE);	//RTS
//
//			// E01EA6	JSR $E00D74			hdv_boot, load boot sector
//			STMemory_WriteWord(0xE01EA6,NOP_OPCODE);	//NOP
//			STMemory_WriteWord(0xE01EA6+2,NOP_OPCODE);	//NOP
//			STMemory_WriteWord(0xE01EA6+4,NOP_OPCODE);	//NOP
//
//			// E00576	BSR.W $E0065C		Boot from DMA bus
//			if (bUseVDIRes) {
//				STMemory_WriteWord(0xE00576,0xa000);	//Init Line-A
//				STMemory_WriteWord(0xE00576+2,0xa0ff);	//Trap Line-A(to get structure)
//			}
//			else {
//				STMemory_WriteWord(0xE00576,NOP_OPCODE);	//NOP
//				STMemory_WriteWord(0xE00576+2,NOP_OPCODE);	//NOP
//			}
//
//			// E002DC	CLR.L $4C2(A5)		Set connected drives
//			STMemory_WriteWord(0xE002DC,CONDRV_OPCODE);
//			STMemory_WriteWord(0xE002DC+2,NOP_OPCODE);	//NOP
//
//			// Timer D(MFP init 0xE036BC)
//			STMemory_WriteWord(0xE03704,TIMERD_OPCODE);
//
//			// Modify assembler loaded into cartridge area
//			Cart_WriteHdvAddress(0x185C);
//			break;

		/*
			TOS 2.05 settings
		*/
		case 0x0205:
			// hdv_init, initialize drives
			[self mem_put: RTS_OPCODE: 0xE0468C: WORD_MASK];	//RTS

			// E04CA0	JSR $E00E8E			hdv_boot, load boot sector
			[self mem_put: NOP_OPCODE: 0xE04CA0: WORD_MASK];	//NOP
			[self mem_put: NOP_OPCODE: 0xE04CA0+2: WORD_MASK];	//NOP
			[self mem_put: NOP_OPCODE: 0xE04CA0+4: WORD_MASK];	//NOP

			// E006AE	BSR.W $E00794		Boot from DMA bus
			if (false /*bUseVDIRes*/) {
				[self mem_put: 0xE006AE : 0xa000: WORD_MASK];	//Init Line-A
				[self mem_put: 0xE006AE + 2: 0xa0ff: WORD_MASK];	//Trap Line-A(to get structure)
			}
			else {
				[self mem_put: NOP_OPCODE: 0xE006AE: WORD_MASK];	//NOP
				[self mem_put: NOP_OPCODE: 0xE006AE + 2: WORD_MASK];	//NOP
			}

			// E002FC	CLR.L $4C2			Set connected drives
			[self mem_put: CONDRV_OPCODE: 0xE002FC: WORD_MASK];
			[self mem_put: NOP_OPCODE: 0xE002FC+2: WORD_MASK];	//NOP

			// Timer D(MFP init 0xE01928)
			[self mem_put: TIMERD_OPCODE: 0xE01972: WORD_MASK];

			// Modify assembler loaded into cartridge area
			//Cart_WriteHdvAddress(0x1410);
			break;

		/*
			TOS 2.06 settings
		*/
		case 0x0206:
			// hdv_init, initialize drives
			[self mem_put: RTS_OPCODE: 0xE0518E: WORD_MASK];	//RTS

			// E05944	JSR	$E011DC			hdv_boot, load boot sector
			[self mem_put: NOP_OPCODE: 0xE05944: WORD_MASK];	//NOP
			[self mem_put: NOP_OPCODE: 0xE05944+2: WORD_MASK];	//NOP
			[self mem_put: NOP_OPCODE: 0xE05944+4: WORD_MASK];	//NOP

			// E00898	BSR.W	$E0097A		Boot from DMA bus
			if ( false /*bUseVDIRes*/) {
				[self mem_put: 0xa000: 0xE00898: WORD_MASK];	//Init Line-A
				[self mem_put: 0xa0ff: 0xE00898+2: WORD_MASK];	//Trap Line-A(to get structure)
			}
			else {
				[self mem_put: NOP_OPCODE: 0xE00898: WORD_MASK];	//NOP
				[self mem_put: NOP_OPCODE: 0xE00898+2: WORD_MASK];	//NOP
			}

			// E00362	CLR.L	$4C2		Set connected drives
			[self mem_put: CONDRV_OPCODE: 0xE00362: WORD_MASK];
			[self mem_put: NOP_OPCODE: 0xE00362+2: WORD_MASK];	//NOP

			// E007FA	MOVE.L	#$1FFFE,D7	Run checksums on 2xROMs(skip)
			// Checksum is total of TOS rom image, but get incorrect results as we've
			// changed bytes in the ROM! So, just skip anyway!
			[self mem_put: BRAW_OPCODE: 0xE007FA: WORD_MASK];	//BRA.W	$E00894
			[self mem_put: 0x98: 0xE007FA+2: WORD_MASK];

			// Timer D(MFP init 0xE02206)
			[self mem_put: TIMERD_OPCODE: 0xE02250: WORD_MASK];

			// Modify assembler loaded into cartridge area
			//Cart_WriteHdvAddress(0x1644);
			break;
	}
}
//----------------------------------------------------------------------------
/*
	Set default memory configuration, connected floppies and memory size
*/
-(void) TOS_SetDefaultMemoryConfig {

	// As TOS checks hardware for memory size + connected devices on boot-up
	// we set these values ourselves and fill in the magic numbers so TOS
	// skips these tests which would crash the emulator as the reference the MMU

	// Fill in magic numbers, so TOS does not try to reference MMU
	[self mem_put: 0x752019f3: 0x420: LONG_MASK];				// memvalid - configuration is valid
	[self mem_put: 0x237698aa: 0x43a: LONG_MASK];				// another magic #
	[self mem_put: 0x5555aaaa: 0x51a: LONG_MASK];				// and another

	// Set memory size, adjust for extra VDI screens if needed
	//if (NO) {
		// This is enough for 1024x768x16colour(0x60000)
	//	STMemory_WriteLong(0x436,MemoryInfo[ConfigureParams.Memory.nMemorySize].PhysTop-0x60000);			// mem top - upper end of user memory(before 32k screen)
	//	STMemory_WriteLong(0x42e,MemoryInfo[ConfigureParams.Memory.nMemorySize].PhysTop-0x58000);			// phys top
	//}
	//else {
		[self mem_put: /*MemoryInfo[ConfigureParams.Memory.nMemorySize].PhysTop*/0x400000 - 0x8000: 0x436: LONG_MASK];	// mem top - upper end of user memory(before 32k screen)
		[self mem_put: /*MemoryInfo[ConfigureParams.Memory.nMemorySize].PhysTop*/0x400000: 0x42e: LONG_MASK];			// phys top
	//}
	[self mem_put: 0x1010: 0x424: LONG_MASK];																// 512k configure 0x00=128k 0x01=512k 0x10=2Mb 11=reserved eg 0x1010 = 4Mb

	// Set memory range, and start of BUS error
	//self->STRamEnd = MemoryInfo[ConfigureParams.Memory.nMemorySize].MemoryEnd;					// Set end of RAM
	self->STRamEnd_BusErr = 0x00420000;		// 4Mb												// Between RAM end and this is void space(0's), after is a BUS error

	// Set TOS floppies
	[self mem_put: 0x00: 0x446: WORD_MASK];						// Boot up on A(0) or C(2)
	[self mem_put: 0x2: 0x4a6: WORD_MASK];						// Connected floppies A,B (0 or 2)
	
	//ConnectedDriveMask = ConnectedDriveMaskList[ConfigureParams.HardDisc.nDriveList];
	//DRIVELIST_CDEF
	[self mem_put: 0x3F /*ConnectedDriveMask*/: 0x4c2: LONG_MASK];		// Drives A,B and C - NOTE some TOS images overwrite value, see 'TOS_ConnectedDrive_OpCode'
}
//----------------------------------------------------------------------------
-(bool) LoadTOS:(NSString *) filename {

	bool	code = false;
	
	NSString* fileRoot = [[NSBundle mainBundle] pathForResource: filename ofType:@"img"];
	
	NSFileHandle *fileTOS = [NSFileHandle fileHandleForReadingAtPath:fileRoot];	
	NSData *datas = [fileTOS readDataToEndOfFile];

	//	allocate 512Mb by default either ROMs TOS
	unsigned char *romImage = malloc( 512 * 1024);
	[datas getBytes:romImage];

	//[fileTOS closeFile];

	// Now, look at start of image to find Version number and Territory
	unsigned short int *pVersionPtr	= (unsigned short int *)((unsigned long)romImage + 0x2);
	unsigned short int *pTerritoryPtr	= (unsigned short int *)((unsigned long)romImage + 0x1c);
	
	self->TOSVersion	= [self Swap68000Int:(unsigned short int)*pVersionPtr];
	self->TOSLanguage	= [self Swap68000Int:(unsigned short int)*pTerritoryPtr];
	self->TOSAddress	= 0L;
	self->TOSSize		= 0L;
	
	// Now see where to copy image
	switch( self->TOSVersion ) {
	
		case 0x0100:					// TOS 1.00
		case 0x0102:					// TOS 1.02
		case 0x0104:					// TOS 1.04
			TOSAddress = 0xFC0000;
			TOSSize = 192*1024;			// 192k
			break;

		// TOSes 1.06 and 1.62 are for the STe ONLY and so don't run on a real STfm.
		// They access illegal memory addresses which don't exist on a real machine and cause the OS
		// to lock up. So, if user selects one of these, show error and default to original TOS
		case 0x0106:					// TOS 1.06
		case 0x0162:					// TOS 1.62
			//WinSTon_Message(hWnd,"TOS versions 1.06 and 1.62 are NOT valid STfm images.\n\nThese were only designed for use on the STe range of machines.\nWinSTon will default back to the built-in TOS 1.00.",PROG_NAME,MB_OK | MB_ICONINFORMATION);
			break;

		case 0x0205:					// TOS 2.05
		case 0x0206:					// TOS 2.06
			TOSAddress = 0xE00000;
			TOSSize = 256*1024;			// 256k
			break;
	}

	if( TOSAddress > 0L && TOSSize > 0L ) {
		// Copy loaded image into ST memory, if found valid one
		long i = 0;
		for( i = 0; i < TOSSize; i++ ) {
			
			self->memory[ (unsigned int)(TOSAddress + i) ] = romImage[ i ];
		}
		
		//memcpy( (void *)((unsigned long)self->memory + TOSAddress), romImage, TOSSize);
	
		// Fix TOS image, modify code for emulation
		[self TOS_FixRom];

		// Set connected devices, memory configuration
		[self TOS_SetDefaultMemoryConfig];
		
		code = true;
	}
	free(romImage);
	
	return code;
}
//----------------------------------------------------------------------------
//	load in the cartridge space the diagnostics Atari ROMs.
-(void) LoadROMCartridge:(NSString *) romHighName:(NSString *)romLowName {

	NSString* nameHigh = [[NSBundle mainBundle] pathForResource: romHighName ofType:@"img"];
	NSString* nameLow = [[NSBundle mainBundle] pathForResource: romLowName ofType:@"img"];
	
	NSFileHandle *fileHigh = [NSFileHandle fileHandleForReadingAtPath: nameHigh];	
	NSFileHandle *fileLow = [NSFileHandle fileHandleForReadingAtPath: nameLow];	

	NSData *datasHigh = [fileHigh readDataToEndOfFile];
	NSData *datasLow = [fileLow readDataToEndOfFile];
	
	//	allocate 512Mb by default
	unsigned char *romHigh = malloc( 64 * 1024);
	unsigned char *romLow = malloc( 64 * 1024);

	[datasHigh getBytes:romHigh];
	[datasLow getBytes:romLow];

	int i = 0;
	int j = 0;
	int size = [datasHigh length];
	while( i < size ) {
		
		self->memory[ (unsigned int)(CARTRIDGEAddress + i + 0) ] = romHigh[ j ];		
		self->memory[ (unsigned int)(CARTRIDGEAddress + i + 1) ] = romLow [ j ];		
		
		i += 2;
		j++;
	}
	
	free(romHigh);
	free(romLow);
}
//----------------------------------------------------------------------------
// Check for memory map violations
// Pre: mapt contains map type flags
//      INVALID | PROTECTED | READ | ROM
// Post: initiates bus error if necessary and returns error code

-(int) memoryMapCheck:(maptype) mapt:(int) loc:(int) bytes {

  /*	Pour le moment aucun controle d'accËs mÈmoire
  
  // if access outside valid 68000 memory map
  if(loc < 0 || loc > MEMSIZE-1){               // if Invalid memory area
    if (exceptions) {
      [self mem_req: 0x8: LONG_MASK: &self->regPC];            // get bus error vector
      [self exceptionHandler: 0: (long) loc: WRITE];
    }
    else{
      //haltSimulator();
      //Form1->Message->Lines->Add(str.sprintf("Bus Error: Instruction at %4x accessing address %4x", self->OLD_PC, loc));
    }
    return BUS_ERROR;
  }

  // Check for access to areas of memory defined in the Memory Map of the
  // hardware window.

  if(InvalidMap && (mapt & Invalid)) {  // if Invalid map (bus error on access)
    if(loc+bytes-1 >= InvalidStart && loc <= InvalidEnd){ // if Invalid memory area
      if (exceptions) {
        [self mem_req: 0x8: LONG_MASK: &self->regPC];        // get bus error vector
        [self exceptionHandler: 0: (long) loc: WRITE];
      }
      else{
        //haltSimulator();
        //Form1->Message->Lines->Add(str.sprintf("Bus Error: Instruction at %4x accessing address %4x", self->OLD_PC, loc));
      }
      return BUS_ERROR;
    }
  }

  if(ProtectedMap && (mapt & Protected)) {    // if Protected map (bus error if not supervisor mode)
    if(loc+bytes-1 >= ProtectedStart && loc <= ProtectedEnd){ // if Protected memory area
      if( (self->regSR & sbit) == 0 /*Form1->regSR->EditText[3] == '0' ){    // if not Supervisor mode
        if ( exceptions) {
          [self mem_req: 0x8: LONG_MASK: &self->regPC];        // get bus error vector
          [self exceptionHandler: 0: (long) loc: WRITE];
        }
        else {
          //haltSimulator();
          //Form1->Message->Lines->Add(str.sprintf("Bus Error: Instruction at %4x accessing address %4x", OLD_PC, loc));
        }
        return BUS_ERROR;
       }
    }
  }

  if(ReadMap && (mapt & Read)) {								// if Read map (bus error on write)
    if(loc+bytes-1 >= ReadStart && loc <= ReadEnd){				// if Read Only memory area
      if (exceptions) {
        [self mem_req: 0x8: LONG_MASK: &self->regPC];			// get bus error vector
        [self exceptionHandler: 0: (long) loc: WRITE];
      }
      else{
        //haltSimulator();
        //Form1->Message->Lines->Add(str.sprintf("Bus Error: Instruction at %4x accessing address %4x", OLD_PC, loc));
      }
      return BUS_ERROR;
    }
  }

  if(ROMMap && (mapt & Rom)) {									// if ROM map, must be checked last, (writes are ignored)
    if(loc+bytes-1 >= ROMStart && loc <= ROMEnd) {				// if ROM memory area
		return ROM_MAP;											// writes are ignored
    }
  }*/

  return SUCCESS;
}

/**************************** int mem_put() ********************************

   name       : int mem_put(data, loc, size)
   parameters : long data : the data to be placed in memory
                int loc   : the location to place the data
                long size : the appropriate size mask for the operation
   function   : mem_put() puts data in main memory.  It acts as the "memory
                  management unit" in that it checks for out-of-bound
                  virtual addresses and odd memory accesses on long and
                  word operations and performs the appropriate traps in
                  the cases where there is a violation.  Theoretically,
                  this is the only place in the simulator where the main
                  memory should be written to.

****************************************************************************/

-(int) mem_put:(long) data:(int) loc:(long) size {

  int bytes = 1;
  int code;

  if (size == WORD_MASK)
    bytes = 2;
  else if (size == LONG_MASK)
    bytes = 4;

  // check for odd location reference on word and longword writes
  // if there is a violation, initiate an address exception
  if ((loc % 2 != 0) && (size != BYTE_MASK))
  {
    // generate an address error
    if (exceptions) {
      [self mem_req: 0xc: LONG_MASK: &self->regPC];        // get address error vector
      [self exceptionHandler: 0: (long) loc: WRITE];
    }
    else{
      //haltSimulator();
      //Form1->Message->Lines->Add(str.sprintf ("Address Error: Instruction at %4x accessing address %4x", OLD_PC, loc));
    }
    return (ADDR_ERROR);
  }

  // CK 10/2009 The upper 8 bits of address are not external to the 68000 so
  // all memory I/O occurs in a 24 bit address map regardless of what the upper
  // 8 bits of the specified address contains.
  loc = loc & ADDRMASK;       // strip upper byte (24 bit address bus on 68000)

  // check memory map
	code = [self memoryMapCheck: (Invalid | Protected | Read | Rom) : loc: bytes ];
  if (code == BUS_ERROR)        // if bus error caused by memory map
    return code;
  if (code == ROM_MAP)          // if ROM map, writes are ignored
    return SUCCESS;

  // if everything is okay then perform the write according to size
  if (size == BYTE_MASK) {
    self->memory[loc] = data & BYTE_MASK;
  }
  else if (size == WORD_MASK)
  {
    self->memory[loc] = (data >> 8) & BYTE_MASK;
    self->memory[loc+1] = data & BYTE_MASK;
  }
  else if (size == LONG_MASK)
  {
    self->memory[loc] = (data >> 24) & BYTE_MASK;
    self->memory[loc+1] = (data >> 16) & BYTE_MASK;
    self->memory[loc+2] = (data >> 8) & BYTE_MASK;
    self->memory[loc+3] = data & BYTE_MASK;
  }

  writeEA = (long *)&self->memory[loc];
  bpWrite = true;
  //Hardware->updateIfNeeded(loc);        // update hardware display
  //MemoryFrm->LivePaint(loc);            // update memory display
  
  return SUCCESS;
}


/**************************** int mem_req() ********************************

   name       : int mem_req(loc, size, result)
   parameters : int loc : the memory location to read data from
                long size : the appropriate size mask for the operation
                long *result : a pointer to the longword location
                      to store the result in
   function   : mem_req() returns the contents of a location in main
                  memory.  It acts as the "memory management unit" in
                  that it checks for out-of-bound virtual addresses and
                  odd memory accesses on long and word operations and
                  performs the appropriate traps in the cases where there
                  is a violation.  Theoretically, this is the only function
                  in the simulator where the main memory should be read
                  from.

****************************************************************************/

-(int) mem_req:(int) loc:(long) size:(long *) result {

  long	temp;

  /* check for odd location reference on word and longword reads. */
  /* If there is a violation, initiate an address exception */
  if ((loc % 2 != 0) && (size != BYTE_MASK))
  {
    // generate an address error
    if (exceptions) {
      self->OLD_PC = self->regPC-2;                        //ck 12-16-2005
      [self mem_req: 0xc: LONG_MASK: &self->regPC];        // get address error vector
      [self exceptionHandler: 0: (long) loc: READ];
    }
    else{
      //haltSimulator();
      //Form1->Message->Lines->Add(str.sprintf("Address Error: Instruction at %4x accessing address %4x", OLD_PC, loc));
    }
    return (ADDR_ERROR);
  }

  // CK 10/2009 The upper 8 bits of address are not external to the 68000 so
  // all memory I/O occurs in a 24 bit address map regardless of what the upper
  // 8 bits of the specified address contains.
  loc = loc & ADDRMASK;       // strip upper byte (24 bit address bus on 68000)

    if(ProtectedMap) {    // bus error if not supervisor mode
      if(loc >= ProtectedStart && loc <= ProtectedEnd){ // if Protected memory area
        if( (self->regSR & sbit) == 0 /*Form1->regSR->EditText[3] == '0'*/){    // if not Supervisor mode
          if (exceptions) {
            [self mem_req: 0x8: LONG_MASK: &self->regPC];        // get bus error vector
            [self exceptionHandler: 0: (long) loc: WRITE];
          }
          else{
            //haltSimulator();
            //Form1->Message->Lines->Add(str.sprintf("Bus Error: Instruction at %4x accessing address %4x", OLD_PC, loc));
          }
          return (BUS_ERROR);
        }
      }
    }
  
  /* if everything is okay then perform the read according to size */
  temp = self->memory[loc] & BYTE_MASK;
  if (size != BYTE_MASK)
  {
    temp = (temp << 8) | (self->memory[loc + 1] & BYTE_MASK);
    if (size != WORD_MASK)
    {
      temp = (temp << 8) | (self->memory[loc + 2] & BYTE_MASK);
      temp = (temp << 8) | (self->memory[loc + 3] & BYTE_MASK);
    }
  }
  *result = temp;

  readEA = (long *)&self->memory[loc];
  bpRead = true;
  return SUCCESS;
}




/**************************** int mem_request() ****************************

   name       : int mem_request (loc, size, result)
   parameters : int *loc : the memory location to read data from
                long size : the appropriate size mask for the operation
                long *result : a pointer to the longword location
                      to store the result in
   function   : mem_request() is another "level" of main-memory access.
                  It performs the task of calling the functin mem_req()
                  (above) using "WORD_MASK" for the size mask if the simulator
                  wants a byte from main memory.  Also, it increments
                  the location pointer passed to it.  This is to
                  facilitate easy opcode and operand fetch operations
                  where the program counter needs to be incremented.

                  Therefore, in the simulator, "mem_req()" requests data
                  from main memory, and "mem_request()" does the same but
                  also increments the location pointer.  Note that
                  mem_request() requires a pointer to an int as the first
                  parameter.

****************************************************************************/

-(int) mem_request:(long *)loc:(long) size:(long *) result {

	int	req_result;

	if (size == LONG_MASK)
		req_result = [self mem_req: *loc: LONG_MASK: result];
	else
		req_result = [self mem_req: *loc: (long) WORD_MASK: result];

	if (size == BYTE_MASK)
		*result = *result & 0xff;

	if (!req_result)
		if (size == LONG_MASK)
			*loc += 4;
		else
			*loc += 2;

	return req_result;
}
-(void) exceptionHandler:(int) clas:(long) loc:(int) r_w {

	//	to be overload in the derivate class
}

@end
