#import <Foundation/Foundation.h>
#import "PPPCanvas.h"
#import "PPPHandler.h"

@interface PPPMorph : PPPHandler {
    PPPMorph* owner;
    NSMutableArray<PPPMorph*>* submorphs;
    PPPPoint position;
    PPPSize size;
    bool sticksOut;
}

- (id) init;

- (void) drawTo: (PPPCanvas*) canvas;
- (void) drawSelfTo: (PPPCanvas*) canvas;

- (PPPMorph*) parentMorph;
- (void) addMorph: (PPPMorph*) newMorph;
- (void) removeMorph: (PPPMorph*) oldMorph;
- (NSArray<PPPMorph*>*) submorphs;

@property PPPPoint position;
@property PPPSize size;

- (PPPRectangle) baseBounds;
- (PPPRectangle) totalBounds;

- (PPPPoint) pointToParent: (const PPPPoint&)point;
- (PPPPoint) pointFromParent: (const PPPPoint&)point;

- (PPPRectangle)rectToParent: (const PPPRectangle&)rect;
- (PPPRectangle)rectFromParent: (const PPPRectangle&)rect;

- (PPPMorph*) morphAtPosition: (PPPPoint)point;

@end