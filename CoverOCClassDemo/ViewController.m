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
    NSLog(@"=====");
}


@end
