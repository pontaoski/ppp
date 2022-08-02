#import "PPPCanvas+Cairo.h"

@implementation PPPCanvas (CairoCanvas)

- (Cairo::RefPtr<Cairo::Context>) context {
    exit(1);
}

@end

@implementation PPPContextCanvas {
    Cairo::RefPtr<Cairo::Context> _context;
}

- (Cairo::RefPtr<Cairo::Context>) context {
    return self->_context;
}

- (id)initWithContext:(Cairo::RefPtr<Cairo::Context>)ctx {
    self = [super init];

    self->_context = ctx;

    return self;
}

- (id)init {
    return [self initWithContext:{}];
}

@end

