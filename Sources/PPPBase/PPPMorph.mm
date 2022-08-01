#import "PPPMorph.h"
#include "PPPCanvas.h"

@implementation PPPMorph

@synthesize position;
@synthesize size;

- (PPPHandler*)nextHandler {
    return self->owner;
}

- (void)drawSelfTo:(PPPCanvas *)canvas {
}

- (void)drawTo:(PPPCanvas *)canvas {
    [self drawSelfTo:canvas];

    for (PPPMorph* submorph in self->submorphs) {
        [submorph drawTo:canvas];
    }
}

- (PPPMorph*) parentMorph {
    return self->owner;
}

- (void) __updateSticksOut {
    self->sticksOut = false;
    for (PPPMorph* morph in submorphs) {
        if (!self.baseBounds.totallyContains(morph.baseBounds)) {
            self->sticksOut = true;
            return;
        }
    }
}

- (void) addMorph: (PPPMorph*) newMorph {
    auto oldOwner = newMorph->owner;
    if (oldOwner != nil) {
        [oldOwner removeMorph: newMorph];
    }
    newMorph->owner = self;
    [newMorph setPosition: [newMorph pointFromParent:[newMorph position]]];
    [self->submorphs addObject: newMorph];
    [self submorphAdded: newMorph in: self];
    [self __updateSticksOut];
}

- (void) removeMorph: (PPPMorph*) oldMorph {
    auto pos = [oldMorph pointToParent:[oldMorph position]];
    oldMorph->owner = nil;
    [oldMorph setPosition:pos];
    [self->submorphs removeObject: oldMorph];
    [self submorphRemoved: oldMorph from: self];
    [self __updateSticksOut];
}

- (NSArray<PPPMorph*>*) submorphs {
    return self->submorphs;
}

- (id)init {
    self = [super init];

    self->owner = nil;
    self->submorphs = [NSMutableArray new];

    return self;
}

- (PPPPoint)pointToParent:(const PPPPoint&)point {
    if (self->owner == nil) {
        return point;
    } else {
        return [self->owner pointToParent:[self->owner position]] + point;
    }
}

- (PPPPoint)pointFromParent:(const PPPPoint&)point {
    if (self->owner == nil) {
        return point;
    } else {
        return point - [self->owner pointToParent:[self->owner position]];
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
        for (PPPMorph* morph in self->submorphs.reverseObjectEnumerator) {
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
    return PPPRectangle::fromPointAndSize(self->position, self->size);
}

- (PPPRectangle)totalBounds {
    if (!self->sticksOut) {
        return self.baseBounds;
    }

    auto rect = self.baseBounds;
    for (PPPMorph* morph in submorphs) {
        rect = rect.mergedWith([morph rectToParent: morph.totalBounds]);
    }

    return rect;
}

- (void)changed:(const PPPRectangle &)rect {
    [owner changed: [self rectToParent: rect]];
}

- (void)changed {
    [owner changed: [self baseBounds]];
}

- (void)submorphAdded:(PPPMorph *)morph in:(PPPMorph *)parent {
    [self.parentMorph submorphAdded:morph in:parent];
}

- (void)submorphRemoved:(PPPMorph *)morph from:(PPPMorph *)oldParent {
    [self.parentMorph submorphRemoved:morph from:oldParent];
}

- (PPPPoint)pointToRoot:(const PPPPoint &)point {
    if (self.parentMorph == nil) {
        return point;
    }
    return [self.parentMorph pointToRoot: [self pointToParent: point]];
}

- (bool)canBeKeyMorph {
    return false;
}

@end
