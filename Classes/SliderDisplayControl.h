//
//  SliderDisplayControl.h
//  kamaaina
//
//  Created by Todd Stellanova on 4/20/08.
//
//
//	Copyright (c) 2012 Todd Stellanova, Rawthought Technologies LLC
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.
//

#import <UIKit/UIKit.h>


@interface SliderDisplayControl : UIView {
	IBOutlet	UISlider*		slider;
	IBOutlet	UITextField*	display;
	
	NSInteger	minValue;
	NSInteger	maxValue;
	
	id			delegate;
}


@property (nonatomic, readonly)		NSInteger		intValue;
@property (nonatomic, retain) UISlider*				slider;
@property (nonatomic, retain) UITextField*			display;
@property (nonatomic, retain) id					delegate;

@property (nonatomic, assign) NSInteger				minValue;
@property (nonatomic, assign) NSInteger				maxValue;

-(id)initWithFrame:(CGRect)frame minValue:(float)min maxValue:(float)max;

-(void)setValue:(NSNumber*)val;
@end


@protocol SliderDisplayControlDelegate <NSObject>

@optional

- (void)sliderValueChanged:(SliderDisplayControl*)slider;

@end
