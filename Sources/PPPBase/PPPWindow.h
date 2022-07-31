#import <Foundation/Foundation.h>
#import "PPPCanvas.h"

typedef struct _GdkWindow GdkWindow;

@class PPPMorph;
@class PPPWindowMorph;

@interface PPPWindow : NSObject {
    GdkWindow* window;
    NSString* title;
    PPPWindowMorph* rootMorph;

    PPPMorph* untilPointerAllUpClient;

    NSMutableArray<PPPMorph*>* pointerClients;
    NSMutableArray<PPPMorph*>* keyboardClients;
}

+ (void) initialize;

- (id) init;
- (void) show;

- (void)changed:(const PPPRectangle &)rect;

- (void) subscribePointerUntilAllUp: (PPPMorph*) morph;
- (void) unsubscribePointerUntilAllUp: (PPPMorph*) morph;
- (void) subscribePointer: (PPPMorph*) morph;
- (void) unsubscribePointer: (PPPMorph*) morph;
- (void) subscribeKeyboard: (PPPMorph*) morph;
- (void) unsubscribeKeyboard: (PPPMorph*) morph;

@property(retain) NSString* title;
@property(readonly) PPPMorph* rootMorph;

@end
