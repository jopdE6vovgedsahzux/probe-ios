#import "TestRunningViewController.h"
#import "Suite.h"

@interface TestRunningViewController ()
@property (nonatomic, strong) AbstractSuite *currentTest;
@end

@implementation TestRunningViewController

@synthesize urls, testSuiteName, testName, result, currentTest;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[TestUtility getColorForTest:testSuiteName]];

    if ([testSuiteName isEqualToString:@"websites"]){
        if (urls == nil){
            //Download urls and then alloc class
            [TestUtility downloadUrls:^(NSArray *urls) {
                if (urls != nil && [urls count] > 0){
                    currentTest = [[WebsitesSuite alloc] initWithUrls:urls andResult:result];
                    [(WebsitesSuite*)currentTest setMaxRuntime];
                    //[self runTest];
                }
                else {
                    [MessageUtility alertWithTitle:@"Modal.Error" message:@"Modal.Error.CantDownloadURLs" inView:self];
                    [self networkTestEnded];
                }
            }];
        }
        else {
            currentTest = [[WebsitesSuite alloc] initWithUrls:urls andResult:result];
        }
    }
    else if ([testSuiteName isEqualToString:@"performance"]){
        if (testName != nil)
            currentTest = [[PerformanceSuite alloc] initWithTest:testName andResult:result];
        else
            currentTest = [[PerformanceSuite alloc] init];
    }
    else if ([testSuiteName isEqualToString:@"middle_boxes"]){
        if (testName != nil)
            currentTest = [[MiddleBoxesSuite alloc] initWithTest:testName andResult:result];
        else
            currentTest = [[MiddleBoxesSuite alloc] init];
    }
    else if ([testSuiteName isEqualToString:@"instant_messaging"]){
        if (testName != nil)
            currentTest = [[InstantMessagingSuite alloc] initWithTest:testName andResult:result];
        else
            currentTest = [[InstantMessagingSuite alloc] init];
    }

    totalRuntime = [currentTest getRuntime];

    NSString *time = NSLocalizedFormatString(@"Dashboard.Running.Seconds", [NSString stringWithFormat:@"%d", totalRuntime]);
    [self.timeLabel setText:time];
    [self.testNameLabel setText:NSLocalizedString(@"Dashboard.Running.PreparingTest", nil)];

    [self runTest];
    self.progressBar.layer.cornerRadius = 7.5;
    self.progressBar.layer.masksToBounds = YES;
    [self.progressBar setTrackTintColor:[UIColor colorWithRGBHexString:color_white alpha:0.2f]];
    [self.runningTestsLabel setText:NSLocalizedString(@"Dashboard.Running.Running", nil)];
    [self.logLabel setText:@""];
    [self.etaLabel setText:NSLocalizedString(@"Dashboard.Running.EstimatedTimeLeft", nil)];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgress:) name:@"updateProgress" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkTestEnded) name:@"networkTestEnded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLog:) name:@"updateLog" object:nil];

    //Keep screen on
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self addAnimation];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

-(void)runTest{
    if (currentTest != nil){
        totalTests = [currentTest.testList count];
        [currentTest runTestSuite];
    }
}
-(void)addAnimation{
    animation = [LOTAnimationView animationNamed:testSuiteName];
    animation.contentMode = UIViewContentModeScaleAspectFit;
    CGRect c = self.animationView.bounds;
    animation.frame = CGRectMake(0, 0, c.size.width, c.size.height);
    [self.animationView setNeedsLayout];
    [self.animationView setClipsToBounds:YES];
    [self.animationView addSubview:animation];
    [animation setLoopAnimation:YES];
    [animation play];
}

-(void)updateLog:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    NSString *log = [userInfo objectForKey:@"log"];
    [self.logLabel setText:log];
}

-(void)updateProgress:(NSNotification *)notification{
    /*
     Format string with minute and seconds
     https://stackoverflow.com/questions/27519533/how-to-format-date-in-to-string-like-as-one-days-ago-minutes-ago-in-ios
     https://stackoverflow.com/questions/2927028/how-do-i-get-hour-and-minutes-from-nsdate
     */
    NSDictionary *userInfo = notification.userInfo;
    NSString *name = [userInfo objectForKey:@"name"];
    NSNumber *prog = [userInfo objectForKey:@"prog"];
    int index = currentTest.measurementIdx;
    float prevProgress = index/totalTests;
    float progress = ([prog floatValue]/totalTests)+prevProgress;

    long eta = totalRuntime;
    if (progress > 0) {
        eta = lroundf(totalRuntime - progress * totalRuntime);
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressBar setProgress:progress animated:YES];
        NSString *time = NSLocalizedFormatString(@"Dashboard.Running.Seconds", [NSString stringWithFormat:@"%ld", eta]);
        [self.timeLabel setText:time];
        [self.testNameLabel setText:[LocalizationUtility getNameForTest:name]];

    });
    [animation playWithCompletion:^(BOOL animationFinished) {}];

}

-(void)networkTestEnded{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_presenting){
            [self.presentingViewController.presentingViewController dismissViewControllerAnimated:TRUE completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"goToResults" object:nil];
            }];
        }
        else {
            [self dismissViewControllerAnimated:TRUE completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"goToResults" object:nil];
            }];
        }
    });

}

@end
