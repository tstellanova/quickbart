//
//  Created by Todd Stellanova on 12/17/10.
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

#import "DeparturesGridVC.h"

#import "BARTDepartureEstimate.h"
#import "BARTResponseProcessor.h"
#import "BARTRequestor.h"
#import "DepartureDetailDataSource.h"
#import "DetailsExpansionView.h"
#import "DepartureSummaryView.h"
#import "StationDeparturePref.h"
#import "StationPrefs.h"
#import "TransitDestination.h"
#import "TransitStation.h"


#define SUMMARY_VIEW_TAG	5001

const NSTimeInterval	kMaxDisplayedInterval = (45*60.0);
const NSTimeInterval	kReloadTimerInterval = 60.0;

const CGFloat kStationNameXInset = 5.0;


NSString * const kSelectedDepartureKey = @"SELECTED_DEPARTURE_KEY";


@interface DeparturesGridVC (Private) 

- (void)requestStations;
- (void)displayResultsFromRequestor:(BARTRequestor *)requestor;
- (StationDeparturePref *)departurePrefForSection:(NSInteger)section;
- (NSArray *)destinationsForSection:(NSInteger)section;
- (TransitDestination *)destinationForIndexPath:(NSIndexPath *)indexPath;

- (NSIndexPath *)getSelectedIndexPath;

- (void)updateDestinationDepartureDetails;
- (void)showLoadingStatus:(NSString *)status;
- (void)showLastLoadedStatus:(NSString *)status;

- (void)clearDepartureMap;

@end

@implementation DeparturesGridVC

@synthesize tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		updateFormatter = [[NSDateFormatter alloc] init];
		[updateFormatter setDateFormat:@"'As of' h:mm a EEEE"];//TODO localize?
		
		_stationPrefs = [StationPrefs sharedInstance];
		
		_noDeparturesNib = [[UINib nibWithNibName:@"NoDeparturesPlaceholderView" bundle:nil] retain];
		_detailsContainerNib = [[UINib nibWithNibName:@"DepartureExpansionView" bundle:nil] retain];   
		
	}
    return self;
}

- (void)viewDidLoad {
	_tableView.rowHeight =  [DepartureSummaryView defaultViewHeight];
	_tableView.layer.cornerRadius = 10;
	_tableClipView.layer.cornerRadius = 10;
	

	_detailsContainerView = [[[_detailsContainerNib instantiateWithOwner:nil options:nil] objectAtIndex:0] retain];
	NSLog(@"_detailsContainerView: %@",_detailsContainerView);
	
//	CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
//	rotationAndPerspectiveTransform.m34 = 1.0 / -500;
//	rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, 45.0f * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
//	_tableView.layer.transform = rotationAndPerspectiveTransform;

}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	[_detailsContainerView release];
	_detailsContainerView = nil;
}


- (void)dealloc {
	[updateFormatter release];
	updateFormatter = nil;

	[_noDeparturesNib release];
	_noDeparturesNib = nil;
	
	[_detailsContainerNib release];
	_detailsContainerNib = nil;
	
    [super dealloc];
}


- (NSIndexPath *)getSelectedIndexPath {
	NSIndexPath *result = nil;
	NSString *destPath = [_stationPrefs selectedDestinationPath];
	if (nil != destPath) {
		NSRange found = [destPath rangeOfString:@":"];
		if (NSNotFound != found.location) {
			NSString *stationPrefKey = [destPath substringToIndex:found.location];
			NSString *destination = [destPath substringFromIndex:found.location+1];
			NSArray *prefStations = [_stationPrefs preferredStations];

			for (NSInteger section = 0 ; section < [prefStations count]; section++) {
				StationDeparturePref *station = [prefStations objectAtIndex:section];
				if ([station.uniqueKey isEqual:stationPrefKey]) {
					//found the right station pref, now try to find matching destination
					NSArray *destList = [self destinationsForSection:section];
					for (NSInteger row = 0 ; row < [destList count] ; row++) {
						TransitDestination *dest = [destList objectAtIndex:row];
						if ([dest.destination isEqual:destination]) {
							result = [NSIndexPath indexPathForRow:row inSection:section];
							break;
						}
					}

				}
			}
		}
		if (nil == result) {
			//couldn't find the matching destination -- clear prefs
			[_stationPrefs setSelectedDestinationPath:nil];
			[_stationPrefs flushPrefs];
		}
	}
	
	return result;
}

#pragma mark -
#pragma mark Timer mgmt

- (IBAction)clearRefreshTimer {
	[_refreshTimer invalidate];
	_refreshTimer = nil;
}

- (void)timerRefreshMethod:(NSTimer*)timer {
	if ([timer isValid]) {
		[self requestStations];
	}
}

- (void)clearDepartureMap {
	[_stationDepartureMap release];
	_stationDepartureMap = [[NSMutableDictionary alloc] init];
}


#pragma mark -
#pragma mark Actions

- (IBAction)showInfo {   
	[_refreshTimer invalidate];
	_refreshTimer = nil;
	
	StationPickerVC *vc = [[StationPickerVC alloc] initWithNibName:@"StationPickerVC" bundle:nil];
	vc.delegate = self;
	
	vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:vc animated:YES];
	[vc release];
}

- (IBAction)refreshResults {
	[self performSelector:@selector(requestStations) withObject:nil afterDelay:0.01];
}

- (IBAction)clearResults {
	[self clearDepartureMap];
	[_tableView reloadData];
	[self updateDestinationDepartureDetails];
}

- (void)requestStations {
	if (0 == [_requestors count])  {

		[_requestors release];
		_requestors = [[NSMutableArray alloc] init];
		
		[NSUserDefaults standardUserDefaults]; //touch
		NSArray *prefStations = [_stationPrefs preferredStations];
		
		if ([prefStations count] > 0) {
			[requestStartTime release];
			requestStartTime = [[NSDate date] retain];

			[self showLoadingStatus:NSLocalizedString(@"Loading Departures...",@"Shown when we're downloading departure estimates")];
			for (StationDeparturePref *station in prefStations) {
				BARTRequestor *requestor = [[BARTRequestor alloc] init];
				//NSLog(@"requestor 0x%x for station: %@",self,station.abbr);
				[_requestors addObject:requestor];
				requestor.delegate = self;
				requestor.station = station;
				[requestor requestDepartureEstimates];
				[requestor release]; //owned by _requestors now
			}
		} else {
			[self showLastLoadedStatus:NSLocalizedString(@"Tap info to select stations",@"Shown when user has no station prefs selected")];
		}
	}
}

- (void)showLastLoadedStatus:(NSString *)status {
	if (nil != status) {
		[self showLoadingStatus:nil];
		_lastLoadedLabel.text = status;
		_lastLoadedLabel.hidden = NO;

	} else {
		_lastLoadedLabel.hidden = YES;
	}
}


- (void)showLoadingStatus:(NSString *)status {
	if (nil != status) {
		[self showLastLoadedStatus:nil];
		_loadingLabel.text = status;
		_loadingLabel.hidden = NO;
		[loadingActivity startAnimating];

	} else {
		_loadingLabel.hidden = YES;
		[loadingActivity stopAnimating];
	}
}

- (void)displayResultsFromRequestor:(BARTRequestor*)requestor {
	NSArray *results = requestor.stationResults;
	//NSLog(@"station: %@ results: %@",requestor.station.abbr,results);
	
	if (nil == _stationDepartureMap) {
		_stationDepartureMap = [[NSMutableDictionary alloc] init];
	}
	NSString *key = [requestor.station uniqueKey];
	[_stationDepartureMap setObject:[results objectAtIndex:0] forKey:key];
	[requestor setDelegate:nil];
	[_requestors removeObject:requestor];

	if (0 == [_requestors count]) {
		[_tableView reloadData];
	
		[loadingActivity stopAnimating];
		NSDate* newTime = [NSDate date];
		NSString *updatedStr = [updateFormatter stringFromDate:newTime];
		[self showLastLoadedStatus:updatedStr];
		
		NSTimeInterval totalRequestTime = [newTime timeIntervalSinceDate:requestStartTime];
		NSLog(@"totalRequestTime: %06.2f",totalRequestTime);
		
		[_refreshTimer invalidate];
		_refreshTimer =  [NSTimer 
			scheduledTimerWithTimeInterval:kReloadTimerInterval 
			target:self 
			selector:@selector(timerRefreshMethod:) 
			userInfo:nil 
			repeats:YES];
	}
}

#pragma mark -
#pragma mark UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSArray *prefStations = [_stationPrefs preferredStations];
	StationDeparturePref *station = [prefStations objectAtIndex:section];
	NSString *title = [NSString stringWithFormat:@"%@ - %@",station.stationName,station.direction];
	
	CGRect headerRect = CGRectMake(0.0, 0.0, tableView.frame.size.width, 32);
	UIView *wrapView = [[[UIView alloc] initWithFrame:headerRect] autorelease];
	wrapView.backgroundColor = [UIColor colorWithWhite:0.4 alpha:1.0];

	CGRect titleRect = CGRectMake(kStationNameXInset, 0.0, headerRect.size.width - kStationNameXInset, headerRect.size.height - 6);
	UILabel *sectionTitle = [[UILabel alloc] initWithFrame:titleRect];
	sectionTitle.font = [UIFont systemFontOfSize:17.0];
	sectionTitle.text = title;
	sectionTitle.backgroundColor = [UIColor clearColor];
	sectionTitle.textColor = [UIColor whiteColor];
	sectionTitle.shadowColor = [UIColor darkGrayColor];
	sectionTitle.shadowOffset = CGSizeMake(0.5, 0.5);
	[wrapView addSubview:sectionTitle];
	[sectionTitle release];
	return wrapView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

	return 24.0;
}

- (void)updateDestinationDepartureDetails {

	NSInteger nStations = [[_stationDepartureMap allKeys] count];
	NSIndexPath *selectedIndexPath = [_tableView indexPathForSelectedRow];
	if ((nStations > 0) && (nil != selectedIndexPath)) {
		TransitDestination *dest = [self destinationForIndexPath:selectedIndexPath];
		NSArray *deps = dest.departureEstimates;
		if ([deps count] > 0) {
			StationDeparturePref *stationPref = [self departurePrefForSection:[selectedIndexPath section]];
			BARTDepartureEstimate *firstDepEst = [deps objectAtIndex:0];
			NSString *platformDetail = [NSString stringWithFormat:@"%@ : platform %@",dest.destination, firstDepEst.platform ];//TODO localize?
			
			[_depDetailDataSource release];
			_depDetailDataSource = [[DepartureDetailDataSource alloc] initWithDepartureEstimates:deps];
			_depDetailDataSource.estimatedTravelTime = [stationPref.travelTime intValue] * 60.0;
			

			[_detailsContainerView updateInfo:platformDetail dataSource:_depDetailDataSource];
			_detailsContainerView.hidden = NO;			
		}
	} else {
		[_detailsContainerView removeFromSuperview];
		_detailsContainerView.hidden = YES;
	}
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	BOOL wasSelected = NO;
	NSIndexPath *oldSelectedPath = [self getSelectedIndexPath];
	if ([oldSelectedPath isEqual:indexPath]) {
		wasSelected = YES;
	}
	
	if (!wasSelected) {
		TransitDestination *dest = [self destinationForIndexPath:indexPath];
		StationDeparturePref *stationPref = [self departurePrefForSection:[indexPath section]];
		NSString *selectedDestinationPath = [[NSString alloc] initWithFormat:@"%@:%@",stationPref.uniqueKey,dest.destination];
		
		_stationPrefs.selectedDestinationPath = selectedDestinationPath;
		[selectedDestinationPath release];
		[_stationPrefs flushPrefs];

		[self updateDestinationDepartureDetails];
		
		NSArray* paths = nil;
		 if (nil != oldSelectedPath)  {
			//order in this case is relevant
			paths = [NSArray arrayWithObjects:oldSelectedPath,indexPath,nil];
		}
		else {
			paths = [NSArray arrayWithObjects:indexPath,nil];
		}

		[tableView beginUpdates];
		[tableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
		//UITableViewRowAnimationFade];//UITableViewRowAnimationMiddle];
		[tableView endUpdates];
	}

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSIndexPath *selectedPath = [self getSelectedIndexPath];

	if ([selectedPath isEqual:indexPath]) {
		return 120.0;
	} else {
		return 50.0;
	}
}

#pragma mark -
#pragma mark UITableViewDataSource

- (TransitDestination *)destinationForIndexPath:(NSIndexPath *)indexPath {
	NSArray *destList = [self destinationsForSection:[indexPath section]];
	TransitDestination *result = [destList objectAtIndex:[indexPath row]];
	return result;
}


- (NSArray *)destinationsForSection:(NSInteger)section {
	StationDeparturePref *prefStation = [self departurePrefForSection:section];
	
	TransitStation *station = [_stationDepartureMap objectForKey:[prefStation uniqueKey]];
	NSArray *destList = [station destinationsList];

	return destList;
}

- (StationDeparturePref *)departurePrefForSection:(NSInteger)section {
	NSArray *prefStations = [_stationPrefs preferredStations];
	StationDeparturePref *prefStation = [prefStations objectAtIndex:section];
	return prefStation;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSArray *prefStations = [_stationPrefs preferredStations];
	return [prefStations count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)curSection {	
	NSArray *destList = [self destinationsForSection:curSection];
	NSInteger destCount = [destList count];
	if (destCount < 1) {
		destCount = 1;
	}
	return destCount;
}


- (UITableViewCell*)departureSummaryCellForForTable:(UITableView*)tableView section:(NSInteger)curSection row:(NSInteger)curRow {
	static NSString *DepartureSummaryCellIdentifier = @"DepartureSummaryCell";

	DepartureSummaryView *sumView = nil;
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DepartureSummaryCellIdentifier];
    if (nil == cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle  
			reuseIdentifier:DepartureSummaryCellIdentifier] autorelease];
		CGFloat tableWidth = tableView.frame.size.width;
		CGRect cellFrame = cell.frame;
		cell.frame = CGRectMake(cellFrame.origin.x,cellFrame.origin.y,tableWidth,cellFrame.size.height);
		
		CGRect sumViewFrame = CGRectMake(0, 0, tableWidth, [DepartureSummaryView defaultViewHeight]);
		sumView = [[DepartureSummaryView alloc] initWithFrame:sumViewFrame];
		sumView.tag = SUMMARY_VIEW_TAG;
		[cell.contentView addSubview:sumView];
		[sumView release]; //will be picked up again below
		
		UIView *selectedBg = [[UIView alloc] initWithFrame:sumViewFrame];
		selectedBg.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.650 alpha:1.0];
		//cell.selectedBackgroundView = selectedBg;
		[selectedBg release];
    } 
	
	sumView = (DepartureSummaryView *)[cell.contentView viewWithTag:SUMMARY_VIEW_TAG];
	NSArray *prefStations = [_stationPrefs preferredStations];
	StationDeparturePref *stationPref = [prefStations objectAtIndex:curSection];
	TransitStation *station = [_stationDepartureMap objectForKey:[stationPref uniqueKey]];
	//NSLog(@"stationPref: %@ for station: %@",stationPref.abbr,station.abbr);

	NSTimeInterval maxTime = kMaxDisplayedInterval; 
	if (maxTime > kMaxDisplayedInterval)
		maxTime = kMaxDisplayedInterval;
	sumView.minDeltaTime = 0.0; 
	sumView.maxDeltaTime = maxTime;
	sumView.travelTime = [stationPref.travelTime floatValue]*60.0;
	NSInteger leftover = (curRow % 2);
	if (0 == leftover) {
		sumView.backgroundColor = [UIColor colorWithHue:0.5 saturation:0.1 brightness:0.9 alpha:1.0];		
	} else {
		sumView.backgroundColor = [UIColor colorWithHue:0.192 saturation:0.1 brightness:0.9 alpha:1.0];		
	}
	TransitDestination *dest  = [station.destinationsList objectAtIndex:curRow];
	sumView.departureData = dest;

	return cell;
}

- (UITableViewCell *)detailExpansionCellForTableView:(UITableView*)tableView {
	static NSString *DeparturePlaceholderCellIdentifier = @"DepatureDetailCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DeparturePlaceholderCellIdentifier];
    if (nil == cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle  
			reuseIdentifier:DeparturePlaceholderCellIdentifier] autorelease];
			
		UIView *selectedBgView = [[UIView alloc] initWithFrame:cell.frame];
		selectedBgView.backgroundColor = [UIColor colorWithRed:(45/255.0) green:(117/255.0) blue:(176/255.0) alpha:1.0];
		selectedBgView.layer.borderColor = [[UIColor whiteColor] CGColor];
		selectedBgView.layer.borderWidth = 3;
		//selectedBgView.layer.cornerRadius = 10;

		cell.selectedBackgroundView = selectedBgView;
		[selectedBgView release];
	} 
	
	//although there may be multiple cells, there can only be one detailsContainerView
	[_detailsContainerView removeFromSuperview];

	cell.frame = CGRectMake(0,0,tableView.frame.size.width,116.0);//TODO
	cell.selectedBackgroundView.frame = cell.frame;
	_detailsContainerView.frame = cell.frame;
	
//	NSLog(@"cell rect: %@",NSStringFromCGRect(cell.frame));
//	NSLog(@"details rect: %@",NSStringFromCGRect(_detailsContainerView.frame));

	[cell.contentView addSubview:_detailsContainerView];
		
	return cell;
}


- (UITableViewCell *)departurePlaceholderCellForTable:(UITableView*)tableView {
	static NSString *DeparturePlaceholderCellIdentifier = @"DepaturePlaceholderCell";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DeparturePlaceholderCellIdentifier];
    if (nil == cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle  
			reuseIdentifier:DeparturePlaceholderCellIdentifier] autorelease];
		CGFloat tableWidth = tableView.frame.size.width;
		CGRect cellFrame = cell.frame;
		cell.frame = CGRectMake(cellFrame.origin.x,cellFrame.origin.y,tableWidth,cellFrame.size.height);
		
		UIView *subView = [[_noDeparturesNib instantiateWithOwner:nil options:nil] objectAtIndex:0];
		subView.frame = cell.frame;
		[cell.contentView addSubview:subView];
	}

	return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	NSInteger curSection = [indexPath section];
	NSInteger curRow = [indexPath row];
	
	NSArray *prefStations = [_stationPrefs preferredStations];
	StationDeparturePref *stationPref = [prefStations objectAtIndex:curSection];
	TransitStation *station = [_stationDepartureMap objectForKey:[stationPref uniqueKey]];

	NSIndexPath *selectedPath = [self getSelectedIndexPath];

	if (nil == station) {
		cell = [self departurePlaceholderCellForTable:tableView];
	} else 	if ([selectedPath isEqual:indexPath]) {
		cell = [self detailExpansionCellForTableView:tableView];
	} else {
		cell = [self departureSummaryCellForForTable:tableView section:curSection row:curRow];
	}

	return cell;
}


#pragma mark -
#pragma mark BARTRequestorDelegate

- (void)bartRequestorDone:(BARTRequestor *)requestor anyError:(NSError *)errorOrNil {
	if (nil == errorOrNil) {
		[self displayResultsFromRequestor:requestor];
	} else {
			NSLog(@"bartRequestorDone with err: %@",errorOrNil);

		[_requestors removeObject:requestor];
		if (-1009 == errorOrNil.code) {
			[self showLastLoadedStatus:NSLocalizedString(@"Network Unavailable",@"Shown when we can't reload due to bad network")];
		} else {
			[self showLastLoadedStatus:[NSString stringWithFormat:@"Error: %@",errorOrNil]];
		}	
		
		if (0 == [_requestors count]) {
			[_tableView reloadData];	
		}	
	}
	
	NSIndexPath *selectedPath = [self getSelectedIndexPath];
	if (nil != selectedPath) {
		[_tableView selectRowAtIndexPath:selectedPath animated:NO scrollPosition:UITableViewScrollPositionNone];
		[self updateDestinationDepartureDetails];
	}
}


#pragma mark -
#pragma mark StationPickerDelegate

- (void)stationPickerFinished:(StationPickerVC *)vc withError:(NSError*)anyError {
	[self clearRefreshTimer];
	[self dismissModalViewControllerAnimated:YES];
	[self clearResults];

	if (nil == anyError) {
		[self performSelector:@selector(requestStations) withObject:nil afterDelay:0.5];
	}	
}


@end
