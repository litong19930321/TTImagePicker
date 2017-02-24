//
//  TTPhotoViewController.m
//  videoStudy_1
//
//  Created by 李曈 on 2017/2/24.
//  Copyright © 2017年 lt. All rights reserved.
//

#import "TTPhotoViewController.h"
#import <Photos/Photos.h>
@interface TTPhotoViewController (){
    CGFloat _scale;
    CGSize _targetSize;
}

@property (strong, nonatomic) PHFetchResult * fetchResults;

@property (assign, nonatomic) NSInteger index;

@property (strong, nonatomic) PHImageManager * imageManager ;

@property (strong, nonatomic) UIImageView * mainImageView;
@end

@implementation TTPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self config];
    [self createUI];
    [self showStaticPic];
}
-(void)config{
    self.view.backgroundColor = [UIColor whiteColor];
    _scale = [UIScreen mainScreen].scale;
    _targetSize = CGSizeMake(self.view.frame.size.width * _scale, self.view.frame.size.width * _scale);
   
    _imageManager = [PHImageManager defaultManager];
    if (self.fetchInfo[@"fetchResult"]) {
        self.fetchResults = self.fetchInfo[@"fetchResult"];
    }
    if (self.fetchInfo[@"index"]) {
        self.index = [self.fetchInfo[@"index"] integerValue];
    }
   
}

-(void)createUI{
    _mainImageView =  [[UIImageView alloc] init];
    _mainImageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _mainImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_mainImageView];
}

-(void)showStaticPic{
    if (self.fetchResults && self.index) {
        PHAsset * assert = self.fetchResults[self.index];
        PHImageRequestOptions * options = [[PHImageRequestOptions alloc] init];
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        [_imageManager requestImageForAsset:assert targetSize:_targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            _mainImageView.image = result;
        }];
    }
}



@end
