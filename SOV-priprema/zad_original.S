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
    # primer iscrtavanja tačke u prvom i poslednjem bajtu ekrana
    # ovaj kod treba zameniti korektnim kodom za iscrtavanje tačke
    pushl %ebp
    movl %esp, %ebp

    movl $screen, %eax      # prvi bajt ekrana
    orb $0b11000000, (%eax) # gornji levi ugao, plava tacka

    addl scrsize, %eax
    decl %eax               # poslednji bajt ekrana
    orb $0b00000010, (%eax) # donji desni ugao, zelena tacka

    movl %ebp, %esp
    popl %ebp
    ret

# void drawrect(int x1, int y1, int x2, int y2, int col)
drawrect:
    ret

# void fillrect(int x1, int y1, int x2, int y2, int col)
fillrect:
    ret

# void sprite(int x, int y, unsigned char *data)
sprite:
    ret

