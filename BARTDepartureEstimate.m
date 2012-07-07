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

#import "BARTDepartureEstimate.h"


@implementation BARTDepartureEstimate

@synthesize platform, direction, length, departureTime = _departureTime, generatedTime = _generatedTime;


- (void)dealloc {
	self.generatedTime = nil;
	[_departureTime release];
	_departureTime = nil;
	self.platform = nil;
	self.length = nil;
	self.direction = nil;

	[super dealloc];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
	//NSLog(@"%@ setValue:%@ forUndefinedKey:%@",[self class],value,key);//TODO ignore for now
}



//	<minutes>5</minutes>
//  <minutes>Arrived</minutes>

- (void)setMinutes:(NSString *)val {
	if ([val isEqualToString:@"Arrived"]) {
		minutes = 0;
	} else {
		minutes = (NSUInteger)[val integerValue];
	}
	
	if (nil != _generatedTime) {
		[_departureTime release];
		_departureTime = [[NSDate alloc] initWithTimeInterval:60*minutes sinceDate:_generatedTime];
	}
}

- (NSString *)minutes {
	return [NSString stringWithFormat:@"%d",minutes];
}



@end
