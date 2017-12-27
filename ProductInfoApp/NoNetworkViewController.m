//
//  NoNetworkViewController.m
//  ProductInfoApp
//
//  Created by Evan on 2015/7/15.
//  Copyright (c) 2015年 FoodChina Company. All rights reserved.
//

#import "NoNetworkViewController.h"

@interface NoNetworkViewController ()

@end

@implementation NoNetworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,20)];
    //設定StatusBar 的背景顏色
    //R-242, G-148, B-23
    label.backgroundColor = [UIColor colorWithRed:242.0/255.0f green:148.0/255.0f blue:23.0/255.0f alpha:1.0];
    [self.view addSubview:label];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
