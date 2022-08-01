#define private public

#import "PPPCanvas.h"
#import "PPPColor+Cairo.h"

#import <cairomm/surface.h>
#import <cairomm/context.h>

@implementation PPPCanvas

// yoinked from gsk drawing code because hell no idk how to write graphics
// probably copyright ebassi
// REMINDME check on that if i actually make this a serious thing

static void arc(Cairo::RefPtr<Cairo::Context>& ctx, double a1, double a2, bool isNegative)
{
    if (isNegative) {
        ctx->arc_negative(0.0, 0.0, 1.0, a1, a2);
    } else {
        ctx->arc(0.0, 0.0, 1.0, a1, a2);
    }
}

static void ellipsis(Cairo::RefPtr<Cairo::Context>& ctx, double xCoord, double yCoord, double xRadius, double yRadius, double a1, double a2)
{
    if (xRadius <= 0.0 || yRadius <= 0.0) {
        ctx->line_to(xCoord, yCoord);
        return;
    }

    const auto savedMatrix = ctx->get_matrix();
    ctx->translate(xCoord, yCoord);
    ctx->scale(xRadius, yRadius);
    arc(ctx, a1, a2, false);
    ctx->set_matrix(savedMatrix);
}

static void roundedRect(Cairo::RefPtr<Cairo::Context>& ctx, const PPPRoundedRectangle& rect)
{
    using Corn = PPPRoundedRectangle::WhichCorner;

    ctx->begin_new_sub_path();

    const auto& topLeft = rect.corners[Corn::TopLeft];
    const auto& topRight = rect.corners[Corn::TopRight];
    const auto& bottomLeft = rect.corners[Corn::BottomLeft];
    const auto& bottomRight = rect.corners[Corn::BottomRight];

    ellipsis(ctx, rect.x + topLeft.width
                , rect.y + topLeft.height
                , topLeft.width, topLeft.height,
                M_PI, 3 * M_PI_2);

    ellipsis(ctx, rect.x + rect.width - topRight.width
                , rect.y + topRight.height
                , topRight.width, topRight.height,
                -M_PI_2, 0);

    ellipsis(ctx, rect.x + rect.width - bottomRight.width
                , rect.y + rect.height - bottomRight.height
                , bottomRight.width, bottomRight.height,
                0, M_PI_2);

    ellipsis(ctx, rect.x + bottomLeft.width
                , rect.y + rect.height - bottomLeft.height
                , bottomLeft.width, bottomLeft.height,
                M_PI_2, M_PI);

    ctx->close_path();
}

- (void) strokeRectangle:(const PPPRectangle&)rect width:(int)width color:(PPPColor *)color {
    auto ctx = self.context;

    ctx->save();

    ctx->set_line_width(width);
    ctx->set_source([color intoPattern]);
    ctx->rectangle(rect.x + ((float)width/2.0), rect.y + ((float)width/2.0), rect.width - width, rect.height - width);
    ctx->stroke();

    ctx->restore();
}

- (void)fillRectangle:(const PPPRectangle&)rect color:(PPPColor *)color {
    auto ctx = self.context;

    ctx->save();

    ctx->set_source([color intoPattern]);
    ctx->rectangle(rect.x, rect.y, rect.width, rect.height);
    ctx->fill();

    ctx->restore();
}

- (Cairo::RefPtr<Cairo::Context>) context {
    exit(1);
}

- (id)init {
    self = [super init];

    return self;
}

- (void)fillRoundedRectangle:(const PPPRoundedRectangle&)rect color:(PPPColor *)color {
    auto ctx = self.context;

    ctx->save();

    ctx->set_source([color intoPattern]);
    roundedRect(ctx, rect);
    ctx->fill();

    ctx->restore();
}

- (void)strokeRoundedRectangle:(const PPPRoundedRectangle&)rect width:(int)width color:(PPPColor *)color {
    auto ctx = self.context;

    ctx->save();

    ctx->set_line_width(width);
    ctx->set_source([color intoPattern]);
    const auto factor = (float)width/2.0;
    roundedRect(ctx, rect.shrink(factor, factor, factor, factor));
    ctx->stroke();

    ctx->restore();
}

- (void)withTransformation:(int)tX tY:(int)tY callback: (CanvasCallback) callback {
    self.context->save();

    self.context->translate(tX, tY);

    callback(self);

    self.context->restore();
}

@end

@implementation PPPImageCanvas

- (id)init {
    self = [super init];

    self->surface = Cairo::ImageSurface::create(Cairo::Format::FORMAT_ARGB32, 100, 100);
    self->context = Cairo::Context::create(self->surface);

    return self;
}

- (Cairo::RefPtr<Cairo::Context>)context {
    return self->context;
}

@end

@implementation PPPContextCanvas

- (Cairo::RefPtr<Cairo::Context>) context {
    return self->context;
}

- (id)initWithContext:(Cairo::RefPtr<Cairo::Context>)ctx {
    self = [super init];

    self->context = ctx;

    return self;
}

- (id)init {
    return [self initWithContext:{}];
}

@end
