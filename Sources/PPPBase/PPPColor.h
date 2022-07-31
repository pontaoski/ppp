#import <Foundation/Foundation.h>

@interface PPPColor : NSObject {
    int red;
    int green;
    int blue;
    int alpha;
}

+ (PPPColor*) red;
+ (PPPColor*) green;
+ (PPPColor*) blue;

- (id) initWithRed: (int)red green: (int)green blue: (int)blue alpha: (int)alpha;

@property int red;
@property int green;
@property int blue;
@property int alpha;

@end
