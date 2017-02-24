//
//  TTPhotosGridViewController.m
//  videoStudy_1
//
//  Created by 李曈 on 2017/2/24.
//  Copyright © 2017年 lt. All rights reserved.
//

#import "TTPhotosGridViewController.h"
#import "TTPhotoViewController.h"
#import <Photos/Photos.h>


#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kGridItemIdentifier @"com.tt.aListcell"
#define kItemWidth (kScreenWidth - 5 * 3) / 4

#pragma mark - TTPhotosGridItemModel

@interface TTPhotosGridItemModel : NSObject

@property (assign, nonatomic) NSInteger index;

@property (assign, nonatomic) BOOL isSelected;

@end

@implementation TTPhotosGridItemModel

@end



#pragma mark - TTPhotosGridItem

typedef void(^TTPhotosGridItemSelect)(NSInteger index,BOOL isSelected);

@interface TTPhotosGridItem: UICollectionViewCell

@property (strong, nonatomic) UIImageView * potoView;

@property (copy, nonatomic) NSString * representedAssetIdentifier;

@property (strong, nonatomic) UIButton * selectBtn;

@property (strong, nonatomic) TTPhotosGridItemModel * model;

@property (copy, nonatomic) TTPhotosGridItemSelect selectBlock;

-(void)itemSelectBlock:(TTPhotosGridItemSelect)block;

@end

@implementation TTPhotosGridItem

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpUI];
    }
    return self;
}

-(void)setUpUI{
    self.potoView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.potoView.contentMode = UIViewContentModeScaleAspectFill;
    self.potoView.clipsToBounds = YES;
    [self.contentView addSubview:_potoView];
    
    _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _selectBtn.frame = CGRectMake(self.bounds.size.width - 40,0, 40, 40);
    [_selectBtn setImage:[UIImage imageNamed:@"tt_item_nor"] forState:UIControlStateNormal];
    [_selectBtn setImage:[UIImage imageNamed:@"tt_item_sel"] forState:UIControlStateSelected];
    _selectBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 12, 12, 0);
    [_selectBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_selectBtn];
}

-(void)setModel:(TTPhotosGridItemModel *)model{
    _model = model;
    _selectBtn.selected = model.isSelected;
}

-(void)buttonClick:(UIButton *)sender{
    sender.selected = !sender.selected;
    _model.isSelected = sender.selected;
    _selectBlock(_model.index,sender.selected);
}

-(void)itemSelectBlock:(TTPhotosGridItemSelect)block{
    _selectBlock = block;
    
}

@end

#pragma mark - TTPhotosGridViewController

typedef void(^TTTestblock)();

@interface TTPhotosGridViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>{
    
}

@property (strong, nonatomic) UICollectionView * mainGirdView;

@property (strong, nonatomic) PHImageManager * imageManager;

@property (strong, nonatomic) PHFetchResult * fetchResults;

@property (assign, nonatomic) CGSize  imageSize;

@property (copy, nonatomic) TTSelectedImg selectImgBlock;

@property (copy, nonatomic) TTTestblock testBlock;

@property (strong, nonatomic) NSArray * dataArray;

@property (strong, nonatomic) NSMutableSet * mset;

@end

@implementation TTPhotosGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    [self readPhotos];
}

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

-(void)setUpUI{
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 3;
    layout.minimumInteritemSpacing = 0;
    layout.itemSize = CGSizeMake(kItemWidth, kItemWidth);
    _mainGirdView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0,kScreenWidth, kScreenHeight - 64) collectionViewLayout:layout];
    _mainGirdView.delegate = self;
    _mainGirdView.dataSource = self;
    _mainGirdView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_mainGirdView];
    [_mainGirdView registerClass:[TTPhotosGridItem class] forCellWithReuseIdentifier:kGridItemIdentifier];
    CGFloat  scale = [UIScreen mainScreen].scale;
    _imageSize = CGSizeMake(kItemWidth * scale, kItemWidth * scale);
    //right barItem
    UIBarButtonItem * rightBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
}

-(void)readPhotos{
    _mset = [NSMutableSet set];
    self.fetchResults = (PHFetchResult *)self.fetchResult;
    NSMutableArray * mArray = [[NSMutableArray alloc] initWithCapacity:self.fetchResults.count];
    for (NSInteger i = 0; i < self.fetchResults.count; i++) {
        TTPhotosGridItemModel * model = [[TTPhotosGridItemModel alloc] init];
        model.isSelected = NO;
        model.index = i;
        [mArray addObject:model];
    }
    self.dataArray = mArray.copy;
    mArray = nil;
    _imageManager = [PHCachingImageManager defaultManager];
    [_mainGirdView reloadData];
}

-(void)executDoneBlock{
    if (self.mset.count > 0) {
        __block NSMutableArray * marr = @[].mutableCopy;
        dispatch_queue_t queue = dispatch_queue_create("com.tt.readImags", DISPATCH_QUEUE_SERIAL);
        dispatch_group_t group = dispatch_group_create();

        NSArray * imageArr = [_mset allObjects];
        dispatch_async(queue, ^{
            for (NSNumber * num in imageArr) {
                PHAsset * asset = self.fetchResults[[num integerValue]];
                PHImageRequestOptions * options = [[PHImageRequestOptions alloc] init];
                options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                dispatch_group_enter(group);
                [_imageManager requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    UIImage * image = [UIImage imageWithData:imageData];
                    [marr addObject:image];
                    dispatch_group_leave(group);
                }];
            }
            dispatch_group_notify(group, queue, ^{
                _selectImgBlock(marr.copy);
                marr = nil;
                [self dismissViewControllerAnimated:YES completion:nil];
                return;
            });
        });

    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)completeChooseImage:(TTSelectedImg)block{
    _selectImgBlock = block;
}

-(void)cancle{
    
}

-(void)done{
    [self executDoneBlock];
}
#pragma mark -UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.fetchResults.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    TTPhotosGridItem * item = [collectionView dequeueReusableCellWithReuseIdentifier:kGridItemIdentifier forIndexPath:indexPath];
    
    PHAsset * asset = self.fetchResults[indexPath.row];
    item.representedAssetIdentifier = asset.localIdentifier;
    if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
        
    }
    TTPhotosGridItemModel * model = self.dataArray[indexPath.row];
    item.model = model;
    if (asset) {
        [_imageManager requestImageForAsset:self.fetchResults[indexPath.item] targetSize:_imageSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//            if (item.representedAssetIdentifier == asset.localIdentifier) {
                item.potoView.image = result;
//            }
        }];
    }
    __weak typeof (_mset)weak_mset = _mset;
    [item itemSelectBlock:^(NSInteger index, BOOL isSelected) {
        if (isSelected) {
            [weak_mset addObject:@(index)];
        }else{
            [weak_mset removeObject:@(index)];
        }
    }];
    
    return item;
}

#pragma mark -UICollectionViewDelegateFlowLayout
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(3, 3, 0, 3);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary * dict = @{@"fetchResult":self.fetchResults,@"index":@(indexPath.item)};
    TTPhotoViewController * photoVC = [[TTPhotoViewController alloc] init];
    photoVC.fetchInfo = dict;
    [self.navigationController pushViewController:photoVC animated:YES];
}
@end
