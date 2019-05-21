# podaci drajvera ekrana
.section .data

# promenljive dostupne iz glavnog C programa
.extern scrwidth    # širina emuliranog ekrana
.extern scrheight   # visina emuliranog ekrana
.extern screen      # memorija emuliranog ekrana
.extern scrsize     # broj bajtova emuliranog ekrana

.section .text
.globl plot
.globl drawrect
.globl fillrect
.globl sprite

# void plot(int x, int y, int col)
plot:
    pushl %ebp
    movl %esp, %ebp
    pushl $4                #argument za divl
    
    leal screen, %ecx       #adresa bajta koji se menja
    
    # X/4 dodajemo na adresu, X%4 na stek
    movl 8(%ebp), %eax
    cmpl scrwidth, %eax     #provera greske za X
    jae pend
    xorl %edx, %edx
    divl -4(%ebp)
    pushl %edx
    addl %eax, %ecx
    
    # Y*sirina/4 dodajemo na adresu, adresa premestena u %eax
    movl 12(%ebp), %eax
    cmpl scrheight, %eax    #provera greske za y
    jae pend
    mull scrwidth
    shrl $2, %eax           #deljenje sa 4
    addl %ecx, %eax
    
    #izracunavanje pozicije bita u %ecx
    popl %edx
    movl $3, %ecx
    subl %edx, %ecx
    shll $1, %ecx           #deljenje sa 2
    
    #postavljanje bita na crnu boju
    movl $0b11, %edx
    shll %cl, %edx
    notl %edx
    andl %edx, (%eax)
    
    #postavljanje bita na odgovarajucu boju
    movl 16(%ebp), %edx
    shll %cl, %edx
    orl %edx, (%eax)
pend:
    movl %ebp, %esp
    popl %ebp
    ret

# void drawrect(int x1, int y1, int x2, int y2, int col)
drawrect:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    pushl %esi
    
    # X -> %ebx, Y -> %esi
    movl 8(%ebp), %ebx
    movl 12(%ebp), %esi
    
    #iscrtavanje prve tacke (da bi radio za x1==x2 i y1==y2)
    pushl 24(%ebp)
    pushl %esi
    pushl %ebx
    call plot
    addl $12, %esp
line1:
    cmpl 16(%ebp), %ebx
    jae line2
    
    pushl 24(%ebp)
    pushl %esi
    pushl %ebx
    call plot
    addl $12, %esp
    
    incl %ebx
    jmp line1
line2:
    cmpl 20(%ebp), %esi
    jae line3
    
    pushl 24(%ebp)
    pushl %esi
    pushl %ebx
    call plot
    addl $12, %esp
    
    incl %esi
    jmp line2
line3:
    cmpl 8(%ebp), %ebx
    jbe line4
    
    pushl 24(%ebp)
    pushl %esi
    pushl %ebx
    call plot
    addl $12, %esp
    
    decl %ebx
    jmp line3
line4:
    cmpl 12(%ebp), %esi
    jbe dend
    
    pushl 24(%ebp)
    pushl %esi
    pushl %ebx
    call plot
    addl $12, %esp
    
    decl %esi
    jmp line4
dend:
    popl %esi
    popl %ebx
    movl %ebp, %esp
    popl %ebp
    ret

# void fillrect(int x1, int y1, int x2, int y2, int col)
fillrect:
    pushl %ebp
    movl %esp, %ebp
    pushl %esi
    pushl %edi
    
    # X -> %esi, Y -> %edi
    movl 8(%ebp), %esi
    movl 12(%ebp), %edi
plotX:
    #iscrtaj red
    pushl 24(%ebp)
    pushl %edi
    pushl %esi
    call plot
    addl $12, %esp
    
    incl %esi
    cmpl 16(%ebp), %esi
    jbe plotX
    
    #sledeci red
    movl 8(%ebp), %esi
    incl %edi
    cmpl 20(%ebp), %edi
    jbe plotX
    
    popl %esi
    popl %edi
    movl %ebp, %esp
    popl %ebp
    ret

# void sprite(int x, int y, unsigned char *data)
sprite:
    pushl %ebp
    movl %esp, %ebp
    subl $9, %esp               #byte bitmask, long maxX, long maxY
    pushl %esi
    pushl %edi
    pushl %ebx
    
    # X -> %esi, Y -> %edi, granice sprajta u memoriju
    movl 8(%ebp), %esi
    movl 12(%ebp), %edi
    movl 16(%ebp), %ebx
    movl %esi, -5(%ebp)
    movl %edi, -9(%ebp)
    addl $16, -5(%ebp)
    addl $16, -9(%ebp)
    
    movl $6, %ecx
    movb $0b11000000, -1(%ebp)
next:
    #izdvajanje boje u %edx
    xorl %edx, %edx
    movb (%ebx), %dl
    andb -1(%ebp), %dl
    shrb %cl, %dl
    
    andb %dl, %dl           #crni piksel je providan
    jz nodraw
    #crtanje piksela
    pushl %ecx              #%ecx se menja u okviru podprograma!
    pushl %edx
    pushl %edi
    pushl %esi
    call plot
    addl $12, %esp
    popl %ecx
nodraw:
    incl %esi
    subl $2, %ecx           #za %ecx < 0 je zavrseno crtanje bajta
    js nextbyte
    shrb $2, -1(%ebp)
    jmp next
nextbyte:
    movl $6, %ecx
    movb $0b11000000, -1(%ebp)
    incl %ebx
    cmpl -5(%ebp), %esi
    jb next
    #kraj jednog reda piksela
    movl 8(%ebp), %esi
    incl %edi
    cmpl -9(%ebp), %edi
    jb next

    popl %ebx
    popl %edi
    popl %esi
    movl %ebp, %esp
    popl %ebp
    ret

