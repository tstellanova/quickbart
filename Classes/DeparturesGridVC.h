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

#import "BARTRequestor.h"
#import "StationPickerVC.h"

@class DepartureDetailDataSource;
@class DetailsExpansionView;
@class StationPrefs;



@interface DeparturesGridVC : UIViewController <
	UITableViewDataSource,
	UITableViewDelegate,
	BARTRequestorDelegate,
	StationPickerDelegate
	> {

	UINib	*_noDeparturesNib;
	NSMutableArray *_requestors;
	NSMutableArray *responseProcessors;
	NSMutableDictionary *_stationDepartureMap;
	IBOutlet UITableView	*_tableView;
	IBOutlet UIView	*_tableClipView;
	IBOutlet UILabel *_loadingLabel; 
	IBOutlet UILabel *_lastLoadedLabel;
	IBOutlet UIActivityIndicatorView *loadingActivity;

	NSDateFormatter *updateFormatter;
	NSString *_selectedDestinationPath;
	NSTimer	*_refreshTimer;
	NSDate	*requestStartTime;
	StationPrefs *_stationPrefs;
	
	DepartureDetailDataSource *_depDetailDataSource;
	IBOutlet DetailsExpansionView *_detailsContainerView;
	UINib	*_detailsContainerNib;

	
}


@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (IBAction)clearRefreshTimer;
- (IBAction)showInfo;
- (IBAction)refreshResults;
- (IBAction)clearResults;


@end
