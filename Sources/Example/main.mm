#import "PPPBase.h"
#include "gdk/gdkkeysyms.h"
#include <cstdio>
#import <gdk/gdk.h>
#import <cairomm/region.h>

@interface RectangleMorph : PPPMorph {
    bool _pressed;
}

@end

@implementation RectangleMorph

- (id) init {
    self = [super init];

    [self setSize: {50, 50}];
    _pressed = false;

    return self;
}

- (void)drawSelfTo:(PPPCanvas *)canvas {
    if (_pressed) {
        [canvas fillRoundedRectangle:{position.x, position.y, 50, 50} color: [PPPColor blue] radius: 5];
    } else {
        [canvas fillRoundedRectangle:{position.x, position.y, 50, 50} color: [PPPColor green] radius: 5];
        [canvas strokeRoundedRectangle:{position.x, position.y, 50, 50} width:5 color: [PPPColor red] radius: 5];
    }
}

- (void)mouseDown:(PPPEvent *)with {
    _pressed = true;

    [with.window subscribePointerUntilAllUp: self];
    [self changed];
}

- (void)mouseUp:(PPPEvent *)with {
    _pressed = false;

    [self changed];
}

- (void)keyDown:(PPPEvent *)with {
    if (with.whatKey == GDK_KEY_Return) {
        _pressed = true;

        [self changed];
    }
}

- (void)keyUp:(PPPEvent *)with {
    if (with.whatKey == GDK_KEY_Return) {
        _pressed = false;

        [self changed];
    }
}

- (bool) canBeKeyMorph {
    return true;
}

@end

int main(int argc, char* argv[]) {
    @autoreleasepool {
        gdk_init(&argc, &argv);

        auto parentMorph = [RectangleMorph new];
        auto childMorph = [RectangleMorph new];
        [childMorph setPosition: {25, 25}];
        [parentMorph addMorph: childMorph];

        auto window = [PPPWindow new];

        [window.rootMorph addMorph: parentMorph];
        [window setTitle:@"Hello World!"];
        [window show];

        [window subscribeKeyboard: childMorph];

        auto loop = g_main_loop_new(nullptr, true);
        g_main_loop_run(loop);

        return 0;
    }
}
