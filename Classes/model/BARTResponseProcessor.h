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

@class TransitStation;
@class TransitDestination;
@class BARTDepartureEstimate;

@class BARTResponseProcessor;



/*
Lines:

Pittsburgh/Bay Point - SFO
Richmond - Millbrae
Richmond - Fremont
Dublin/Pleasanton - Millbrae
Fremont - Daly City


*/
@protocol  ResponseProcessorDelegate 
- (void)responseProcessorDone:(BARTResponseProcessor*)processor anyError:(NSError*)errorOrNil;
@end

@interface BARTResponseProcessor : NSObject {
	NSXMLParser *parser;
	NSMutableString *currentElementValue;
	
	NSMutableArray	*_stationResults;
	NSDate			*_curEstimateTimestamp;
	NSMutableDictionary	*currentRootEntity;
	TransitStation	*currentStation;
	TransitDestination *currentDestination;
	BARTDepartureEstimate *currentDepartureEstimate;
	
	NSMutableArray *elementObjectStack;
	
	NSObject<ResponseProcessorDelegate> *delegate;
}


@property (nonatomic, assign) NSObject<ResponseProcessorDelegate> *delegate;
@property (nonatomic, readonly) NSArray *stationResults;

- (id)initWithURL:(NSURL*)url;
- (id)initwithData:(NSData*)data;

- (BOOL)start;

@end
