//
//  ViewController.m
//  DDNormalRobot
//
//  Created by dudu on 2020/4/10.
//  Copyright © 2020 dudu. All rights reserved.
//

#import "ViewController.h"
#import <SDWebImage.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    [view sd_setImageWithURL:[NSURL URLWithString:@"https://publicimg.dd373.com/Upload/SitePic/2020-01-02/54dfaa21-fcc7-40b6-8288-d305177ae344.gif"]];
    [self.view addSubview:view];
    // Do any additional setup after loading the view.
}


@end
