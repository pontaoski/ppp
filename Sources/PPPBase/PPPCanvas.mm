#define private public

#import "PPPCanvas.h"
#import "PPPColor+Cairo.h"

#import <cairomm/surface.h>
#import <cairomm/context.h>

@implementation PPPCanvas

template<typename T>
void roundedRect(Cairo::RefPtr<Cairo::Context>& ctx, T x, T y, T w, T h, T r)
{
    ctx->begin_new_sub_path();
    ctx->arc(x + r, y + r, r, M_PI, 3 * M_PI / 2);
    ctx->arc(x + w - r, y + r, r, 3 *M_PI / 2, 2 * M_PI);
    ctx->arc(x + w - r, y + h - r, r, 0, M_PI / 2);
    ctx->arc(x + r, y + h - r, r, M_PI / 2, M_PI);
    ctx->close_path();
}

- (void) strokeRectangle:(PPPRectangle)rect width:(int)width color:(PPPColor *)color {
    auto ctx = self.context;

    ctx->save();

    ctx->set_line_width(width);
    ctx->set_source([color intoPattern]);
    ctx->rectangle(rect.x + ((float)width/2.0), rect.y + ((float)width/2.0), rect.width - width, rect.height - width);
    ctx->stroke();

    ctx->restore();
}

- (void)fillRectangle:(PPPRectangle)rect color:(PPPColor *)color {
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

- (void)fillRoundedRectangle:(PPPRectangle)rect color:(PPPColor *)color radius:(int)radius {
    auto ctx = self.context;

    ctx->save();

    ctx->set_source([color intoPattern]);
    roundedRect(ctx, rect.x, rect.y, rect.width, rect.height, radius);
    ctx->fill();

    ctx->restore();
}

- (void)strokeRoundedRectangle:(PPPRectangle)rect width:(int)width color:(PPPColor *)color radius:(int)radius {
    auto ctx = self.context;

    ctx->save();

    ctx->set_line_width(width);
    ctx->set_source([color intoPattern]);
    roundedRect<double>(ctx, rect.x + ((float)width/2.0), rect.y + ((float)width/2.0), rect.width - width, rect.height - width, radius);
    ctx->stroke();

    ctx->restore();
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
