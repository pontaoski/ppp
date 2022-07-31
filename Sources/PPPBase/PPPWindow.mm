#import "PPPBase.h"

#import <gdk/gdk.h>
#import <cairomm/region.h>

@interface PPPWindowMorph : PPPMorph
@end

@implementation PPPWindowMorph
@end

@implementation PPPWindow

@synthesize rootMorph;

- (NSString*) title {
    @synchronized (self) {
        return title;
    }
}

- (void)setTitle:(NSString *)newTitle {
    @synchronized (self) {
        title = newTitle;
        gdk_window_set_title(window, title.cString);
    }
}

- (void)dealloc {
    g_object_unref(self->window);
}

+ (void)initialize {
    [super initialize];

    gdk_event_handler_set([](GdkEvent* event, gpointer) {
        switch (event->type) {
        case GDK_EXPOSE: {
            auto region = Cairo::Region::create(Cairo::RectangleInt { .x = 0, .y = 0, .width = 400, .height = 400 });

            auto ctx = gdk_window_begin_draw_frame(event->expose.window, region->cobj());
            auto cairo = gdk_drawing_context_get_cairo_context(ctx);
            auto cairoContext = Cairo::RefPtr<Cairo::Context>(new Cairo::Context(cairo));

            auto window = (__bridge PPPWindow*)(g_object_get_data(G_OBJECT(event->expose.window), "PPPWindow"));
            auto canvas = [[PPPContextCanvas alloc] initWithContext:cairoContext];
            [window->rootMorph drawTo: canvas];

            gdk_window_end_draw_frame(event->expose.window, ctx);
            break;
        }
        case GDK_WINDOW_STATE:
            // TODO: notify state changes
            break;
        case GDK_FOCUS_CHANGE:
            // TODO: notify state changes
            break;
        case GDK_VISIBILITY_NOTIFY:
        case GDK_SETTING:
        case GDK_MAP:
        case GDK_UNMAP:
        case GDK_CONFIGURE:
        case GDK_OWNER_CHANGE:
        case GDK_ENTER_NOTIFY:
        case GDK_LEAVE_NOTIFY:
            break;
        default: {
            auto pppEvent = [[PPPEvent alloc] initFrom: event];
            auto window = (__bridge PPPWindow*)(g_object_get_data(G_OBJECT(event->any.window), "PPPWindow"));

            switch (pppEvent.eventType) {
            case PPPEventType::LeftMouseClick:
                [[window->rootMorph morphAtPosition: pppEvent.point] mouseDown: pppEvent];
                break;
            case PPPEventType::LeftMouseRelease:
                [[window->rootMorph morphAtPosition: pppEvent.point] mouseUp: pppEvent];
                break;
            case PPPEventType::LeftMouseDoubleClick:
                break;
            case PPPEventType::LeftMouseTripleClick:
                break;
            case PPPEventType::MiddleMouseClick:
                break;
            case PPPEventType::MiddleMouseRelease:
                break;
            case PPPEventType::MiddleMouseDoubleClick:
                break;
            case PPPEventType::MiddleMouseTripleClick:
                break;
            case PPPEventType::RightMouseClick:
                break;
            case PPPEventType::RightMouseRelease:
                break;
            case PPPEventType::RightMouseDoubleClick:
                break;
            case PPPEventType::RightMouseTripleClick:
                break;
            case PPPEventType::OtherMouseClick:
                break;
            case PPPEventType::OtherMouseRelease:
                break;
            case PPPEventType::OtherMouseDoubleClick:
                break;
            case PPPEventType::OtherMouseTripleClick:
                break;
            case PPPEventType::MouseMove:
                [[window->rootMorph morphAtPosition: pppEvent.point] mouseMoved: pppEvent];
                break;
            }
        }
        }
    }, nullptr, nullptr);
}

- (id)init {
    self = [super init];

    GdkWindowAttr attr;
    attr.width = 400;
    attr.height = 400;
    attr.wclass = GDK_INPUT_OUTPUT;
    attr.window_type = GDK_WINDOW_TOPLEVEL;
    attr.override_redirect = false;
    attr.title = nullptr;
    attr.event_mask = GDK_ALL_EVENTS_MASK;
    attr.x = -1;
    attr.y = -1;
    attr.type_hint = GDK_WINDOW_TYPE_HINT_NORMAL;

    self->window = gdk_window_new(nullptr, &attr, 0);
    self->rootMorph = [[PPPWindowMorph alloc] init];
    g_object_set_data(G_OBJECT(self->window), "PPPWindow", (__bridge void*)self);

    return self;
}

- (void) show {

    gdk_window_show(self->window);

}

@end
