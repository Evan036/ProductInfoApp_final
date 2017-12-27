//
//  ProdInfoMessage.h
//  ProductInfoApp
//
//  Created by Evan on 2015/7/25.
//  Copyright (c) 2015年 FoodChina Company. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProdInfoMessage : NSObject
@property (nonatomic) int rdid;
@property (strong, nonatomic) NSString * message;
@property (strong, nonatomic) NSString * webUrl;
@property (strong, nonatomic) NSString * publishDate;
@property (strong, nonatomic) NSNumber * webUrlEnbled;
@end
