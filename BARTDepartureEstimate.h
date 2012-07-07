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


@interface BARTDepartureEstimate : NSObject {
	NSDate		*_generatedTime;
	NSDate		*_departureTime;
	NSUInteger	minutes;
	NSString	*platform;
	NSString	*direction;
	NSString	*length;
	
}

@property (nonatomic, retain) NSDate	*generatedTime;
@property (nonatomic, readonly) NSDate	*departureTime;
@property (nonatomic, assign) NSString *minutes;
@property (nonatomic, retain) NSString *platform;
@property (nonatomic, retain) NSString *length;
@property (nonatomic, retain) NSString *direction;


//	<minutes>5</minutes>
//  <minutes>Arrived</minutes>

//	<platform>2</platform>

//	<direction>North</direction>
//	<direction>South</direction>

//	<length>8</length>
//	<length>10</length>




@end
