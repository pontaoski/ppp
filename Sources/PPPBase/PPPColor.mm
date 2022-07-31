#import "PPPColor.h"

@implementation PPPColor

@synthesize red;
@synthesize green;
@synthesize blue;
@synthesize alpha;

+ (PPPColor *)blue {
    return [[PPPColor alloc] initWithRed:0 green:0 blue:255 alpha:255];
}

+ (PPPColor *)green {
    return [[PPPColor alloc] initWithRed:0 green:255 blue:0 alpha:255];
}

+ (PPPColor *)red {
    return [[PPPColor alloc] initWithRed:255 green:0 blue:0 alpha:255];
}

- (id)initWithRed:(int)withRed green:(int)withGreen blue:(int)withBlue alpha:(int)withAlpha {
    self = [super init];

    self->red = withRed;
    self->green = withGreen;
    self->blue = withBlue;
    self->alpha = withAlpha;

    return self;
}

@end