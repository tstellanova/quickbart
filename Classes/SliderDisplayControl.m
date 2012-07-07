//
//  SliderDisplayControl.m
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

#import "SliderDisplayControl.h"


@implementation SliderDisplayControl

@synthesize slider;
@synthesize display;
@synthesize delegate;

@synthesize		minValue;
@synthesize		maxValue;

-(id)initWithFrame:(CGRect)frame minValue:(float)min maxValue:(float)max {
    if (self = [super initWithFrame:frame]) {
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;

		self.slider = [[UISlider alloc] initWithFrame:CGRectZero];
		slider.minimumValue  = min;
		slider.maximumValue = max;
		slider.value = min;
		slider.autoresizingMask = UIViewAutoresizingFlexibleWidth;

		[slider addTarget:self action:@selector(sliderUpdated) forControlEvents:UIControlEventValueChanged];
		[self addSubview:slider];
		
		NSNumber* nVal = [NSNumber numberWithInt: (int)slider.value];
		UITextField* textInput = [[UITextField alloc] initWithFrame:CGRectZero];
		textInput.borderStyle =   UITextBorderStyleBezel;
	
		self.display = textInput;
		[textInput release];
		display.userInteractionEnabled = NO; //don't allow user to edit...
		display.textAlignment =  UITextAlignmentCenter;
		display.text =  [nVal stringValue];
		[self addSubview:display];
	}
	return self;
}

- (void)layoutSubviews {
	CGRect myBounds = self.bounds; 
	NSString* maxStr = [[NSNumber numberWithInt: slider.maximumValue] stringValue];
	CGSize maxSize = [maxStr sizeWithFont:display.font];
	
	float displayWidth = maxSize.width + 15;
	float inputWidth = (myBounds.size.width - displayWidth);
	
	display.frame =  CGRectMake(myBounds.origin.x,myBounds.origin.y,displayWidth,myBounds.size.height);
	slider.frame =  CGRectMake(myBounds.origin.x + displayWidth,myBounds.origin.y,inputWidth,myBounds.size.height);
}

- (void)sliderUpdated {
	float val = slider.value;
	NSNumber* nVal = [NSNumber numberWithInt: (int)val];
	[display setText: [nVal stringValue]];
	
	if (self.delegate) {
		[self.delegate sliderValueChanged:self];
	}
}

-(NSInteger)	intValue {
	float val = slider.value;
	NSInteger nint = (int)val;
	
	return nint;
}

-(void)setValue:(NSNumber*)val {	
	[display setText: [val stringValue]];
	slider.value = [val floatValue];
}




- (void)dealloc {
	[slider release];
	[display release];
	[super dealloc];
}

@end
