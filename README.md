# TTImagePicker
照片选择器，适用于一次性选择多张照片，简单易用，使用PhotoKit，只支持iOS8+
- 用法


1.将TTImagePicker文件拷贝到工程中

2.导入头文件
```
#import "TTPhotoPickerController.h"
```
3.直接初始化即可	
```
TTPhotoPickerController * vc = [[TTPhotoPickerController alloc] initWithComplete:^(NSArray *images) {
        //选择照片之后的回调  images为选择的图片数组
        //your code
    }];
    [self presentViewController:vc animated:YES completion:nil];
```
