// hot-corner: transparent 8px zone at top-left corner.
// Hovering there toggles niri overview (GNOME Activities-style).
// Also triggered by mod-alone (handled in kbind-daemon.c).
// Compile: gcc -O2 $(pkg-config --cflags gtk+-3.0 gtk-layer-shell-0) \
//               -o ~/.local/bin/hot-corner hot-corner.c \
//               $(pkg-config --libs gtk+-3.0 gtk-layer-shell-0)
#include <gtk/gtk.h>
#include <gtk-layer-shell.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#define CORNER_SIZE 8
#define COOLDOWN_SEC 2

static guint cooldown_id = 0;

static gboolean clear_cooldown(gpointer user_data) {
    cooldown_id = 0;
    return G_SOURCE_REMOVE;
}

static void toggle_overview(void) {
    pid_t pid = fork();
    if (pid == 0) {
        close(0); close(1); close(2);
        execlp("niri", "niri", "msg", "action", "toggle-overview", NULL);
        _exit(1);
    }
}

static gboolean on_enter(GtkWidget *widget, GdkEventCrossing *event, gpointer user_data) {
    if (cooldown_id != 0)
        return GDK_EVENT_PROPAGATE;

    toggle_overview();

    cooldown_id = g_timeout_add_seconds(COOLDOWN_SEC, clear_cooldown, NULL);
    return GDK_EVENT_STOP;
}

static gboolean on_draw(GtkWidget *widget, cairo_t *cr, gpointer user_data) {
    cairo_set_source_rgba(cr, 0, 0, 0, 0);
    cairo_set_operator(cr, CAIRO_OPERATOR_SOURCE);
    cairo_paint(cr);
    return GDK_EVENT_STOP;
}

static void activate(GtkApplication *app, gpointer user_data) {
    GtkWidget *window = gtk_application_window_new(app);
    gtk_window_set_default_size(GTK_WINDOW(window), CORNER_SIZE, CORNER_SIZE);
    gtk_widget_set_size_request(window, CORNER_SIZE, CORNER_SIZE);
    gtk_window_set_resizable(GTK_WINDOW(window), FALSE);
    gtk_window_set_decorated(GTK_WINDOW(window), FALSE);
    gtk_widget_set_app_paintable(window, TRUE);

    GdkScreen *screen = gtk_window_get_screen(GTK_WINDOW(window));
    GdkVisual *visual = gdk_screen_get_rgba_visual(screen);
    if (visual)
        gtk_widget_set_visual(window, visual);

    gtk_layer_init_for_window(GTK_WINDOW(window));
    gtk_layer_set_layer(GTK_WINDOW(window), GTK_LAYER_SHELL_LAYER_OVERLAY);
    gtk_layer_set_anchor(GTK_WINDOW(window), GTK_LAYER_SHELL_EDGE_LEFT, TRUE);
    gtk_layer_set_anchor(GTK_WINDOW(window), GTK_LAYER_SHELL_EDGE_TOP, TRUE);
    gtk_layer_set_namespace(GTK_WINDOW(window), "hot-corner");
    gtk_layer_auto_exclusive_zone_enable(GTK_WINDOW(window));

    gtk_widget_add_events(window, GDK_ENTER_NOTIFY_MASK);
    g_signal_connect(window, "enter-notify-event", G_CALLBACK(on_enter), NULL);
    g_signal_connect(window, "draw", G_CALLBACK(on_draw), NULL);

    gtk_widget_show_all(window);
}

int main(int argc, char **argv) {
    int foreground = 0;
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--foreground") == 0 || strcmp(argv[i], "-f") == 0)
            foreground = 1;
    }

    // Filter out our own flags so GTK doesn't choke on -f
    char *filtered[64];
    int n = 0;
    filtered[n++] = argv[0];
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-f") != 0 && strcmp(argv[i], "--foreground") != 0)
            filtered[n++] = argv[i];
    }
    filtered[n] = NULL;

    if (!foreground) {
        if (fork() != 0) _exit(0);
        if (fork() != 0) _exit(0);
        setsid();
        close(0); close(1); close(2);
    }

    GtkApplication *app = gtk_application_new("sevens.hotcorner", G_APPLICATION_NON_UNIQUE);
    g_signal_connect(app, "activate", G_CALLBACK(activate), NULL);
    int status = g_application_run(G_APPLICATION(app), n, filtered);
    g_object_unref(app);
    return status;
}
