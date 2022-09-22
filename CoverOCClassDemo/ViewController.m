//
//  ViewController.m
//  CoverOCClassDemo
//
//  Created by song.meng on 2022/9/21.
//

#import "ViewController.h"
#import "CoverClassTool.h"
#import "PersonClass.h"
#import "CarClass.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor yellowColor];
    
    [CoverClassTool useClass:[PersonClass class] coverClass:[CarClass class]];
    
    CarClass *car = [CarClass new];
    [car performSelector:@selector(study)];
    [[CarClass class] performSelector:@selector(study)];
    
    
    CoverRiskLevel level = [CoverClassTool getRiskLevelWithClass:[PersonClass class] beCoveredClass:[CarClass class]];
    
    
    NSDictionary *lev = @{
        @(CoverRiskLevelLow) : @"CoverRiskLevelLow",      // 成员变量顺序相同，且布局相同
        @(CoverRiskLevelAccept) : @"CoverRiskLevelAccept",   // 成员变量顺序不同，强弱引用相同
        @(CoverRiskLevelMiddle) : @"CoverRiskLevelMiddle",   // 成员变量相同，强弱引用不相同
        @(CoverRiskLevelHigh) : @"CoverRiskLevelHigh",     // 成员变量不相同，个数不同，名字不同
    };
    NSLog(@"===== %@", lev[@(level)]);
}


@end
