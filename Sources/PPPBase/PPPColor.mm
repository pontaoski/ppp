#import "PPPColor.h"

@implementation PPPColor {
    double _red;
    double _green;
    double _blue;
    double _alpha;
}

@synthesize red;
@synthesize green;
@synthesize blue;
@synthesize alpha;

+ (PPPColor *)blue {
    return [[PPPColor alloc] initWithRed:0 green:0 blue:1.0 alpha:1.0];
}

+ (PPPColor *)green {
    return [[PPPColor alloc] initWithRed:0 green:1.0 blue:0 alpha:1.0];
}

+ (PPPColor *)red {
    return [[PPPColor alloc] initWithRed:1.0 green:0 blue:0 alpha:1.0];
}

- (id)initWithRed:(double)withRed green:(double)withGreen blue:(double)withBlue alpha:(double)withAlpha {
    self = [super init];

    self->_red = withRed;
    self->_green = withGreen;
    self->_blue = withBlue;
    self->_alpha = withAlpha;

    return self;
}

@end