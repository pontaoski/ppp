#import "PPPColor+Cairo.h"
#import <cairomm/pattern.h>

@implementation PPPColor (CairoColor)

- (Cairo::RefPtr<Cairo::Pattern>)intoPattern {
    return Cairo::RefPtr<Cairo::Pattern>(Cairo::SolidPattern::create_rgba(self.red, self.green, self.blue, self.alpha));
}

@end
