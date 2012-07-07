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

#import "AppDelegate.h"
#import "DeparturesGridVC.h"

@implementation AppDelegate


@synthesize window;
@synthesize mainVC;



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
	DeparturesGridVC *aController = [[DeparturesGridVC alloc] initWithNibName:@"DeparturesGrid" bundle:nil];
	self.mainVC = aController;
	[aController release];
	
    mainVC.view.frame = [UIScreen mainScreen].applicationFrame;
	[window addSubview:[mainVC view]];
    [window makeKeyAndVisible];
		
	return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[self.mainVC refreshResults];
	//NSLog(@"applicationDidBecomeActive");
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[[NSUserDefaults standardUserDefaults] synchronize];
	[self.mainVC clearRefreshTimer];
	//NSLog(@"applicationWillResignActive");
}

- (void)dealloc {
	self.mainVC = nil;
    [window release];
    [super dealloc];
}

@end
