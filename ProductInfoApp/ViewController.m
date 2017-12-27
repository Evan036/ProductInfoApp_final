//
//  ViewController.m
//  ProductInfoApp
//
//  Created by Evan on 2015/5/28.
//  Copyright (c) 2015年 FoodChina Company. All rights reserved.
//
#import "ViewController.h"
#import "ProductViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *adImage;
- (IBAction)pressConButton:(id)sender;
- (IBAction)pressSMButton:(id)sender;
- (IBAction)pressSBButton:(id)sender;
- (IBAction)pressDDGSButton:(id)sender;
- (IBAction)pressPigButton:(id)sender;
- (IBAction)pressNewsButton:(id)sender;
- (IBAction)pressAboutButton:(id)sender;
@property NSMutableDictionary *appSetting;
@property NSString *myStorybord;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,20)];
    //設定StatusBar 的背景顏色
    //R-242, G-148, B-23
    label.backgroundColor = [UIColor colorWithRed:242.0/255.0f green:148.0/255.0f blue:23.0/255.0f alpha:1.0];
    [self.view addSubview:label];
    //檢查StoryBoard
    [self checkStoryBoard];

    //change background color with gradientlayer
    CAGradientLayer *backgroundLayer = [self flavescentGradientLayer];
    backgroundLayer.frame = self.view.frame;
    [self.view.layer insertSublayer:backgroundLayer atIndex:0];
    
    //在ad banner上加上點選時的lister
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)];
    singleTap.numberOfTapsRequired = 1;
    [self.adImage setUserInteractionEnabled:YES];
    [self.adImage addGestureRecognizer:singleTap];
    
    //讀取APP的設定檔
    NSString *plistPath = [self getPlistPath];
    self.appSetting = [[NSMutableDictionary dictionaryWithContentsOfFile:plistPath] mutableCopy];
    
    //如果使用者不是會員, 訊息中心的圖示會改變
    if ([[self.appSetting objectForKey:@"IsMember"] isEqualToString:@"NO"]) {
        UIButton *myButton = (UIButton *)[self.view viewWithTag:7];
        UIImage * buttonImage = [UIImage imageNamed:@"btn_navi_msg-disable.png"];
        [myButton setImage:buttonImage forState:UIControlStateNormal];
    }
    
 }

-(void)tapDetected{
    NSLog(@"Open URL for the banner");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.foodchina.com.tw/DB/AD/20150605/edm-20150605.html"]];
    
}

-(void) checkStoryBoard{
    CGSize iOSScreenSize = [[UIScreen mainScreen] bounds].size;
    if (iOSScreenSize.height == 568) {
        //iPhone 5/5C/5S
        self.myStorybord = @"Main";
    }
    if (iOSScreenSize.height == 667) {
        //iPhone 6
        self.myStorybord = @"iPhone6";
    }
    if (iOSScreenSize.height == 736) {
        //iPhone 6 plus
        self.myStorybord = @"iPhone6p";
    }
}

#pragma mark - 存取PList檔
-(NSString *)getPlistPath {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"Setting.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath: plistPath])
    {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Setting" ofType:@"plist"];
        NSError *error;
        [fileManager copyItemAtPath:bundlePath toPath:plistPath error:&error];
    }
    
    return plistPath;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear: animated];
    [self.navigationController.navigationBar setHidden:NO];
}

- (CAGradientLayer *)flavescentGradientLayer
{
    UIColor *topColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    UIColor *bottomColor = [UIColor colorWithRed:252.0/255.0f green:229.0/255.0f blue:196.0/255.0f alpha:1];
    
    NSArray *gradientColors = [NSArray arrayWithObjects:(id)topColor.CGColor, (id)bottomColor.CGColor, nil];
    NSArray *gradientLocations = [NSArray arrayWithObjects:[NSNumber numberWithInt:0.0],[NSNumber numberWithInt:1.0], nil];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = gradientColors;
    gradientLayer.locations = gradientLocations;
    
    return gradientLayer;
}


- (IBAction)pressConButton:(id)sender {
    ProductViewController * productViewController = [[ProductViewController alloc]initWithNibName:@"ProductViewController" bundle:nil];
    [productViewController setValue:@"玉米" forKey:@"titleName"];
    [productViewController setValue:@"http://biz.foodchina.com.tw:8080/fcc-appserver/content/corn" forKey:@"webURL"];
    [self.navigationController pushViewController:productViewController animated:YES];
}

- (IBAction)pressSMButton:(id)sender {
    ProductViewController* productViewController = [[ProductViewController alloc]initWithNibName:@"ProductViewController" bundle:nil];
    [productViewController setValue:@"豆粉" forKey:@"titleName"];
    [productViewController setValue:@"http://biz.foodchina.com.tw:8080/fcc-appserver/content/sm" forKey:@"webURL"];
    [self.navigationController pushViewController:productViewController animated:YES];
}

- (IBAction)pressSBButton:(id)sender {
    ProductViewController* productViewController = [[ProductViewController alloc]initWithNibName:@"ProductViewController" bundle:nil];
    [productViewController setValue:@"黃豆" forKey:@"titleName"];
    [productViewController setValue:@"http://biz.foodchina.com.tw:8080/fcc-appserver/content/sb" forKey:@"webURL"];
    [self.navigationController pushViewController:productViewController animated:YES];
}

- (IBAction)pressDDGSButton:(id)sender {
    ProductViewController* productViewController = [[ProductViewController alloc]initWithNibName:@"ProductViewController" bundle:nil];
    [productViewController setValue:@"玉米酒糟" forKey:@"titleName"];
    [productViewController setValue:@"http://biz.foodchina.com.tw:8080/fcc-appserver/content/ddgs" forKey:@"webURL"];
    [self.navigationController pushViewController:productViewController animated:YES];
}

- (IBAction)pressPigButton:(id)sender {
    ProductViewController* productViewController = [[ProductViewController alloc]initWithNibName:@"ProductViewController" bundle:nil];
    [productViewController setValue:@"豬價" forKey:@"titleName"];
    [productViewController setValue:@"http://biz.foodchina.com.tw:8080/fcc-appserver/content/pig" forKey:@"webURL"];
    [self.navigationController pushViewController:productViewController animated:YES];
}

- (IBAction)pressNewsButton:(id)sender {
    ProductViewController* productViewController = [[ProductViewController alloc]initWithNibName:@"ProductViewController" bundle:nil];
    [productViewController setValue:@"行情快訊" forKey:@"titleName"];
    [productViewController setValue:@"http://biz.foodchina.com.tw:8080/fcc-appserver/content/messages" forKey:@"webURL"];
    [self.navigationController pushViewController:productViewController animated:YES];
}


- (IBAction)pressAboutButton:(id)sender {
    ProductViewController* productViewController = [[ProductViewController alloc]initWithNibName:@"ProductViewController" bundle:nil];
    [productViewController setValue:@"關於我們" forKey:@"titleName"];
    [productViewController setValue:@"http://biz.foodchina.com.tw:8080/fcc-appserver/AppWeb/aboutus.html" forKey:@"webURL"];
    [self.navigationController pushViewController:productViewController animated:YES];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"forMessage"]) {
        if ([[self.appSetting objectForKey:@"IsMember"] isEqualToString:@"NO"]) {
            //訊息中心未開通, 顯示相關訊息
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"訊息功能未開通"
                                                            message:@"您尚未成為中華食物網的網站會員，請先至官網註冊加入。 www.foodchina.com.tw"
                                                           delegate:self
                                                  cancelButtonTitle:@"確定"
                                                  otherButtonTitles:@"前往註冊", nil];
            [alert show];            
            return NO;
        }
    }
    return YES;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"This is alertView.clickedButtonAtIndex fun:%zd",buttonIndex);
    switch(buttonIndex){
        case 1:
            //Open website url for registeration
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.foodchina.com.tw"]];
            break;
    }
}

@end
