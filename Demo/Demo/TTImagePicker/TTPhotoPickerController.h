//
//  TTPhotoPickerController.h
//  videoStudy_1
//
//  Created by 李曈 on 2017/2/24.
//  Copyright © 2017年 lt. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^TTComplete)(NSArray * images);

@interface TTPhotoPickerController : UINavigationController

-(void)completeSelect:(TTComplete)block;
-(instancetype)initWithComplete:(TTComplete)block;

@end
