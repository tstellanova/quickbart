//
//  DepartureSummaryView.m
//  quickbart
//
//  Created by Todd Stellanova on 12/29/10.
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

#import <QuartzCore/QuartzCore.h>

#import "DepartureSummaryView.h"

#import "BARTDepartureEstimate.h"
#import "TrainDepartureView.h"
#import "TransitDestination.h"

@interface DepartureSummaryView (Private)

-(void)drawInContext:(CGContextRef)context;
- (CGFloat)timeToPixels:(NSTimeInterval)time;

@end

@implementation DepartureSummaryView


@synthesize departureData = _departureData, 
	minDeltaTime = _minDeltaTime,
	maxDeltaTime = _maxDeltaTime, 
	travelTime = _travelTime;


const CGFloat kDestLabelXInset = 15.0;
const CGFloat kTimeLineXInset = 5.0;


const CGFloat	kTimeLineHeight = 20.0;
const CGFloat	kDestinationLabelFontSize = 18.0;
const CGFloat	kDestinationLabelHeight = 20.0;
const CGFloat	kTrainWidth = 30.0;
const CGFloat	kTrainHeight = 20.0;
const CGFloat	kTrainLabelYOffset = 0.0;
const CGFloat	kTopPad = 4.0;
const CGFloat	kMidGap = 4.0;
const CGFloat	kBottomPad = 4.0;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		_destinationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_destinationLabel.backgroundColor = [UIColor clearColor ]; 
		_destinationLabel.clipsToBounds = NO;
		[self addSubview:_destinationLabel];
		
		_timeLine = [[UIView alloc] initWithFrame:CGRectZero];
		_timeLine.backgroundColor = [UIColor clearColor];
		_timeLine.clipsToBounds = YES;
		[self addSubview:_timeLine];
		
		[self layoutIfNeeded];
    }
    return self;
}

- (void)dealloc {
	[_departureData release];
	_departureData = nil;
	
	[_destinationLabel release];
	_destinationLabel = nil;
	
	[_timeLine release];
	_timeLine = nil;
    [super dealloc];
}

//- (void)drawRect:(CGRect)rect {
//    // custom Drawing code	
//	CGContextRef ctx = UIGraphicsGetCurrentContext();
//	[self drawInContext:ctx];
//}


- (CGFloat)timeToPixels:(NSTimeInterval)time {
	CGFloat result = 0.0;
	if (time >= _minDeltaTime) {
		if (time < _maxDeltaTime) {
			result = ((time - _minDeltaTime)  / (_maxDeltaTime  - _minDeltaTime)) * _timeLine.frame.size.width;
			if (result > _maxTrainX)
				result = _maxTrainX;
		} else {
			result = _maxTrainX;
		}

	} 
	
//	if (0.0 == result) {	
//		NSLog(@"minDelta: %f time: %f maxDelta: %f width: %d",_minDeltaTime,time,_maxDeltaTime,_timeLine.frame.size.width);
//	}
	
	return result;
}

- (void)setDepartureData:(TransitDestination*)data {
	if (![data isEqual:_departureData]) {
		[_departureData release];
		_departureData = [data retain];

		//remove all the train icons
		[[_timeLine subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
		
		_maxTrainX = _timeLine.frame.size.width - kTrainWidth;
		
		if (nil != _departureData) {
			NSDate *curTime = [NSDate date];

			//draw in reverse order so that later departures are on the bottom,
			//sooner departures are on top
			NSEnumerator *enumerator = [self.departureData.departureEstimates reverseObjectEnumerator];
			for (BARTDepartureEstimate *estimate in enumerator) {
				NSTimeInterval deltaTime = [estimate.departureTime  timeIntervalSinceDate:curTime]; 
				if (deltaTime < 0)
					deltaTime = 0;

				BOOL onTime = (deltaTime >= _travelTime);

				CGFloat xOffset = [self timeToPixels:deltaTime];					
				CGRect trainFrame = CGRectMake(xOffset,kTrainLabelYOffset,kTrainWidth,kTrainHeight);
				TrainDepartureView *trainView = 
					[[TrainDepartureView alloc] initWithFrame:trainFrame mode:onTime departing:deltaTime];
									
				[_timeLine addSubview:trainView];
				[trainView release];		
			}

			_destinationLabel.text = _departureData.destination;
		} else {
			_destinationLabel.text = nil;
		}
		
		[self setNeedsDisplay];
	}
}


-(void)drawInContext:(CGContextRef)context
{
//	CGFloat yInset = 42.0;
	CGFloat xInset = 10.0;
//	CGFloat fullWidth = self.frame.size.width - 2*xInset;

/*
	// Drawing lines with a white stroke color
	CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 0.5);
	// Draw them with a 2.0 stroke width so they are a bit more visible.
	CGContextSetLineWidth(context, 2.0);
	
	// Draw a single line from left to right
	CGContextMoveToPoint(context, xInset, yInset);
	CGContextAddLineToPoint(context, fullWidth, yInset);
	CGContextStrokePath(context);
*/

	CGFloat xOffset = xInset + [self timeToPixels:_travelTime];
	
	CGContextSetLineWidth(context, 1.0);
	CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 0.5);
	CGContextMoveToPoint(context, xOffset, _timeLine.frame.origin.y);
	CGContextAddLineToPoint(context, xOffset, [DepartureSummaryView defaultViewHeight]);
	CGContextStrokePath(context);
}


- (void)layoutSubviews {
	CGFloat top = kTopPad;

	CGRect destLabelFrame = CGRectMake(kDestLabelXInset, top, self.frame.size.width - 2*kDestLabelXInset, kDestinationLabelHeight);
	_destinationLabel.frame = destLabelFrame;
	_destinationLabel.font = [UIFont systemFontOfSize:kDestinationLabelFontSize];
	_destinationLabel.adjustsFontSizeToFitWidth = YES;
	_destinationLabel.textColor = [UIColor darkGrayColor];
	
	top += _destinationLabel.frame.size.height + kMidGap;

	CGRect timeLabelFrame = CGRectMake(kTimeLineXInset, top, self.frame.size.width - kTimeLineXInset, kTimeLineHeight);
	_timeLine.frame = timeLabelFrame;
}

+ (CGFloat)defaultViewHeight {
	return kTopPad + kTimeLineHeight + kMidGap + kDestinationLabelHeight + kBottomPad;
}

@end
