//
//  AppDelegate.h
//  ProductInfoApp
//
//  Created by Evan on 2015/5/28.
//  Copyright (c) 2015年 FoodChina Company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    Reachability *reachabilty;
}
@property (strong, nonatomic) UIWindow *window;


@end

