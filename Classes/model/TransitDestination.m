//
//  Created by Todd Stellanova on 12/17/10.
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

#import "TransitDestination.h"

#import "BARTDepartureEstimate.h"

@implementation TransitDestination

@synthesize departureEstimates = _departureEstimates, destination = _destination, abbreviation = _abbreviation,
	lastDepartureEstimateReceived = _lastDepartureEstimateReceived;

- (id)init {
	if (self = [super init]) {
		_departureEstimates = [[NSMutableArray alloc] init];
	}

	return self;
}

- (void)dealloc {
	self.destination = nil;
	self.abbreviation = nil;
	[_departureEstimates release];
	_departureEstimates = nil;
	self.lastDepartureEstimateReceived = nil;
	[_soonestDeparture release];
	_soonestDeparture = nil;
	[_latestDeparture release];
	_latestDeparture = nil;
	[super dealloc];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
	//NSLog(@"%@ setValue:%@ forUndefinedKey:%@",[self class],value,key);//TODO ignore for now
}

- (void)addDepartureEstimate:(BARTDepartureEstimate *)estimate {
	[_departureEstimates addObject:estimate];
	
	NSDate *newDeparture = estimate.departureTime;
	if (nil == _soonestDeparture) 
		_soonestDeparture = [estimate retain];
		
	if ([[newDeparture earlierDate:_soonestDeparture.departureTime] isEqualToDate:newDeparture]) {
		[_soonestDeparture release];
		_soonestDeparture = [estimate retain];
	}
	
	if (nil == _latestDeparture)
		_latestDeparture = [estimate retain];
		
	if ([[_latestDeparture.departureTime laterDate:newDeparture] isEqualToDate:newDeparture]) {
		[_latestDeparture release];
		_latestDeparture = [estimate retain];
	}

}


- (BARTDepartureEstimate *)soonestDeparture {
	return _soonestDeparture;
}

- (BARTDepartureEstimate *)latestDeparture {
	return _latestDeparture;
}


- (NSString *)description {
	NSMutableString *desc = [NSMutableString stringWithFormat:@"%@: ",self.abbreviation];
	
	for (BARTDepartureEstimate *estimate in  _departureEstimates) {
		NSTimeInterval deltaTime = [estimate.departureTime timeIntervalSinceNow];
		if (deltaTime < 0)
			deltaTime = 0;
		[desc appendFormat:@"%03.1f ", deltaTime];
	}
	
	return desc;
}



@end
