//
//  DeviceListTableViewCell.m
//  YSTParentClient
//
//  Created by apple on 15/8/18.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "DeviceListTableViewCell.h"
#import "ProtoType.h"

@implementation DeviceListTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier array:(NSMutableArray*)itemArray
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self initSubview:itemArray];
        // Initialization code
    }
    
    return self;
}

- (void)initSubview:(NSArray*)itemArray
{
    CGRect itemRect, clientRect = [ UIScreen mainScreen ].bounds;
    itemRect.size.width = (clientRect.size.width-30)/2;
    itemRect.size.height = itemRect.size.width*2/3+25;
    
    int posX, posY;
    
    for (int i = 0; i < itemArray.count; i++) {
        
        posX = 10+(i%2)*itemRect.size.width+(i%2)*10;
        posY = 10+(i/2)*itemRect.size.height+(i/2)*10;
        
        XDeviceNode *node = itemArray[i];
        
        UIImageView *imagV = [[UIImageView alloc] initWithFrame:CGRectMake(posX, posY, itemRect.size.width, itemRect.size.height-25)];
        [self.contentView addSubview:imagV];
        
        NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:node.deviceId];
        
        if (imageData) {
            imagV.image = [UIImage imageWithData:imageData];
        }
        else
        {
            imagV.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"deviceBK@2x" ofType:@"png"]];
        }
        
        UIView *pannel = [[UIView alloc] initWithFrame:CGRectMake(posX, posY+itemRect.size.height-50, itemRect.size.width, 25)];
        [self.contentView addSubview:pannel];
        
        if (node.offline == 1) {
            UIImageView *offlineV = [[UIImageView alloc] initWithFrame:CGRectMake(posX+itemRect.size.width-20, posY+5, 16, 16)];
            [self.contentView addSubview:offlineV];
            offlineV.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"deviceOffline@2x" ofType:@"png"]];
        }
        
        imagV.userInteractionEnabled = YES;
        imagV.tag = 0x1000+i;
        UITapGestureRecognizer *singleTapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapImage:)];
        [imagV addGestureRecognizer:singleTapGesture1];
        
        pannel.userInteractionEnabled = YES;
        pannel.tag = 0x1000+i;
        UITapGestureRecognizer *singleTapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapImage:)];
        [imagV addGestureRecognizer:singleTapGesture2];
        
        pannel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        
        UIImageView *timeLogoV = [[UIImageView alloc] initWithFrame:CGRectMake(3, 5, 15, 15)];
        [pannel addSubview:timeLogoV];
        
        timeLogoV.image =  [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"shijian@2x" ofType:@"png"]];
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 3, itemRect.size.width-20, 20)];
        [pannel addSubview:timeLabel];
        
        timeLabel.font = [UIFont systemFontOfSize:11];
        timeLabel.textColor = [UIColor whiteColor];
        
        if (node.validWatchTime.length > 0) {
            timeLabel.text = [NSString stringWithFormat:@"开放时间:(%@)", node.validWatchTime];
        }
        else
        {
            timeLabel.text = @"开放时间:(全天)";
        }
        
        UILabel *deviceNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(posX, posY+itemRect.size.height-20, itemRect.size.width, 20)];
        [self.contentView addSubview:deviceNameLabel];
        deviceNameLabel.font = [UIFont boldSystemFontOfSize:15];
        deviceNameLabel.text = node.deviceName;
        deviceNameLabel.textAlignment = NSTextAlignmentCenter;
    }
}

+ (float)calculateCellHeight:(NSMutableArray*)itemArray
{
    if (itemArray.count == 0) {
        return 40;
    }
    
    CGRect itemRect, clientRect = [ UIScreen mainScreen ].bounds;
    itemRect.size.width = (clientRect.size.width-30)/2;
    itemRect.size.height = itemRect.size.width*2/3+25;
    
    float additionHeight = 0;
    
    for (int i = 0; i < itemArray.count; i++) {
        
        if (i % 2 == 0 && i > 0)
        {
            additionHeight += 10;
        }
    }
    
    return ((itemArray.count/2)*itemRect.size.height+additionHeight+(itemArray.count%2)*itemRect.size.height+20);
}

- (void)onTapImage:(UITapGestureRecognizer*)gesture
{
    UIView *tmpView = [gesture view];
    
    if (tmpView != nil) {
        NSInteger index = tmpView.tag-0x1000;
        
        if ([self.delegate respondsToSelector:@selector(onClickVideo:)]) {
            [self.delegate onClickVideo:index];
        }
    }
}

@end
