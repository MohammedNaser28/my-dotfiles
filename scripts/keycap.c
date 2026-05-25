#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <fcntl.h>
#include <unistd.h>
#include <linux/input.h>
#include <linux/input-event-codes.h>

static const char *mod_name(int code) {
    switch (code) {
        case KEY_LEFTMETA:  case KEY_RIGHTMETA:  return "MOD";
        case KEY_LEFTCTRL:  case KEY_RIGHTCTRL:  return "Ctrl";
        case KEY_LEFTALT:   case KEY_RIGHTALT:   return "Alt";
        case KEY_LEFTSHIFT: case KEY_RIGHTSHIFT: return "Shift";
        default: return NULL;
    }
}

static const char *key_name(int code) {
    switch (code) {
        case KEY_ESC:         return "Escape";
        case KEY_TAB:         return "Tab";
        case KEY_SPACE:       return "Space";
        case KEY_ENTER:       return "Return";
        case KEY_BACKSPACE:   return "BackSpace";
        case KEY_DELETE:      return "Delete";
        case KEY_HOME:        return "Home";
        case KEY_END:         return "End";
        case KEY_PAGEUP:      return "Page_Up";
        case KEY_PAGEDOWN:    return "Page_Down";
        case KEY_UP:          return "Up";
        case KEY_DOWN:        return "Down";
        case KEY_LEFT:        return "Left";
        case KEY_RIGHT:       return "Right";
        case KEY_KPENTER:     return "KP_Enter";
        case KEY_VOLUMEUP:    return "KEY_VOLUMEUP";
        case KEY_VOLUMEDOWN:  return "KEY_VOLUMEDOWN";
        case KEY_MUTE:        return "KEY_MUTE";
        default:
            if (code >= KEY_F1 && code <= KEY_F24) {
                static char buf[8];
                snprintf(buf, sizeof(buf), "F%d", code - KEY_F1 + 1);
                return buf;
            }
            if (code >= KEY_1 && code <= KEY_9) {
                static char buf[2];
                buf[0] = '0' + (code - KEY_1 + 1);
                buf[1] = '\0';
                return buf;
            }
            if (code == KEY_0) return "0";
            if (code >= KEY_A && code <= KEY_Z) {
                static char buf[2];
                buf[0] = 'A' + (code - KEY_A);
                buf[1] = '\0';
                return buf;
            }
            return NULL; // pass through as raw name
    }
}

// Check if an evdev device has keyboard capability
static int is_keyboard(int fd) {
    unsigned long ev_bits[EV_MAX/8+1];
    memset(ev_bits, 0, sizeof(ev_bits));
    if (ioctl(fd, EVIOCGBIT(0, sizeof(ev_bits)), ev_bits) < 0) return 0;
    if (!(ev_bits[EV_KEY/8] & (1 << (EV_KEY % 8)))) return 0;

    char name[256] = {0};
    ioctl(fd, EVIOCGNAME(sizeof(name)-1), name);
    // Skip non-keyboard devices by name
    if (strstr(name, "Video Bus") || strstr(name, "Power Button") ||
        strstr(name, "Lid Switch") || strstr(name, "Sleep Button") ||
        strstr(name, "Wireless") || strstr(name, "Mouse") ||
        strstr(name, "Touchpad") || strstr(name, "USB Receiver"))
        return 0;
    return 1;
}

int main() {
    struct dirent *de;
    DIR *dir = opendir("/dev/input");
    if (!dir) {
        fprintf(stderr, "cannot open /dev/input\n");
        return 1;
    }

    int fds[64];
    int nfds = 0;

    while ((de = readdir(dir)) && nfds < 64) {
        if (strncmp(de->d_name, "event", 5) != 0) continue;
        char path[64];
        snprintf(path, sizeof(path), "/dev/input/%s", de->d_name);
        int fd = open(path, O_RDONLY);
        if (fd < 0) continue;
        if (is_keyboard(fd)) {
            fds[nfds++] = fd;
        } else {
            close(fd);
        }
    }
    closedir(dir);

    if (nfds == 0) {
        fprintf(stderr, "no keyboard devices found\n");
        return 1;
    }

    int held[KEY_CNT] = {0};
    int captured_code = 0;
    struct input_event ev;

    while (1) {
        fd_set set;
        FD_ZERO(&set);
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

            const char *mn = mod_name(ev.code);

            if (ev.value == 1) { // pressed
                if (mn) {
                    held[ev.code] = 1;
                } else if (!captured_code) {
                    captured_code = ev.code;
                }
            } else if (ev.value == 0) { // released
                if (mn) {
                    held[ev.code] = 0;
                }
                if (!mn && captured_code == ev.code) {
                    // Build combo string
                    const char *names[4];
                    int mod_codes[4] = {
                        KEY_LEFTMETA, KEY_LEFTCTRL,
                        KEY_LEFTALT, KEY_LEFTSHIFT
                    };
                    int nmods = 0;
                    for (int m = 0; m < 4; m++) {
                        if (held[mod_codes[m]] || held[mod_codes[m]+1])
                            names[nmods++] = mod_name(mod_codes[m]);
                    }

                    const char *kname = key_name(captured_code);
                    if (!kname) kname = "?";

                    for (int m = 0; m < nmods; m++) {
                        printf("%s%s", m > 0 ? " + " : "", names[m]);
                    }
                    if (nmods > 0) printf(" + ");
                    printf("%s\n", kname);
                    fflush(stdout);

                    for (int i = 0; i < nfds; i++) close(fds[i]);
                    return 0;
                }
            }
        }
    }

    for (int i = 0; i < nfds; i++) close(fds[i]);
    return 0;
}
