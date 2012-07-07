//
//  DepartureDetailDataSource.m
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


#import "DepartureDetailDataSource.h"

#import "BARTDepartureEstimate.h"
#import "TrainDepartureView.h"

@implementation DepartureDetailDataSource

@synthesize estimatedTravelTime = _estimatedTravelTime;

#pragma mark -
#pragma mark UITableViewDataSource


- (id)initWithDepartureEstimates:(NSArray *)estimates {
	if (self = [super init]) {
		_departureEstimates = [estimates retain];
		
		_depFormatter = [[NSDateFormatter alloc] init];
		[_depFormatter setDateFormat:@"'at' h:mm a"];//TODO localize?

	}
	
	return self;

}

- (void)dealloc {
	[_departureEstimates release];
	_departureEstimates = nil;
	[_depFormatter release];
	_depFormatter = nil;
	[super dealloc];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	NSInteger rowCount = [_departureEstimates count];
	return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"DepartureDestinationDetailCell";	
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (nil == cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
			reuseIdentifier:CellIdentifier] autorelease];
		CGRect o = cell.frame;
		cell.frame = CGRectMake(o.origin.x, o.origin.y,160, 14.0); 
    }
	
	
	BARTDepartureEstimate *est = [_departureEstimates objectAtIndex:[indexPath row]];

	cell.indentationLevel = 3;
	cell.textLabel.text = [NSString stringWithFormat:@"%@ car %@",est.length,[_depFormatter stringFromDate:est.departureTime]]; //TODO localize?
	cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
	cell.textLabel.textColor = [UIColor whiteColor];
	//cell.textLabel.highlightedTextColor = [UIColor colorWithRed:1.0 green:1.0 blue:(177/255.0) alpha:1.0];
	cell.textLabel.textAlignment = UITextAlignmentRight;
	cell.textLabel.shadowColor = [UIColor blackColor];
	cell.textLabel.shadowOffset = CGSizeMake(1.0,1.0);
	
	CGRect labelFrame = cell.textLabel.frame;
	CGFloat trainY = labelFrame.origin.y + 20;
	CGRect trainFrame = CGRectMake(5,trainY,30,20);
	NSTimeInterval timeTilDeparture = [est.departureTime timeIntervalSinceNow];
	if (timeTilDeparture < 0)
		timeTilDeparture = 0;
	BOOL plentyOfTime = (_estimatedTravelTime < timeTilDeparture);
	TrainDepartureView *trainView = 
		[[TrainDepartureView alloc] initWithFrame:trainFrame mode:plentyOfTime departing:timeTilDeparture];

	cell.backgroundView = trainView;
	[trainView release];
	return cell;

}

@end
