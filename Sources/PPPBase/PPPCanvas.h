#import <Foundation/Foundation.h>
#import "PPPColor.h"
#import <algorithm>

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

struct PPPRoundedRectangle {
    struct Corner {
        float width;
        float height;

        constexpr inline Corner shrink(float width, float height, float maxWidth, float maxHeight) const
        {
            auto self = *this;

            if (self.width > 0)
                self.width -= width;
            if (self.height > 0)
                self.height -= height;

            if (self.width <= 0 || self.height <= 0)
            {
                self.width = 0;
                self.height = 0;
            }
            else
            {
                self.width = std::min(self.width, maxWidth);
                self.height = std::min(self.height, maxHeight);
            }

            return self;
        }
    };

    enum WhichCorner {
        TopLeft = 0,
        TopRight = 1,
        BottomLeft = 2,
        BottomRight = 3,
    };

    float x;
    float y;
    float width;
    float height;
    Corner corners[4];

    constexpr static inline PPPRoundedRectangle init(float x, float y, float width, float height)
    {
        return PPPRoundedRectangle{x, y, width, height, {{0, 0}, {0, 0}, {0, 0}, {0, 0}}};
    }
    constexpr static inline PPPRoundedRectangle initWithRadius(float x, float y, float width, float height, float radius) {
        return PPPRoundedRectangle{x, y, width, height, {{radius, radius}, {radius, radius}, {radius, radius}, {radius, radius}}};
    }
    constexpr static inline PPPRoundedRectangle initWithRadii(float x, float y, float width, float height, float topLeft, float topRight, float bottomLeft, float bottomRight) {
        return PPPRoundedRectangle{x, y, width, height, {{topLeft, topLeft}, {topRight, topRight}, {bottomLeft, bottomLeft}, {bottomRight, bottomRight}}};
    }
    constexpr inline PPPRoundedRectangle shrink(float top, float right, float bottom, float left) const
    {
        auto self = *this;

        if (self.width - left - right < 0) {
            self.x += left * self.width / (left + right);
            self.width = 0;
        } else {
            self.x += left;
            self.width -= left + right;
        }

        if (self.height - bottom - top < 0) {
            self.y += top * self.height / (top+bottom);
        } else {
            self.y += top;
            self.height -= top + bottom;
        }

        self.corners[TopLeft] = self.corners[TopLeft].shrink(left, top, self.width, self.height);
        self.corners[TopRight] = self.corners[TopRight].shrink(right, top, self.width, self.height);
        self.corners[BottomLeft] = self.corners[BottomLeft].shrink(left, bottom, self.width, self.height);
        self.corners[BottomRight] = self.corners[BottomRight].shrink(right, bottom, self.width, self.height);

        return self;
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

- (void) strokeRectangle: (const PPPRectangle&) rect width: (int) width color: (PPPColor*) color;
- (void) fillRectangle: (const PPPRectangle&) rect color: (PPPColor*) color;

- (void) strokeRoundedRectangle: (const PPPRoundedRectangle&) rect width: (int) width color: (PPPColor*) color;
- (void) fillRoundedRectangle: (const PPPRoundedRectangle&) rect color: (PPPColor*) color;

typedef void (^CanvasCallback) (PPPCanvas* canvas);

- (void) withTransformation: (int) tX tY: (int) tY callback: (CanvasCallback) callback;

@end

@interface PPPImageCanvas : PPPCanvas

@end
