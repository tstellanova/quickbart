//
//  StationPrefs.m
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

#import "StationPrefs.h"

#import "StationDeparturePref.h"

static StationPrefs *_instance;

@implementation StationPrefs


NSString * const kStationPrefsDefault = @"STATION_PREFS";
NSString * const kSelectedDepartureDefault = @"SELECTED_DEPARTURE_PATH";

@synthesize preferredStations = _preferredStations;
@synthesize selectedDestinationPath = _selectedDestinationPath;

+ (StationPrefs *)sharedInstance {
	if (nil == _instance) {
		_instance = [[StationPrefs alloc] init];
	}
	
	return _instance;
}


- (id)init {

	if (self = [super init]) {
		_userDefaults = [[NSUserDefaults standardUserDefaults] retain];
		NSArray *existingStationData = [_userDefaults objectForKey:kStationPrefsDefault];
		if (nil == existingStationData)  {
			//Set some default values
			StationDeparturePref *east = [[StationDeparturePref alloc] 
									initWithAbbr:@"12th"
									direction:kTrainDirectionSouth];
			east.travelTime = [NSNumber numberWithFloat:11.0];

			StationDeparturePref *west = [[StationDeparturePref alloc] 
									initWithAbbr:@"embr"
									direction:kTrainDirectionNorth];
			west.travelTime = [NSNumber numberWithFloat:5.0];


			_preferredStations = [[NSMutableArray alloc] initWithObjects:
				east,
				west,
				nil
			];
			
			[east release];
			[west release];
		} else {
			_preferredStations = [[NSMutableArray alloc] initWithCapacity:[existingStationData count]];
			for (NSDictionary *stationData in existingStationData) {
				StationDeparturePref *newPref = [[StationDeparturePref alloc] initWithDictionary:stationData];
				[_preferredStations addObject:newPref];
				[newPref release];
			}
			
			_selectedDestinationPath = [_userDefaults objectForKey:kSelectedDepartureDefault];
		}
		
	}
	
	return self;
}

- (void)dealloc {
	[self flushPrefs];
	[_userDefaults release];
	_userDefaults = nil;

	[_selectedDestinationPath release];
	_selectedDestinationPath = nil;

	[_preferredStations release];
	_preferredStations = nil;
	[super dealloc];
}

- (void)flushPrefs {
	NSMutableArray *stationPrefs = [[NSMutableArray alloc] initWithCapacity:[_preferredStations count]];
	for (StationDeparturePref *pref in _preferredStations) {
		[stationPrefs addObject:[pref toDictionary]];
	}
	
	[_userDefaults setObject:stationPrefs forKey:kStationPrefsDefault];
	[_userDefaults setObject:_selectedDestinationPath forKey:kSelectedDepartureDefault];
	
	[_userDefaults synchronize];
	[stationPrefs release];
}

@end
