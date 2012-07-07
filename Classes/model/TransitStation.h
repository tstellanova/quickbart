//
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

#import <Foundation/Foundation.h>


@class TransitDestination;
@class BARTDepartureEstimate;

@interface TransitStation : NSObject {
	NSDate	*_lastDepartureEstimateReceived;
	NSString	*_abbreviation;
	//collection of TransitDestination
	NSMutableDictionary *_destinationsMap;
	NSMutableArray	*_destinationsList;
	
	BARTDepartureEstimate	*_soonestDepartureEstimate;
	BARTDepartureEstimate	*_latestDepartureEstimate;
	
	NSTimeInterval		_estimatedTravelTime;
}

@property (nonatomic, retain) NSDate *lastDepartureEstimateReceived;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, retain) NSString *abbr;

@property (readonly) NSArray *destinationsList;
@property (nonatomic, readonly) NSDictionary *destinationsMap;

@property (nonatomic, readonly) BARTDepartureEstimate *soonestDepartureEstimate;
@property (nonatomic, readonly) BARTDepartureEstimate *latestDepartureEstimate;
@property (nonatomic, readonly) NSTimeInterval minDepartureDelta;
@property (nonatomic, readonly) NSTimeInterval maxDepartureDelta;
@property (nonatomic, assign)	NSTimeInterval estimatedTravelTime;

- (void)addDestination:(TransitDestination *)destination;


@end
