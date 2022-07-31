#import "PPPBase.h"
#include <cstdio>
#import <gdk/gdk.h>
#import <cairomm/region.h>

@interface RectangleMorph : PPPMorph
@end

@implementation RectangleMorph

- (id) init {
    self = [super init];

    [self setSize: {50, 50}];

    return self;
}

- (void)drawSelfTo:(PPPCanvas *)canvas {
    [canvas fillRectangle:{position.x, position.y, 50, 50} color: [PPPColor green]];
    [canvas strokeRectangle:{position.x, position.y, 50, 50} width:5 color: [PPPColor red]];
}

- (void)mouseDown:(PPPEvent *)with {
    printf("the one at (%d, %d) was clicked!\n", position.x, position.y);
    [with.window subscribePointerUntilAllUp: self];
}

- (void)mouseUp:(PPPEvent *)with {
    printf("the one at (%d, %d) was released!\n", position.x, position.y);
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
