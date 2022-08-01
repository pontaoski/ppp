#import "PPPCanvas.h"
#import <cairomm/surface.h>
#import <cairomm/context.h>

@interface PPPCanvas (CairoCanvas)

- (Cairo::RefPtr<Cairo::Context>) context;

@end

@interface PPPContextCanvas : PPPCanvas

- (id) initWithContext: (Cairo::RefPtr<Cairo::Context>) context;

@end
