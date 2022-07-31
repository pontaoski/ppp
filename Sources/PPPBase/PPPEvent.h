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

    KeyDown,
    KeyUp,
};

enum class PPPButtonState {
    None = 0,
    Left = 1 << 0,
    Middle = 1 << 1,
    Right = 1 << 2,
    Other = 1 << 3,
};

constexpr PPPButtonState operator|(PPPButtonState lhs, PPPButtonState rhs) {
    return PPPButtonState((int)lhs|(int)rhs);
}
constexpr PPPButtonState& operator|=(PPPButtonState& lhs, PPPButtonState rhs) {
    lhs = lhs|rhs;
    return lhs;
}
constexpr bool operator&(PPPButtonState lhs, PPPButtonState rhs) {
    return ((int)lhs & (int)rhs) != 0;
}

@class PPPWindow;

@interface PPPEvent : NSObject {
    PPPEventType eventType;
    PPPPoint point;
    __weak PPPWindow* window;
    PPPButtonState buttonState;
    uint32_t whatKey;
}

- (id) initFrom: (GdkEvent*)event window: (__weak PPPWindow*) window;

@property(readonly) PPPEventType eventType;
@property(readonly) PPPPoint point;
@property(readonly) PPPWindow* window;
@property(readonly) PPPButtonState buttonState;
@property(readonly) uint32_t whatKey;

@end
