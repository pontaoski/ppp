#import <Foundation/Foundation.h>
#import "PPPCanvas.h"
#import "PPPHandler.h"

@interface PPPMorph : PPPHandler

- (id) init;

- (void) drawTo: (PPPCanvas*) canvas;
- (void) drawSelfTo: (PPPCanvas*) canvas;

@property(readonly) PPPMorph* parentMorph;

- (void) addMorph: (PPPMorph*) newMorph;
- (void) removeMorph: (PPPMorph*) oldMorph;

@property(readonly) NSArray<PPPMorph*>* submorphs;

@property PPPPoint position;
@property PPPSize size;

@property(readonly) PPPRectangle baseBounds;
@property(readonly) PPPRectangle totalBounds;

- (PPPPoint) pointToParent: (const PPPPoint&)point;
- (PPPPoint) pointFromParent: (const PPPPoint&)point;

- (PPPRectangle)rectToParent: (const PPPRectangle&)rect;
- (PPPRectangle)rectFromParent: (const PPPRectangle&)rect;

- (PPPMorph*) morphAtPosition: (PPPPoint)point;

- (void) changed: (const PPPRectangle&)rect;
- (void) changed;

@end
