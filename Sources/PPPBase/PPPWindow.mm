#import "PPPBase.h"
#include "PPPCanvas.h"

#import <gdk/gdk.h>
#import <gdk/gdkwayland.h>
#import <cairomm/region.h>

@interface PPPWindowMorph : PPPMorph {
    PPPWindow* _window;
}

- (id) initFrom: (PPPWindow*) window;

@end

@implementation PPPWindowMorph

- (id) initFrom: (PPPWindow*) window {
    self = [super init];

    _window = window;

    return self;
}

- (void)changed:(const PPPRectangle &)rect {
    [_window changed: rect];
}

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
            auto region = Cairo::Region(gdk_window_get_clip_region(event->expose.window));
            auto extents = region.get_extents();

            auto ctx = gdk_window_begin_draw_frame(event->expose.window, region.cobj());
            auto cairo = gdk_drawing_context_get_cairo_context(ctx);
            auto cairoContext = Cairo::RefPtr<Cairo::Context>(new Cairo::Context(cairo));

            auto window = (__bridge PPPWindow*)(g_object_get_data(G_OBJECT(event->expose.window), "PPPWindow"));
            auto canvas = [[PPPContextCanvas alloc] initWithContext:cairoContext];
            const auto rrect = PPPRoundedRectangle::initWithRadii(extents.x, extents.y, extents.width, extents.height, 0.0, 0.0, 5.0, 5.0);
            [canvas fillRoundedRectangle:rrect color:[[PPPColor alloc] initWithRed: 222.0/255.0 green: 224.0/255.0 blue: 226.0/255.0 alpha: 1.0]];
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
        case GDK_PROPERTY_NOTIFY:
            break;
        default: {
            auto window = (__bridge PPPWindow*)(g_object_get_data(G_OBJECT(event->any.window), "PPPWindow"));
            auto pppEvent = [[PPPEvent alloc] initFrom: event window: window];

            switch (pppEvent.eventType) {
            case PPPEventType::LeftMouseClick:
                [[window->rootMorph morphAtPosition: pppEvent.point] mouseDown: pppEvent];
                break;
            case PPPEventType::LeftMouseRelease:
                for (PPPMorph* subscriber in window->pointerClients) {
                    [subscriber mouseUp: pppEvent];
                }
                break;
            case PPPEventType::KeyDown:
                for (PPPMorph* subscriber in window->keyboardClients) {
                    [subscriber keyDown: pppEvent];
                }
                break;
            case PPPEventType::KeyUp:
                for (PPPMorph* subscriber in window->keyboardClients) {
                    [subscriber keyUp: pppEvent];
                }
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
                for (PPPMorph* subscriber in window->pointerClients) {
                    [subscriber mouseMoved: pppEvent];
                }
                break;
            }

            // handle the release
            switch (pppEvent.eventType) {
            case PPPEventType::LeftMouseRelease:
            case PPPEventType::MiddleMouseRelease:
            case PPPEventType::RightMouseRelease:
            case PPPEventType::OtherMouseRelease:
                if (pppEvent.buttonState == PPPButtonState::None) {
                    [window unsubscribePointerUntilAllUp: window->untilPointerAllUpClient];
                }
                break;
            default:
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
    if (GDK_IS_WAYLAND_WINDOW(self->window)) {
        gdk_wayland_window_announce_ssd(self->window);
    } else {
        gdk_window_set_decorations(window, GDK_DECOR_ALL);
    }
    self->rootMorph = [[PPPWindowMorph alloc] initFrom: self];
    self->untilPointerAllUpClient = nil;
    self->pointerClients = [NSMutableArray new];
    self->keyboardClients = [NSMutableArray new];
    g_object_set_data(G_OBJECT(self->window), "PPPWindow", (__bridge void*)self);

    return self;
}

- (void) show {

    gdk_window_show(self->window);

}

- (void)subscribeKeyboard:(PPPMorph *)morph {
    [self->keyboardClients addObject: morph];
}

- (void)unsubscribeKeyboard:(PPPMorph *)morph {
    [self->keyboardClients removeObject: morph];
}

- (void)subscribePointer:(PPPMorph *)morph {
    [self->pointerClients addObject: morph];
}

- (void)unsubscribePointer:(PPPMorph *)morph {
    [self->pointerClients removeObject: morph];
}

- (void)subscribePointerUntilAllUp:(PPPMorph *)morph {
    if (self->untilPointerAllUpClient != nil) {
        [self unsubscribePointer: self->untilPointerAllUpClient];
    }
    self->untilPointerAllUpClient = morph;
    [self subscribePointer: morph];
}

- (void)unsubscribePointerUntilAllUp:(PPPMorph*) morph {
    if (self->untilPointerAllUpClient != morph || self->untilPointerAllUpClient == nil) {
        return;
    }

    [self unsubscribePointer:morph];
    self->untilPointerAllUpClient = nil;
}


- (void)changed:(const PPPRectangle &)rect {
    GdkRectangle gdkRect = {rect.x, rect.y, rect.width, rect.height};

    gdk_window_invalidate_rect(self->window, &gdkRect, false);
}

@end
