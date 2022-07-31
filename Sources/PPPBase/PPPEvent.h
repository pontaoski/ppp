#import <Foundation/Foundation.h>
#import "PPPCanvas.h"

typedef union _GdkEvent GdkEvent;

@class PPPHandler;

enum class PPPEventType {
    LeftMouseClick,
    LeftMouseRelease,
    LeftMouseDoubleClick,
    LeftMouseTripleClick,

    MiddleMouseClick,
    MiddleMouseRelease,
    MiddleMouseDoubleClick,
    MiddleMouseTripleClick,

    RightMouseClick,
    RightMouseRelease,
    RightMouseDoubleClick,
    RightMouseTripleClick,

    OtherMouseClick,
    OtherMouseRelease,
    OtherMouseDoubleClick,
    OtherMouseTripleClick,

    MouseMove,
};

@interface PPPEvent : NSObject {
    PPPEventType eventType;
    PPPPoint point;
}

- (id) initFrom: (GdkEvent*)event;

@property(readonly) PPPEventType eventType;
@property(readonly) PPPPoint point;

@end
