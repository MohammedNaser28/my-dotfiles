// cursor-speeder: enlarge cursor on fast mouse movement
// Writes to niri cursor-override.kdl; niri auto-reloads on change
// Compile: gcc -O2 -o ~/.local/bin/cursor-speeder cursor-speeder.c
#include <dirent.h>
#include <fcntl.h>
#include <linux/input-event-codes.h>
#include <linux/input.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <time.h>
#include <unistd.h>

#define THRESHOLD 250
#define WINDOW_MS 40
#define COOLDOWN_MS 800
#define BIG_SIZE 92

#define CONFIG_DIR "/home/mohammed-niri/.config/niri"
#define OVERRIDE_FILE CONFIG_DIR "/cursor-override.kdl"

static int cursor_enlarged = 0;
static struct timespec last_fast = {0, 0};

static int is_mouse(int fd) {
  unsigned long ev[EV_MAX / 8 + 1] = {0};
  unsigned long rel[REL_MAX / 8 + 1] = {0};
  unsigned long key[KEY_MAX / 8 + 1] = {0};

  if (ioctl(fd, EVIOCGBIT(0, sizeof(ev)), ev) < 0) return 0;
  if (!(ev[EV_KEY / 8] & (1 << (EV_KEY % 8)))) return 0;
  if (!(ev[EV_REL / 8] & (1 << (EV_REL % 8)))) return 0;

  if (ioctl(fd, EVIOCGBIT(EV_REL, sizeof(rel)), rel) < 0) return 0;
  if (!(rel[REL_X / 8] & (1 << (REL_X % 8)))) return 0;
  if (!(rel[REL_Y / 8] & (1 << (REL_Y % 8)))) return 0;

  // Exclude touchpads (absolute positioning + tool finger)
  unsigned long abs_bits[ABS_MAX / 8 + 1] = {0};
  if (ioctl(fd, EVIOCGBIT(EV_ABS, sizeof(abs_bits)), abs_bits) >= 0) {
    if (abs_bits[ABS_X / 8] & (1 << (ABS_X % 8)))
      return 0;  // absolute positioning → not a mouse
  }

  if (ioctl(fd, EVIOCGBIT(EV_KEY, sizeof(key)), key) < 0) return 0;
  if (key[BTN_TOOL_FINGER / 8] & (1 << (BTN_TOOL_FINGER % 8))) return 0;

  char name[256] = {0};
  ioctl(fd, EVIOCGNAME(sizeof(name) - 1), name);
  if (strstr(name, "Touchpad") || strstr(name, "TrackPoint") ||
      strstr(name, "Touchscreen") || strstr(name, "Tablet") ||
      strstr(name, "Keyboard") || strstr(name, "kbd"))
    return 0;

  return 1;
}

static void write_override(void) {
  FILE* f = fopen(OVERRIDE_FILE, "w");
  if (!f) return;
  fprintf(f, "cursor {\n    xcursor-size %d\n}\n", BIG_SIZE);
  fclose(f);
}

static void remove_override(void) { unlink(OVERRIDE_FILE); }

static void cleanup(int sig) {
  (void)sig;
  remove_override();
  _exit(0);
}

static long ms_diff(struct timespec* a, struct timespec* b) {
  return (a->tv_sec - b->tv_sec) * 1000L + (a->tv_nsec - b->tv_nsec) / 1000000L;
}

int main(int argc, char** argv) {
  int foreground = 0;
  if (argc > 1 && strcmp(argv[1], "-f") == 0) foreground = 1;

  DIR* dir = opendir("/dev/input");
  if (!dir) {
    fprintf(stderr, "cannot open /dev/input\n");
    return 1;
  }

  int fds[64] = {0}, nfds = 0;
  struct dirent* de;
  while ((de = readdir(dir)) && nfds < 64) {
    if (strncmp(de->d_name, "event", 5) != 0) continue;
    char path[64];
    snprintf(path, sizeof(path), "/dev/input/%s", de->d_name);
    int fd = open(path, O_RDONLY);
    if (fd < 0) continue;
    if (is_mouse(fd))
      fds[nfds++] = fd;
    else
      close(fd);
  }
  closedir(dir);

  if (nfds == 0) {
    fprintf(stderr, "no mouse devices\n");
    return 1;
  }

  if (!foreground) {
    if (fork() != 0) _exit(0);
    if (fork() != 0) _exit(0);
    setsid();
    close(0);
    close(1);
    close(2);
  }

  // Clean up stale override on startup
  remove_override();

  // Restore cursor on clean exit
  signal(SIGINT, cleanup);
  signal(SIGTERM, cleanup);

  struct input_event ev;
  int frame_dx = 0, frame_dy = 0, cumulative = 0;
  struct timespec window_start;

  clock_gettime(CLOCK_MONOTONIC, &window_start);

  while (1) {
    struct timeval tv = {0, 100 * 1000};  // 100ms timeout for cooldown checks
    fd_set set;
    FD_ZERO(&set);
    int maxfd = 0;
    for (int i = 0; i < nfds; i++) {
      FD_SET(fds[i], &set);
      if (fds[i] > maxfd) maxfd = fds[i];
    }

    int ret = select(maxfd + 1, &set, NULL, NULL, &tv);

    if (ret == 0) {
      struct timespec now;
      clock_gettime(CLOCK_MONOTONIC, &now);
      if (cursor_enlarged && ms_diff(&now, &last_fast) > COOLDOWN_MS) {
        remove_override();
        cursor_enlarged = 0;
      }
      continue;
    }

    if (ret < 0) break;

    for (int i = 0; i < nfds; i++) {
      if (!FD_ISSET(fds[i], &set)) continue;

      ssize_t n = read(fds[i], &ev, sizeof(ev));
      if (n < (ssize_t)sizeof(ev)) continue;

      if (ev.type == EV_REL) {
        if (ev.code == REL_X) frame_dx += ev.value;
        if (ev.code == REL_Y) frame_dy += ev.value;
      } else if (ev.type == EV_SYN) {
        int dist = abs(frame_dx) + abs(frame_dy);
        frame_dx = frame_dy = 0;

        if (dist == 0) continue;

        cumulative += dist;

        struct timespec now;
        clock_gettime(CLOCK_MONOTONIC, &now);

        if (ms_diff(&now, &window_start) >= WINDOW_MS) {
          if (cumulative >= THRESHOLD) {
            last_fast = now;
            if (!cursor_enlarged) {
              write_override();
              cursor_enlarged = 1;
            }
          } else if (cursor_enlarged &&
                     ms_diff(&now, &last_fast) > COOLDOWN_MS) {
            remove_override();
            cursor_enlarged = 0;
          }
          cumulative = 0;
          window_start = now;
        }
      }
    }
  }

  for (int i = 0; i < nfds; i++) close(fds[i]);
  return 0;
}
