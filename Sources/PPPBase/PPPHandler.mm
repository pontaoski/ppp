#import "PPPHandler.h"

@implementation PPPHandler

- (PPPHandler*)nextHandler {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
        reason:[NSString stringWithFormat:@"You need to override %@", NSStringFromSelector(_cmd)]
        userInfo:nil];
}

- (void)mouseDown:(PPPEvent *)with {
    [self.nextHandler mouseDown: with];
}

- (void)mouseMoved:(PPPEvent *)with {
    [self.nextHandler mouseMoved: with];
}

- (void)mouseUp:(PPPEvent *)with {
    [self.nextHandler mouseUp: with];
}

- (void)keyDown:(PPPEvent *)with {
    [self.nextHandler keyDown: with];
}

- (void)keyUp:(PPPEvent *)with {
    [self.nextHandler keyUp: with];
}

@end
