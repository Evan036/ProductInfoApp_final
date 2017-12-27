//
//  AgreenmentViewController.m
//  ProductInfoApp
//
//  Created by Evan on 2015/6/19.
//  Copyright (c) 2015年 FoodChina Company. All rights reserved.
//

#import "AgreenmentViewController.h"

@interface AgreenmentViewController ()
@property (strong, nonatomic) IBOutlet UITextView *agreenmentTextView;
@property NSMutableDictionary *appSetting;
@property NSString *myStorybord;
- (IBAction)pressAgreen:(id)sender;
@end

@implementation AgreenmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 改變Status bar 的顏色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //設定StatusBarStyle為白色文字表示
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,20)];
    //設定StatusBar 的背景顏色
    //R-242, G-148, B-23
    label.backgroundColor = [UIColor colorWithRed:242.0/255.0f green:148.0/255.0f blue:23.0/255.0f alpha:1.0];
    [self.view addSubview:label];
    //檢查StoryBoard
    [self checkStoryBoard];
    
    //改變TextViewer的邊框顏色與粗細
    [[self.agreenmentTextView layer] setBorderColor:
     [[UIColor grayColor] CGColor]];
    [[self.agreenmentTextView layer] setBorderWidth:1.0];
    [self.agreenmentTextView setEditable:NO];
    
    //讀取APP的設定檔
    NSString *plistPath = [self getPlistPath];
    self.appSetting = [[NSDictionary dictionaryWithContentsOfFile:plistPath] mutableCopy];

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
    NSLog(@"plistPath=%@",plistPath);
    return plistPath;
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

- (IBAction)pressAgreen:(id)sender {
    //檢查是否有註冊過

    NSString *isRegisted = [self.appSetting objectForKey:@"IsRegisted"];
    NSLog(@"IsRegisted=%@",isRegisted);
    if ([isRegisted isEqualToString:@"YES"]) {
        //前往主選單
        NSString * storyboardName = self.myStorybord;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"MainMenu"];
        [self presentViewController:vc animated:YES completion:nil];
    }else{
        //前往註冊畫面
        NSString * storyboardName = self.myStorybord;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"RegisterView"];
        [self presentViewController:vc animated:YES completion:nil];
    }
}
@end
