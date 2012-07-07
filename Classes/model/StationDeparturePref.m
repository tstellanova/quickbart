//
//  StationDeparturePref.m
//  quickbart
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

#import "StationDeparturePref.h"

#import "BARTStationsUtil.h"


NSString * const kTrainDirectionSouth = @"South";
NSString * const kTrainDirectionNorth = @"North";
NSString * const kTrainDirectionBoth = @"Both";

NSString * const kDictKeyAbbr = @"abbr";
NSString * const kDictKeyDir = @"direction";
NSString * const kDictKeyTravelTime = @"travelTime";

@implementation StationDeparturePref

@synthesize abbr = _abbreviation, direction = _direction, travelTime = _travelTime;


- (id)initWithDictionary:(NSDictionary *)dict {
	if (self = [self init]) {
		self.abbr = [dict valueForKey:kDictKeyAbbr];
		self.direction = [dict valueForKey:kDictKeyDir];
		self.travelTime = [dict valueForKey:kDictKeyTravelTime];
	}
	
	return self;
}

- (id)initWithAbbr:(NSString*)abbr direction:(NSString*)direction {
	if (self = [self init]) {
		self.abbr = abbr;
		self.direction = direction;
	}
	
	return self;
}

- (NSDictionary *)toDictionary {

	NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:
		self.abbr,kDictKeyAbbr,
		self.direction,kDictKeyDir,
		self.travelTime,kDictKeyTravelTime,
		nil];
		
	return result;
	
}

- (NSString*)stationName {
	NSString *result = [[BARTStationsUtil sharedInstance] stationNameFromAbbr:self.abbr];
	return result;
}

- (NSString*)actualDirection {
	NSString *result = [[BARTStationsUtil sharedInstance] actualDirectionFromAbbr:self.abbr radialDirection:self.direction];
	return result;
}

- (NSString *)uniqueKey {
	NSString *result = [NSString stringWithFormat:@"%@ - %@",self.stationName,self.direction];
	return result;
}

- (BOOL)isEqual:(id)anObject {
	NSString *otherKey = [anObject uniqueKey];
	NSString *myKey = [self uniqueKey];
	return [otherKey isEqual:myKey];
}

- (NSUInteger)hash {
	NSString *myKey = [self uniqueKey];
	return [myKey hash];
}



@end
