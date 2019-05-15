# Program za sabiranje dva broja u proizvoljnoj bazi
# Imenko Prezimić ra1234

# Napisati asemblerski program koji, koristeći potprograme za konverziju
# za bilo koju bazu 2‑36, vrši sabiranje dva neoznačena cela broja data u
# znakovnom obliku i rezultat vraća u znakovnom obliku. Sve konverzije
# raditi odmah nakon unosa, a u slučaju greške prekinuti dalji rad
# programa i ispisati odgovarajuću poruku. Primer korišćenja:
#       Unesite bazu broja:16
#       Unesite broj:Fa
#       Unesite bazu broja:8
#       Unesite broj:123
#       Unesite bazu rezultata:2
#       Rezultat:101001101
# Za ostale primere pokrenuti testiraj.sh.
# Dodatni primeri se mogu napraviti pomoću kalkulatora (Accessories/Calculator)
.section .data
ulaz1:      .ascii "Unesite bazu broja:\0"
u1len = . - ulaz1
ulaz2:      .ascii "Unesite broj:\0"
u2len = . - ulaz2
ulaz3:      .ascii "Unesite bazu rezultata:\0"
u3len = . - ulaz3
izlaz1:     .ascii "Rezultat:\0"
strresult: .fill 32, 1, 0
i1len = . - izlaz1
greska1:    .ascii "Greska: pogresan znak!\0"
g1len = . - greska1
greska2:    .ascii "Greska: prekoracenje!\0"
g2len = . - greska2

inputlen = 42
baselen = 3

error: .long 0

a: .long 0
b: .long 0
basea: .long 0
baseb: .long 0
base: .long 0

stra: .fill inputlen, 1, 0
strbasea: .fill baselen, 1, 0
strb: .fill inputlen, 1, 0
strbaseb: .fill baselen, 1, 0
strbase: .fill baselen, 1, 0

.section .text
.globl main
main:
#print numA base query
    movl $4, %eax
    movl $1, %ebx
    leal ulaz1, %ecx
    movl $u1len, %edx
    int $0x80
#input numA base
    movl $3, %eax
    movl $0, %ebx
    leal strbasea, %ecx
    movl $baselen, %edx
    int $0x80
#convert numA base to int
    pushl $10
    pushl $basea
    pushl $strbasea
    call strtoint
    addl $12, %esp
    
    andl %eax, %eax
    jnz err
    cmpl $2, basea
    jb er2
    cmpl $36, basea
    ja er2
    
#print numA query
    movl $4, %eax
    movl $1, %ebx
    leal ulaz2, %ecx
    movl $u2len, %edx
    int $0x80
#input numA 
    movl $3, %eax
    movl $0, %ebx
    leal stra, %ecx
    movl $inputlen, %edx
    int $0x80
#convert numA to int
    pushl basea
    pushl $a
    pushl $stra
    call strtoint
    addl $12, %esp
    
    andl %eax, %eax
    jnz err
    
#print numB base query
    movl $4, %eax
    movl $1, %ebx
    leal ulaz1, %ecx
    movl $u1len, %edx
    int $0x80
#input numB base
    movl $3, %eax
    movl $0, %ebx
    leal strbaseb, %ecx
    movl $baselen, %edx
    int $0x80
#convert numB base to int
    pushl $10
    pushl $baseb
    pushl $strbaseb
    call strtoint
    addl $12, %esp
    
    andl %eax, %eax
    jnz err
    cmpl $2, baseb
    jb er2
    cmpl $36, baseb
    ja er2
    
#print numB query
    movl $4, %eax
    movl $1, %ebx
    leal ulaz2, %ecx
    movl $u2len, %edx
    int $0x80
#input numB
    movl $3, %eax
    movl $0, %ebx
    leal strb, %ecx
    movl $inputlen, %edx
    int $0x80
#convert numB to int
    pushl baseb
    pushl $b
    pushl $strb
    call strtoint
    addl $12, %esp
    
    andl %eax, %eax
    jnz err
    
#add the numbers
    movl b, %edx
    addl %edx, a
    jc er2
    
#print result base query
    movl $4, %eax
    movl $1, %ebx
    leal ulaz3, %ecx
    movl $u3len, %edx
    int $0x80
#input result base
    movl $3, %eax
    movl $0, %ebx
    leal strbase, %ecx
    movl $baselen, %edx
    int $0x80
#convert result base to int
    pushl $10
    pushl $base
    pushl $strbase
    call strtoint
    addl $12, %esp
    
    andl %eax, %eax
    jnz err
    cmpl $2, base
    jb er2
    cmpl $36, base
    ja er2
    
#convert the result to string
    pushl base
    pushl $strresult
    pushl a
    call inttostr
    addl $12, %esp
    
    andl %eax, %eax
    jnz err
#print the result
    movl $4, %eax
    movl $1, %ebx
    leal izlaz1, %ecx
    movl $i1len, %edx
    int $0x80
    
    jmp end
err:
    cmpl $1, %eax
    ja er2
er1:
    movl $1, error
#print error1
    movl $4, %eax
    movl $1, %ebx
    leal greska1, %ecx
    movl $g1len, %edx
    int $0x80
    jmp end
er2:
    movl $2, error
#print error2
    movl $4, %eax
    movl $1, %ebx
    leal greska2, %ecx
    movl $g2len, %edx
    int $0x80
end:
	movl $1, %eax
	movl error, %ebx
	int $0x80
