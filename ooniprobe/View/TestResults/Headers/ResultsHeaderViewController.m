#import "ResultsHeaderViewController.h"

@interface ResultsHeaderViewController ()

@end

@implementation ResultsHeaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addLine:self.view2];
    if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
        [self addLine:self.view1];
    }
    else {
        [self addLine:self.view3];
    }
    [self.testsLabel setText:NSLocalizedString(@"TestResults.Overview.Hero.Tests", nil)];
    [self.networksLabel setText:NSLocalizedString(@"TestResults.Overview.Hero.Networks", nil)];
    [self.dataUsageLabel setText:NSLocalizedString(@"TestResults.Overview.Hero.DataUsage", nil)];
    filter = @"";
    [self.headerView setBackgroundColor:[UIColor colorWithRGBHexString:color_blue5 alpha:1.0f]];
    [self.upImage setTintColor:[UIColor colorWithRGBHexString:color_white alpha:1.0f]];
    [self.downImage setTintColor:[UIColor colorWithRGBHexString:color_white alpha:1.0f]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadQuery) name:@"uploadFinished" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadQueryNoFilter) name:@"networkTestEnded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadQuery) name:@"reloadHeader" object:nil];

    self.dropdownMenu.tintColor = [UIColor colorWithRGBHexString:color_gray9 alpha:1.0f];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reloadQuery];
}

-(void)reloadQueryNoFilter{
    filter = @"";
    [self reloadQuery];
}

-(void)reloadQuery{
    dispatch_async(dispatch_get_main_queue(), ^{
        SRKQuery *query;
        if ([filter length] > 0)
            query = [[[Result query] where:[NSString stringWithFormat:@"test_group_name = '%@'", filter]] orderByDescending:@"start_time"];
        else
            query = [[Result query] orderByDescending:@"start_time"];
        
        [self.delegate testFilter:query];

        double dataUsageDown = [query sumOf:@"data_usage_down"];
        double dataUsageUp = [query sumOf:@"data_usage_up"];
        
        [self.upLabel setText:[NSByteCountFormatter stringFromByteCount:dataUsageUp*1024 countStyle:NSByteCountFormatterCountStyleFile]];
        [self.downLabel setText:[NSByteCountFormatter stringFromByteCount:dataUsageDown*1024 countStyle:NSByteCountFormatterCountStyleFile]];

        [self.numberTestsLabel setText:[NSString stringWithFormat:@"%lu", (unsigned long)[query count]]];
        [self.numberNetworksLabel setText:[NSString stringWithFormat:@"%lu", (unsigned long)[[[[Network query] where:[NSString stringWithFormat:@"asn != 'null'"]] distinct:@"asn"] count]]];
    });
}

#pragma mark - MKDropdownMenuDataSource

- (NSInteger)numberOfComponentsInDropdownMenu:(MKDropdownMenu *)dropdownMenu {
    return 1;
}

- (NSInteger)dropdownMenu:(MKDropdownMenu *)dropdownMenu numberOfRowsInComponent:(NSInteger)component {
    return [[TestUtility getTestTypes] count]+1;
}

#pragma mark - MKDropdownMenuDelegate

- (CGFloat)dropdownMenu:(MKDropdownMenu *)dropdownMenu rowHeightForComponent:(NSInteger)component {
    return 44;
}

- (NSAttributedString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu attributedTitleForComponent:(NSInteger)component{
    NSString *text = NSLocalizedString(@"TestResults.Overview.FilterTests", nil);
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"FiraSans-Regular" size:16],
                                 NSForegroundColorAttributeName:[UIColor colorWithRGBHexString:color_gray9 alpha:1.0f]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

-(NSAttributedString*)dropdownMenu:(MKDropdownMenu *)dropdownMenu attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString *text;
    NSDictionary *attributes;
    if ((row == 0 && [filter isEqualToString:@""]) || (row > 0 && [[[TestUtility getTestTypes] objectAtIndex:row-1] isEqualToString:filter]))
        attributes = @{NSFontAttributeName: [UIFont fontWithName:@"FiraSans-SemiBold" size:16],
                       NSForegroundColorAttributeName:[UIColor colorWithRGBHexString:color_gray9 alpha:1.0f]};
    else
        attributes = @{NSFontAttributeName: [UIFont fontWithName:@"FiraSans-Regular" size:16],
                       NSForegroundColorAttributeName:[UIColor colorWithRGBHexString:color_gray9 alpha:1.0f]};

    if (row == 0)
        text = NSLocalizedString(@"TestResults.Overview.FilterTests.AllTests", nil);
    else {
        NSArray *tests =  [TestUtility getTestTypes];
        text = [LocalizationUtility getFilterNameForTest:[tests objectAtIndex:row-1]];
    }
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIColor *)dropdownMenu:(MKDropdownMenu *)dropdownMenu backgroundColorForRow:(NSInteger)row forComponent:(NSInteger)component {
    if ((row == 0 && [filter isEqualToString:@""]) || (row > 0 && [[[TestUtility getTestTypes] objectAtIndex:row-1] isEqualToString:filter]))
        return [UIColor colorWithRGBHexString:color_gray2 alpha:1.0f];
    else
        return [UIColor colorWithRGBHexString:color_white alpha:1.0f];
}

- (void)dropdownMenu:(MKDropdownMenu *)dropdownMenu didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *current = @"";
    if (row > 0){
        NSArray *tests =  [TestUtility getTestTypes];
        current = [tests objectAtIndex:row-1];
    }
    filter = current;
    [self reloadQuery];

    double delayInSeconds = 0.15;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.dropdownMenu closeAllComponentsAnimated:YES];
    });
}

-(void)addLine:(UIView*)view{
    UIView *lineView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 1, view.frame.size.height)];
    [lineView setBackgroundColor:[UIColor colorWithRGBHexString:color_white alpha:1.0f]];
    [view addSubview:lineView];
}

@end
