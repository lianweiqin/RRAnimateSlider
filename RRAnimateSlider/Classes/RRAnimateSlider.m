//
//  RRAnimateSlider.m
//  RRAnimateSlider
//
//  Created by 连伟钦 on 16/1/29.
//  Copyright © 2016年 chunyu. All rights reserved.
//

#import "RRAnimateSlider.h"

#define kSliderRoundPositionRight	@"slider_round_position_right"
#define kSliderRoundPositionLeft	@"slider_round_position_left"
#define kHighlightColorYellow		[UIColor colorWithRed:0.98 green:0.76 blue:0.22 alpha:1]
#define kCheckColorGreen			[UIColor colorWithRed:0.38 green:0.68 blue:0.07 alpha:1]
#define kAnimatingTime				0.4
#define kCriticalValue				80
#define kMaxSliderValue				100


@interface RRAnimateSlider()
@property (nonatomic, strong) UIImageView* loadingCircle;
@property (nonatomic, strong) RRLoadingMaskView* loadingMask;
@property (nonatomic, strong) UIImageView* sliderRound;
@property (nonatomic, strong) UILabel* textLabel;
@property (nonatomic, strong) CAShapeLayer* greenCircle;
@property (nonatomic, strong) CAShapeLayer* checkLayer;
@end

@implementation RRAnimateSlider

- (instancetype)initWithFrame:(CGRect)frame{
	self = [super initWithFrame:frame];
	if (self){
		[self setUpApperance];
		
		// tap gesture
		UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
																			  action:@selector(tapAction:)];
		[self addGestureRecognizer:tap];
		
		// loading cicle
//		_loadingCircle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rr_slider_loading_circle.png"]];
		_loadingCircle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rr_slider_loading_circle_alpha.png"]];
		_loadingCircle.center = CGPointMake(30, self.frame.size.height / 2);
		_loadingCircle.hidden = YES;
		[_loadingCircle addSubview:self.loadingMask];
		
		[self insertSubview:_loadingCircle belowSubview:self.sliderRound];

		// text label
		_textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - 100, 0)];
		_textLabel.font = [UIFont systemFontOfSize:15];
		[self insertSubview:_textLabel belowSubview:self.sliderRound];
		
		// arrow icon
		UIImageView* arrowIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rr_slider_arrow.png"]];
		arrowIcon.center = CGPointMake(self.frame.size.width - 22, self.frame.size.height / 2);
		[self addSubview:arrowIcon];
		
	}
	return self;
}

- (void)setUpApperance{
	self.clipsToBounds = YES;
	self.layer.cornerRadius = self.frame.size.height / 2;
	self.backgroundColor = [UIColor whiteColor];
	self.layer.borderColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1].CGColor;
	self.layer.borderWidth = 2;
	
	[self setThumbImage:[UIImage imageNamed:@"rr_slider_round.png"] forState:UIControlStateNormal];
	[self setMinimumTrackImage:[UIImage imageNamed:@"clear_blank.png"] forState:UIControlStateNormal];
	[self setMaximumTrackImage:[UIImage imageNamed:@"clear_blank.png"] forState:UIControlStateNormal];
	self.maximumValue = kMaxSliderValue;
	self.minimumValue = 0;
	[self setValue:2 animated:YES];
	
}

#pragma mark - UIControl touch event tracking
-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	// If we don't touch the round or slider state is finished, We can't response to start tracking. There is no influence to response Tap Gesture Recognizer.
	CGFloat touchX = [touch locationInView:self].x;
	CGFloat touchY = [touch locationInView:self].y;
	if ( touchX > 50 || touchX < 7 || touchY > 50 || touchY < 7
		|| self.sliderState != kSliderStateUnFinished) return NO;
	self.backgroundColor = [UIColor colorWithRed:0.98 green:0.76 blue:0.22 alpha:1];
	[self setMovingState:YES];
	return [super beginTrackingWithTouch:touch withEvent:event];
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	self.loadingMask.progress = self.value;
	[self setMovingState:YES];
	return [super continueTrackingWithTouch:touch withEvent:event];
}

-(void)cancelTrackingWithEvent:(UIEvent *)event {
	[super cancelTrackingWithEvent:event];
	[self animateToFinishMoving];
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	[super endTrackingWithTouch:touch withEvent:event];
	[self animateToFinishMoving];
}

- (void)setMovingState:(BOOL)moving{
	if (moving){
//		self.backgroundColor = kHighlightColorYellow;
		self.layer.borderColor = kHighlightColorYellow.CGColor;
		self.backgroundColor = kHighlightColorYellow;
	}else{
		self.backgroundColor = [UIColor whiteColor];
		self.layer.borderColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1].CGColor;
	}
}

- (void) animateToFinishMoving{
	[self.loadingMask invokeDrawAnimation:self.value];
	BOOL isFinishToLeft = self.value < kCriticalValue;
	CABasicAnimation *positionAnima = [CABasicAnimation animationWithKeyPath:@"position.x"];
	positionAnima.fromValue = @( MIN(MAX(self.value / kMaxSliderValue * self.frame.size.width, 25), self.frame.size.width - 27 ));
	positionAnima.toValue = isFinishToLeft ? @(30) : @(self.frame.size.width - 30);
	positionAnima.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	positionAnima.removedOnCompletion = NO;
	positionAnima.fillMode = kCAFillModeForwards;
	positionAnima.duration = self.value < 98 ? kAnimatingTime : 0.1;
	positionAnima.delegate = self;
	[self.sliderRound.layer addAnimation:positionAnima forKey: isFinishToLeft ? kSliderRoundPositionLeft : kSliderRoundPositionRight];

	[self setValue:2 animated:NO];
	
}


- (void)checkAnimation{

	[self.greenCircle addSublayer:self.checkLayer];

	CABasicAnimation *checkAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
	checkAnimation.duration = 0.5;
	checkAnimation.fromValue = @(0.0f);
	checkAnimation.toValue = @(1.0f);
	checkAnimation.delegate = self;
	[checkAnimation setValue:@"checkAnimation" forKey:@"animationName"];
	[self.checkLayer addAnimation:checkAnimation forKey:nil];
}

- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
	if ([anim isEqual:[self.sliderRound.layer animationForKey:kSliderRoundPositionRight]]){
		self.sliderState = kSliderStateInCheckAnimation;
		[self.layer addSublayer:self.greenCircle];
		[self checkAnimation];
	}
	[self setMovingState:NO];
	[self.sliderRound.layer removeAllAnimations];
	
	if ([[anim valueForKey:@"animationName"] isEqualToString:@"checkAnimation"]){
		[self.checkLayer removeAllAnimations];
		[self.checkLayer removeFromSuperlayer];
		self.checkLayer = nil;
		[self.greenCircle removeFromSuperlayer];
		self.greenCircle = nil;
		self.sliderState = kSliderStateFinished;
		
		if (self.finishBlock){
			self.finishBlock();
		}
	}
	
}

#pragma mark - UITapGestureRecognizer tapAction
- (void)tapAction:(UITapGestureRecognizer *)gesture{
	if ([gesture locationInView:self].x < 50) return;
	NSLog(@"TAP");
	[self setMovingState:NO];
	// invoke the follow up business logic
	if (self.tapBlock){
		self.tapBlock();
	}
}

#pragma mark - Property getter && setter

- (UIImageView *)sliderRound{
	// hack to find the slider round
	if (!_sliderRound){
		for (UIView* view in self.subviews){
			if ([view isKindOfClass:[UIImageView class]]){
				UIImageView* imageView = (UIImageView *)view;
				if ([imageView.image isEqual:[UIImage imageNamed:@"rr_slider_round.png"]]
					|| [imageView.image isEqual:[UIImage imageNamed:@"rr_slider_round_finish.png"]]
					){
					_sliderRound = imageView;
				}
			}
		}
	}
	return _sliderRound;
}

- (void)setSliderState:(SliderState)sliderState{
	_sliderState = sliderState;
	if (sliderState == kSliderStateFinished){
		[self setThumbImage:[UIImage imageNamed:@"rr_slider_round_finish.png"]
				   forState:UIControlStateNormal];
		_loadingCircle.hidden = YES;
	}else if (sliderState == kSliderStateUnFinished){
		[self setThumbImage:[UIImage imageNamed:@"rr_slider_round.png"]
				   forState:UIControlStateNormal];
		_loadingCircle.hidden = NO;
	}else if (sliderState == kSliderStateInCheckAnimation){
		[self setThumbImage:[UIImage imageNamed:@"clear_blank.png"]
				   forState:UIControlStateNormal];
		_loadingCircle.hidden = YES;
	}
}

- (void)setText:(NSString *)text{
	_text = text;
	_textLabel.text = text;
	[_textLabel sizeToFit];
	_textLabel.textColor = _sliderState == kSliderStateFinished ?
							[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1] :
							[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
	_textLabel.frame = CGRectMake(60, self.frame.size.height / 2 - 8, self.frame.size.width - 100, 16);
}

- (RRLoadingMaskView *)loadingMask{
	if (!_loadingMask){
		_loadingMask = [[RRLoadingMaskView alloc] initWithFrame:CGRectZero];
	}
	return _loadingMask;
}

- (CAShapeLayer *)greenCircle{
	if (!_greenCircle){
		UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(29, self.frame.size.height / 2)
															radius:22.5
														startAngle:-M_PI
														  endAngle:M_PI
														 clockwise:YES];
		_greenCircle = [CAShapeLayer layer];
		_greenCircle.path = path.CGPath;
		_greenCircle.strokeColor = kCheckColorGreen.CGColor;
		_greenCircle.lineWidth = 1.5;
		_greenCircle.fillColor = [UIColor whiteColor].CGColor;
	}
	return _greenCircle;
}

- (CAShapeLayer *)checkLayer{
	if (!_checkLayer){
		_checkLayer = [CAShapeLayer layer];
		
		UIBezierPath *path = [UIBezierPath bezierPath];
//		CGRect rect = CGRectMake(7, self.frame.size.height / 2 - 23, 52, 52);
//		[path moveToPoint:CGPointMake(rect.size.width / 3, rect.size.height / 2)];
//		[path addLineToPoint:CGPointMake(rect.size.width / 2, rect.size.height / 3 * 2)];
//		[path addLineToPoint:CGPointMake(rect.size.width / 3 * 2 + 2, rect.size.height / 3 + 2)];
		[path moveToPoint:CGPointMake(22, self.frame.size.height / 2)];
		[path addLineToPoint:CGPointMake(28, 33)];
		[path addLineToPoint:CGPointMake(39, 21)];
		_checkLayer.path = path.CGPath;
		_checkLayer.fillColor = [UIColor whiteColor].CGColor;
		_checkLayer.strokeColor = kCheckColorGreen.CGColor;
		_checkLayer.lineWidth = 2;
		_checkLayer.lineCap = kCALineCapRound;
		_checkLayer.lineJoin = kCALineJoinRound;
	}
	return _checkLayer;
}
@end


@interface RRLoadingMaskView()
@property (nonatomic,strong) CADisplayLink *displayLink;
@property (nonatomic) CGFloat animateValueInterval;
@end

@implementation RRLoadingMaskView

- (instancetype) initWithFrame:(CGRect)frame{
	self = [super initWithFrame: CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), 46, 46)];
	if (self) {
		self.progress = 0;
		self.clipsToBounds = YES;
		self.layer.cornerRadius = 23;
		self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

- (void)setProgress:(CGFloat)progress{
	_progress = progress;
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	UIColor* color = kHighlightColorYellow;
//	UIColor* color = [UIColor colorWithRed:0.98 green:0.76 blue:0.22 alpha:1];
	[color set];
	
	UIBezierPath* circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)
															  radius:self.frame.size.height / 2
														  startAngle:-(M_PI / 2)
															endAngle:- (M_PI / 2) + (_progress / kMaxSliderValue) * (2 * M_PI)
														   clockwise:NO];
	
	circlePath.lineWidth = 10;
	[circlePath stroke];
}

- (void)invokeDrawAnimation:(CGFloat)value{
	if (self.displayLink){
		return;
	}
	if (value < kCriticalValue){
		// animate to left   clear the circle
		self.animateValueInterval = - value / (60 * kAnimatingTime);		// key frame
	}else{
		// animate to right  fill the circle
		self.animateValueInterval = (kMaxSliderValue - value) / (60 * kAnimatingTime);
	}
	
	self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction:)];
	[self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void) displayLinkAction:(CADisplayLink *)dis{
	self.progress = self.progress + self.animateValueInterval;

	if (self.progress < 5 || self.progress > 95){
		[self.displayLink invalidate];
		self.displayLink = nil;
	}
}

@end
