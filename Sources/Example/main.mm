#import "PPPBase.h"
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
        [canvas fillRectangle:{position.x, position.y, 50, 50} color: [PPPColor blue]];
    } else {
        [canvas fillRectangle:{position.x, position.y, 50, 50} color: [PPPColor green]];
    }
    [canvas strokeRectangle:{position.x, position.y, 50, 50} width:5 color: [PPPColor red]];
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

        auto loop = g_main_loop_new(nullptr, true);
        g_main_loop_run(loop);

        return 0;
    }
}
