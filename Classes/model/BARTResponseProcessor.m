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

#import "BARTResponseProcessor.h"


#import "TransitStation.h"
#import "TransitDestination.h"
#import "BARTDepartureEstimate.h"

static NSString * const ELEMENT_ROOT = @"root";
static NSString * const ELEMENT_STATION = @"station";
static NSString * const ELEMENT_ETD = @"etd";
static NSString * const ELEMENT_ESTIMATE = @"estimate";


@implementation BARTResponseProcessor


@synthesize stationResults = _stationResults, delegate;

- (id)init {
	if (self = [super init]) {
		_stationResults = [[NSMutableArray alloc] init];
		elementObjectStack = [[NSMutableArray alloc] init];
	}
	return self;
}

- (id)initWithURL:(NSURL*)url {
	if (self = [self init])  {
		parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
	}
	
	return self;
}

- (id)initwithData:(NSData*)data {
	if (self = [self init]) {
		parser = [[NSXMLParser alloc] initWithData:data];
	}
	
	return self;
}

- (void)dealloc {
	[parser release];
	parser = nil;

	[_stationResults release];
	_stationResults = nil;
	
	[elementObjectStack release];
	elementObjectStack = nil;
	
	[_curEstimateTimestamp release];
	_curEstimateTimestamp = nil;
	[super dealloc];
}

- (BOOL)start {
	[parser setDelegate:self];
	return [parser parse];
}

#pragma mark -
#pragma mark NSXMLParser Delegate 

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
	namespaceURI:(NSString *)namespaceURI 
	qualifiedName:(NSString *)qualifiedName 
	attributes:(NSDictionary *)attributeDict { 

	if ([elementName isEqualToString:ELEMENT_ESTIMATE]) {
		[currentDepartureEstimate release];
		currentDepartureEstimate = [[BARTDepartureEstimate alloc] init];
		currentDepartureEstimate.generatedTime = _curEstimateTimestamp;
		[elementObjectStack addObject:currentDepartureEstimate];
	} else if ([elementName isEqualToString:ELEMENT_ETD]) {
		[currentDestination release];
		currentDestination = [[TransitDestination alloc] init];	
		currentDestination.lastDepartureEstimateReceived = _curEstimateTimestamp;
		[elementObjectStack addObject:currentDestination];
	} else if ([elementName isEqualToString:ELEMENT_STATION]) {
		//NOTE this asssumes we've already received the header of the <root> element
		NSString *estimateTime = [[currentRootEntity valueForKey:@"time"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if (nil != estimateTime) {
			// <time>01:50:00 PM PST</time>
			NSDateFormatter *df = [[NSDateFormatter alloc] init];
			[df setDefaultDate:[NSDate date]];
			[df setDateFormat:@"HH:mm:ss aa zzz"];
			[_curEstimateTimestamp release];
			_curEstimateTimestamp = [[df dateFromString:estimateTime] retain];			
			[df release];
		}
		currentStation = [[TransitStation alloc] init];
		currentStation.lastDepartureEstimateReceived = _curEstimateTimestamp;
		[elementObjectStack addObject:currentStation];
	} else if ([elementName isEqualToString:ELEMENT_ROOT]) {
		[currentRootEntity release];
		currentRootEntity = [[NSMutableDictionary alloc] init];
		[elementObjectStack addObject:currentRootEntity];
	}
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
	namespaceURI:(NSString *)namespaceURI
	qualifiedName:(NSString *)qName {
	
	//NSLog(@"%@ end", elementName); 

	if ([elementName isEqualToString:ELEMENT_ESTIMATE]) {
		[currentDestination addDepartureEstimate:currentDepartureEstimate];
		[elementObjectStack removeLastObject];
		[currentDepartureEstimate release];
		currentDepartureEstimate = nil;
	} else if ([elementName isEqualToString:ELEMENT_ETD]) {
		[currentStation addDestination:currentDestination];
		[elementObjectStack removeLastObject];
		[currentDestination release];
		currentDestination = nil;
	} else if ([elementName isEqualToString:ELEMENT_STATION]) {
		[_stationResults addObject:currentStation];
		[elementObjectStack removeLastObject];
		[currentStation release];
		currentStation = nil;
	}  else if ([elementName isEqualToString:ELEMENT_ROOT]) {
		[elementObjectStack removeLastObject];
		[currentRootEntity release];
		currentRootEntity = nil;
	} else {
		NSObject *curObj = [elementObjectStack lastObject];
		if (nil != curObj) {
			[curObj setValue:currentElementValue forKey:elementName];
		}
	}
	
	[currentElementValue release];
	currentElementValue = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	if (nil == currentElementValue) {
		currentElementValue = [[NSMutableString alloc] init];
	}
	[currentElementValue appendString:string];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	if (nil != delegate) {
		[delegate responseProcessorDone:self anyError:nil];
	}
}




@end
