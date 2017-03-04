//
//  ViewController.m
//  Demo
//
//  Created by 李曈 on 2017/2/25.
//  Copyright © 2017年 lt. All rights reserved.
//

#import "ViewController.h"
#import "TTPhotoPickerController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)choosePhoto:(id)sender {
    TTPhotoPickerController * vc = [[TTPhotoPickerController alloc] initWithComplete:^(NSArray *images) {
        //选择照片之后的回调  images为选择的图片数组
        //下面代码为 示例
        for (int i = 0; i < images.count ; i ++) {
            UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10 + i % 3 * 100 + 10 * (i % 3), 150 + i / 3 * 150 + 10 * (i / 3), 100, 150)];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.image = images[i];
            imageView.clipsToBounds = YES;
            [self.view addSubview:imageView];
        }
    }];
    //设置最大选择量为3张，如果不设置则默认为6张
    vc.maxPhotoNum = 3;
    vc.navigationBar.barTintColor = [UIColor whiteColor];
    [self presentViewController:vc animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
