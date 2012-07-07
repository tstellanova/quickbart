//
//  StationPicker.m
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

#import <QuartzCore/QuartzCore.h>
#import "StationPickerVC.h"

#import "StationDeparturePref.h"
#import "StationEditorVC.h"
#import "StationPrefs.h"

@implementation StationPickerVC

@synthesize delegate;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {

    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	_tableView.editing = YES;
	_tableClipView.layer.cornerRadius = 10;
	_tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 100.0, 0.0) ;
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


#pragma mark -
#pragma mark UITableViewDelegate


- (BOOL)tableView:(UITableView *)tableView 
	shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger row = [indexPath row];
	NSMutableArray *prefsArray = [[StationPrefs sharedInstance] preferredStations];
	StationDeparturePref *stationPref = [prefsArray objectAtIndex:row];
	[self editStation:stationPref];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSMutableArray *prefsArray = [[StationPrefs sharedInstance] preferredStations];
	return [prefsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSMutableArray *prefsArray = [[StationPrefs sharedInstance] preferredStations];
	StationDeparturePref *stationPref = [prefsArray objectAtIndex:[indexPath row]];

	static NSString *MyIdentifier = @"StationCell";

    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:MyIdentifier];

    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
			reuseIdentifier:MyIdentifier] autorelease];
		CGRect o = cell.frame;
		cell.frame = CGRectMake(o.origin.x, o.origin.y, tableView.frame.size.width, o.size.height); 
    }
	
	cell.textLabel.text = stationPref.stationName;
	cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
	cell.detailTextLabel.text = stationPref.direction;
	cell.showsReorderControl = YES;
	cell.shouldIndentWhileEditing = NO;

	return cell;
}


- (void)tableView:(UITableView *)tableView 
	moveRowAtIndexPath:(NSIndexPath *)fromIndexPath 
	toIndexPath:(NSIndexPath *)toIndexPath {

	NSMutableArray *prefsArray = [[StationPrefs sharedInstance] preferredStations];
	StationDeparturePref *movePref = [prefsArray objectAtIndex:[fromIndexPath row]];
	[movePref retain];
	[prefsArray removeObjectAtIndex:[fromIndexPath row]];
	if (nil != toIndexPath) {
		[prefsArray insertObject:movePref atIndex:[toIndexPath row]];
	}
	[movePref release];
	
	[[StationPrefs sharedInstance] flushPrefs];

}

- (void)tableView:(UITableView *)tableView 
		commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
		forRowAtIndexPath:(NSIndexPath *)indexPath {
		
		if (UITableViewCellEditingStyleDelete == editingStyle) {
			[self tableView:tableView moveRowAtIndexPath:indexPath toIndexPath:nil];
		}
		[_tableView reloadData];
}


#pragma mark -
#pragma mark StationEditorDelegate

- (void)stationEditor:(StationEditorVC *)vc editedStation:(StationDeparturePref*)station {
	if (nil != station) {
		NSMutableArray *prefsArray = [[StationPrefs sharedInstance] preferredStations];
		if (![prefsArray containsObject:station]) {
			[prefsArray addObject:station];
		}
		[[StationPrefs sharedInstance] flushPrefs];
		[_tableView reloadData];
	}
	
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark IBActions

- (IBAction)userDone {
	[delegate stationPickerFinished:self withError:nil];
}


- (IBAction)addStation {
	[self editStation:nil];
}

- (void)editStation:(StationDeparturePref *)station {
	StationEditorVC *vc = [[StationEditorVC alloc] initWithNibName:@"StationEditorVC" bundle:nil];
	vc.delegate = self;
	
	vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:vc animated:YES];
	vc.departurePref = station;
	[vc release];
}


- (IBAction)contactUs {
	//mail the developer
   // NSString *recipients = @"mailto:first@example.com?cc=second@example.com,third@example.com&subject=Hello from California!";
   //&body=%@

	NSString *mailUrlStr = [NSString stringWithFormat:@"mailto:%@?subject=%@",
		@"teamquickbart@gmail.com",
		@"I love quickbart!"
		];
	NSString *encodedUrlStr = [mailUrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:encodedUrlStr]];
}


@end
