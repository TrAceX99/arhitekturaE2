#int inttostr(int num, char * string, int base);
.section .text
.globl inttostr
inttostr:
	pushl %ebp
	movl %esp, %ebp
	pushl $0
    
    movl 12(%ebp), %ecx
    movl 8(%ebp), %eax
processDigit:
    xorl %edx, %edx
    divl 16(%ebp)
    cmpb $10, %dl
    jae letter
    addb $'0', %dl
    jmp cont
letter:
    addb $55, %dl
cont:
    movb %dl, (%ecx)
    incl %ecx
    andl %eax, %eax
    jnz processDigit
    
    decl %ecx
    movl 12(%ebp), %edx
reverse:
    cmpl %ecx, %edx
    jae end
    movb (%edx), %ah
    movb (%ecx), %al
    movb %al, (%edx)
    movb %ah, (%ecx)
    decl %ecx
    incl %edx
    jmp reverse
end:
    movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
