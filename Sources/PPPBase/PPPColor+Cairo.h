#import <Foundation/Foundation.h>
#import "PPPColor.h"
#import <cairomm/pattern.h>

@interface PPPColor (CairoColor)

- (Cairo::RefPtr<Cairo::Pattern>) intoPattern;

@end
