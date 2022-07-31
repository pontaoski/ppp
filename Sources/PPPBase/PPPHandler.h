#import <Foundation/Foundation.h>
#import "PPPEvent.h"

@interface PPPHandler : NSObject

- (PPPHandler*) nextHandler;

/// The left mouse button is down
- (void) mouseDown: (PPPEvent*) with;
/// The mouse has moved
- (void) mouseMoved: (PPPEvent*) with;
/// The left mouse button is up
- (void) mouseUp: (PPPEvent*) with;

/// A key has been pressed down
- (void) keyDown: (PPPEvent*) with;

/// A key has been released
- (void) keyUp: (PPPEvent*) with;

@end
