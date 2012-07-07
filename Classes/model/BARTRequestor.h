//
//  BARTRequestor.h
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

#import <Foundation/Foundation.h>

#import "BARTResponseProcessor.h"

@class BARTRequestor;
@class StationDeparturePref;

@protocol BARTRequestorDelegate
- (void)bartRequestorDone:(BARTRequestor *)requestor anyError:(NSError *)errorOrNil;
@end



@interface BARTRequestor : NSObject<ResponseProcessorDelegate> {
	NSDate	*_reqStartTime;
	NSMutableData *_recvBuf;
	NSURLConnection *_recvConn;
	NSObject<BARTRequestorDelegate> *_delegate;
	BARTResponseProcessor *_responseProcessor;
	StationDeparturePref *_station;
	NSArray *_stationResults;
}

@property (nonatomic, assign) NSObject<BARTRequestorDelegate> *delegate;
@property (nonatomic, readonly) NSArray	*stationResults;
@property (nonatomic, retain) StationDeparturePref *station;
- (void)requestDepartureEstimates;


@end
