#define private public

#import "PPPCanvas.h"
#import "PPPColor+Cairo.h"

#import <cairomm/surface.h>
#import <cairomm/context.h>

@implementation PPPCanvas

- (void) strokeRectangle:(PPPRectangle)rect width:(int)width color:(PPPColor *)color {
    auto ctx = self.context;

    ctx->save();

    ctx->set_line_width(width);
    ctx->set_source([color intoPattern]);
    ctx->rectangle(rect.x + ((float)width/2.0), rect.y + ((float)width/2.0), rect.width, rect.height);
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
