/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 Copyright (c) 2010, Janrain, Inc.
 
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this
	 list of conditions and the following disclaimer. 
 * Redistributions in binary form must reproduce the above copyright notice, 
	 this list of conditions and the following disclaimer in the documentation and/or
	 other materials provided with the distribution. 
 * Neither the name of the Janrain, Inc. nor the names of its
	 contributors may be used to endorse or promote products derived from this
	 software without specific prior written permission.
 
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 
 File:	 JRModalNavigationController.m 
 Author: Lilli Szafranski - lilli@janrain.com, lillialexis@gmail.com
 Date:	 Tuesday, June 1, 2010
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


#import "JRModalNavigationController.h"

// TODO: Figure out why the -DDEBUG cflag isn't being set when Active Conf is set to debug
#define DEBUG
#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define DLog(...)
#endif

#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

@implementation JRModalNavigationController

@synthesize navigationController;
@synthesize sessionData;

@synthesize myUserLandingController;
@synthesize myWebViewController;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (JRModalNavigationController*)initWithSessionData:(JRSessionData*)data
{
	DLog(@"");
	
	if (self = [super init])
	{
		shouldRestore = NO;
		sessionData = [data retain];
	}
	
	return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView  
{
	DLog(@"");

	UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	
	if (!navigationController)
	{
		navigationController = [[UINavigationController alloc] 
								initWithRootViewController:
								[[[JRProvidersController alloc] 
								  initWithNibName:@"JRProvidersController" 
								  bundle:[NSBundle mainBundle]] autorelease]];

		navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	}
	
	myUserLandingController = [[JRUserLandingController alloc]
							   initWithNibName:@"JRUserLandingController"
							   bundle:[NSBundle mainBundle]];
	
	myWebViewController = [[JRWebViewController alloc]
							   initWithNibName:@"JRWebViewController"
							   bundle:[NSBundle mainBundle]];
	
	[view setHidden:YES];
	[self setView:view];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
}
*/

- (void)presentModalNavigationController
{
	DLog(@"");
	navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;

	[self presentModalViewController:navigationController animated:YES];
}

- (void)restore:(BOOL)animated
{
	DLog(@"");
	[navigationController popToRootViewControllerAnimated:animated];
}

- (void)viewDidAppear:(BOOL)animated 
{
	DLog(@"");
	if (shouldRestore)
		[[JRAuthenticate jrAuthenticate] unloadModalViewController];	
	//	[self restore:animated];
	
	shouldRestore = NO;
}

- (void)cancelButtonPressed:(id)sender
{
	DLog(@"");
	[sessionData authenticationDidCancel];
	[self dismissModalNavigationController:NO];
	[self restore:NO];
}

- (void)dismissModalNavigationController:(BOOL)successfullyAuthed
{
	DLog(@"%@", (successfullyAuthed ? @"YES" : @"NO"));
	
	if (successfullyAuthed)
	{
		shouldRestore = YES;
		navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		[self.view setHidden:NO];
		[self dismissModalViewControllerAnimated:YES];
	}
	else 
	{
		navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		[self dismissModalViewControllerAnimated:YES];
		[self.view removeFromSuperview];
	}
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return YES;
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
	DLog(@"");

	[sessionData release];
	[navigationController release];
	[myUserLandingController release];
	[myWebViewController release];
	
	[super dealloc];
}


@end
