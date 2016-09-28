//
//  AXRefreshControl.m
//  AXRefreshControl
//
//  Created by devedbox on 2016/9/27.
//  Copyright © 2016年 devedbox. All rights reserved.
//

#import "AXRefreshControl.h"
#import "AXRefreshControl_Private.h"
#import <pop/POP.h>

@implementation AXRefreshControl
@synthesize refreshIndicator = _refreshIndicator;
#pragma mark - Initializer
- (instancetype)init {
    if (self = [super init]) {
        [self initializer];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializer];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initializer];
    }
    return self;
}

- (void)initializer {
    [self addSubview:self.refreshIndicator];
}

#pragma mark - Override
- (void)layoutSubviews {
    [super layoutSubviews];
    
    _refreshIndicator.center = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
}

#pragma mark - Getters
- (BOOL)isRefreshing {
    return self.refreshIndicator.isAnimating;
}

- (AXRefreshControlIndicator *)refreshIndicator {
    if (_refreshIndicator) return _refreshIndicator;
    _refreshIndicator = [[AXRefreshControlIndicator alloc] initWithFrame:CGRectMake(0, 0, kAXRefreshControlIndicatorSize, kAXRefreshControlIndicatorSize)];
    _refreshIndicator.backgroundColor = [UIColor clearColor];
    return _refreshIndicator;
}

#pragma mark - Public
- (void)beginRefreshing {
    if (self.refreshIndicator.drawingComponents != 12) {
        self.refreshIndicator.drawingComponents = 12;
    }
    [self.refreshIndicator beginAnimating];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    // Set the content inset of the scroll view.
    UIEdgeInsets contentInset = _scrollView.originalInset;
    contentInset.top += kAXRefreshControlHeight;
    if (_scrollView.isDragging) return;
    POPBasicAnimation *anim1 = [POPBasicAnimation animationWithPropertyNamed:kPOPScrollViewContentInset];
    anim1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    anim1.toValue = [NSValue valueWithUIEdgeInsets:contentInset];
    [_scrollView pop_removeAnimationForKey:@"contentInset"];
    [_scrollView pop_addAnimation:anim1 forKey:@"contentInset"];
    POPBasicAnimation *anim2 = [POPBasicAnimation animationWithPropertyNamed:kPOPScrollViewContentOffset];
    anim2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    anim2.toValue = [NSValue valueWithCGPoint:CGPointMake(0, -contentInset.top)];
    [_scrollView pop_removeAnimationForKey:@"contentOffset"];
    [_scrollView pop_addAnimation:anim2 forKey:@"contentOffset"];
}

- (void)endRefreshing {
    [self.refreshIndicator endAniamting];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    // Reset the content inset of the scroll view.
    UIEdgeInsets contentInset = _scrollView.originalInset;
    if (_scrollView.isDragging) return;
    POPBasicAnimation *anim1 = [POPBasicAnimation animationWithPropertyNamed:kPOPScrollViewContentInset];
    anim1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    anim1.toValue = [NSValue valueWithUIEdgeInsets:contentInset];
    [_scrollView pop_removeAnimationForKey:@"contentInset"];
    [_scrollView pop_addAnimation:anim1 forKey:@"contentInset"];
    POPBasicAnimation *anim2 = [POPBasicAnimation animationWithPropertyNamed:kPOPScrollViewContentOffset];
    anim2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    anim2.toValue = [NSValue valueWithCGPoint:CGPointMake(0, -contentInset.top)];
    [_scrollView pop_removeAnimationForKey:@"contentOffset"];
    [_scrollView pop_addAnimation:anim2 forKey:@"contentOffset"];
}
@end

static NSString *const _kAXRefreshIndicatorRotateAnimationKey = @"_kAXRefreshIndicatorRotateAnimationKey";
static NSString *const _kAXRefreshIndicatorAnimatedColorIndexKey = @"_animatedColorIndex";

@implementation AXRefreshControlIndicator
@synthesize animating = _animating, rotating = _rotating;
#pragma mark - Initializer
- (instancetype)init {
    if (self = [super init]) {
        [self initializer];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initializer];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializer];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initializer];
}

- (void)initializer {
    _lineWidth = 2.0;
    _colorDuration = 0.8;
    _rotateDuration = 1.6;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    // Get the 12 components of the bounds.
    CGFloat angle = M_PI*2/12;
    CGContextRef cxt = UIGraphicsGetCurrentContext();
    UIColor *tintColor = self.tintColor?:[UIColor blackColor];
    for (int64_t i = _animatedColorIndex; i < _animatedColorIndex+_drawingComponents; i++) {
        [self drawLineWithAngle:angle*i+_rotateOffset-M_PI_2 context:cxt tintColor:_animating?[tintColor colorWithAlphaComponent:((float)i-(float)_animatedColorIndex)/12.0]:tintColor];
    }
}

#pragma mark - Getters
- (BOOL)isAnimating {
    return _animating;
}

- (BOOL)isRotating {
    return _rotating;
}

#pragma mark - Setters
- (void)setRotateOffset:(CGFloat)rotateOffset {
    _rotateOffset = rotateOffset;
    [self setNeedsDisplay];
}

- (void)setAnimatedColorIndex:(int64_t)animatedColorIndex {
    _animatedColorIndex = animatedColorIndex;
    [self setNeedsDisplay];
}

- (void)setDrawingComponents:(int64_t)drawingComponents {
    _drawingComponents = MIN(12, drawingComponents);
    [self setNeedsDisplay];
}

- (void)setAnimating:(BOOL)animating {
    _animating = animating;
    [self pop_removeAnimationForKey:_kAXRefreshIndicatorAnimatedColorIndexKey];
    
    if (animating) {
        [self addColorAnimationRepeat:0 duration:_colorDuration];
    }
}

- (void)setRotating:(BOOL)rotating {
    _rotating = rotating;
    if (rotating) {
        [self rotateWithRepeat:0 reverse:NO duration:_rotateDuration];
    } else {
        [self pop_removeAnimationForKey:_kAXRefreshIndicatorRotateAnimationKey];
    }
}

#pragma mark - Public 
- (void)rotateWithRepeat:(int64_t)repeat reverse:(BOOL)reverse duration:(NSTimeInterval)duration {
    _rotating = YES;
    POPBasicAnimation *rotateAnimation = [POPBasicAnimation linearAnimation];
    POPAnimatableProperty *property = [POPAnimatableProperty propertyWithName:_kAXRefreshIndicatorRotateAnimationKey initializer:^(POPMutableAnimatableProperty *prop) {
        // Read value.
        prop.readBlock = ^(AXRefreshControlIndicator *indicator, CGFloat values[]) {
            values[0] = indicator.rotateOffset;
        };
        // write value
        prop.writeBlock = ^(AXRefreshControlIndicator *indicator, const CGFloat values[]) {
            [indicator setRotateOffset:values[0]];
        };
    }];
    rotateAnimation.property = property;
    rotateAnimation.duration = duration;
    rotateAnimation.toValue = @(reverse?-M_PI*2:M_PI*2);
    rotateAnimation.repeatForever = repeat == 0;
    if (!rotateAnimation.repeatForever) {
        rotateAnimation.repeatCount = repeat;
    }
    [self pop_removeAnimationForKey:_kAXRefreshIndicatorRotateAnimationKey];
    [self pop_addAnimation:rotateAnimation forKey:_kAXRefreshIndicatorRotateAnimationKey];
}

- (void)beginAnimating {
    POPSpringAnimation *scale = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    CGFloat widthDiff = CGRectGetWidth(self.frame)*0.3;
    CGFloat heightDiff = CGRectGetHeight(self.frame)*0.3;
    CGRect original = self.frame;
    scale.springSpeed = 8;
    scale.springBounciness = 20;
    scale.fromValue = [NSValue valueWithCGRect:CGRectMake(original.origin.x - widthDiff/2, original.origin.y - heightDiff/2, original.size.width+widthDiff, original.size.height+heightDiff)];
    scale.toValue = [NSValue valueWithCGRect:original];
    scale.removedOnCompletion = YES;
    [self.layer pop_removeAnimationForKey:@"scale"];
    [self.layer pop_addAnimation:scale forKey:@"scale"];
    
    // Begin rotate.
    [self rotateWithRepeat:1 reverse:NO duration:_rotateDuration];
    [self _beginAnimating];
}


- (void)endAniamting {
    _animating = NO;
    [self pop_removeAnimationForKey:_kAXRefreshIndicatorAnimatedColorIndexKey];
    [self pop_removeAnimationForKey:_kAXRefreshIndicatorRotateAnimationKey];
    // Reset the state of control.
    _animatedColorIndex = 0;
    _rotateOffset = 0.0;
}

#pragma mark - Helper
- (void)drawLineWithAngle:(CGFloat)angle context:(CGContextRef)context tintColor:(UIColor *)tintColor {
    CGContextSetStrokeColorWithColor(context, tintColor.CGColor);
    CGContextSetLineWidth(context, _lineWidth);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    CGRect box = CGRectInset(self.bounds, _lineWidth, _lineWidth);
    
    // Get the begin point of the bounds.
    CGFloat radius = CGRectGetWidth(box)/2;
    CGPoint beginPoint = CGPointMake(self.center.x-self.frame.origin.x+radius*0.5*cos(angle), self.center.y-self.frame.origin.y+radius*0.5*sin(angle));
    CGPoint endPoint = CGPointMake(self.center.x-self.frame.origin.x+radius*cos(angle), self.center.y-self.frame.origin.y+radius*sin(angle));
    
    CGContextMoveToPoint(context, beginPoint.x, beginPoint.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    
    CGContextStrokePath(context);
}

- (void)_beginAnimating {
    [self setAnimating:YES];
}

- (void)addColorAnimationRepeat:(int64_t)repeat duration:(NSTimeInterval)duration {
    POPBasicAnimation *colorAnimation = [POPBasicAnimation linearAnimation];
    POPAnimatableProperty *property = [POPAnimatableProperty propertyWithName:_kAXRefreshIndicatorAnimatedColorIndexKey initializer:^(POPMutableAnimatableProperty *prop) {
        // Read value.
        prop.readBlock = ^(AXRefreshControlIndicator *indicator, CGFloat values[]) {
            values[0] = (CGFloat)indicator.animatedColorIndex;
        };
        // write value
        prop.writeBlock = ^(AXRefreshControlIndicator *indicator, const CGFloat values[]) {
            [indicator setAnimatedColorIndex:values[0]];
        };
    }];
    colorAnimation.property = property;
    colorAnimation.duration = duration;
    if (repeat  <= 0) {
        colorAnimation.repeatForever = YES;
    } else {
        colorAnimation.repeatCount = repeat;
    }
    colorAnimation.toValue = @(12);
    [self pop_addAnimation:colorAnimation forKey:_kAXRefreshIndicatorAnimatedColorIndexKey];
}
@end
