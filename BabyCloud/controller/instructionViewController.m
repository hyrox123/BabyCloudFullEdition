//
//  instructionViewController.m
//  YSTParentClient
//
//  Created by apple on 14-11-21.
//  Copyright (c) 2014年 jason. All rights reserved.
//

#import "instructionViewController.h"
#import "UMSocialControllerService.h"
#import "UMSocial.h"
#import "UMSocialScreenShoter.h"

@interface instructionViewController()<UMSocialUIDelegate>
@end

@implementation instructionViewController

- (UIImage*)closeButtonImageWithSize:(CGSize)size strokeColor:(UIColor*)strokeColor fillColor:(UIColor*)fillColor shadow:(BOOL)hasShadow
{
    UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, CGRectMake(0, 0, size.width, size.height));
    
    float cx = size.width/2;
    float cy = size.height/2;
    
    float radius = size.width > size.height ? size.height/2 : size.height/2;
    radius -= 4;
    
    CGRect rectEllipse = CGRectMake(cx - radius, cy - radius, radius*2, radius*2);
    
    if (fillColor) {
        [fillColor setFill];
        CGContextFillEllipseInRect(context, rectEllipse);
    }
    
    if (strokeColor) {
        [strokeColor setStroke];
        CGContextSetLineWidth(context, 3.0);
        CGFloat lineLength  = radius/2.5;
        CGContextMoveToPoint(context, cx-lineLength, cy-lineLength);
        CGContextAddLineToPoint(context, cx+lineLength, cy+lineLength);
        CGContextDrawPath(context, kCGPathFillStroke);
        
        CGContextMoveToPoint(context, cx+lineLength, cy-lineLength);
        CGContextAddLineToPoint(context, cx-lineLength, cy+lineLength);
        CGContextDrawPath(context, kCGPathFillStroke);
    }
    
    if (hasShadow) {
        CGContextSetShadow(context, CGSizeMake(3, 3), 2);
    }
    
    if (strokeColor) {
        CGContextStrokeEllipseInRect(context, rectEllipse);
    }
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(void)onBtnClose:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(onCloseInstruction)]) {
        [self.delegate onCloseInstruction];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect clientRect = [ UIScreen mainScreen ].bounds;
    UIView *canvasView = [[UIView alloc] initWithFrame:CGRectMake((clientRect.size.width-300)/2, (clientRect.size.height-240)/2, 300, 240)];
    canvasView.layer.cornerRadius = 8;
    canvasView.backgroundColor = [UIColor whiteColor];
    
    UIImageView* logoImgBk = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"scan@2x" ofType:@"png"]]];
    [logoImgBk setFrame:CGRectMake(100, 20, 100, 100)];
    
    UITextView *textArea = [[UITextView alloc] initWithFrame:CGRectMake(10, 125, 280, 60)];
    
    textArea.layer.masksToBounds = YES;
    textArea.scrollEnabled = YES;
    textArea.editable = NO;
    textArea.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    textArea.textColor = [UIColor blackColor];
    textArea.backgroundColor = [UIColor whiteColor];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineHeightMultiple = 15.f;
    paragraphStyle.maximumLineHeight = 20.f;
    paragraphStyle.minimumLineHeight = 20.f;
    paragraphStyle.alignment = NSTextAlignmentJustified;
    
    NSDictionary *attributes = @{ NSFontAttributeName:[UIFont systemFontOfSize:14], NSParagraphStyleAttributeName:paragraphStyle, NSForegroundColorAttributeName:[UIColor colorWithRed:76./255. green:75./255. blue:71./255. alpha:1]
                                  };
    textArea.attributedText = [[NSAttributedString alloc]initWithString:@"本应用是集视频服务、资讯服务、位置服务、社交服务为一体的幼教综合沟通平台!" attributes:attributes];
    
    NSString *versionStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    UILabel *version = [[UILabel alloc] initWithFrame:CGRectMake(200, 185, 80, 20)];
    version.font = [UIFont systemFontOfSize:14];
    version.text = [NSString stringWithFormat:@"版本:v%@", versionStr];
    
    UIButton *shareUrl = [UIButton buttonWithType:UIButtonTypeCustom];
    shareUrl.frame = CGRectMake(15, 185, 150, 20);
    shareUrl.showsTouchWhenHighlighted = YES;
    shareUrl.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    shareUrl.titleLabel.font = [UIFont systemFontOfSize:14];
    shareUrl.backgroundColor = [UIColor clearColor];
    [shareUrl setTitleColor:[UIColor colorWithRed:0.121f green:0.376f blue:1.0f alpha:1] forState:UIControlStateNormal];
    [shareUrl setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
    [shareUrl setTitle: @"分享到社交圈子" forState: UIControlStateNormal];
    [shareUrl addTarget:self action:@selector(onShare) forControlEvents:UIControlEventTouchUpInside];
   
    UIImage *btnImg = [self closeButtonImageWithSize:CGSizeMake(30, 30)
                                                  strokeColor:[UIColor whiteColor]
                                                    fillColor:[UIColor blackColor]
                                                       shadow:NO];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setImage: btnImg forState:UIControlStateNormal];
    closeButton.frame = CGRectMake(0, 0, 30, 30);
    closeButton.showsTouchWhenHighlighted = YES;
    closeButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [closeButton addTarget:self action:@selector(onBtnClose:) forControlEvents:UIControlEventTouchUpInside];
    closeButton.frame = CGRectMake(282+(clientRect.size.width-300)/2,
                                    (clientRect.size.height-240)/2-10,
                                    30,
                                    30);
    
    closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
   
    [canvasView addSubview:logoImgBk];
    [canvasView addSubview:textArea];
    [canvasView addSubview:version];
    [canvasView addSubview:shareUrl];
    [self.view addSubview:canvasView];
    [self.view addSubview:closeButton];
}

- (void)onShare
{
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = @"http://mp.weixin.qq.com/s?__biz=MzA5MDYwODk5OA==&mid=208094697&idx=1&sn=b551cc8b7eeb49d87fdb3f8ae891aa5d&scene=18#wechat_redirect";
    
    [UMSocialData defaultData].extConfig.wechatSessionData.url = @"http://mp.weixin.qq.com/s?__biz=MzA5MDYwODk5OA==&mid=208094697&idx=1&sn=b551cc8b7eeb49d87fdb3f8ae891aa5d&scene=18#wechat_redirect";
    
    [UMSocialData defaultData].extConfig.qqData.url = @"http://mp.weixin.qq.com/s?__biz=MzA5MDYwODk5OA==&mid=208094697&idx=1&sn=b551cc8b7eeb49d87fdb3f8ae891aa5d&scene=18#wechat_redirect";
    
    
    [UMSocialData defaultData].extConfig.title = @"你不知道的幼视通";
    [UMSocialData defaultData].extConfig.wechatTimelineData.shareText = @"幼视通是一个家园共育的幼教综合沟通平台,点击下载APP";
    [UMSocialData defaultData].extConfig.wechatSessionData.shareText = @"幼视通是一个家园共育的幼教综合沟通平台,点击下载APP";
    [UMSocialData defaultData].extConfig.qqData.shareText = @"幼视通是一个家园共育的幼教综合沟通平台,点击下载APP";
    
    NSArray *mediaArray = [NSArray arrayWithObjects:UMShareToWechatSession, UMShareToWechatTimeline, UMShareToQQ, UMShareToTencent, nil];
    
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"55306795fd98c58930000c67"
                                      shareText:nil
                                     shareImage:[UIImage imageNamed:@"morentouxing1"]
                                shareToSnsNames:mediaArray
                                       delegate:self];
}


-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    NSLog(@"didFinishGetUMSocialDataInViewController with response is %@", response);
    
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
    }
}

- (void)dealloc
{
    NSLog(@"instructionViewController dealloc");
}

@end
