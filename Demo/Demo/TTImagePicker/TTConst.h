//
//  TTConst.h
//  Demo
//
//  Created by 李曈 on 2017/3/4.
//  Copyright © 2017年 lt. All rights reserved.
//
#import <Foundation/Foundation.h>

#define TTScreenWidth [UIScreen mainScreen].bounds.size.width

#define TTScreenHeight [UIScreen mainScreen].bounds.size.height

#define TTScale [UIScreen mainScreen].scale

//设置最大选择数量的通知
extern NSString * const TTSetMaxPhotoNumNotice;
//选择数量达到最大的通知
extern NSString * const TTSelectFillNotice;
//还可以继续选择的通知
extern NSString * const TTSelectCanNotice;
