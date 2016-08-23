//
//  ImageViewController.m
//  cocopod3
//
//  Created by ZYS on 16/8/23.
//  Copyright © 2016年 jingqi. All rights reserved.
//

#import "ImageViewController.h"
#import "Conf.h"
#import "Auth.h"
#import "TXQcloudFrSDK.h"
@interface ImageViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
{
    UIImagePickerController *_imagePicker;
    TXQcloudFrSDK *_sdk;
    UILabel *_faceInfo;
}
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [Conf instance].appId = @"1000277";
    [Conf instance].secretId = @"AKIDjyWnGXehU7d9casOl7cTQgix3UHJEiPv";
    [Conf instance].secretKey = @"sY1rUU9nBUKpVXWioGW7tUnOgJ1VXLaC";
    
    NSString *auth = [Auth appSign:1000000 userId:nil];
    _sdk = [[TXQcloudFrSDK alloc] initWithName:[Conf instance].appId authorization:auth];
    
    _sdk.API_END_POINT = @"http://api.youtu.qq.com/youtu";
    
    _imagePicker = [[UIImagePickerController alloc]init];
    //_imagePicker.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
    _imagePicker.delegate = self;
    
    _faceInfo = [[UILabel alloc]init];
    _faceInfo.frame = CGRectMake(10, 10, 100, 100);
    _faceInfo.backgroundColor = [UIColor clearColor];
    _faceInfo.numberOfLines = 0;
    _faceInfo.hidden = YES;
    
    [self.view addSubview:_faceInfo];
    
}
- (IBAction)takePhoto:(id)sender {
    
    UIActionSheet *action = [[UIActionSheet alloc]initWithTitle:@"人脸识别" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册" ,nil];
    
    
    [action showInView:self.view];
    
    
    //_faceInfo.hidden = YES;
    //[self presentViewController:_imagePicker animated:YES completion:nil];
    
    
//    self.photo.image = [UIImage imageNamed:@"face.jpg"];
//    [_sdk detectFace:[UIImage imageNamed:@"face.jpg"] successBlock:^(id responseObject) {
//        NSLog(@"responseObject: %@", responseObject);
//        
//        NSDictionary *dic = [responseObject[@"face"] firstObject];
//        
//        _faceInfo.text = [NSString stringWithFormat:@"年龄 :%@ \n眼镜: %@\n颜值 :%@ \n笑容 :%@",dic[@"age"],dic[@"glass"],dic[@"beauty"],dic[@"expression"]];
//        
//        _faceInfo.hidden = NO;
//        
//        
//    } failureBlock:^(NSError *error) {
//        NSLog(@"error");
//    }];
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:{
            _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:_imagePicker animated:YES completion:nil];
        }
            
            break;
        case 1:{
            _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:_imagePicker animated:YES completion:nil];
        }
            
            break;
        case 2:{
            
        }
            
            break;
        default:
            break;
    }
    
    
    
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    
    UIImage* original = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    
    self.photo.image = original;
    
    
    [_sdk detectFace:original successBlock:^(id responseObject) {
        NSLog(@"responseObject: %@", responseObject);
        
        NSDictionary *dic = [responseObject[@"face"] firstObject];
        
        _faceInfo.text = [NSString stringWithFormat:@"年龄 :%@ \n眼镜: %@\n颜值 :%@ \n笑容 :%@",dic[@"age"],dic[@"glass"],dic[@"beauty"],dic[@"expression"]];
        
        _faceInfo.hidden = NO;
        
        
    } failureBlock:^(NSError *error) {
        NSLog(@"error");
    }];
    
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
