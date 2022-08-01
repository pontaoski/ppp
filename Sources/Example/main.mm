#import "PPPBase.h"
#include "PPPCanvas.h"
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
    const auto rrect = PPPRoundedRectangle::initWithRadius(0, 0, 50, 50, 5);
    if (_pressed) {
        [canvas fillRoundedRectangle:rrect color: [PPPColor blue]];
    } else {
        [canvas fillRoundedRectangle:rrect color: [PPPColor green]];
        [canvas strokeRoundedRectangle:rrect width:5 color: [PPPColor red]];
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
