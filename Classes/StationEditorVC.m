//
//  StationEditorVC.m
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

#import "StationEditorVC.h"

#import "BARTStationsUtil.h"
#import "SliderDisplayControl.h"
#import "StationDeparturePref.h"


#define kPickerComponentStationName	0

@implementation StationEditorVC

@synthesize delegate = _delegate, departurePref = _departurePref;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		BARTStationsUtil *stationUtil = [BARTStationsUtil sharedInstance];
		_abbreviationsSortedByStation = [stationUtil.abbreviationsSortedByStationName retain];
		
		_directionNames = [[NSArray alloc] initWithObjects:
			kTrainDirectionSouth,
			kTrainDirectionNorth,
			kTrainDirectionBoth,
			nil];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIView *placeholderView = [_travelTimeInput retain];
	[_travelTimeInput release];
	_travelTimeInput = [[SliderDisplayControl alloc] initWithFrame:placeholderView.frame minValue:0 maxValue:10];
	_travelTimeInput.slider.minimumValue = 1.0f;
	_travelTimeInput.slider.maximumValue = 45.0;//TODO allow higher max travel time?
	
	[self.view addSubview:_travelTimeInput];
	[placeholderView removeFromSuperview];
	[placeholderView release];
	
	//make the middle one the default selection
	NSInteger selectedRow = [_abbreviationsSortedByStation count] / 2;
	[_stationNamePicker selectRow:selectedRow inComponent:kPickerComponentStationName animated:NO];
	
	for (NSInteger i = 0; i < [_directionNames count]; i++) {
		[_sortOrderSelect setTitle:[_directionNames objectAtIndex:i] forSegmentAtIndex:i];
	}
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[_directionNames release];
	_directionNames = nil;
	[_abbreviationsSortedByStation release];
	_abbreviationsSortedByStation = nil;
	self.departurePref = nil;
    [super dealloc];
}



- (NSInteger)indexForStationAbbr:(NSString *)aAbbr { //TODO speedup
	NSInteger result = NSNotFound;
	for (NSInteger i = 0; i < [_abbreviationsSortedByStation count]; i++) {
		NSString *abbr = [_abbreviationsSortedByStation objectAtIndex:i];
		if ([aAbbr isEqualToString:abbr]) {
			result = i;
			break;
		}
	}
	return result;
}

#pragma mark -
#pragma mark Properties

- (void)setDeparturePref:(StationDeparturePref *)aStationPref {
	if (![_departurePref isEqual:aStationPref]) {
		[_departurePref release];
		_departurePref = [aStationPref retain];
		if (nil != _departurePref) {
			NSInteger dirIdx = [_directionNames indexOfObject:_departurePref.direction];
			_sortOrderSelect.selectedSegmentIndex = dirIdx;
			
			[_travelTimeInput setValue:_departurePref.travelTime];

			NSInteger row = [self indexForStationAbbr:_departurePref.abbr];
			[_stationNamePicker selectRow:row inComponent:kPickerComponentStationName animated:NO];
		}
	}
}

#pragma mark -
#pragma mark UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	if ([_stationNamePicker isEqual:pickerView])  {
		return 1;
	}
	return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	if ([_stationNamePicker isEqual:pickerView])  {
		if (kPickerComponentStationName == component) {
			return [_abbreviationsSortedByStation count];
		} 
	}
	
	return 0;
}

#pragma mark -
#pragma mark UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	NSString *result = nil;
	if ([_stationNamePicker isEqual:pickerView])  {
		if (kPickerComponentStationName == component) {
			NSString *abbr = [_abbreviationsSortedByStation objectAtIndex:row];
			result = [[BARTStationsUtil sharedInstance] stationNameFromAbbr:abbr];
		}
	}

	return result;
}

#pragma mark -
#pragma mark IBActions

- (IBAction)saveStationEdits {
	NSInteger selectedStationIndex =  [_stationNamePicker selectedRowInComponent:kPickerComponentStationName];
	NSString *abbr = [_abbreviationsSortedByStation objectAtIndex:selectedStationIndex];
			
	NSString *dir = [_directionNames objectAtIndex: [_sortOrderSelect selectedSegmentIndex]];
	NSNumber *travelTime = [NSNumber numberWithInt:[_travelTimeInput intValue]];

	if (nil == _departurePref) {
		_departurePref =[[StationDeparturePref alloc] initWithAbbr:abbr direction:dir];
	} else {
		_departurePref.abbr = abbr;
		_departurePref.direction = dir;
	}
	_departurePref.travelTime = travelTime;
	[_delegate stationEditor:self editedStation:_departurePref];
}

- (IBAction)cancelStationEdits {
	[_delegate stationEditor:self editedStation:nil];
}

@end
