//
//  ProductViewController.m
//  ProductInfoApp
//
//  Created by Evan on 2015/6/21.
//  Copyright (c) 2015年 FoodChina Company. All rights reserved.
//

#import "ProductViewController.h"

@interface ProductViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSString * titleName;
@property (strong, nonatomic) NSString * webURL;
@property NSMutableDictionary *appSetting;
@end

@implementation ProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //Set nevigation bar title
    self.navigationItem.title = _titleName;
    self.webView.delegate = self;
    NSString *plistPath = [self getPlistPath];
    self.appSetting = [[NSMutableDictionary dictionaryWithContentsOfFile:plistPath] mutableCopy];
    NSLog(@"Evan, I am here!");
    
    //Set the webURL
    NSURL *url = [NSURL URLWithString:_webURL];
    NSString *body = [NSString stringWithFormat: @"mobile=%@&token=%@", [self.appSetting objectForKey:@"RegPhone"],[self.appSetting objectForKey:@"DeviceToken"]];
    NSLog(@"String=%@",body);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    request.HTTPMethod =@"POST";
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    [self.webView loadRequest: request];

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


- (void)viewDidLayoutSubviews {
    _webView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
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
