/*

Da bi primer mogao da se kompajlira treba dodati pakete:
- za Debian/Ubuntu bazirane distribucije: libx11-dev:i386 libxext-dev:i386
- Za Arch bazirane distribucije: lib32-libx11 lib32-libxext

*/

// X11 biblioteka
#include <X11/Xlib.h>

// tajmeri
#include <unistd.h>

// niti
#include <pthread.h>

// standardne biblioteke
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

/************************************************
   Deklaracije funkcija koje treba realizovati
*************************************************/

void plot(int x, int y, int col);
void drawrect(int x1, int y1, int x2, int y2, int col);
void fillrect(int x1, int y1, int x2, int y2, int col);
void sprite(int x, int y, unsigned char *data);

/************************************************
               Definicije za ekran
*************************************************/

// dimenzije emuliranog ekrana
#define SCRWIDTH 320
#define SCRHEIGHT 200
#define SCRSIZE (SCRWIDTH*SCRHEIGHT)
#define SCRBYTESIZE (SCRSIZE/8*2)
// skaliranje emuliranog ekrana
#define SCALING 2
// promenljive za dimenzije emuliranog ekrana
const int scrwidth = SCRWIDTH;
const int scrheight = SCRHEIGHT;
const int scrsize = SCRBYTESIZE;
// memorija za emulirani ekran
unsigned char screen[SCRBYTESIZE];

/************************************************
             Iscrtavanje i niti
*************************************************/

// oznaka da li nit za iscrtavanje treba da radi
int thread_working = 1;

// X11 prozor
Display *d;
Window w;

// redni brojevi i kodovi boja
enum GCColors {GCBlack=0,GCRed,GCGreen,GCBlue,GCWhite};
enum Colors {ColBlack = 0x00000000, ColRed=0x00ff5050, ColGreen=0x0050ff50, ColBlue=0x005050ff, ColWhite=0x00ffffff};

// osvežavanje prikaza
void XRefresh() {
    XEvent edraw;
    memset(&edraw, 0, sizeof(edraw));
    edraw.type = Expose;
    edraw.xexpose.window = w;
    XSendEvent(d,w,False,ExposureMask,&edraw);
    XFlush(d);
}

/************************************************
           Pomoćna funkcija za sprajt
*************************************************/

char alien_chr[16][16] = {
    "   3111111113   ",
    "  31122  22113  ",
    "  31122  22113  ",
    "  311      113  ",
    "   3112222113   ",
    "    33311333    ",
    "222   3113      ",
    "22213 3113  333 ",
    "  31133113311113",
    "   3113113113311",
    "    31111113 311",
    "     331133  222",
    "    33311333 222",
    "  331111111133  ",
    "3311133333311133",
    "11133      33111"
};

unsigned char* makesprite(char data[16][16], unsigned char* spr, int mirror) {
    int offset,col,xx,yy;
    unsigned char mask;
    for (xx=0;xx<16;xx++)
        for (yy=0;yy<16;yy++) {
            offset = xx/4 + yy*16/4;
            mask = 3 << ((3-xx&3)*2);
            if (mirror)
                col = (data[yy][15-xx] != ' ') ? data[yy][15-xx]-'0' : 0;
            else
                col = (data[yy][xx] != ' ') ? data[yy][xx]-'0' : 0;
            spr[offset] &= ~mask;
            spr[offset] |= col << ((3-xx&3)*2);
        }
}

/************************************************
         Testiranje ispravnosti funkcija
*************************************************/

int onex,oney,onecol;

// test za jednu tačku
void *test_oneplot(void *param) {
//    while (thread_working) {
        plot(onex,oney,onecol);

        // osvežavanje prikaza
        XRefresh();
        // pauza u mikrosekunama
//        usleep(40000);
//    }
    return NULL;
}

// test za tačke
void *test_plot(void *param) {
    // uglovi
    plot(0,0,2);        // gornji levi ugao, zelena tačka
    plot(319,0,2);      // gornji desni ugao, zelena tačka
    plot(0,199,1);      // donji levi ugao, crvena tačka
    plot(319,199,3);    // donji desni ugao, plava tačka

    // sredina
    plot(158,98,2);
    plot(161,98,2);
    plot(158,101,1);
    plot(161,101,3);

    // nekorektne koordinate
    plot(-1,1,2);
    plot(1,-1,2);
    plot(320,1,2);
    plot(1,200,2);

    // osvežavanje prikaza
    XRefresh();
    return NULL;
}

// test za pravougaonike
void *test_drawrect(void *param) {
    int i,col=1;
    for (i=0; i<=180; i+=20, col++)
        drawrect(i,i,i+19,i+19,col%3+1);

    // osvežavanje prikaza
    XRefresh();
    return NULL;
}

// test za popunjene pravougaonike
void *test_fillrect(void *param) {
    int i,col=1;
    for (i=0; i<=180; i+=20, col++)
        fillrect(i+i/2,i,i+i/2+19+10,i+19,col%3+1);

    // osvežavanje prikaza
    XRefresh();
    return NULL;
}

// test za linije
void *test_line(void *param) {
    int i,col=1;
    for (i=0; i<=180; i+=20, col++) {
        drawrect(i,i,i+19,i,col%3+1);
        fillrect(i+20,i,i+20,i+19,col%3+1);
        drawrect(i+60,i,i+60,i+19,col%3+1);
        fillrect(i+40,i,i+19+40,i,col%3+1);
    }

    // osvežavanje prikaza
    XRefresh();
    return NULL;
}


// test za pravougaonike
void *test_rect(void *param) {
    int i;
    fillrect(0,0,319,99,1);
    fillrect(0,100,319,199,3);
    for (i=0; i<=90; i+=10)
        drawrect(i,i,319-i,199-i,2);

    // osvežavanje prikaza
    XRefresh();
    return NULL;
}

// test za sprajt
void *test_sprite(void *param) {
    unsigned char alien[64];
    fillrect(0,0,319,99,1);
    fillrect(0,100,319,199,3);
    makesprite(alien_chr,alien,0);
    sprite(151,91,alien);

    // osvežavanje prikaza
    XRefresh();
    return NULL;
}

// test za animirane pravougaonike
void *test_rect_anim(void *param) {
    int x = 100, y = 100, a = 10, b = 50, dx = 2, dy = 1, dyy, z=0;
    while (thread_working) {
        fillrect(0,0,319,199,0);
        //fillrect(x, y, x+a-1, y+a-1, 0);
        if ((x>=320-a)||(x<=0)) dx = -dx;
        if ((y>=190-a)||(y<=0)) dy = -dy;
        dyy = ( sin(y/190.0*3.14/4)*10+2 )*dy;
        x+=dx; y+=dyy;
        if (y>=190-a) y=190-a;
        if (y<0) y=0;
        fillrect(x, y, x+a-1, y+a-1, 1);

        //fillrect(z, 189, z+b-1, 199, 0);
        z = x + a/2 - b/2;
        if (z<0) z = 0;
        if (z>=319-b) z=319-b;
        drawrect(z, 189, z+b-1, 199, 2);
        fillrect(z+1, 190, z+b-2, 198, 3);

        // osvežavanje prikaza
        XRefresh();
        // pauza u mikrosekunama
        usleep(40000);
    }
    return NULL;
}

// test za animirani sprajt
void *test_sprite_anim(void *param) {
    int xs=113,ys=71,dxs=3,dys=2,col=0,i,ac=0,a=0;
    unsigned char alien1[64],alien2[64];
    makesprite(alien_chr,alien1,0);
    makesprite(alien_chr,alien2,1);
    while (thread_working) {
        fillrect(0,0,319,199,0);
        for (i=30,col=0;i<90;i+=10,col++)
            fillrect(i,i,319-i,199-i,col%3+1);
        xs+=dxs; ys+=dys;
        if ((xs>=319-16)||(xs<1)) dxs = -dxs;
        if ((ys>=199-16)||(ys<1)) dys = -dys;
        if (ac++>15) { a=!a; ac=0; }
        if (a)
            sprite(xs,ys,alien1);
        else
            sprite(xs,ys,alien2);
        // osvežavanje prikaza
        XRefresh();
        // pauza u mikrosekunama
        usleep(40000);
    }
    return NULL;
}


/************************************************
         Glavni program sa X11 petljom
*************************************************/

int main(void) {
    // X11 prozor
    Window r;
    XEvent e;
    Atom wmDeleteMessage;
    GC GCCol[5];
    Pixmap DblBuffer;
    int s;
    XRectangle rects[5][SCRSIZE];
    int nrects[5];

    // nit za emulirani ekan
    pthread_t testing;
    int parameter;

    // kopiranje ekrana u X bafer
    int i,j,k,offset;
    unsigned char mask,col;

    // kontrola glavne X11 petlje
    int loop = 1;

    // izbor testa
    char c;
    printf("Odaberite test (izlaz je sa ESC):\n");
    printf("0 - Iscrtavanje jedne tacke\n");
    printf("1 - Iscrtavanje tacaka\n");
    printf("2 - Iscrtavanje pravougaonika\n");
    printf("3 - Iscrtavanje popunjenih pravougaonika\n");
    printf("4 - Iscrtavanje linija\n");
    printf("5 - Iscrtavanje raznih pravougaonika\n");
    printf("6 - Iscrtavanje sprajta\n");
    printf("7 - Animacija pravougaonika\n");
    printf("8 - Animacija sprajta\n");
    scanf("%c",&c);
    if (c=='0') {
        printf("Unesite X: ");
        scanf("%d",&onex);
        printf("Unesite Y: ");
        scanf("%d",&oney);
        printf("Unesite boju: ");
        scanf("%d",&onecol);
    }

    XInitThreads();
    d = XOpenDisplay(NULL);
    if (d == NULL) {
        fprintf(stderr, "Cannot open display\n");
        exit(1);
    }

    // kreiranje prozora
    s = DefaultScreen(d);
    r = RootWindow(d, s);
    w = XCreateSimpleWindow(d, r, 10, 10, scrwidth*SCALING, scrheight*SCALING, 0, ColBlack , ColBlack);
    XSelectInput(d, w, ExposureMask | KeyPressMask);
    XMapWindow(d, w);
    XFlush(d);
    XStoreName(d, w, "320x200 Simulacija");

    // Graphics Context za iscrtavanje definisanim bojama
    GCCol[GCBlack] = XCreateGC(d, w, 0, NULL);
    XSetForeground(d, GCCol[GCBlack], ColBlack);
    GCCol[GCRed] = XCreateGC(d, w, 0, NULL);
    XSetForeground(d, GCCol[GCRed], ColRed);
    GCCol[GCGreen] = XCreateGC(d, w, 0, NULL);
    XSetForeground(d, GCCol[GCGreen], ColGreen);
    GCCol[GCBlue] = XCreateGC(d, w, 0, NULL);
    XSetForeground(d, GCCol[GCBlue], ColBlue);
    GCCol[GCWhite] = XCreateGC(d, w, 0, NULL);
    XSetForeground(d, GCCol[GCWhite], ColWhite);

    // bafer za iscrtavanje
    DblBuffer = XCreatePixmap(d, w, scrwidth*SCALING, scrheight*SCALING, DefaultDepth(d,s));

    // obrada zatvaranja prozora na 'X'
    wmDeleteMessage = XInternAtom(d, "WM_DELETE_WINDOW", False);
    XSetWMProtocols(d, w, &wmDeleteMessage, 1);

    // pokretanje niti za emulirani ekran
    switch (c) {
        case '0' : pthread_create(&testing, NULL, test_oneplot, &parameter); break;
        case '1' : pthread_create(&testing, NULL, test_plot, &parameter); break;
        case '2' : pthread_create(&testing, NULL, test_drawrect, &parameter); break;
        case '3' : pthread_create(&testing, NULL, test_fillrect, &parameter); break;
        case '4' : pthread_create(&testing, NULL, test_line, &parameter); break;
        case '5' : pthread_create(&testing, NULL, test_rect, &parameter); break;
        case '6' : pthread_create(&testing, NULL, test_sprite, &parameter); break;
        case '7' : pthread_create(&testing, NULL, test_rect_anim, &parameter); break;
        case '8' : pthread_create(&testing, NULL, test_sprite_anim, &parameter); break;
        default: loop=0; break;
    }    

    // X11 petlja
    while (loop) {
        XNextEvent(d, &e);
        // ako je prozor zatvoren na 'X'
        if (e.type == ClientMessage && e.xclient.data.l[0] == wmDeleteMessage)
            loop=0;
        // ako je pritisnut ESC taster
        if (e.type == KeyPress && e.xkey.keycode == 0x09)
            loop=0;
        // kopiranje bafera na sadržaj prozora
        if (e.type == Expose) {
            XFillRectangle(d, DblBuffer, GCCol[GCBlack], 0, 0, scrwidth*SCALING, scrheight*SCALING);
            for (i=0;i<scrwidth;i++) {
                for (j=0;j<scrheight;j++) {
                    offset = i/4 + j*scrwidth/4;
                    mask = 3 << ((3-i&3)*2);
                    col = (screen[offset]>>((3-i&3)*2))&3;
                    XFillRectangle(d, DblBuffer, GCCol[col], i*SCALING, j*SCALING, SCALING, SCALING);
                }
            }
            XCopyArea(d, DblBuffer, w, GCCol[GCBlack], 0, 0, scrwidth*SCALING, scrheight*SCALING, 0, 0);
        }
    }

    thread_working = 0;
    pthread_join(testing,NULL);

    XCloseDisplay(d);
    return 0;
}

