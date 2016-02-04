//
//  ViewController.m
//  RRAnimateSlider
//
//  Created by 连伟钦 on 16/1/29.
//  Copyright © 2016年 chunyu. All rights reserved.
//

#import "ViewController.h"
#import "RRAnimateSlider.h"

@interface ViewController ()

@end

@implementation ViewController{
	RRAnimateSlider* _slider1;
	RRAnimateSlider* _slider2;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor whiteColor];

	_slider1 = [[RRAnimateSlider alloc] initWithFrame:CGRectMake(15, 100, 340, 54)];
	_slider1.sliderState = kSliderStateUnFinished;
	_slider1.text = @"1. 早晨喝了一杯水";
	__weak ViewController* _self = self;
	_slider1.tapBlock = ^(void){
		ViewController* vc = [ViewController new];
		[_self.navigationController pushViewController:vc animated:YES];
	};
	[self.view addSubview:_slider1];
	
	_slider2 = [[RRAnimateSlider alloc] initWithFrame:CGRectMake(15, 200, 340, 54)];
	_slider2.sliderState = kSliderStateFinished;
	_slider2.text = @"2. 喝了个和呵呵呵呵";
	_slider2.tapBlock = ^(void){
		ViewController* vc = [ViewController new];
		[_self.navigationController pushViewController:vc animated:YES];
	};
	[self.view addSubview:_slider2];
	
	UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(10, 300, 200, 20)];
	[btn setTitle:@"reset" forState:UIControlStateNormal];
	[btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(onResetClicked) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btn];
}

- (void)onResetClicked{
	_slider1.sliderState = kSliderStateUnFinished;
	_slider2.sliderState = kSliderStateUnFinished;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
