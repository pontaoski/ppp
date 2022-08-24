#import "PPPEvent.h"
#import "PPPHandler.h"

#import <gdk/gdk.h>

@interface PPPEvent()

- (void) setFromButtonEvent: (GdkEventButton*)event;
- (void) setFromMotionEvent: (GdkEventMotion*)event;
- (void) setFromKeyEvent: (GdkEventKey*)event;

@end

@implementation PPPEvent {
    PPPEventType _eventType;
    PPPPoint _point;
    __weak PPPWindow* _window;
    PPPButtonState _buttonState;
    uint32_t _whatKey;
}

@synthesize eventType = _eventType;
@synthesize point = _point;
@synthesize window = _window;
@synthesize buttonState = _buttonState;
@synthesize whatKey = _whatKey;

- (id)initFrom:(GdkEvent *)event window: (__weak PPPWindow*) win {
    self = [super init];

    self->_window = win;

    switch (event->type) {
    case GDK_BUTTON_PRESS:
    case GDK_2BUTTON_PRESS:
    case GDK_3BUTTON_PRESS:
    case GDK_BUTTON_RELEASE:
        [self setFromButtonEvent: (GdkEventButton*)event];
        break;
    case GDK_MOTION_NOTIFY:
        [self setFromMotionEvent: (GdkEventMotion*)event];
        break;
    case GDK_KEY_PRESS:
    case GDK_KEY_RELEASE:
        [self setFromKeyEvent: (GdkEventKey*)event];
        break;
    default:
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                    reason:[NSString stringWithFormat:@"I don't know how to handle that event type! %d", event->type]
                    userInfo:nil];
    }

    return self;
}

- (void) setButtonStateFrom: (guint)state type: (guint)type button: (guint)button {
    self->_buttonState = PPPButtonState::None;
    if (state & GDK_BUTTON1_MASK && (type != GDK_BUTTON_RELEASE || button != 1)) {
        self->_buttonState |= PPPButtonState::Left;
    }
    if (state & GDK_BUTTON2_MASK && (type != GDK_BUTTON_RELEASE || button != 2)) {
        self->_buttonState |= PPPButtonState::Middle;
    }
    if (state & GDK_BUTTON3_MASK && (type != GDK_BUTTON_RELEASE || button != 3)) {
        self->_buttonState |= PPPButtonState::Right;
    }
    if (state & GDK_BUTTON4_MASK && (type != GDK_BUTTON_RELEASE || button != 4)) {
        self->_buttonState |= PPPButtonState::Other;
    }
    if (state & GDK_BUTTON5_MASK && (type != GDK_BUTTON_RELEASE || button != 5)) {
        self->_buttonState |= PPPButtonState::Other;
    }
}

- (void) setFromButtonEvent:(GdkEventButton *)event {
    self->_point = {static_cast<int>(event->x), static_cast<int>(event->y)};
    [self setButtonStateFrom: event->state type: event->type button: event->button];

    switch (event->button) {
    case 1: // left
        switch (event->type) {
        case GDK_BUTTON_PRESS: self->_eventType = PPPEventType::LeftMouseClick; break;
        case GDK_2BUTTON_PRESS: self->_eventType = PPPEventType::LeftMouseDoubleClick; break;
        case GDK_3BUTTON_PRESS: self->_eventType = PPPEventType::LeftMouseTripleClick; break;
        case GDK_BUTTON_RELEASE: self->_eventType = PPPEventType::LeftMouseRelease; break;
        default: break;
        }
        break;
    case 2: // middle
        switch (event->type) {
        case GDK_BUTTON_PRESS: self->_eventType = PPPEventType::MiddleMouseClick; break;
        case GDK_2BUTTON_PRESS: self->_eventType = PPPEventType::MiddleMouseDoubleClick; break;
        case GDK_3BUTTON_PRESS: self->_eventType = PPPEventType::MiddleMouseTripleClick; break;
        case GDK_BUTTON_RELEASE: self->_eventType = PPPEventType::MiddleMouseRelease; break;
        default: break;
        }
        break;
    case 3: // right
        switch (event->type) {
        case GDK_BUTTON_PRESS: self->_eventType = PPPEventType::RightMouseClick; break;
        case GDK_2BUTTON_PRESS: self->_eventType = PPPEventType::RightMouseDoubleClick; break;
        case GDK_3BUTTON_PRESS: self->_eventType = PPPEventType::RightMouseTripleClick; break;
        case GDK_BUTTON_RELEASE: self->_eventType = PPPEventType::RightMouseRelease; break;
        default: break;
        }
        break;
    default:
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"I don't know how to handle that mouse button" userInfo:nil];
    }
}

- (void)setFromMotionEvent:(GdkEventMotion *)event {
    self->_eventType = PPPEventType::MouseMove;
    self->_point = {static_cast<int>(event->x), static_cast<int>(event->y)};
    [self setButtonStateFrom: event->state type: event->type button: 0];
}

- (void)setFromKeyEvent:(GdkEventKey *)event {
    self->_point = {-1, -1};
    [self setButtonStateFrom: event->state type: event->type button: 0];

    switch (event->type) {
    case GDK_KEY_PRESS:
        self->_eventType = PPPEventType::KeyDown;
        break;
    case GDK_KEY_RELEASE:
        self->_eventType = PPPEventType::KeyUp;
        break;
    default:
        break;
    }

    self->_whatKey = event->keyval;    
}

@end
