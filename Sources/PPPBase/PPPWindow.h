#import <Foundation/Foundation.h>

typedef struct _GdkWindow GdkWindow;

@class PPPMorph;
@class PPPWindowMorph;

@interface PPPWindow : NSObject {
    GdkWindow* window;
    NSString* title;
    PPPWindowMorph* rootMorph;
}

+ (void) initialize;

- (id) init;
- (void) show;

@property(retain) NSString* title;
@property(readonly) PPPMorph* rootMorph;

@end
