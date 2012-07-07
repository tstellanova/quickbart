//
//  StationEditorVC.h
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

#import <UIKit/UIKit.h>


@protocol StationEditorDelegate;
@class StationDeparturePref;
@class SliderDisplayControl;

@interface StationEditorVC : UIViewController <UIPickerViewDataSource,UIPickerViewDelegate> {
	IBOutlet	UIPickerView	*_stationNamePicker;
	IBOutlet	UISegmentedControl	*_sortOrderSelect;
	IBOutlet	SliderDisplayControl *_travelTimeInput;
	
	StationDeparturePref *_departurePref;
	NSObject<StationEditorDelegate> *_delegate;

	NSArray *_directionNames;
	NSArray *_abbreviationsSortedByStation;

}

@property (nonatomic, retain) StationDeparturePref *departurePref;
@property (nonatomic, assign) NSObject<StationEditorDelegate> *delegate;

- (IBAction)saveStationEdits;
- (IBAction)cancelStationEdits;

@end


@protocol StationEditorDelegate 
- (void)stationEditor:(StationEditorVC *)vc editedStation:(StationDeparturePref*)station;
@end
