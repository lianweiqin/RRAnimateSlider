//
//  RRAnimateSlider.h
//  RRAnimateSlider
//
//  Created by 连伟钦 on 16/1/29.
//  Copyright © 2016年 chunyu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^RRAnimationInvokeBlock)(void);

typedef NS_ENUM(NSInteger, SliderState){
	kSliderStateUnFinished,
	kSliderStateFinished,
	
	kSliderStateInCheckAnimation,			// private state
};

/**
 *  A slider with loading animation
 *	How to use? 
    Example Code :
 
		_slider1 = [[RRAnimateSlider alloc] initWithFrame:CGRectMake(15, 100, 340, 54)];
		_slider1.sliderState = kSliderStateUnFinished;
		_slider1.text = @"1. 早晨喝了一杯水";
		__weak ViewController* _self = self;
		_slider1.tapBlock = ^(void){
			ViewController* vc = [ViewController new];
			[_self.navigationController pushViewController:vc animated:YES];
		};
		[self.view addSubview:_slider1];
 *  
 *  The slider's height might better be 54, because I'm lazy to fit the common situation.
 *  = =||||||
 */

// You can new a subclass of this class to extend other propertys.
@interface RRAnimateSlider : UISlider

@property (nonatomic, strong) NSString* text;			// set the text in label.

@property (nonatomic) SliderState sliderState;			// public state contain finished & unfinished.

@property (nonatomic, strong) RRAnimationInvokeBlock tapBlock;	// tap event invoke this block to do something.

@property (nonatomic, strong) RRAnimationInvokeBlock finishBlock;	// invoke when the sliderstate change to Finished
@end


@interface RRLoadingMaskView : UIView

@property (nonatomic) CGFloat progress;			// it has the same range with RRAnimateSlider's value

- (void)invokeDrawAnimation:(CGFloat)value;

@end
