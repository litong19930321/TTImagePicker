//
//  TTAListViewController.m
//  videoStudy_1
//
//  Created by 李曈 on 2017/2/24.
//  Copyright © 2017年 lt. All rights reserved.
//

#import "TTAListViewController.h"
#import <Photos/Photos.h>
#import "TTPhotosGridViewController.h"
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kAListCellIdentifier @"com.tt.aListcell"
@interface TTAListViewController ()<UITableViewDelegate,UITableViewDataSource>{

}

@property (strong, nonatomic) UITableView * aListView;

@property (copy, nonatomic) NSArray * aListArray;

@property (copy, nonatomic) TTSelectedImg selectImgBlock;

@end

@implementation TTAListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
}

-(void)setUpUI{
    self.title = @"照片";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    _aListView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64)];
    _aListView.delegate = self;
    _aListView.dataSource = self;
    [self.view addSubview:_aListView];
    [_aListView registerClass:[UITableViewCell class] forCellReuseIdentifier:kAListCellIdentifier];
    [_aListView setTableFooterView:[UIView new]];
    [self getAListFromSystems];

    UIBarButtonItem * rightBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(cancle)];
    self.navigationItem.rightBarButtonItem = rightBarItem;

}

-(void)cancle{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 获取所有相册信息
 */
-(void)getAListFromSystems{
    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"estimatedAssetCount" ascending:NO];
    PHFetchOptions * fetchOptions= [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[sort];
    PHFetchResult * alist_smart = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum  subtype:PHAssetCollectionSubtypeAlbumRegular options:fetchOptions];
    PHFetchResult * alist_album = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum  subtype:PHAssetCollectionSubtypeAlbumRegular options:fetchOptions];
    NSMutableArray * mArray = [NSMutableArray arrayWithCapacity:alist_smart.count + alist_album.count];
    for (NSInteger i = 0; i < alist_album.count; i++) {
        PHCollection * collection = alist_album[i];
        [mArray addObject:collection];
    }
    for (NSInteger i = 0; i < alist_smart.count; i++) {
        PHCollection * collection = alist_smart[i];
        [mArray addObject:collection];
    }
    self.aListArray = mArray.copy;
    mArray = nil;
    [_aListView reloadData];
    
}

-(void)completeChooseImage:(TTSelectedImg)block{
    _selectImgBlock = block;
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _aListArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kAListCellIdentifier];
    
    PHCollection * collection = _aListArray[indexPath.row];
    if (collection.localizedTitle) {
        cell.textLabel.text = collection.localizedTitle;
    }else{
        cell.textLabel.text = @"未命名相薄";
    }
    
    
    return cell;
}
#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0f;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TTPhotosGridViewController * girdVC = [[TTPhotosGridViewController alloc] init];
    PHAssetCollection * assetCollection = (PHAssetCollection *)self.aListArray[indexPath.row];
    PHFetchOptions * options = [[PHFetchOptions alloc] init];
    NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:YES];
    options.sortDescriptors = @[descriptor];
    PHFetchResult * fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
    girdVC.fetchResult = fetchResult;
    [girdVC completeChooseImage:^(NSArray *images) {
        _selectImgBlock(images);
    }];
    [self.navigationController pushViewController:girdVC animated:YES];
}
@end
