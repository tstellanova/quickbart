//
//  BARTStationsUtil.m
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

#import "BARTStationsUtil.h"

#import "StationDeparturePref.h"

NSString * const kBARTDirectionNorth = @"N";
NSString * const kBARTDirectionSouth = @"S";

static BARTStationsUtil *_instance;

@interface BARTStationsUtil (Private)

- (void)setupData;

@end

@implementation BARTStationsUtil

+ (BARTStationsUtil *)sharedInstance {
	if (nil == _instance) {
		_instance = [[BARTStationsUtil alloc] init];
	}
	
	return _instance;
}

- (id)init {
	if (self = [super init]) {
		[self setupData];
	}
	return self;
}

- (NSString*)stationNameFromAbbr:(NSString*)abbr {
	NSString *result = [_abbrToNameMap objectForKey:[abbr lowercaseString]];
	return result;
}

- (void)setupData {
	_abbrToNameMap = [[NSDictionary alloc] initWithObjectsAndKeys:
	@"12th St. Oakland City Center", @"12th",
	@"16th St. Mission (SF)", @"16th",
	@"19th St. Oakland", @"19th",
	@"24th St. Mission (SF)", @"24th",
	@"Ashby (Berkeley)", @"ashb",
	@"Balboa Park (SF)", @"balb",
	@"Bay Fair (San Leandro)",@"bayf", 
	@"Castro Valley", @"cast",
	@"Civic Center (SF)", @"civc",
	@"Coliseum/Oakland Airport", @"cols",
	@"Colma", @"colm",
	@"Concord", @"conc",
	@"Daly City", @"daly",
	@"Downtown Berkeley", @"dbrk",
	@"Dublin/Pleasanton", @"dubl",
	@"El Cerrito del Norte", @"deln",
	@"El Cerrito Plaza", @"plza",
	@"Embarcadero (SF)", @"embr",
	@"Fremont", @"frmt",
	@"Fruitvale (Oakland)", @"ftvl",
	@"Glen Park (SF)", @"glen",
	@"Hayward", @"hayw",
	@"Lafayette", @"lafy",
	@"Lake Merritt (Oakland)", @"lake",
	@"MacArthur (Oakland)", @"mcar",
	@"Millbrae",@"mlbr", 
	@"Montgomery (SF)",@"mont", 
	@"North Berkeley",@"nbrk", 
	@"North Concord/Martinez", @"ncon",
	@"Orinda", @"orin",
	@"Pittsburg/Bay Point", @"pitt",
	@"Pleasant Hill", @"phil",
	@"Powell Street (SF)", @"powl",
	@"Richmond", @"rich",
	@"Rockridge (Oakland)", @"rock",
	@"San Bruno", @"sbrn",
	@"San Francisco Airport (SFO)", @"sfia",
	@"San Leandro", @"sanl",
	@"South Hayward", @"shay",
	@"South San Francisco", @"ssan",
	@"Union City", @"ucty",
	nil];
	
	NSArray * const kNorthInboundStation  = [NSArray arrayWithObjects:kBARTDirectionNorth,kBARTDirectionSouth,nil];
	NSArray * const kSouthInboundStation  = [NSArray arrayWithObjects:kBARTDirectionSouth,kBARTDirectionNorth,nil];

	_abbrToDirectionsMap =  [[NSDictionary alloc] initWithObjectsAndKeys:
	kSouthInboundStation, @"12th",
	kNorthInboundStation, @"16th",
	kSouthInboundStation, @"19th",
	kNorthInboundStation, @"24th",
	kSouthInboundStation, @"ashb",
	kNorthInboundStation, @"balb",
	kNorthInboundStation,@"bayf", 
	kNorthInboundStation, @"cast",
	kNorthInboundStation, @"civc",
	kNorthInboundStation, @"cols",
	kNorthInboundStation, @"colm",
	kSouthInboundStation, @"conc",
	kNorthInboundStation, @"daly",
	kSouthInboundStation, @"dbrk",
	kNorthInboundStation, @"dubl",
	kSouthInboundStation, @"deln",
	kSouthInboundStation, @"plza",
	kSouthInboundStation, @"embr", //TODO wtf -- check
	kNorthInboundStation, @"frmt",
	kNorthInboundStation, @"ftvl",
	kNorthInboundStation, @"glen",
	kNorthInboundStation, @"hayw",
	kSouthInboundStation, @"lafy",
	kNorthInboundStation, @"lake",
	kSouthInboundStation, @"mcar",
	kNorthInboundStation,@"mlbr", 
	kNorthInboundStation,@"mont", 
	kSouthInboundStation,@"nbrk", 
	kSouthInboundStation, @"ncon",
	kSouthInboundStation, @"orin",
	kSouthInboundStation, @"pitt",
	kSouthInboundStation, @"phil",
	kNorthInboundStation, @"powl",
	kSouthInboundStation, @"rich",
	kSouthInboundStation, @"rock",
	kNorthInboundStation, @"sbrn",
	kNorthInboundStation, @"sfia",
	kNorthInboundStation, @"sanl",
	kNorthInboundStation, @"shay",
	kNorthInboundStation, @"ssan",
	kNorthInboundStation, @"ucty",
	nil];


}

- (NSString*)actualDirectionFromAbbr:(NSString*)abbr radialDirection:(NSString*)dir {
	NSString *result = nil;
	if ([dir isEqual:kTrainDirectionSouth]) {
		result = kBARTDirectionSouth;
	} else if ([dir isEqual:kTrainDirectionNorth]) {
		result = kBARTDirectionNorth;
	}

	/*
	NSArray *directions = [_abbrToDirectionsMap objectForKey:[abbr lowercaseString]];
	if (nil != directions) {
		if ([dir isEqual:kTrainDirectionSouth]) {
			result = [directions objectAtIndex:0];
		} else if ([dir isEqual:kTrainDirectionNorth]) {
			result =  [directions objectAtIndex:1];
		}
	}
	*/
	return result;
}

- (NSArray*)allStationAbbrs {
	return [_abbrToNameMap allKeys];
}

- (NSArray*)allStationNames {
	NSArray *allKeys = [self allStationAbbrs];
	NSMutableArray *allVals = [NSMutableArray arrayWithCapacity:[allKeys count]];
	for (NSString *key in allKeys) {
		[allVals addObject:[self stationNameFromAbbr:key]];
	}

	return allVals;
}


- (NSArray *)abbreviationsSortedByStationName {
	NSArray *result = [_abbrToNameMap keysSortedByValueUsingSelector:@selector(compare:)];
	return result;
}

NSInteger stationNameSort(id elt1, id elt2, void *context)
{
    NSString *v1 = (NSString*)[elt1 objectAtIndex:1];
    NSString *v2 = [elt2 objectAtIndex:1];
	return [v1 localizedCompare:v2];
}

- (NSArray*)sortedStationNamesAndKeys {
	NSMutableArray *keyValuePairs = [NSMutableArray array];
	
	NSArray *allKeys = [_abbrToNameMap allKeys];
	
	for (NSInteger i = 0; i < [allKeys count]; i++) {
		NSString *key =[allKeys objectAtIndex:i];
		[keyValuePairs addObject:[NSArray arrayWithObjects:key,[self stationNameFromAbbr:key],nil]];
	}
	
	
	NSArray *sortedArray = [keyValuePairs sortedArrayUsingFunction:&stationNameSort context:nil];


	return sortedArray;

}

@end
