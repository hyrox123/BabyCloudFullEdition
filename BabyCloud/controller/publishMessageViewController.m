//
//  publishMessageViewController.m
//  YSTParentClient
//
//  Created by apple on 15/3/17.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "publishMessageViewController.h"
#import "publishMessageView.h"
#import "messageScrollViewController.h"
#import "HttpService.h"
#import "MBProgressHUD.h"
#import "ProtoType.h"
#import "utilityFunction.h"
#import "ELCImagePickerHeader.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "MobClick.h"
#import "publishCatgory.h"

@interface publishMessageViewController ()<publishMessageViewDelegate,ELCImagePickerControllerDelegate,ZBMessageManagerFaceViewDelegate,ZBMessageShareMenuViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property(nonatomic) publishMessageView *canvasView;
@property(nonatomic) bool messagePublished;
@end

@implementation publishMessageViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
   
    if (_messagePublished) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"refreshNews"
         object:nil
         userInfo:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [_canvasView.pannelTable reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect clientRect = [UIScreen mainScreen].bounds;
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(clientRect.size.width/2-130, 0, 130, 20)];
    titleLable.font = [UIFont boldSystemFontOfSize:20];
    titleLable.textColor = [UIColor whiteColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = @"消息发布";
    self.navigationItem.titleView = titleLable;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"wancheng"] style:UIBarButtonItemStylePlain target:self action:@selector(onSubmit)];
    rightButton.imageInsets = UIEdgeInsetsMake(2, 0, -2, 0);
    self.navigationItem.rightBarButtonItem = rightButton;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"fanhui1.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    self.navigationItem.leftBarButtonItem = backItem;
    self.navigationItem.hidesBackButton = YES;
    
    _canvasView = [[publishMessageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_canvasView];
    
    _canvasView.delegate = self;
    _messagePublished = NO;
    
    [self.view bringSubviewToFront:self.messageToolView];
    [self.view bringSubviewToFront:self.faceView];
    [self.view bringSubviewToFront:self.shareMenuView];
    
    self.messageToolView.hidden = YES;
    self.faceView.delegate = self;
    self.shareMenuView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onBack
{
    [self shrinkKeyboardAction];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onSubmit
{
    [self shrinkKeyboardAction];
    
    if ([_canvasView.textMessageView.text length] == 0 && [_canvasView.imageArray count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"必须要有发布内容" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        NSString *targetStr = nil, *textContent = _canvasView.textMessageView.text;
        
        if(!_messageType.length)
        {
            targetStr = @"";
        }
        else
        {
            if ([[HttpService getInstance].userExtentInfo.privilege isEqualToString:@"1"])
            {
                targetStr = [HttpService getInstance].userExtentInfo.schoolId;
            }
            else if([[HttpService getInstance].userExtentInfo.privilege isEqualToString:@"4"])
            {
                targetStr = [HttpService getInstance].userExtentInfo.officialId;
            }
            else
            {
                if ([HttpService getInstance].userExtentInfo.babyArray.count == 1) {
                    targetStr = ((BabyInfo*)[HttpService getInstance].userExtentInfo.babyArray[0]).classId;
                }
                else
                {
                    return [publishCatgory showPublishCatgory:_canvasView content:textContent images:_canvasView.imageArray serverUrl:_imgServerUrl messageType:_messageType andBlock:^{
                        _messagePublished = YES;
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                }
            }
        }
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *destDateString = [dateFormatter stringFromDate:[NSDate date]];
        
        NewsItem *item = [NewsItem new];
        item.textContent = textContent;
        item.imageArray = _canvasView.imageArray;
        item.updateTime = destDateString;
        item.serverUrl = _imgServerUrl;
        item.picHashCode = @"";
        item.targetId = targetStr;
        
        if (!_messageType.length) {
            item.open = YES;
        }
        else
        {
            item.open = [[NSUserDefaults standardUserDefaults] boolForKey:@"publicTopic"];
        }
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"处理中...";
        
        [[HttpService getInstance] publishNewsMessage:item messageType:_messageType andBlock:^(int retValue) {
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MobClick event:@"XXFB"];
            
            if (retValue == 200)
            {
                _messagePublished = YES;
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                NSString *tipMessage = [utilityFunction getErrorString:retValue];
                UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"提示" message:tipMessage delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertV show];
            }
        }];
    }
}

- (void)onLocalPic
{
    [self shrinkKeyboardAction];
    
    ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
    
    elcPicker.maximumImagesCount = (9-_canvasView.imageArray.count); //Set the maximum number of images to select to 100
    elcPicker.returnsOriginalImage = YES; //Only return the fullScreenImage, not the fullResolutionImage
    elcPicker.returnsImage = YES; //Return UIimage if YES. If NO, only return asset location information
    elcPicker.onOrder = YES; //For multiple image selection, display and return order of selected images
    elcPicker.mediaTypes = @[(NSString *)kUTTypeImage]; //Supports image and movie types
    elcPicker.imagePickerDelegate = self;
    
    [self presentViewController:elcPicker animated:YES completion:nil];
}

- (void)onCameraPic
{
    [self shrinkKeyboardAction];
    
    UIImagePickerController *imagePickerCamera = [[UIImagePickerController alloc] init];
    imagePickerCamera.delegate = self;
    imagePickerCamera.sourceType =  UIImagePickerControllerSourceTypeCamera;
    imagePickerCamera.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self presentViewController:imagePickerCamera animated:YES completion:nil];
}

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    for (NSDictionary *dict in info) {
        if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypePhoto){
            if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
                
                UIImage* srcImage = [dict objectForKey:UIImagePickerControllerOriginalImage];
                CGFloat rawW = srcImage.size.width;
                CGFloat rawH = srcImage.size.height;
                CGFloat dstW, dstH;
                
                if (rawW > rawH)
                {
                    if (rawW > 1024)
                    {
                        dstW = 1024;
                        dstH = (rawH/rawW)*1024;
                    }
                    else
                    {
                        dstW = rawW;
                        dstH = rawH;
                    }
                }
                else
                {
                    if (rawH > 1024)
                    {
                        dstH = 1024;
                        dstW = (rawW/rawH)*1024;
                    }
                    else
                    {
                        dstW = rawW;
                        dstH = rawH;
                    }
                }
                
                CGSize dstSize = {dstW, dstH};
                UIGraphicsBeginImageContext(dstSize);
                [srcImage drawInRect:CGRectMake(0, 0, dstSize.width, dstSize.height)];
                UIImage *dstImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                [_canvasView.imageArray addObject:dstImage];
            }
        }
    }
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController: (UIImagePickerController *)picker
didFinishPickingMediaWithInfo: (NSDictionary *)info
{
    UIImage* srcImage = [info objectForKey: @"UIImagePickerControllerOriginalImage"];
    
    CGFloat rawW = srcImage.size.width;
    CGFloat rawH = srcImage.size.height;
    CGFloat dstW, dstH;
    
    if (rawW > rawH)
    {
        if (rawW > 1024)
        {
            dstW = 1024;
            dstH = (rawH/rawW)*1024;
        }
        else
        {
            dstW = rawW;
            dstH = rawH;
        }
    }
    else
    {
        if (rawH > 1024)
        {
            dstH = 1024;
            dstW = (rawW/rawH)*1024;
        }
        else
        {
            dstW = rawW;
            dstH = rawH;
        }
    }
    
    CGSize dstSize = {dstW, dstH};
    UIGraphicsBeginImageContext(dstSize);
    [srcImage drawInRect:CGRectMake(0, 0, dstSize.width, dstSize.height)];
    UIImage *dstImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [_canvasView.imageArray addObject:dstImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) onTapImage:(int)index
{
    messageScrollViewController *scrlCtrl = [messageScrollViewController new];
    scrlCtrl.imageArray = _canvasView.imageArray;
    scrlCtrl.currentIndex = index;
    scrlCtrl.imageIsUrl = NO;
    
    [self presentViewController:scrlCtrl animated:YES completion:nil];
}

- (void)onSaveImag:(UIImage *)srcImg
{
    [_canvasView.imageArray addObject:srcImg];
}

- (void)messageViewAnimationWithMessageRect:(CGRect)rect  withMessageInputViewRect:(CGRect)inputViewRect andDuration:(double)duration andState:(ZBMessageViewState)state{
    
    if (state == ZBMessageViewStateShowFace || state == ZBMessageViewStateShowShare)
    {
        [_canvasView.textMessageView resignFirstResponder];
    }
    else
    {
        [_canvasView.textMessageView becomeFirstResponder];
    }
    
    [super messageViewAnimationWithMessageRect:rect withMessageInputViewRect:inputViewRect andDuration:duration andState:state];
    
    self.messageToolView.hidden = NO;
}

- (void)SendTheFaceStr:(NSString *)faceStr isDelete:(BOOL)dele
{
    if (dele)
    {
        if (_canvasView.textMessageView.text.length == 0) {
            return;
        }
        
        if ([[_canvasView.textMessageView.text substringFromIndex:_canvasView.textMessageView.text.length-1] isEqualToString:@"]"])
        {
            NSRange range = [_canvasView.textMessageView.text rangeOfString:@"[" options:NSBackwardsSearch];
            
            if (range.length > 0)
            {
                if (range.location == 0)
                {
                    _canvasView.textMessageView.text = @"";
                }
                else
                {
                    _canvasView.textMessageView.text = [_canvasView.textMessageView.text substringToIndex:range.location];
                }
            }
        }
    }
    else
    {
        _canvasView.textMessageView.text = [_canvasView.textMessageView.text stringByAppendingString:faceStr];
        [self.canvasView textViewDidChange:_canvasView.textMessageView];
    }
}

- (void)shrinkKeyboardAction
{
    if (![self.messageToolView isHidden])
    {
        [super didSelectedMultipleMediaAction:NO];
        [_canvasView.textMessageView resignFirstResponder];
        
        [UIView animateWithDuration:0.3f animations:^{
            self.messageToolView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame),CGRectGetWidth(self.view.frame),CGRectGetHeight(self.messageToolView.frame));
        } completion:^(BOOL finished) {
            self.messageToolView.hidden = YES;
        }];
    }
}

- (void)didSelecteShareMenuItem:(ZBMessageShareMenuItem *)shareMenuItem atIndex:(NSInteger)index
{
    switch (index) {
            
        case 0:
        {
            [self onLocalPic];
        }
            break;
            
        case 1:
        {
            [self onCameraPic];
        }
            break;
            
        default:
            break;
    }
}

- (void)dealloc
{
    self.faceView.delegate = nil;
    self.shareMenuView.delegate = nil;
    NSLog(@"publishMessageViewController dealloc");
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
