#/* $begin seq-all-hcl */
#/* $begin seq-plus-all-hcl */
####################################################################
#  HCL Description of Control for Single Cycle Y86 Processor SEQ   #
#  Copyright (C) Randal E. Bryant, David R. O'Hallaron, 2002       #
####################################################################

####################################################################
#    C Include's.  Don't alter these                               #
####################################################################

quote '#include <stdio.h>'
quote '#include "isa.h"'
quote '#include "sim.h"'
quote 'int sim_main(int argc, char *argv[]);'
quote 'int gen_pc(){return 0;}'
quote 'int main(int argc, char *argv[])'
quote '  {plusmode=0;return sim_main(argc,argv);}'

####################################################################
#    Declarations.  Do not change/remove/delete any of these       #
####################################################################

##### Symbolic representation of Y86 Instruction Codes #############
intsig NOP 	'I_NOP'
intsig HALT	'I_HALT'
intsig RRMOVL	'I_RRMOVL'
intsig IRMOVL	'I_IRMOVL'
intsig RMMOVL	'I_RMMOVL'
intsig MRMOVL	'I_MRMOVL'
intsig OPL	'I_ALU'
intsig IOPL	'I_ALUI'
intsig JXX	'I_JXX'
intsig CALL	'I_CALL'
intsig RET	'I_RET'
intsig PUSHL	'I_PUSHL'
intsig POPL	'I_POPL'
intsig JMEM	'I_JMEM'
intsig JREG	'I_JREG'
intsig LEAVE	'I_LEAVE'

intsig ENTER	'I_ENTER'
intsig MUL	'I_MUL'
intsig LODS	'I_LODS'	
intsig MOVS     'I_MOVS'
#I_fun pour la factorisation push/call/pop/ret : composés de PUSH et des deux premières
#lettres de l'instruction originelle.	
intsig PUSH_PU 	'J_PUSH'
intsig PUSH_CA 	'J_CALL'
intsig PUSH_PO	'J_POP'
intsig PUSH_RE  'J_RET'

intsig LODS_LO  'J_LODS'
intsig LODS_ST	'J_STOS'
##### Symbolic representation of Y86 Registers referenced explicitly #####
intsig RESP     'REG_ESP'    	# Stack Pointer
intsig REBP     'REG_EBP'    	# Frame Pointer
intsig RNONE    'REG_NONE'   	# Special value indicating "no register"
intsig REAX	'REG_EAX'	# eax register
intsig RESI	'REG_ESI'	# esi register
intsig REDI	'REG_EDI'	# edi register

##### ALU Functions referenced explicitly                            #####
intsig ALUADD	'A_ADD'		# ALU should add its arguments

intsig cc 'cc'

##### Signals that can be referenced by control logic ####################

##### Fetch stage inputs		#####
intsig pc 'pc'				# Program counter
##### Fetch stage computations		#####
intsig icode	'icode'			# Instruction control code
intsig ifun	'ifun'			# Instruction function
intsig rA	'ra'			# rA field from instruction
intsig rB	'rb'			# rB field from instruction
intsig valC	'valc'			# Constant from instruction
intsig valP	'valp'			# Address of following instruction

##### Decode stage computations		#####
intsig valA	'vala'			# Value from register A port
intsig valB	'valb'			# Value from register B port

##### Execute stage computations	#####
intsig valE	'vale'			# Value computed by ALU
boolsig Bch	'bcond'			# Branch test

##### Memory stage computations		#####
intsig valM	'valm'			# Value read from memory


####################################################################
#    Control Signal Definitions.                                   #
####################################################################

################ Fetch Stage     ###################################

# Does fetched instruction require a regid byte?
bool need_regids =
	icode in { RRMOVL, OPL, PUSHL, RMMOVL, MRMOVL, JREG, JMEM, MUL };

# Does fetched instruction require a constant word?
bool need_valC =
	icode in { RRMOVL, RMMOVL, MRMOVL, JXX, PUSHL, OPL, JMEM };

bool instr_valid = icode in 
	{ NOP, HALT, RRMOVL, RMMOVL, MRMOVL,
	OPL, JXX, PUSHL, JREG, JMEM, LEAVE, ENTER, MUL, LODS, MOVS };

int instr_next_ifun = [
        icode == MUL && ifun == 0 : 1;
        icode == MUL && ifun == 1 : 2;
        icode == MUL && ifun == 2 && cc == 2 : -1;
        icode == MUL : 1;
        icode == MOVS && ifun == 0 : 1;
        icode == MOVS && ifun == 1 : 2;
        icode == MOVS && ifun == 2 : 3;
        icode == ENTER && ifun == 0 : 1;
        1 : -1;
];

################ Decode Stage    ###################################

## What register should be used as the A source?
int srcA = [
	icode == MUL && ifun == 1 : rB;
	icode == LODS && ifun == LODS_LO :  RESI;
	icode == LODS : REDI;
        icode == MOVS && ifun == 1 : RESI;
        icode == MOVS && ifun == 2 : REDI;
        icode == MOVS : RESP;
	icode in { RRMOVL, RMMOVL, OPL, PUSHL, JREG, MUL } : rA;
	icode in { LEAVE, ENTER } : REBP;
	1 : RNONE; # Don't need register
];

## What register should be used as the B source?
int srcB = [
	icode in { MUL, LODS, MOVS } : REAX;
	icode in { OPL, RMMOVL, MRMOVL, JMEM } : rB;
	icode in { PUSHL, ENTER } : RESP;
	icode in { LEAVE } : REBP;
	1 : RNONE;  # Don't need register
];

## What register should be used as the E destination?
int dstE = [
	icode in { RRMOVL, OPL } : rB;
	icode == LODS && ifun == LODS_LO : RESI;
	icode == LODS : REDI;
        icode == MOVS && ifun == 1 : RESI;
        icode == MOVS && ifun == 2 : REDI;
        icode == MOVS : RESP;
	icode == ENTER && ifun == 1 : REBP;
	icode in { PUSHL, LEAVE, ENTER } : RESP;
	icode == MUL && ifun == 1 : rB;    
	icode == MUL : REAX;
	1 : RNONE;  # Don't need register
];

## What register should be used as the M destination?
int dstM = [
	icode == PUSHL && ifun in { PUSH_PO, PUSH_RE } : rA;
	icode == LODS && ifun == LODS_LO : REAX;
        icode == MOVS && ifun in  { 1, 3 } : REAX;
	icode == MRMOVL : rA;
	icode in { LEAVE } : REBP;
	1 : RNONE;  # Don't need register
];

################ Execute Stage   ###################################

## Select input A to ALU
int aluA = [
	icode == OPL && rA == RNONE: valC;
	icode == OPL : valA;
	icode == MUL && ifun == 0 : 0;
	icode == MUL && cc == 2: 0;
	icode == MUL : valA;
	icode == RRMOVL && rA == RNONE: valC;
	icode in { RRMOVL } : valA;
	icode == LODS : valA;
        icode == MOVS : valA;
	icode in { RMMOVL, MRMOVL, JMEM } : valC;
	icode == PUSHL  && ifun in { PUSH_PU, PUSH_CA } : -4;
	icode == ENTER && ifun == 1 : 0;
	icode == ENTER : -4;
	icode in { PUSHL, LEAVE } : 4;
	# Other instructions don't need ALU
];

## Select input B to ALU
int aluB = [
	icode in { RMMOVL, MRMOVL, OPL, PUSHL, JMEM, LEAVE, ENTER } : valB;
	icode == MUL && ifun == 0 : 0;
	icode == MUL && ifun == 1 :-1;
	icode == MUL : valB;
	icode == LODS : 4;
        icode == MOVS && ifun in { 1 , 2, 3 } : 4;
        icode == MOVS : -4;
	icode in { RRMOVL } : 0;
	# Other instructions don't need ALU
];

## Set the ALU function
int alufun = [
	icode in { OPL } : ifun;
	1 : ALUADD;
];

## Should the condition codes be updated?
bool set_cc = icode in { OPL } ||
              icode == MUL && ifun in { 0, 1 };

################ Memory Stage    ###################################

## Set read control signal
bool mem_read =
    (icode == PUSHL && ifun in { PUSH_PO, PUSH_RE }) ||
    (icode == LODS && ifun == LODS_LO) ||
    (icode == MOVS && ifun in { 1, 3 }) ||
    (icode in { MRMOVL, JMEM, LEAVE });


## Set write control signal
bool mem_write =
    (icode == PUSHL && ifun in { PUSH_PU, PUSH_CA }) ||
    (icode == LODS && ifun == LODS_ST) ||
    (icode == MOVS && ifun in { 0, 2 }) ||
    (icode == ENTER && ifun in { 0, 2 }) ||
    (icode == RMMOVL);

## Select memory address
int mem_addr = [
	icode == PUSHL && ifun in { PUSH_PU, PUSH_CA } : valE;
	icode in { RMMOVL, MRMOVL, JMEM, ENTER } : valE;
        icode == MOVS && ifun == 0 : valE;
	icode in { LODS, MOVS } : valA;
	icode == PUSHL : valB;
	icode == LEAVE : valA;
	# Other instructions don't need address
];

## Select memory input data
int mem_data = [
	# Return PC
	icode == PUSHL && ifun == PUSH_CA : valP;
	icode == PUSHL && ifun == PUSH_PU : valA;
	icode in { LODS, MOVS } : valB;
	# Value from register
	icode in { RMMOVL, ENTER } : valA;
	
	# Default: Don't write anything
];

################ Program Counter Update ############################

## What address should instruction be fetched at

int new_pc = [
	icode == JMEM : valM ;
	# Call.  Use instruction constant
	icode == PUSHL && ifun == PUSH_CA : valC;
	# Taken branch.  Use instruction constant
	icode == JXX && Bch : valC;
	# Completion of RET instruction.  Use value from stack
	icode == PUSHL && ifun == PUSH_RE : valM;

	icode == JREG : valA;
	# Default: Use incremented PC
	1 : valP;
];
#/* $end seq-plus-all-hcl */
#/* $end seq-all-hcl */
