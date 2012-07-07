//
//  BARTRequestor.m
//  quickbart
//
//  Created by Todd Stellanova on 1/3/11.
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

#import "BARTRequestor.h"
#import "StationDeparturePref.h"


@interface BARTRequestor (Private)

-(void)fetchAndProcessURL:(NSString*) urlStr;
-(void)processReceivedData;
-(void)cleanupAfterResponse;
@end

@implementation BARTRequestor

//You will need to obtain a BART API validation key here: http://api.bart.gov/api/register.aspx
#error "You must obtain your own BART API validation key"

static NSString *const kBART_API_ValidationKey = @"BOGUS";

@synthesize delegate = _delegate, station = _station, stationResults = _stationResults;


- (void)dealloc {
	[self cleanupAfterResponse];
	[_stationResults release];
	_stationResults = nil;
	[super dealloc];
}

- (void)cleanupAfterResponse {
	[_responseProcessor setDelegate:nil];
	[_responseProcessor release];
	_responseProcessor = nil;

	[_recvConn cancel];
	[_recvConn release];
	_recvConn = nil;
	
	[_recvBuf release];
	_recvBuf = nil;
	
	[_reqStartTime release];
	_reqStartTime = nil;
}

- (void)requestDepartureEstimates {
	
	[_responseProcessor setDelegate:nil];
	[_responseProcessor release];
	_responseProcessor = nil;
	
	//TODO temporary for debugging
#if !TARGET_IPHONE_SIMULATOR
		NSString *filePath = [[NSBundle mainBundle] pathForResource:@"etd-ALL" ofType:@"xml"];  
		[_recvBuf release];
		_recvBuf = [[NSData alloc] initWithContentsOfFile:filePath];
		[self performSelector:@selector(processReceivedData) withObject:nil afterDelay:0.1];
#else

	NSString *urlStr;
	NSString *actualDir = _station.actualDirection;

	if (nil != actualDir) {
		urlStr = [NSString stringWithFormat:
		@"http://api.bart.gov/api/etd.aspx?cmd=etd&orig=%@&dir=%@&key=%@",
		_station.abbr,
		actualDir,
		kBART_API_ValidationKey];
	} else {
		urlStr = [NSString stringWithFormat:
		@"http://api.bart.gov/api/etd.aspx?cmd=etd&orig=%@&key=%@",
		_station.abbr,
		kBART_API_ValidationKey];		
	}
	
	[self fetchAndProcessURL:urlStr];
	
#endif

}

-(void)fetchAndProcessURL:(NSString*) urlStr {
	NSURL* url = [[NSURL alloc] initWithString:urlStr];
	NSMutableURLRequest* req = [[NSMutableURLRequest alloc] initWithURL:url];
	
//#if !TARGET_IPHONE_SIMULATOR
	[req addValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	NSString* uaStr = [req valueForHTTPHeaderField:@"User-Agent"];
	if (nil != uaStr) {
		uaStr = [[NSString alloc] initWithFormat:@"%@ (gzip)",uaStr];
	}
	else {
		NSString *curBundleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];		
		uaStr = [[NSString alloc] initWithFormat:@"quickbart iOS %@ (gzip)",curBundleVersion];
	}
	[req setValue:uaStr forHTTPHeaderField:@"User-Agent"];
	[uaStr release];
//#endif
	
//	[req setCachePolicy: NSURLRequestReloadIgnoringLocalCacheData]; //don't use cached data

	_recvBuf = [[NSMutableData alloc] init];
	_reqStartTime = [[NSDate date] retain];
	_recvConn = [[NSURLConnection alloc] initWithRequest:req delegate:self];	
	
	//NSLog(@"requestor: 0x%x conn starting: 0x%x",self,_recvConn);

	[req release];
	[url release];
}

-(void)processReceivedData {
	_responseProcessor = [[BARTResponseProcessor alloc] initwithData:_recvBuf];
	[_responseProcessor setDelegate:self];
	//NSLog(@"reqestor 0x%x start processor: 0x%x",self,_responseProcessor);
	[_responseProcessor start]; 
}

#pragma mark -
#pragma mark Properties

- (NSArray	*)stationResults {
	NSArray *result = [_responseProcessor stationResults];
	return result;
}


#pragma mark -
#pragma mark NSURLConnection delegate

// Sent as a connection loads data incrementally.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[_recvBuf appendData:data];
}


//last callback received when conn is done
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	//NSTimeInterval respTime = -[_reqStartTime timeIntervalSinceNow];
	//NSLog(@"requestor: 0x%x conn finished: 0x%x  time: %f",self,connection,respTime);
	[_recvConn release];
	_recvConn = nil;
	
	[self processReceivedData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[_delegate bartRequestorDone:self anyError:error];
	//TODO cleanup after failure
}


#pragma mark -
#pragma mark ResponseProcessorDelegate

- (void)responseProcessorDone:(BARTResponseProcessor*)processor anyError:(NSError*)anyError {
	//NSLog(@"reqestor 0x%x done processor: 0x%x",self,processor);

	if (nil == anyError) {
		[_stationResults release];
		_stationResults = [_responseProcessor.stationResults copy];
		[_delegate bartRequestorDone:self anyError:nil];
		[self cleanupAfterResponse];

	} else {
		NSLog(@"responseProcessorDone with err: %@",anyError);
		[_delegate bartRequestorDone:self anyError:anyError];

	}
}

@end
