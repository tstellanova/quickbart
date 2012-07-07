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

#import "TransitStation.h"

#import "TransitDestination.h"
#import "BARTDepartureEstimate.h"
#import "BARTStationsUtil.h"

@implementation TransitStation

@synthesize destinationsList = _destinationsList, 
	destinationsMap = _destinationsMap, 
	abbr = _abbreviation,
	lastDepartureEstimateReceived = _lastDepartureEstimateReceived,
	soonestDepartureEstimate = _soonestDepartureEstimate,
	latestDepartureEstimate = _latestDepartureEstimate,
	estimatedTravelTime =		_estimatedTravelTime;

- (id)init {
	if (self = [super init]) {
		_destinationsList = [[NSMutableArray alloc] init];
		_destinationsMap = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

- (void)dealloc {
	[_destinationsList release];
	_destinationsList = nil;
	[_destinationsMap release];
	_destinationsMap = nil;
	[_soonestDepartureEstimate release];
	_soonestDepartureEstimate= nil;
	[_latestDepartureEstimate release];
	_latestDepartureEstimate = nil;
	self.lastDepartureEstimateReceived = nil;
	[super dealloc];
}

- (void)addDestination:(TransitDestination *)destination {
	@synchronized(_destinationsList) {
		[_destinationsList addObject:destination];
	}
	[_destinationsMap setObject:destination forKey:destination.abbreviation];
	
	BARTDepartureEstimate *soonest = destination.soonestDeparture;
	if (nil == _soonestDepartureEstimate)
		_soonestDepartureEstimate = [soonest retain];
	
	NSDate *newSoonest = soonest.departureTime;
	if ([[newSoonest earlierDate:_soonestDepartureEstimate.departureTime] isEqualToDate:newSoonest]) {
		[_soonestDepartureEstimate release];
		_soonestDepartureEstimate = [soonest retain];
	}
	
	BARTDepartureEstimate *latest = destination.latestDeparture;
	if (nil == _latestDepartureEstimate)
		_latestDepartureEstimate = [latest retain];
		
	NSDate *newLatest = latest.departureTime;
	if ([[_latestDepartureEstimate.departureTime laterDate:newLatest] isEqualToDate:newLatest]) {
		[_latestDepartureEstimate release];
		_latestDepartureEstimate = [latest retain];
	}
}

- (NSString*)name {
	NSString *result = [[BARTStationsUtil sharedInstance] stationNameFromAbbr:_abbreviation];
	return result;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
	//NSLog(@"%@ setValue:%@ forUndefinedKey:%@",[self class],value,key);//TODO ignore for now
}

- (NSTimeInterval)minDepartureDelta {
	NSTimeInterval result = [_soonestDepartureEstimate.departureTime timeIntervalSinceNow];
	if (result < 0.0)
		result = 0.0;
	return result;
}

- (NSTimeInterval)maxDepartureDelta {
	NSTimeInterval result = [_latestDepartureEstimate.departureTime timeIntervalSinceNow];
	return result;
}

- (NSString *)description {
	NSMutableString *desc = [NSMutableString stringWithFormat:
	@"%@ (%@): \n",self.name,self.abbr];
	
	for (NSString *dest in [_destinationsMap allValues]) {
		[desc appendFormat:@"%@ \n",dest];
	}
	
	return desc;
}

@end
