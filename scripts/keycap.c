#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <linux/input.h>
#include <linux/input-event-codes.h>

int main() {
    int fd = open("/dev/input/event3", O_RDONLY);
    if (fd < 0) {
        fd = open("/dev/input/by-path/platform-i8042-serio-0-event-kbd", O_RDONLY);
        if (fd < 0) return 1;
    }

    struct input_event ev;
    int held_mod = 0, held_ctrl = 0, held_alt = 0, held_shift = 0;
    int captured = 0;

    while (1) {
        fd_set set;
        FD_ZERO(&set);
        FD_SET(fd, &set);
        if (select(fd + 1, &set, NULL, NULL, NULL) < 0) break;
        if (!FD_ISSET(fd, &set)) continue;

        if (read(fd, &ev, sizeof(ev)) < (ssize_t)sizeof(ev)) continue;
        if (ev.type != EV_KEY) continue;

        if (ev.value == 1) {
            // pressed
            if (ev.code == KEY_LEFTMETA || ev.code == KEY_RIGHTMETA) held_mod = 1;
            else if (ev.code == KEY_LEFTCTRL || ev.code == KEY_RIGHTCTRL) held_ctrl = 1;
            else if (ev.code == KEY_LEFTALT || ev.code == KEY_RIGHTALT) held_alt = 1;
            else if (ev.code == KEY_LEFTSHIFT || ev.code == KEY_RIGHTSHIFT) held_shift = 1;
            else if (!captured) captured = ev.code;
            continue;
        }

        if (ev.value != 0) continue; // ignore repeat (value=2)

        // released
        if (ev.code == KEY_LEFTMETA || ev.code == KEY_RIGHTMETA) held_mod = 0;
        else if (ev.code == KEY_LEFTCTRL || ev.code == KEY_RIGHTCTRL) held_ctrl = 0;
        else if (ev.code == KEY_LEFTALT || ev.code == KEY_RIGHTALT) held_alt = 0;
        else if (ev.code == KEY_LEFTSHIFT || ev.code == KEY_RIGHTSHIFT) held_shift = 0;
        else if (captured && ev.code == captured) {
            if (held_mod) printf("MOD + ");
            if (held_alt) printf("Alt + ");
            if (held_ctrl) printf("Ctrl + ");
            if (held_shift) printf("Shift + ");
            if (captured >= KEY_A && captured <= KEY_Z)
                printf("%c\n", 'A' + (captured - KEY_A));
            else if (captured >= KEY_1 && captured <= KEY_0)
                printf("%c\n", '1' + (captured - KEY_1));
            else if (captured == KEY_SPACE) printf("Space\n");
            else if (captured == KEY_ENTER) printf("Return\n");
            else if (captured == KEY_ESC) printf("Escape\n");
            else if (captured == KEY_TAB) printf("Tab\n");
            else if (captured == KEY_BACKSPACE) printf("BackSpace\n");
            else printf("(%d)\n", captured);
            fflush(stdout);
            close(fd);
            return 0;
        }
    }

    close(fd);
    return 1;
}
