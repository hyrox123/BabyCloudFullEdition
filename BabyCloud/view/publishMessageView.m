//
//  publishMessageView.m
//  YSTParentClient
//
//  Created by apple on 15/3/17.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "publishMessageView.h"
#import "HttpService.h"
#import "ProtoType.h"

@interface publishMessageView()
@property(nonatomic) UIButton *addImageBtn;
@property(nonatomic) UIImageView *imageView1, *imageView2;
@property(nonatomic) UIView *horizontalMark1, *horizontalMark2, *horizontalMark3;
@property(nonatomic) UILabel *locationLable, *whoWatchLable;
@property(nonatomic) NSMutableArray *viewArray;
@end

@implementation publishMessageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (NSMutableArray*)imageArray
{
    if (_imageArray == nil) {
        _imageArray = [NSMutableArray new];
    }
    
    return _imageArray;
}

- (NSMutableArray*)viewArray
{
    if (_viewArray == nil) {
        _viewArray = [NSMutableArray new];
    }
    
    return _viewArray;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        
        _textMessageView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, frame.size.width-20, 100)];
        _textMessageView.layer.borderWidth = 0.5;
        _textMessageView.layer.masksToBounds = YES;
        _textMessageView.scrollEnabled = YES;
        _textMessageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _textMessageView.textColor = [UIColor blackColor];
        _textMessageView.backgroundColor = [UIColor whiteColor];
        _textMessageView.layer.borderWidth = 0;
        _textMessageView.font = [UIFont systemFontOfSize:16];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineHeightMultiple = 18.f;
        paragraphStyle.maximumLineHeight = 21.f;
        paragraphStyle.minimumLineHeight = 21.f;
        paragraphStyle.alignment = NSTextAlignmentJustified;
        
        NSDictionary *attributes = @{ NSFontAttributeName:[UIFont systemFontOfSize:16], NSParagraphStyleAttributeName:paragraphStyle, NSForegroundColorAttributeName:[UIColor colorWithRed:76./255. green:75./255. blue:71./255. alpha:1]
                                      };
        _textMessageView.attributedText = [[NSAttributedString alloc] initWithString:@"" attributes:attributes];
        
        _placeholderLabel = [[UILabel alloc] init];
        _placeholderLabel.frame = CGRectMake(13, 15, 200, 20);
        _placeholderLabel.text = @"请输入您要发布的信息";
        _placeholderLabel.enabled = NO;
        _placeholderLabel.backgroundColor = [UIColor clearColor];
        _placeholderLabel.textColor = [UIColor lightGrayColor];
        
        _addImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addImageBtn setImage:[UIImage imageNamed:@"morenjia_.png"] forState:UIControlStateNormal];
        [_addImageBtn setImage:[UIImage imageNamed:@"morenjia_2.png"] forState:UIControlStateSelected];
        [_addImageBtn addTarget:self action:@selector(onAddImage) forControlEvents:UIControlEventTouchUpInside];
        
        _horizontalMark1 = [[UIView alloc] init];
        _horizontalMark1.backgroundColor = [UIColor lightGrayColor];
        
        [self addSubview:_textMessageView];
        [self addSubview:_addImageBtn];
        [self addSubview:_horizontalMark1];
        [self addSubview:_placeholderLabel];
        
        [self refreshLayout];
    }
    
    return self;
}

- (void)onAddImage
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                      message:nil
                                     delegate:self
                            cancelButtonTitle:@"取消"
                            otherButtonTitles:@"拍照", @"从手机相册选择", @"使用模板", nil];
    
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        if ([self.delegate respondsToSelector:@selector(onCameraPic)]) {
            [self.delegate onCameraPic];
        }
    }
    
    if (buttonIndex == 2) {
        
        if ([self.delegate respondsToSelector:@selector(onLocalPic)]) {
            [self.delegate onLocalPic];
        }
    }
    
    if (buttonIndex == 3) {
        
        if ([self.delegate respondsToSelector:@selector(onTemplet)]) {
            [self.delegate onTemplet];
        }
    }
}

-(int)layoutPicture:(int)originY pictures:(NSMutableArray*)pictureList
{
    
    for (int i = 0; i < [self.viewArray count]; i++) {
        
        UIImageView *tmp = (UIImageView*)[self.viewArray objectAtIndex:i];
        
        if (tmp)
        {
            [tmp removeFromSuperview];
            tmp = nil;
        }
    }
    
    int picW = (self.frame.size.width-60)/3;
    
    if ([pictureList count] == 0) {
        
        [self.addImageBtn setFrame:CGRectMake(15, originY, picW, picW)];
        return (originY+picW+5);
    }
    
    CGRect imgRect = CGRectMake(0, 0, picW, picW);
    int originX = 100;
    
    for (int i = 0; i < [pictureList count]+1; i++) {
        
        if (i > 0 && (i%3) == 0)
        {
            originY += imgRect.size.height + 5;
            originX = 15;
        }
        else
        {
            originX = 15 + (i%3)*imgRect.size.width + (i%3)*15;
        }
        
        CGRect rect = imgRect;
        rect.origin.x = originX;
        rect.origin.y = originY;
        
        if (i < [pictureList count]) {
            
            UIImageView *imageItem = [[UIImageView alloc] initWithFrame:rect];
            imageItem.backgroundColor = [UIColor lightGrayColor];
            imageItem.userInteractionEnabled = YES;
            imageItem.tag = 0x100+i;
            [self addSubview:imageItem];
            [self.viewArray addObject:imageItem];
            
            UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapImage:)];
            [imageItem addGestureRecognizer:singleTapGesture];
            
            imageItem.image = [pictureList objectAtIndex:i];
        }
        else
        {
            [self.addImageBtn setFrame:rect];
        }
    }
    
    return (originY+imgRect.size.height+5);
}

-(void)refreshLayout
{
    int itemHeight = [self layoutPicture:120 pictures:self.imageArray];
    
    [self.horizontalMark1 setFrame:CGRectMake(5, itemHeight, self.frame.size.width-10, 0.5)];
    [self.imageView1 setFrame:CGRectMake(10, itemHeight+15, 30, 30)];
    [self.locationLable setFrame:CGRectMake(60, itemHeight+20, 150, 20)];
    [self.horizontalMark2 setFrame:CGRectMake(5, itemHeight+60, self.frame.size.width-10, 0.5)];
    [self.imageView2 setFrame:CGRectMake(10, itemHeight+75, 30, 30)];
    [self.whoWatchLable setFrame:CGRectMake(60, itemHeight+80, 150, 20)];
    [self.horizontalMark3 setFrame:CGRectMake(5, itemHeight+120, self.frame.size.width-10, 0.5)];
}

- (void)onTapImage:(UITapGestureRecognizer*)gesture
{
    UIView *temView = [gesture view];
    NSInteger index = temView.tag-0x100;
    
    if ([self.delegate respondsToSelector:@selector(onTapImage:)]) {
        [self.delegate onTapImage:index];
    }
    
    [self refreshLayout];
}

@end
