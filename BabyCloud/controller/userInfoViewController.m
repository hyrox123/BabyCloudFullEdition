//
//  userInfoViewController.m
//  YSTParentClient
//
//  Created by apple on 15/3/12.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "userInfoViewController.h"
#import "ProtoType.h"
#import "HttpService.h"
#import "UIImageView+WebCache.h"
#import "utilityFunction.h"
#import "SDTransparentPieProgressView.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#import "KxMenu.h"

@interface userInfoViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property(nonatomic) UITableView *infoList;
@property(nonatomic) UIImageView *portraitView;
@property(nonatomic) UIButton *btnValideTime, *btnForbidden, *btnConfirm;
@property(nonatomic) NSString *portraitUrl;
@property(nonatomic) NSArray *menuItemArray, *validTimeArray;
@property(nonatomic) int selectIndex;

-(void)onBtnModify;
-(void)onBtnForbidden;
-(void)onClickImg;
-(void)showMenu:(UIButton *)sender;
-(void)onMenuItem:(id)sender;
@end

@implementation userInfoViewController

-(CandidateItem*)personInfo
{
    if (_personInfo == nil) {
        _personInfo = [CandidateItem new];
    }
    
    return _personInfo;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
     _menuItemArray = @[@"30分钟",@"1个小时",@"3个小时",@"6个小时",@"12小时",@"24小时"];
    _validTimeArray = @[@"30",@"60",@"180",@"360",@"720",@"1440"];
    
    CGRect clientRect = [UIScreen mainScreen].bounds;
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    self.navigationItem.titleView = titleLabel;
    self.view.backgroundColor = [UIColor whiteColor];
    
    _portraitView = [[UIImageView alloc] initWithFrame:CGRectMake(clientRect.size.width/2-35, 10, 70, 70)];
    _infoList = [[UITableView alloc] initWithFrame:CGRectMake(10, 85, clientRect.size.width-20, 300)];
    [self.view addSubview:_portraitView];
    [self.view addSubview:_infoList];
    
    _portraitView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickImg)];
    [_portraitView addGestureRecognizer:singleTapGesture];
    _portraitView.layer.masksToBounds = YES;
    _portraitView.layer.cornerRadius = 8;
    
    _infoList.delegate = self;
    _infoList.dataSource = self;
    [utilityFunction setExtraCellLineHidden:_infoList];
    
    _btnConfirm = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if ([[HttpService getInstance].userExtentInfo.privilege isEqualToString:@"1"]
        || [[HttpService getInstance].userExtentInfo.privilege isEqualToString:@"2"])
    {
        _btnConfirm.frame = CGRectMake(5, 305, clientRect.size.width-10, 35);
    }
    else
    {
        _btnConfirm.frame = CGRectMake(5, 265, clientRect.size.width-10, 35);
    }
    
    _btnConfirm.showsTouchWhenHighlighted = YES;
    _btnConfirm.titleLabel.font = [UIFont systemFontOfSize:20];
    _btnConfirm.layer.cornerRadius = 17.5;
    _btnConfirm.titleLabel.textColor = [UIColor whiteColor];
    _btnConfirm.backgroundColor = [UIColor colorWithRed:0.2235f green:0.6235f blue:0.8745f alpha:1.0f];
    [_btnConfirm setTitle: @"修 改" forState: UIControlStateNormal];
    [_btnConfirm addTarget:self action:@selector(onBtnModify) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnConfirm];
    
    
    UILabel *descLabe = [[UILabel alloc] initWithFrame:CGRectMake(25, 210, 120, 20)];
    [self.view addSubview:descLabe];
    
    descLabe.textColor = [UIColor lightGrayColor];
    descLabe.font = [UIFont systemFontOfSize:14];
    descLabe.text = @"对该用户禁言:";
    
    _btnValideTime = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:_btnValideTime];
    
    _btnValideTime.frame = CGRectMake(125, 210, 80, 20);
    _btnValideTime.showsTouchWhenHighlighted = YES;
    _btnValideTime.titleLabel.font = [UIFont systemFontOfSize:16];
    _btnValideTime.titleLabel.textColor = [UIColor blueColor];
    _btnValideTime.backgroundColor = [UIColor lightGrayColor];
    [_btnValideTime setTitle: @"30分钟" forState: UIControlStateNormal];
    [_btnValideTime addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    _btnForbidden = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:_btnForbidden];
    
    _btnForbidden.frame = CGRectMake(clientRect.size.width-80, 205, 70, 30);
    _btnForbidden.showsTouchWhenHighlighted = YES;
    _btnForbidden.titleLabel.font = [UIFont systemFontOfSize:20];
    _btnForbidden.titleLabel.textColor = [UIColor whiteColor];
    _btnForbidden.backgroundColor = [UIColor colorWithRed:0.3529f green:0.7569f blue:0.7490f alpha:1.0f];
    [_btnForbidden setTitle: @"禁言" forState: UIControlStateNormal];
    [_btnForbidden addTarget:self action:@selector(onBtnForbidden) forControlEvents:UIControlEventTouchUpInside];
  
    _selectIndex = 0;
    NSString *portraitUrl = nil;
    
    if (_solidStyle == NO)
    {
        if ([[HttpService getInstance].userExtentInfo.privilege isEqualToString:@"1"]
            ||[[HttpService getInstance].userExtentInfo.privilege isEqualToString:@"2"]
            )
        {
            descLabe.hidden = NO;
            _btnValideTime.hidden = NO;
            _btnForbidden.hidden = NO;
        }
        else
        {
            descLabe.hidden = YES;
            _btnValideTime.hidden = YES;
            _btnForbidden.hidden = YES;
        }
        
        
        _btnConfirm.hidden = YES;
        titleLabel.text = self.personInfo.nickName;
        portraitUrl = self.personInfo.portrait;
    }
    else
    {
        descLabe.hidden = YES;
        _btnValideTime.hidden = YES;
        _btnForbidden.hidden = YES;
        _btnConfirm.hidden = NO;
        titleLabel.text = @"个人信息";
        portraitUrl =  [NSString stringWithFormat:@"%@%@", [HttpService getInstance].userExtentInfo.imgServerUrl, [HttpService getInstance].userBaseInfo.portrait];
    }
    
    if ([HttpService getInstance].userBaseInfo.portrait != nil && [HttpService getInstance].userBaseInfo.portrait.length > 0) {
        
        __block SDTransparentPieProgressView *activityIndicator = nil;
        __weak UIImageView *weakImageView = _portraitView;
        [_portraitView sd_setImageWithURL:[NSURL URLWithString:portraitUrl]
                         placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"touxiaNGMORENLAN_@2x" ofType:@"png"]]
                                  options:SDWebImageProgressiveDownload
                                 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                     if (!activityIndicator) {
                                         activityIndicator = [SDTransparentPieProgressView progressView];
                                         activityIndicator.frame = CGRectMake((weakImageView.frame.size.width-40)/2, (weakImageView.frame.size.height-40)/2, 40, 40);
                                         [weakImageView addSubview:activityIndicator];
                                     }
                                     
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         activityIndicator.progress = (float)receivedSize/(float)expectedSize;
                                     });
                                 }
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                    [activityIndicator dismiss];
                                    [activityIndicator removeFromSuperview];
                                    activityIndicator = nil;
                                }];
    }
    else
    {
        _portraitView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"touxiaNGMORENLAN_@2x" ofType:@"png"]];
    }
    
    _portraitUrl = @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (_solidStyle == YES)
    {
        if ([[HttpService getInstance].userExtentInfo.privilege isEqualToString:@"1"]
            || [[HttpService getInstance].userExtentInfo.privilege isEqualToString:@"2"])

        {
            return 4;
        }
        else
        {
            return 3;
        }
    }
    else
    {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CustomCellIdentifier = @"CustomCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CustomCellIdentifier];
    }
    
    for (UIView *subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }
    
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 75, 30)];
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(85, 10, 150, 30)];
    textField.returnKeyType = UIReturnKeyDone;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    textField.delegate = self;
    descLabel.font = [UIFont systemFontOfSize:18];
    textField.font = [UIFont systemFontOfSize:16];
    
    if (_solidStyle == YES)
    {
        if ([indexPath row] == 0)
        {
            descLabel.text = @"性别";
            textField.placeholder = @"请输入性别";
            textField.tag = 0x1001;
            
            if ([HttpService getInstance].userBaseInfo.sex.length > 0)
            {
                if([[HttpService getInstance].userBaseInfo.sex isEqualToString:@"0"])
                {
                    textField.text = @"男";
                }
                else
                {
                    textField.text = @"女";
                }
            }
            else
            {
                textField.text = [HttpService getInstance].userBaseInfo.sex;
            }
        }
        else if([indexPath row] == 1)
        {
            descLabel.text = @"姓名";
            textField.placeholder = @"请输入真实姓名";
            textField.tag = 0x1002;
            
            textField.text = [HttpService getInstance].userBaseInfo.realName;
        }
        else if([indexPath row] == 2)
        {
            descLabel.text = @"昵称";
            textField.placeholder = @"请输入昵称";
            textField.tag = 0x1003;
            textField.text = [HttpService getInstance].userBaseInfo.nickName;
        }
        else if([indexPath row] == 3)
        {
            descLabel.text = @"职位";
            textField.placeholder = @"请输入职位";
            textField.tag = 0x1004;
            textField.text = [HttpService getInstance].userBaseInfo.position;
        }
    }
    else
    {
        if ([indexPath row] == 0)
        {
            descLabel.text = @"昵称";
            textField.text = self.personInfo.nickName;
        }
        else if([indexPath row] == 1)
        {
            descLabel.text = @"学校";
            textField.text = [HttpService getInstance].userExtentInfo.schoolName;
        }
        
        textField.enabled = NO;
    }
    
    [cell.contentView addSubview:descLabel];
    [cell.contentView addSubview:textField];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark Table Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

-(void)onBtnModify
{
    UITableViewCell *cell1 = [_infoList cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    UITableViewCell *cell2 = [_infoList cellForRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
    UITableViewCell *cell3 = [_infoList cellForRowAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]];
    UITableViewCell *cell4 = [_infoList cellForRowAtIndexPath:[NSIndexPath indexPathForItem:3 inSection:0]];
    
    UITextField *textfield1 = (UITextField*)[cell1 viewWithTag:0x1001];
    UITextField *textfield2 = (UITextField*)[cell2 viewWithTag:0x1002];
    UITextField *textfield3 = (UITextField*)[cell3 viewWithTag:0x1003];
    UITextField *textfield4 = nil;
    
    if (cell4 != nil) {
        textfield4 = (UITextField*)[cell4 viewWithTag:0x1004];
    }
    
    UserBaseInfo *baseInfo = [UserBaseInfo new];
    
    if ([textfield1.text isEqualToString:@"男"] == YES)
    {
        baseInfo.sex = @"0";
    }
    else if([textfield1.text isEqualToString:@"女"] == YES)
    {
        baseInfo.sex = @"1";
    }
    else
    {
        baseInfo.sex = @"";
    }
    
    baseInfo.phone = @"";
    baseInfo.portrait = _portraitUrl;
    baseInfo.realName = textfield2.text;
    baseInfo.nickName = textfield3.text;
    
    if (textfield4 != nil)
    {
        baseInfo.position = textfield4.text;
    }
    else
    {
        baseInfo.position = @"";
    }
    
    _btnConfirm.enabled = NO;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"处理中...";
    
    [[HttpService getInstance] modifyUserBaseInfo:baseInfo andBlock:^(int retValue) {
        
        _btnConfirm.enabled = YES;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSString *messageTip = @"";
        
        if (retValue == 200)
        {
            messageTip = @"修改用户基本信息成功";
        }
        else
        {
            messageTip = @"修改用户基本信息失败";
        }
        
        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"提示" message:messageTip delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertV show];
    }];
}

- (void)showMenu:(UIButton *)sender
{
    int itemIndex = 0;
    
    NSMutableArray *menuItems = [NSMutableArray new];
    
    for (NSString *itemName in _menuItemArray) {
        
        KxMenuItem *item = [KxMenuItem menuItem:itemName
                                          image:nil
                                         target:self
                                         action:@selector(onMenuItem:)];
        
        [menuItems addObject:item];
        item.index = itemIndex;
        itemIndex++;
    }
    
    [KxMenu showMenuInView:self.view
                  fromRect:sender.frame
                 menuItems:menuItems];
}

-(void)onMenuItem:(id)sender
{
    _selectIndex = ((KxMenuItem*)sender).index;
    [_btnValideTime setTitle:_menuItemArray[_selectIndex] forState: UIControlStateNormal];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)onClickImg
{
    if (_solidStyle == NO)
    {
        return;
    }
    
    
    UIAlertView*alert = [[UIAlertView alloc]initWithTitle:nil
                                                  message:nil
                                                 delegate:self
                                        cancelButtonTitle:@"取消"
                                        otherButtonTitles:@"拍照", @"从手机相册选择",nil];
    
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self onBtnClickCamera];
    }
    
    if (buttonIndex == 2)
    {
        [self onBtnClickLocal];
    }
}

-(void)imagePickerController: (UIImagePickerController *)picker
didFinishPickingMediaWithInfo: (NSDictionary *)info
{
    UIImage* srcImage = [info objectForKey: @"UIImagePickerControllerEditedImage"];
    
    CGSize dstSize = {320, 320};
    UIGraphicsBeginImageContext(dstSize);
    [srcImage drawInRect:CGRectMake(0, 0, dstSize.width, dstSize.height)];
    UIImage *dstImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *picData = UIImageJPEGRepresentation(dstImage, 0.8);
    
    [[NSUserDefaults standardUserDefaults] setObject:picData forKey:@"userPortrait"];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"处理中...";
    
    [[HttpService getInstance] uploadUserPortrait:^(NSString *url) {
        
        if (url != nil) {
            _portraitUrl = url;
            [_portraitView setImage:dstImage];
        }
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

-(void) imagePickerControllerDidCancel: (UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)onBtnClickLocal
{
    UIImagePickerController *imagePickerLocal = [[UIImagePickerController alloc] init];
    imagePickerLocal.delegate = self;
    imagePickerLocal.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerLocal.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    imagePickerLocal.allowsEditing = YES;
    
    [self presentViewController:imagePickerLocal animated:YES completion:nil];
}

-(void)onBtnClickCamera
{
    UIImagePickerController *imagePickerCamera = [[UIImagePickerController alloc] init];
    imagePickerCamera.delegate = self;
    imagePickerCamera.sourceType =  UIImagePickerControllerSourceTypeCamera;
    imagePickerCamera.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    imagePickerCamera.allowsEditing = YES;
    
    [self presentViewController:imagePickerCamera animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    NSLog(@"userInfoViewController dealoc");
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
