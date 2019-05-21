Da bi primer mogao da se kompajlira treba dodati pakete:

- Za Debian/Ubuntu bazirane distribucije: libx11-dev:i386 libxext-dev:i386

```
apt-get install libx11-6:i386 libxext-dev:i386
```

- Za Arch bazirane distribucije: lib32-libx11 lib32-libxext

```
sudo pacman -S lib32-libx11 lib32-libxext
```
(potrebno je aktivirati multilib repo za pacman kod 64bit sistema)
