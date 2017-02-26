//
//  TTPhotoPickerController.m
//  videoStudy_1
//
//  Created by 李曈 on 2017/2/24.
//  Copyright © 2017年 lt. All rights reserved.
//

#import "TTPhotoPickerController.h"
#import "TTAListViewController.h"
#import "TTConst.h"
#import <pthread.h>
@interface TTPhotoPickerController (){

}
@property (copy,nonatomic) TTComplete  completeBlock;

@end

@implementation TTPhotoPickerController


-(instancetype)initWithComplete:(TTComplete)block{
    TTAListViewController * ttVC = [[TTAListViewController alloc] init];
    [ttVC completeChooseImage:^(NSArray *images){
        if (pthread_main_np()) {
            _completeBlock(images);
        }else{
            dispatch_sync(dispatch_get_main_queue(), ^{
                _completeBlock(images);
            });
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    self = [super initWithRootViewController:ttVC];
    if (self) {
        
        _completeBlock = block;
    }
    return self;
}


-(void)completeSelect:(TTComplete)block{
    _completeBlock = block;
}

-(void)setMaxPhotoNum:(NSInteger)maxPhotoNum{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSetMaxPhotoNumNotice object:@(maxPhotoNum)];
}
@end
