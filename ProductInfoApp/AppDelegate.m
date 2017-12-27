//
//  AppDelegate.m
//  ProductInfoApp
//
//  Created by Evan on 2015/5/28.
//  Copyright (c) 2015年 FoodChina Company. All rights reserved.
//

#import "AppDelegate.h"
#import "NoNetworkViewController.h"

@interface AppDelegate ()
@property NSMutableDictionary *appSetting;
@property NSString *networkStatus;
@property NSString *myMainSB;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    sleep(2);
    // 改變Status bar 的顏色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //設定StatusBarStyle為白色文字表示
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.window.frame.size.width,20)];
    //設定StatusBar 的背景顏色
    //R-242, G-148, B-23
    label.backgroundColor = [UIColor colorWithRed:242.0/255.0f green:148.0/255.0f blue:23.0/255.0f alpha:1.0];
    [self.window.rootViewController.view addSubview:label];
    self.window.backgroundColor = [UIColor blackColor];
    
    //檢查Device的螢幕大小套用相對應的Storyboard
    [self checkStoryBoard];
    
    //setup remote notification
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        // use registerUserNotificationSettings
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
        // use registerForRemoteNotificationTypes:
       [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert| UIRemoteNotificationTypeBadge |  UIRemoteNotificationTypeSound)];
    }
    
    //Check Networkstatus
    //  Register notification for Network status change
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    // Initialize the listener for network status
    // Check current network status
    reachabilty = [Reachability reachabilityForInternetConnection];
    NetworkStatus ntstatus = [reachabilty currentReachabilityStatus];
    if (ntstatus == 0) {
        //Change networkStatus value
        self.networkStatus = @"No";
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"無網路訊號" message:@"無網路訊號！請在有網路環境下使用APP。" delegate:self cancelButtonTitle:@"確定" otherButtonTitles:nil, nil];
        [av show];
    }
    // Start to check when status changed
    [reachabilty startNotifier];
    
    //Check 是否註冊過, 如果是就直接跳主選單畫面
    //讀取APP的設定檔
    NSString *plistPath = [self getPlistPath];
    self.appSetting = [[NSMutableDictionary dictionaryWithContentsOfFile:plistPath] mutableCopy];
    if ([[self.appSetting objectForKey:@"IsRegisted"] isEqualToString:@"YES"]) {
        //Redirected to main menu viewcontroller
        self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:self.myMainSB bundle:nil];
        
        UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"MainMenu"];
        
        self.window.rootViewController = viewController;
        [self.window makeKeyAndVisible];
        
    }
    return YES;
}

-(void) checkStoryBoard{
    CGSize iOSScreenSize = [[UIScreen mainScreen] bounds].size;
    if (iOSScreenSize.height == 568) {
        //iPhone 5/5C/5S
        UIStoryboard *myStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *initialController = [myStoryboard instantiateInitialViewController];
        self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        self.window.rootViewController = initialController;
        self.myMainSB = @"Main";
        [self.window makeKeyAndVisible];
    }
    if (iOSScreenSize.height == 667) {
        //iPhone 6
        UIStoryboard *myStoryboard = [UIStoryboard storyboardWithName:@"iPhone6" bundle:nil];
        UIViewController *initialController = [myStoryboard instantiateInitialViewController];
        self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        self.window.rootViewController = initialController;
        self.myMainSB = @"iPhone6";
        [self.window makeKeyAndVisible];
    }
    if (iOSScreenSize.height == 736) {
        //iPhone 6 plus
        UIStoryboard *myStoryboard = [UIStoryboard storyboardWithName:@"iPhone6p" bundle:nil];
        UIViewController *initialController = [myStoryboard instantiateInitialViewController];
        self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        self.window.rootViewController = initialController;
        self.myMainSB = @"iPhone6p";
        [self.window makeKeyAndVisible];
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

// Called by Reachability whenever status changes.
- (void)reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    [self updateInterfaceWithReachability: curReach];
}

//  Implementation for Network status notification
- (void)updateInterfaceWithReachability:(Reachability *)curReach
{
    NetworkStatus curStatus;
    
    BOOL m_bReachableViaWWAN;
    BOOL m_bReachableViaWifi;
    BOOL m_bReachable;
    //  According to curReach, modify current internal flags
    
    //  Internet reachability
    //  Need network status to know real reachability method
    curStatus = [curReach currentReachabilityStatus];
    
    //  Modify current network status flags
    if (curStatus == ReachableViaWWAN) {
        m_bReachableViaWWAN = true;
    } else {
        m_bReachableViaWWAN = false;
    }
    
    if (curStatus == ReachableViaWiFi) {
        m_bReachableViaWifi = true;
    } else {
        m_bReachableViaWifi = false;
    }
    
    //  Reachable is the OR result of two internal connection flags
    m_bReachable = (m_bReachableViaWifi || m_bReachableViaWWAN);
    
    if (!m_bReachable) {
        //Change networkStatus value
        self.networkStatus = @"No";
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"無網路訊號！" message:@"請在有網路環境下使用APP。" delegate:self cancelButtonTitle:@"確定" otherButtonTitles:nil, nil];
        [av show];
    }
    if (m_bReachable && [self.networkStatus isEqualToString:@"No"]) {
        //Change networkStatus value
        self.networkStatus = @"Yes";
        //Change Screen back to Agreenment
         if ([[self.appSetting objectForKey:@"IsRegisted"] isEqualToString:@"NO"]) {
            self.window.rootViewController =  [[UIStoryboard storyboardWithName:self.myMainSB bundle:nil]
                     instantiateViewControllerWithIdentifier:@"AgreenmentView"];
         } else {
            self.window.rootViewController =[[UIStoryboard storyboardWithName:self.myMainSB bundle:nil]
                     instantiateViewControllerWithIdentifier:@"MainMenu"];
         }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //NSLog(@"This is alertView.clickedButtonAtIndex fun:%zd",buttonIndex);
    switch(buttonIndex){
        case 0:
            //Chnge Screen to blank screen
            self.window.rootViewController =
            [[UIStoryboard storyboardWithName:self.myMainSB bundle:nil]
             instantiateViewControllerWithIdentifier:@"NoNetworkView"];
            break;
    }
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    //將Device Token由NSData轉換為字串
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *iOSDeviceToken =
    [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
     ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
     ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
     ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    NSLog(@"Receive deviceToken: %@", iOSDeviceToken);
    //將Device Token 寫入 Setting.plist
    [self.appSetting setObject:iOSDeviceToken forKey:@"DeviceToken"];
    NSString * targetFile = [NSHomeDirectory()
                             stringByAppendingPathComponent:@"Documents/Setting.plist"];
    [self.appSetting writeToFile:targetFile atomically:YES];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Remote notification error:%@", [error localizedDescription]);
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
