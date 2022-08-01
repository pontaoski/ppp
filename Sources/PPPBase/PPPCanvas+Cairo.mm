#import "PPPCanvas+Cairo.h"

@implementation PPPCanvas (CairoCanvas)

- (Cairo::RefPtr<Cairo::Context>) context {
    exit(1);
}

@end

@implementation PPPContextCanvas {
    Cairo::RefPtr<Cairo::Context> context;
}

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

