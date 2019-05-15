#int strtoint(char * string, int * num, int base);
.section .text
.globl strtoint
strtoint:
	pushl %ebp
	movl %esp, %ebp
	pushl $0
	pushl %ebx

	movl 8(%ebp), %ecx

	xorl %eax, %eax
processDigit:
    xorl %ebx, %ebx
    movb (%ecx), %bl
    
	#cmpb $'0', %bl
	#jb error
	cmpb $'9', %bl
	jbe num
	#cmpb $'A', %bl
	#jb error
	cmpb $'Z', %bl
	jbe cap
	#cmpb $'a', %bl
	#jb error
	cmpb $'z', %bl
	jbe nocap
	jmp error
num:
    subb $'0', %bl
    js error
    jmp cont
cap:
    subb $55, %bl
    js error
    jmp cont
nocap:
    subb $87, %bl
    js error
cont:
    cmpl 16(%ebp), %ebx
    jae error
    
	mull 16(%ebp)
	jc error2
	
	addl %ebx, %eax
	jc error2
	
	incl %ecx
	cmpb $10, (%ecx)       #\n instead of \0
	je done
	jmp processDigit
error2:
	incl -4(%ebp)
error:
	incl -4(%ebp)
done:
	movl 12(%ebp), %edx
	movl %eax, (%edx)
	movl -4(%ebp), %eax
end:
    popl %ebx
	movl %ebp, %esp
	popl %ebp
	ret
