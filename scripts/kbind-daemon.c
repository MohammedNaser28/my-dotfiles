// kbind-daemon: background evdev key re-binder for keys that niri can't match
// Compile: gcc -O2 -o ~/.local/bin/kbind-daemon kbind-daemon.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <fcntl.h>
#include <unistd.h>
#include <linux/input.h>
#include <linux/input-event-codes.h>

#define ARRAY_SIZE(a) (sizeof(a) / sizeof((a)[0]))

struct binding {
    int code;           // evdev keycode
    const char *action; // command to run
};

static const struct binding bindings[] = {
    {115, "mediactl volume_up"},    // KEY_VOLUMEUP
    {114, "mediactl volume_down"},  // KEY_VOLUMEDOWN
    {113, "mediactl volume_mute"},  // KEY_MUTE
    {225, "mediactl brightness_up"},   // KEY_BRIGHTNESSUP
    {224, "mediactl brightness_down"}, // KEY_BRIGHTNESSDOWN
};

static int is_keyboard(int fd, const char *name) {
    unsigned long ev_bits[EV_MAX/8+1] = {0};
    if (ioctl(fd, EVIOCGBIT(0, sizeof(ev_bits)), ev_bits) < 0) return 0;
    if (!(ev_bits[EV_KEY/8] & (1 << (EV_KEY % 8)))) return 0;
    if (strstr(name, "Video Bus") || strstr(name, "Power Button") ||
        strstr(name, "Lid Switch") || strstr(name, "Sleep Button") ||
        strstr(name, "Wireless") || strstr(name, "Mouse") ||
        strstr(name, "Touchpad") || strstr(name, "USB Receiver"))
        return 0;
    return 1;
}

int main(int argc, char **argv) {
    int foreground = 0;
    if (argc > 1 && strcmp(argv[1], "-f") == 0) foreground = 1;
    struct dirent *de;
    DIR *dir = opendir("/dev/input");
    if (!dir) { fprintf(stderr, "cannot open /dev/input\n"); return 1; }

    int fds[64] = {0};
    int nfds = 0;

    while ((de = readdir(dir)) && nfds < 64) {
        if (strncmp(de->d_name, "event", 5) != 0) continue;
        char path[64]; snprintf(path, 64, "/dev/input/%s", de->d_name);
        int fd = open(path, O_RDONLY);
        if (fd < 0) continue;
        char name[256] = {0};
        ioctl(fd, EVIOCGNAME(sizeof(name)-1), name);
        if (is_keyboard(fd, name)) {
            fds[nfds++] = fd;
        } else {
            close(fd);
        }
    }
    closedir(dir);

    if (nfds == 0) { fprintf(stderr, "no keyboard devices\n"); return 1; }

    if (!foreground) {
        if (fork() != 0) _exit(0);
        if (fork() != 0) _exit(0);
        setsid();
        close(0); close(1); close(2);
    }

    struct input_event ev;
    int last_press[KEY_CNT] = {0};

    while (1) {
        fd_set set; FD_ZERO(&set);
        int maxfd = 0;
        for (int i = 0; i < nfds; i++) {
            FD_SET(fds[i], &set);
            if (fds[i] > maxfd) maxfd = fds[i];
        }
        if (select(maxfd + 1, &set, NULL, NULL, NULL) < 0) break;

        for (int i = 0; i < nfds; i++) {
            if (!FD_ISSET(fds[i], &set)) continue;
            ssize_t n = read(fds[i], &ev, sizeof(ev));
            if (n < (ssize_t)sizeof(ev)) continue;
            if (ev.type != EV_KEY) continue;
            if (ev.code >= KEY_CNT) continue;

            if (ev.value == 1) { // pressed
                last_press[ev.code] = 1;
            } else if (ev.value == 0) { // released
                if (last_press[ev.code]) {
                    last_press[ev.code] = 0;
                    // Check if this key is bound
                    for (size_t b = 0; b < ARRAY_SIZE(bindings); b++) {
                        if (bindings[b].code == ev.code) {
                            // Fork and exec the action
                            if (fork() == 0) {
                                close(0); close(1); close(2);
                                execlp("sh", "sh", "-c", bindings[b].action, NULL);
                                _exit(1);
                            }
                        }
                    }
                }
            }
        }
    }

    for (int i = 0; i < nfds; i++) close(fds[i]);
    return 0;
}
