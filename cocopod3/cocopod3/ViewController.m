//
//  ViewController.m
//  cocopod3
//
//  Created by ZYS on 16/8/19.
//  Copyright © 2016年 jingqi. All rights reserved.
//

#import "ViewController.h"
#import <MAMapKit/MAMapKit.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    ///初始化地图
    MAMapView *_mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    _mapView.showsUserLocation = YES;
    ///把地图添加至view
    [self.view addSubview:_mapView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
