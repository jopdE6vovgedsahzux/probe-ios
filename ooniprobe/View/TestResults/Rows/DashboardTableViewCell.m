#import "DashboardTableViewCell.h"

@implementation DashboardTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        [UIView
            animateWithDuration:0.3f
            delay:0
            options:UIViewAnimationOptionCurveEaseOut
            animations:^{
                self.contentView.alpha = 0.7f;
            }
            completion: NULL
         ];
    } else {
        [UIView
         animateWithDuration:0.8f
         delay:0.5f
         options:UIViewAnimationOptionCurveEaseInOut
         animations:^{
             self.contentView.alpha = 1.f;
         }
         completion: NULL
        ];
    }
}

-(void)setTestName:(NSString*)testName{
    [self setBackgroundColor:[UIColor colorWithRGBHexString:color_gray1 alpha:1.0f]];
    
    [self.runButton setTitleColor:[TestUtility getColorForTest:testName] forState:UIControlStateNormal];
    [self.runButton setTitle:[NSString stringWithFormat:@"%@", NSLocalizedString(@"Dashboard.Card.Run", nil)] forState:UIControlStateNormal];
    
    [self.titleLabel setText:[LocalizationUtility getNameForTest:testName]];
    [self.descLabel setText:[LocalizationUtility getDescriptionForTest:testName]];
    //TODO GET TIME
    NSString *time = NSLocalizedFormatString(@"Dashboard.Card.Seconds", [NSString stringWithFormat:@"%d", 5]);
    [self.estimateTime setText:time];
    [self.bottomLabel setText:NSLocalizedString(@"Dashboard.Card.Subtitle", nil)];
    
    [self.testLogo setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", testName]]];
    [self.testLogo setTintColor:[UIColor colorWithRGBHexString:color_white alpha:1.0f]];
    [self.cardbackgroundView setBackgroundColor:[TestUtility getColorForTest:testName]];
    self.cardbackgroundView.layer.cornerRadius = 15;
    self.cardbackgroundView.layer.masksToBounds = YES;
}

@end
