#import "TestOverviewViewController.h"
#import "CountlyUtility.h"

@interface TestOverviewViewController ()

@end

@implementation TestOverviewViewController
@synthesize testSuite;

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadLastMeasurement) name:@"networkTestEnded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsChanged) name:@"settingsChanged" object:nil];

    [self.testNameLabel setText:[LocalizationUtility getNameForTest:testSuite.name]];
    NSString *testLongDesc = [LocalizationUtility getLongDescriptionForTest:testSuite.name];
    [self.testDescriptionLabel setFont:[UIFont fontWithName:@"FiraSans-Regular" size:14]];
    [self.testDescriptionLabel setTextColor:[UIColor colorWithRGBHexString:color_gray9 alpha:1.0f]];
    [self.testDescriptionLabel setMarkdown:testLongDesc];
    [self.testDescriptionLabel setDidSelectLinkWithURLBlock:^(RHMarkdownLabel *label, NSURL *url) {
        [[UIApplication sharedApplication] openURL:url];
    }];
    [self.runButton setTitle:[NSString stringWithFormat:@"%@", NSLocalizedString(@"Dashboard.Overview.Run", nil)] forState:UIControlStateNormal];
    if ([testSuite.name isEqualToString:@"websites"])
        [self.websitesButton setTitle:[NSString stringWithFormat:@"%@", NSLocalizedString(@"Dashboard.Overview.ChooseWebsites", nil)] forState:UIControlStateNormal];
    else
        [self.websitesButton setHidden:YES];

    [self reloadLastMeasurement];
    [self.testImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", testSuite.name]]];
    [self.testImage setTintColor:[UIColor colorWithRGBHexString:color_white alpha:1.0f]];
    defaultColor = [TestUtility getColorForTest:testSuite.name];
    [self.runButton setTitleColor:defaultColor forState:UIControlStateNormal];
    [self.backgroundView setBackgroundColor:defaultColor];
    [NavigationBarUtility setNavigationBar:self.navigationController.navigationBar color:defaultColor];
    self.navigationController.navigationBar.topItem.title = @"";
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [NavigationBarUtility setBarTintColor:self.navigationController.navigationBar
                                    color:defaultColor];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [CountlyUtility recordView:@"TestOverview"];
    [CountlyUtility recordView:[NSString stringWithFormat:@"TestOverview_%@", testSuite.name]];
}

-(void)reloadLastMeasurement{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.estimatedLabel setText:NSLocalizedString(@"Dashboard.Overview.Estimated", nil)];
        [self.estimatedDetailLabel setText:
         [NSString stringWithFormat:@"%@ %@",
          testSuite.dataUsage,
          [LocalizationUtility getReadableRuntime:[testSuite getRuntime]]]];
        [self.lastrunLabel setText:NSLocalizedString(@"Dashboard.Overview.LatestTest", nil)];
        
        NSString *ago;
        SRKResultSet *results = [[[[[Result query] limit:1] where:[NSString stringWithFormat:@"test_group_name = '%@'", testSuite.name]] orderByDescending:@"start_time"] fetch];
        if ([results count] > 0){
            ago = [[[results objectAtIndex:0] start_time] timeAgoSinceNow];
        }
        else
            ago = NSLocalizedString(@"Dashboard.Overview.LastRun.Never", nil);
        [self.lastrunDetailLabel setText:ago];
    });
}

-(void)settingsChanged{
    [testSuite.testList removeAllObjects];
    [testSuite getTestList];
    [self reloadLastMeasurement];
}

-(NSInteger)daysBetweenTwoDates:(NSDate*)testDate{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                        fromDate:testDate
                                                          toDate:[NSDate date]
                                                         options:0];
    return components.day;
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    [super willMoveToParentViewController:parent];
    if (!parent) {
        [NavigationBarUtility setBarTintColor:self.navigationController.navigationBar
                                        color:[UIColor colorWithRGBHexString:color_blue5 alpha:1.0f]];
    }
}

-(IBAction)run:(id)sender{
    if ([[ReachabilityManager sharedManager].reachability currentReachabilityStatus] != NotReachable){
        [CountlyUtility recordEvent:[NSString stringWithFormat:@"Run_%@", testSuite.name]];
        [self performSegueWithIdentifier:@"toTestRun" sender:sender];
    }
    else
        [MessageUtility alertWithTitle:NSLocalizedString(@"Modal.Error", nil)
                               message:NSLocalizedString(@"Modal.Error.NoInternet", nil) inView:self];
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"toTestRun"]){
        TestRunningViewController *vc = (TestRunningViewController * )segue.destinationViewController;
        [vc setTestSuites:[NSMutableArray arrayWithObject:testSuite]];
    }
    else if ([[segue identifier] isEqualToString:@"toTestSettings"]){
        SettingsTableViewController *vc = (SettingsTableViewController * )segue.destinationViewController;
        [vc setTestSuite:testSuite];
    }
}


@end
