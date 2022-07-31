#import "PPPEvent.h"
#import "PPPHandler.h"

#import <gdk/gdk.h>

@interface PPPEvent()

- (void) setFromButtonEvent: (GdkEventButton*)event;
- (void) setFromMotionEvent: (GdkEventMotion*)event;

@end

@implementation PPPEvent

@synthesize eventType;
@synthesize point;

- (id)initFrom:(GdkEvent *)event {
    self = [super init];

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
    default:
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                    reason:[NSString stringWithFormat:@"I don't know how to handle that event type! %d", event->type]
                    userInfo:nil];
    }

    return self;
}

- (void) setFromButtonEvent:(GdkEventButton *)event {
    self->point = {static_cast<int>(event->x), static_cast<int>(event->y)};

    switch (event->button) {
    case 1: // left
        switch (event->type) {
        case GDK_BUTTON_PRESS: self->eventType = PPPEventType::LeftMouseClick; break;
        case GDK_2BUTTON_PRESS: self->eventType = PPPEventType::LeftMouseDoubleClick; break;
        case GDK_3BUTTON_PRESS: self->eventType = PPPEventType::LeftMouseTripleClick; break;
        case GDK_BUTTON_RELEASE: self->eventType = PPPEventType::LeftMouseRelease; break;
        default: break;
        }
        break;
    case 2: // middle
        switch (event->type) {
        case GDK_BUTTON_PRESS: self->eventType = PPPEventType::MiddleMouseClick; break;
        case GDK_2BUTTON_PRESS: self->eventType = PPPEventType::MiddleMouseDoubleClick; break;
        case GDK_3BUTTON_PRESS: self->eventType = PPPEventType::MiddleMouseTripleClick; break;
        case GDK_BUTTON_RELEASE: self->eventType = PPPEventType::MiddleMouseRelease; break;
        default: break;
        }
        break;
    case 3: // right
        switch (event->type) {
        case GDK_BUTTON_PRESS: self->eventType = PPPEventType::RightMouseClick; break;
        case GDK_2BUTTON_PRESS: self->eventType = PPPEventType::RightMouseDoubleClick; break;
        case GDK_3BUTTON_PRESS: self->eventType = PPPEventType::RightMouseTripleClick; break;
        case GDK_BUTTON_RELEASE: self->eventType = PPPEventType::RightMouseRelease; break;
        default: break;
        }
        break;
    default:
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"I don't know how to handle that mouse button" userInfo:nil];
    }
}

- (void)setFromMotionEvent:(GdkEventMotion *)event {
    self->eventType = PPPEventType::MouseMove;
}

@end
