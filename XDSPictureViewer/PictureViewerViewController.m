//
//  PictureViewerViewController.m
//  XDSPictureViewer
//
//  Created by zhengda on 15/4/23.
//  Copyright (c) 2015年 zhengda. All rights reserved.
//

#import "PictureViewerViewController.h"
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeigh [UIScreen mainScreen].bounds.size.height
#define kmaxScale 2.0f
#define kminScale 1.0f
#define knormalScale 1.0f
@interface PictureViewerViewController ()<UIScrollViewDelegate>{
    UIScrollView * _scrollView;
    NSInteger page;
}
@end

@implementation PictureViewerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
}

#pragma mark - 图片浏览器，实现双击，捏合放大缩小
- (void)createUI{
    _scrollView= [[UIScrollView alloc]initWithFrame:self.view.bounds];
    _scrollView.backgroundColor= [UIColor clearColor];
    _scrollView.scrollEnabled=YES;
    _scrollView.pagingEnabled=YES;
    _scrollView.delegate=self;
    _scrollView.contentSize=CGSizeMake(self.imageListArray.count * kScreenWidth, kScreenHeigh);
    for(int i = 0; i < self.imageListArray.count; i++){
        UITapGestureRecognizer * doubleTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleTap:)];
        [doubleTap setNumberOfTapsRequired:2];
        UIScrollView * subScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(kScreenWidth * i, 0.0f, kScreenWidth, kScreenHeigh)];
        subScrollView.showsHorizontalScrollIndicator = NO;
        subScrollView.showsVerticalScrollIndicator = NO;
        subScrollView.backgroundColor= [UIColor clearColor];
        subScrollView.contentSize=CGSizeMake(kScreenWidth, kScreenHeigh);
        subScrollView.delegate=self;
        subScrollView.minimumZoomScale=kminScale;
        subScrollView.maximumZoomScale=kmaxScale;
        subScrollView.zoomScale = knormalScale;
        UIImageView * imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, kScreenWidth, kScreenHeigh)];
        imageview.contentMode = UIViewContentModeScaleAspectFit;
        imageview.image= self.imageListArray[i];
        imageview.userInteractionEnabled=YES;
        imageview.tag= i + 1;
        [imageview addGestureRecognizer:doubleTap];
        [subScrollView addSubview:imageview];
        [_scrollView addSubview:subScrollView];
    }
    [self.view addSubview:_scrollView];
}
#pragma mark - ScrollView delegate
- (UIView*)viewForZoomingInScrollView:(UIScrollView*)scrollView{
    for(UIView* subView in scrollView.subviews){
        return subView;
    }
    return nil;
}
-(void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView{
    if(scrollView == _scrollView){
        NSInteger x = scrollView.contentOffset.x / kScreenWidth;
        if(x == page){
            //如果还是当前页，则不做操作
        }else{
            page = x;
            for(UIScrollView * subScrollView in scrollView.subviews){
                if([subScrollView isKindOfClass:[UIScrollView class]]){
                    [subScrollView setZoomScale:knormalScale]; //scrollView每滑动一次将要出现的图片较正常时候图片的倍数（将要出现的图片显示的倍数）
                }
            }
        }
    }
}
#pragma mark -
-(void)handleDoubleTap:(UIGestureRecognizer*)gesture{
    CGFloat newScale = ([(UIScrollView*)gesture.view.superview zoomScale] == kminScale)?kmaxScale:kminScale;//每次双击放大倍数
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gesture locationInView:gesture.view]];
    [(UIScrollView*)gesture.view.superview zoomToRect:zoomRect animated:YES];
}
- (CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center{
    CGRect zoomRect;
    zoomRect.size.height=self.view.frame.size.height/ scale;
    zoomRect.size.width=self.view.frame.size.width/ scale;
    zoomRect.origin.x= center.x - (zoomRect.size.width/2.0);
    zoomRect.origin.y= center.y - (zoomRect.size.height/2.0);
    return zoomRect;
}

@end
