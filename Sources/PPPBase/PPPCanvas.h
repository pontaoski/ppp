#import <Foundation/Foundation.h>
#import <cairomm/context.h>
#import <cairomm/surface.h>
#import "PPPColor.h"

struct PPPSize {
    int width;
    int height;
};

struct PPPPoint {
    int x;
    int y;

    constexpr inline PPPPoint operator+(const PPPPoint& other) const {
        return {x+other.x, y+other.y};
    }
    constexpr inline PPPPoint operator-(const PPPPoint& other) const {
        return {x-other.x, y-other.y};
    }
};

struct PPPRectangle {
    int x;
    int y;
    int width;
    int height;

    constexpr static inline PPPRectangle fromPointAndSize(const PPPPoint& point, const PPPSize& size)
    {
        return {point.x, point.y, size.width, size.height};
    }
    constexpr inline PPPPoint topLeft() const
    { return {x, y}; }
    constexpr inline PPPPoint topRight() const
    { return {x+width, y}; }
    constexpr inline PPPPoint bottomLeft() const
    { return {x, y+height}; }
    constexpr inline PPPPoint bottomRight() const
    { return {x+width, y+height}; }
    constexpr inline bool contains(const PPPPoint& point) const
    {
        if (point.x >= x && point.x <= x+width && point.y >= y && point.y <= y+height)
            return true;

        return false;
    }
    constexpr inline bool totallyContains(const PPPRectangle& other) const
    {
        return contains(other.topLeft()) && contains(other.topRight()) &&
               contains(other.bottomLeft()) && contains(other.bottomRight());
    }
    constexpr inline PPPRectangle mergedWith(const PPPRectangle& other) const
    {
        return {std::min(x, other.x), std::min(y, other.y), std::max(width, other.x+other.width), std::max(height, other.y+other.height)};
    }
    constexpr inline PPPRectangle withPoint(const PPPPoint& point) const
    {
        return {point.x, point.y, width, height};
    }
};

@interface PPPCanvas : NSObject

- (id) init;

- (Cairo::RefPtr<Cairo::Context>) context;

- (void) strokeRectangle: (PPPRectangle) rect width: (int) width color: (PPPColor*) color;
- (void) fillRectangle: (PPPRectangle) rect color: (PPPColor*) color;

- (void) strokeRoundedRectangle: (PPPRectangle) rect width: (int) width color: (PPPColor*) color radius: (int) radius;
- (void) fillRoundedRectangle: (PPPRectangle) rect color: (PPPColor*) color radius: (int) radius;

@end





@interface PPPImageCanvas : PPPCanvas {
    Cairo::RefPtr<Cairo::ImageSurface> surface;
    Cairo::RefPtr<Cairo::Context> context;
}

@end

@interface PPPContextCanvas : PPPCanvas {
    Cairo::RefPtr<Cairo::Context> context;
}

- (id) initWithContext: (Cairo::RefPtr<Cairo::Context>) context;

@end
