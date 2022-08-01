#import "PPPBase.h"

#import <gdk/gdk.h>
#import <gdk/gdkwayland.h>
#import <cairomm/region.h>

@interface PPPWindowMorph : PPPMorph {
    PPPWindow* _window;
    NSMutableArray<PPPMorph*>* _focusLoop;
    PPPMorph* _keyMorph;
}

- (id) initFrom: (PPPWindow*) window;
- (void) _sortFocusLoop;

@end

@implementation PPPWindowMorph

- (id) initFrom: (PPPWindow*) window {
    self = [super init];

    _window = window;
    _focusLoop = [NSMutableArray new];
    _keyMorph = nil;

    return self;
}

- (void)changed:(const PPPRectangle &)rect {
    [_window changed: rect];
}

- (void)submorphAdded:(PPPMorph *)morph in:(PPPMorph *)parent {
    [_focusLoop addObject: morph];
    [self _sortFocusLoop];
}

- (void)submorphRemoved:(PPPMorph *)morph from:(PPPMorph *)oldParent {
    [_focusLoop removeObject: morph];
}

- (void)_doKeyMorph: (bool)forward {
    if (_keyMorph == nil) {
        for (PPPMorph* morph in _focusLoop) {
            if (morph.canBeKeyMorph) {
                _keyMorph = morph;
                break;
            }
        }
        return;
    }

    PPPMorph* beforeMorph = nil;
    PPPMorph* afterMorph = nil;
    bool foundCurrentMorph = false;

    for (PPPMorph* morph in _focusLoop) {
        NSLog(@"looping at %@", morph);
        if (!foundCurrentMorph) {
            if (morph == _keyMorph) {
                printf("morph is key morph\n");
                foundCurrentMorph = true;
            } else if (beforeMorph == nil && morph.canBeKeyMorph) {
                printf("morph before finding key morph can be key morph\n");
                beforeMorph = morph;
            }
        } else if (afterMorph == nil && morph.canBeKeyMorph) {
            printf("morph after finding key morph can be key morph\n");
            afterMorph = morph;
        }
        if (beforeMorph != nil && afterMorph != nil) {
            break;
        }
    }

    if (forward) {
        if (afterMorph != nil) {
            // no loop needed

            _keyMorph = afterMorph;

        } else if (beforeMorph != nil) {
            // loop around

            _keyMorph = beforeMorph;

        }
    } else {
        if (beforeMorph != nil) {
            // no loop needed

            _keyMorph = beforeMorph;
        } else if (afterMorph != nil) {
            // loop around

            _keyMorph = afterMorph;
        }
    }

    NSLog(@"key morph is now %@", _keyMorph);
}

- (void)_sortFocusLoop {
    NSComparator block = ^NSComparisonResult (PPPMorph* a, PPPMorph* b) {
        const auto pointA = [a pointToRoot: a.position];
        const auto pointB = [b pointToRoot: b.position];

        if (pointA.y > pointB.y) {
            return NSOrderedDescending;
        } else if (pointA.y < pointB.y) {
            return NSOrderedAscending;
        }

        if (pointA.x > pointB.x) {
            return NSOrderedDescending;
        } else if (pointA.x < pointB.x) {
            return NSOrderedAscending;
        }

        return NSOrderedSame;
    };
    [_focusLoop sortUsingComparator: block];
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
                if (pppEvent.whatKey == GDK_KEY_Tab) {
                    printf("tab pressed!\n");
                    [window->rootMorph _doKeyMorph:true];
                }
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
