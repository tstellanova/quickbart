//
//  TrainDepartureView.m
//  quickbart
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


#import "TrainDepartureView.h"


@implementation TrainDepartureView


- (id)initWithFrame:(CGRect)frame mode:(BOOL)onTime departing:(NSTimeInterval)seconds {
    if ((self = [super initWithFrame:frame])) {
	
		UIImage *img = nil;
		CGRect subFrame = [self bounds];
		subFrame = CGRectInset(subFrame,4.0,2.0);
		_timeLabel = [[UILabel alloc] initWithFrame:subFrame];

		if (onTime) {
			_timeLabel.textColor = [UIColor blackColor];
			img = [UIImage imageNamed:@"/train_icons/departure_train_8BFF19.png"];
		} else {
			_timeLabel.textColor = [UIColor whiteColor];
			img = [UIImage imageNamed:@"/train_icons/departure_train_AA0000.png"];
		}
		
		_trainIconView = [[UIImageView alloc] initWithImage:img]; 
		_timeLabel.backgroundColor = [UIColor clearColor];
		_timeLabel.textAlignment = UITextAlignmentRight;
		_timeLabel.text = [NSString stringWithFormat:@"%d",(NSUInteger)(seconds / 60.0)];

		[self addSubview:_trainIconView];
		[self addSubview:_timeLabel];
	}
    return self;
}


- (void)dealloc {
	[_timeLabel release];
	_timeLabel = nil;
	[_trainIconView release];
	_trainIconView = nil;
    [super dealloc];
}


@end
