//
//  IflyViewController.m
//  cocopod3
//
//  Created by ZYS on 16/8/23.
//  Copyright © 2016年 jingqi. All rights reserved.
//

#import "IflyViewController.h"
#import <iflyMSC/IFlyFaceSDK.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+CornerImage.h"
NSString* const KCIFlyFaceResultRet      = @"ret";
NSString* const KCIFlyFaceResultFace     = @"face";
NSString* const KCIFlyFaceResultResult   = @"result";
NSString* const KCIFlyFaceResultPosition = @"position";
NSString* const KCIFlyFaceResultLandmark = @"landmark";
NSString* const KCIFlyFaceResultBottom   = @"bottom";
NSString* const KCIFlyFaceResultTop      = @"top";
NSString* const KCIFlyFaceResultLeft     = @"left";
NSString* const KCIFlyFaceResultRight    = @"right";
NSString* const KCIFlyFaceResultPointX   = @"x";
NSString* const KCIFlyFaceResultPointY   = @"y";
@interface IflyViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *photo;//照片
@property (nonatomic,retain) IFlyFaceDetector         * faceDetector;//识别
@property (nonatomic,retain) CALayer                  * imgToUseCoverLayer;//框
@end

@implementation IflyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //初始化 识别器
    self.faceDetector=[IFlyFaceDetector sharedInstance];
}
- (IBAction)choose:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"图片获取方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"摄相机", @"图片库", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    actionSheet.alpha = 1.f;
    actionSheet.tag = 1;
    [actionSheet showInView:self.view];
    actionSheet=nil;
}
- (IBAction)detector:(id)sender {
    
    if (!self.photo.image) {
        return;
    }
    
    
    //调用讯飞人脸识别
    
    NSString* strResult=[self.faceDetector detectARGB:[self.photo image]];
    NSLog(@"result:%@",strResult);
    [self praseDetectResult:strResult];
    
    
    
}

#pragma mark-ActionSheet 代理方法

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    switch (actionSheet.tag)
    {
        case 1://选择图片
            switch (buttonIndex)
        {
                
            case 0:
            {
                [self btnPhotoClicked:nil];
            }
                break;
            case 1:
            {
                [self btnExploerClicked:nil];
            }
                break;
        }
            break;
    }
}

- (void)btnPhotoClicked:(id)sender {
    
   
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.modalPresentationStyle = UIModalPresentationFullScreen;
        if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]){
            picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        
        picker.mediaTypes = @[(NSString*)kUTTypeImage];
        picker.allowsEditing = NO;//设置可编辑
        picker.delegate = self;
        
        [self presentViewController:picker animated:YES completion:nil];
        
    }else{
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"设备不可用" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        
    }
}

- (void)btnExploerClicked:(id)sender {
    
    
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.modalPresentationStyle = UIModalPresentationCurrentContext;
    if([UIImagePickerController isSourceTypeAvailable: picker.sourceType ]) {
        picker.mediaTypes = @[(NSString*)kUTTypeImage];
        picker.delegate = self;
        picker.allowsEditing = NO;
    }
    
    [self presentViewController:picker animated:YES completion:nil];
    
}

#pragma mark-图片选择代理

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    picker.delegate=nil;
    picker=nil;
    if(_imgToUseCoverLayer){
        [_imgToUseCoverLayer removeFromSuperlayer];
        _imgToUseCoverLayer.sublayers=nil;
        _imgToUseCoverLayer=nil;
    }
    
    UIImage* image=[info objectForKey:@"UIImagePickerControllerOriginalImage"];
    self.photo.image=nil;
    self.photo.layer.sublayers=nil;
    self.photo.image = [image fixOrientation] ;
    
    image=nil;
    
    
    
}


#pragma mark - Data Parser  识别 数据解析

-(void)praseDetectResult:(NSString*)result{
    NSString *resultInfo = @"";
    
    @try {
        NSError* error;
        NSData* resultData=[result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* dic=[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:&error];
        
        if(dic){
            NSNumber* ret=[dic objectForKey:KCIFlyFaceResultRet];
            NSArray* faceArray=[dic objectForKey:KCIFlyFaceResultFace];
            //检测
            if(ret && [ret intValue]==0 && faceArray &&[faceArray count]>0){
                resultInfo=[resultInfo stringByAppendingFormat:@"检测到人脸轮廓"];
            }else{
                resultInfo=[resultInfo stringByAppendingString:@"未检测到人脸轮廓"];
            }
            
            
            //绘图
            if(_imgToUseCoverLayer){
                _imgToUseCoverLayer.sublayers=nil;
                [_imgToUseCoverLayer removeFromSuperlayer];
                _imgToUseCoverLayer=nil;
            }
            _imgToUseCoverLayer = [[CALayer alloc] init];
            
            for(id faceInArr in faceArray){
                
                CALayer* layer= [[CALayer alloc] init];
                layer.borderWidth = 2.0f;
                [layer setCornerRadius:2.0f];
                
                float image_x, image_y, image_width, image_height;
                if(_photo.image.size.width/_photo.image.size.height > _photo.frame.size.width/_photo.frame.size.height){
                    image_width = _photo.frame.size.width;
                    image_height = image_width/_photo.image.size.width * _photo.image.size.height;
                    image_x = 0;
                    image_y = (_photo.frame.size.height - image_height)/2;
                    
                }else if(_photo.image.size.width/_photo.image.size.height < _photo.frame.size.width/_photo.frame.size.height)
                {
                    image_height = _photo.frame.size.height;
                    image_width = image_height/_photo.image.size.height * _photo.image.size.width;
                    image_y = 0;
                    image_x = (_photo.frame.size.width - image_width)/2;
                    
                }else{
                    image_x = 0;
                    image_y = 0;
                    image_width = _photo.frame.size.width;
                    image_height = _photo.frame.size.height;
                }
                
                CGFloat resize_scale = image_width/_photo.image.size.width;
                //
                if(faceInArr && [faceInArr isKindOfClass:[NSDictionary class]]){
                    NSDictionary* position=[faceInArr objectForKey:KCIFlyFaceResultPosition];
                    if(position){
                        CGFloat bottom =[[position objectForKey:KCIFlyFaceResultBottom] floatValue];
                        CGFloat top=[[position objectForKey:KCIFlyFaceResultTop] floatValue];
                        CGFloat left=[[position objectForKey:KCIFlyFaceResultLeft] floatValue];
                        CGFloat right=[[position objectForKey:KCIFlyFaceResultRight] floatValue];
                        
                        float x = left;
                        float y = top;
                        float width = right- left;
                        float height = bottom- top;
                        
                        CGRect innerRect = CGRectMake( resize_scale*x+image_x, resize_scale*y+image_y, resize_scale*width, resize_scale*height);
                        
                        [layer setFrame:innerRect];
                        layer.borderColor = [[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0] CGColor];
                    }
                }
                
                [_imgToUseCoverLayer addSublayer:layer];
                layer=nil;
                
            }
            self.photo.layer.sublayers=nil;
            [self.photo.layer addSublayer:_imgToUseCoverLayer];
            _imgToUseCoverLayer=nil;
            
        }
        
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"结果" message:resultInfo delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
    }
    @catch (NSException *exception) {
        NSLog(@"prase exception:%@",exception.name);
    }
    @finally {
    }
    
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
