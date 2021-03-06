char simname[] = "Y86 Processor: seq-std.hcl";
#include <stdio.h>
#include "isa.h"
#include "sim.h"
int sim_main(int argc, char *argv[]);
int gen_pc(){return 0;}
int main(int argc, char *argv[])
  {plusmode=0;return sim_main(argc,argv);}
int gen_need_regids()
{
    return ((icode) == (I_RRMOVL)||(icode) == (I_ALU)||(icode) == (I_PUSHL)||(icode) == (I_RMMOVL)||(icode) == (I_MRMOVL)||(icode) == (I_JREG)||(icode) == (I_JMEM)||(icode) == (I_MUL));
}

int gen_need_valC()
{
    return ((icode) == (I_RRMOVL)||(icode) == (I_RMMOVL)||(icode) == (I_MRMOVL)||(icode) == (I_JXX)||(icode) == (I_PUSHL)||(icode) == (I_ALU)||(icode) == (I_JMEM));
}

int gen_instr_valid()
{
    return ((icode) == (I_NOP)||(icode) == (I_HALT)||(icode) == (I_RRMOVL)||(icode) == (I_RMMOVL)||(icode) == (I_MRMOVL)||(icode) == (I_ALU)||(icode) == (I_JXX)||(icode) == (I_PUSHL)||(icode) == (I_JREG)||(icode) == (I_JMEM)||(icode) == (I_LEAVE)||(icode) == (I_ENTER)||(icode) == (I_MUL));
}

int gen_instr_next_ifun()
{
    return ((((icode) == (I_MUL)) & ((ifun) == 0)) ? 1 : (((icode) == (I_MUL)) & ((ifun) == 1)) ? 2 : ((((icode) == (I_MUL)) & ((ifun) == 2)) & ((cc) == 2)) ? -1 : ((icode) == (I_MUL)) ? 1 : (((icode) == (I_ENTER)) & ((ifun) == 0)) ? 1 : 1 ? -1 : 0);
}

int gen_srcA()
{
    return ((((icode) == (I_MUL)) & ((ifun) == 1)) ? (rb) : ((icode) == (I_RRMOVL)||(icode) == (I_RMMOVL)||(icode) == (I_ALU)||(icode) == (I_PUSHL)||(icode) == (I_JREG)||(icode) == (I_MUL)) ? (ra) : ((icode) == (I_LEAVE)||(icode) == (I_ENTER)) ? (REG_EBP) : 1 ? (REG_NONE) : 0);
}

int gen_srcB()
{
    return (((icode) == (I_MUL)) ? (REG_EAX) : ((icode) == (I_ALU)||(icode) == (I_RMMOVL)||(icode) == (I_MRMOVL)||(icode) == (I_JMEM)) ? (rb) : ((icode) == (I_PUSHL)||(icode) == (I_ENTER)) ? (REG_ESP) : ((icode) == (I_LEAVE)) ? (REG_EBP) : 1 ? (REG_NONE) : 0);
}

int gen_dstE()
{
    return (((icode) == (I_RRMOVL)||(icode) == (I_ALU)) ? (rb) : (((icode) == (I_ENTER)) & ((ifun) == 1)) ? (REG_EBP) : ((icode) == (I_PUSHL)||(icode) == (I_LEAVE)||(icode) == (I_ENTER)) ? (REG_ESP) : (((icode) == (I_MUL)) & ((ifun) == 1)) ? (rb) : ((icode) == (I_MUL)) ? (REG_EAX) : 1 ? (REG_NONE) : 0);
}

int gen_dstM()
{
    return ((((icode) == (I_PUSHL)) & ((ifun) == (J_POP)||(ifun) == (J_RET))) ? (ra) : ((icode) == (I_MRMOVL)) ? (ra) : ((icode) == (I_LEAVE)) ? (REG_EBP) : 1 ? (REG_NONE) : 0);
}

int gen_aluA()
{
    return ((((icode) == (I_ALU)) & ((ra) == (REG_NONE))) ? (valc) : ((icode) == (I_ALU)) ? (vala) : (((icode) == (I_MUL)) & ((ifun) == 0)) ? 0 : (((icode) == (I_MUL)) & ((cc) == 2)) ? 0 : ((icode) == (I_MUL)) ? (vala) : (((icode) == (I_RRMOVL)) & ((ra) == (REG_NONE))) ? (valc) : ((icode) == (I_RRMOVL)) ? (vala) : ((icode) == (I_RMMOVL)||(icode) == (I_MRMOVL)||(icode) == (I_JMEM)) ? (valc) : (((icode) == (I_PUSHL)) & ((ifun) == (J_PUSH)||(ifun) == (J_CALL))) ? -4 : (((icode) == (I_ENTER)) & ((ifun) == 1)) ? 0 : ((icode) == (I_ENTER)) ? -4 : ((icode) == (I_PUSHL)||(icode) == (I_LEAVE)) ? 4 : 0);
}

int gen_aluB()
{
    return (((icode) == (I_RMMOVL)||(icode) == (I_MRMOVL)||(icode) == (I_ALU)||(icode) == (I_PUSHL)||(icode) == (I_JMEM)||(icode) == (I_LEAVE)||(icode) == (I_ENTER)) ? (valb) : (((icode) == (I_MUL)) & ((ifun) == 0)) ? 0 : (((icode) == (I_MUL)) & ((ifun) == 1)) ? -1 : ((icode) == (I_MUL)) ? (valb) : ((icode) == (I_RRMOVL)) ? 0 : 0);
}

int gen_alufun()
{
    return (((icode) == (I_ALU)) ? (ifun) : 1 ? (A_ADD) : 0);
}

int gen_set_cc()
{
    return (((icode) == (I_ALU)) | (((icode) == (I_MUL)) & ((ifun) == 0||(ifun) == 1)));
}

int gen_mem_read()
{
    return ((((icode) == (I_PUSHL)) & ((ifun) == (J_POP)||(ifun) == (J_RET))) | ((icode) == (I_MRMOVL)||(icode) == (I_JMEM)||(icode) == (I_LEAVE)));
}

int gen_mem_write()
{
    return (((((icode) == (I_PUSHL)) & ((ifun) == (J_PUSH)||(ifun) == (J_CALL))) | (((icode) == (I_ENTER)) & ((ifun) == 0))) | ((icode) == (I_RMMOVL)));
}

int gen_mem_addr()
{
    return ((((icode) == (I_PUSHL)) & ((ifun) == (J_PUSH)||(ifun) == (J_CALL))) ? (vale) : ((icode) == (I_RMMOVL)||(icode) == (I_MRMOVL)||(icode) == (I_JMEM)||(icode) == (I_ENTER)) ? (vale) : ((icode) == (I_PUSHL)) ? (valb) : ((icode) == (I_LEAVE)) ? (vala) : 0);
}

int gen_mem_data()
{
    return ((((icode) == (I_PUSHL)) & ((ifun) == (J_CALL))) ? (valp) : (((icode) == (I_PUSHL)) & ((ifun) == (J_PUSH))) ? (vala) : ((icode) == (I_RMMOVL)||(icode) == (I_ENTER)) ? (vala) : 0);
}

int gen_new_pc()
{
    return (((icode) == (I_JMEM)) ? (valm) : (((icode) == (I_PUSHL)) & ((ifun) == (J_CALL))) ? (valc) : (((icode) == (I_JXX)) & (bcond)) ? (valc) : (((icode) == (I_PUSHL)) & ((ifun) == (J_RET))) ? (valm) : ((icode) == (I_JREG)) ? (vala) : 1 ? (valp) : 0);
}

