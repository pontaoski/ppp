#import <Foundation/Foundation.h>

@interface PPPColor : NSObject

+ (PPPColor*) red;
+ (PPPColor*) green;
+ (PPPColor*) blue;

- (id) initWithRed: (double)red green: (double)green blue: (double)blue alpha: (double)alpha;

@property double red;
@property double green;
@property double blue;
@property double alpha;

@end
