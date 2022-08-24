#import "PPPMorph.h"
#include "PPPCanvas.h"

@implementation PPPMorph {
    PPPMorph* _owner;
    NSMutableArray<PPPMorph*>* _submorphs;
    PPPPoint _position;
    PPPSize _size;
    bool _sticksOut;
}

@synthesize position = _position;
@synthesize size = _size;

- (PPPHandler*)nextHandler {
    return self->_owner;
}

- (void)drawSelfTo:(PPPCanvas *)canvas {
}

- (void)drawTo:(PPPCanvas *)canvas {
    [self drawSelfTo:canvas];

    for (PPPMorph* submorph in self->_submorphs) {
        const auto pos = submorph.position;
        [canvas withTransformation: pos.x tY:pos.y callback: ^(PPPCanvas *canvas) {
            [submorph drawTo:canvas];
        }];
    }
}

- (PPPMorph*) parentMorph {
    return self->_owner;
}

- (void) __updateSticksOut {
    self->_sticksOut = false;
    for (PPPMorph* morph in _submorphs) {
        if (!self.baseBounds.totallyContains(morph.baseBounds)) {
            self->_sticksOut = true;
            return;
        }
    }
}

- (void) addMorph: (PPPMorph*) newMorph {
    auto oldOwner = newMorph->_owner;
    if (oldOwner != nil) {
        [oldOwner removeMorph: newMorph];
    }
    newMorph->_owner = self;
    [newMorph setPosition: [newMorph pointFromParent:[newMorph position]]];
    [self->_submorphs addObject: newMorph];
    [self __updateSticksOut];
}

- (void) removeMorph: (PPPMorph*) oldMorph {
    auto pos = [oldMorph pointToParent:[oldMorph position]];
    oldMorph->_owner = nil;
    [oldMorph setPosition:pos];
    [self->_submorphs removeObject: oldMorph];
    [self __updateSticksOut];
}

- (NSArray<PPPMorph*>*) submorphs {
    return self->_submorphs;
}

- (id)init {
    self = [super init];

    self->_owner = nil;
    self->_submorphs = [NSMutableArray new];

    return self;
}

- (PPPPoint)pointToParent:(const PPPPoint&)point {
    if (self->_owner == nil) {
        return point;
    } else {
        return [self->_owner pointToParent:[self->_owner position]] + point;
    }
}

- (PPPPoint)pointFromParent:(const PPPPoint&)point {
    if (self->_owner == nil) {
        return point;
    } else {
        return point - [self->_owner pointToParent:[self->_owner position]];
    }
}

- (PPPRectangle)rectToParent:(const PPPRectangle&)rect {
    return rect.withPoint([self pointToParent: {rect.x, rect.y}]);
}

- (PPPRectangle)rectFromParent:(const PPPRectangle&)rect {
    return rect.withPoint([self pointFromParent: {rect.x, rect.y}]);
}

- (PPPMorph *)morphAtPosition:(PPPPoint)point {
    @autoreleasepool {
        for (PPPMorph* morph in self->_submorphs.reverseObjectEnumerator) {
            auto pt = [morph pointFromParent: point];
            if (morph.totalBounds.contains(pt)) {
                if (auto child = [morph morphAtPosition:pt]) {
                    return child;
                }
            }
        }
    }
    if (self.baseBounds.contains(point)) {
        return self;
    }
    return nil;
}

- (PPPRectangle)baseBounds {
    return PPPRectangle::fromPointAndSize(self->_position, self->_size);
}

- (PPPRectangle)totalBounds {
    if (!self->_sticksOut) {
        return self.baseBounds;
    }

    auto rect = self.baseBounds;
    for (PPPMorph* morph in _submorphs) {
        rect = rect.mergedWith([morph rectToParent: morph.totalBounds]);
    }

    return rect;
}

- (void)changed:(const PPPRectangle &)rect {
    [_owner changed: [self rectToParent: rect]];
}

- (void)changed {
    [_owner changed: [self baseBounds]];
}

@end
