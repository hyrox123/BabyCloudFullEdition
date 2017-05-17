//
//  publishCatgory.m
//  YSTParentClient
//
//  Created by apple on 15/9/7.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "publishCatgory.h"
#import "HttpService.h"
#import "ProtoType.h"
#import "MBProgressHUD.h"
#import "utilityFunction.h"

static publicCatgorytBlock navtiveBlock;

@interface publishCatgory()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,weak) NSMutableArray *imagesArray;
@property(nonatomic) NSString *textContent, *serverUrl, *messageType;
@property(nonatomic) NSMutableDictionary *stateDict;
@property(nonatomic) UITableView *classTable;
@property(nonatomic) BOOL hasSelected;
@end

@implementation publishCatgory

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (NSMutableDictionary*)stateDict
{
    if (!_stateDict) {
        _stateDict = [NSMutableDictionary new];
    }
    
    return _stateDict;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f];
        
        CGRect ClientRect;
        ClientRect.size.width = CGRectGetWidth(frame)-40;
        ClientRect.size.height = 250;
        ClientRect.origin.x = 20;
        ClientRect.origin.y = (frame.size.height-ClientRect.size.height)/2-50;
        
        UIView *pannel = [[UIView alloc] initWithFrame:ClientRect];
        [self addSubview:pannel];
        
        pannel.backgroundColor = [UIColor whiteColor];
        pannel.layer.cornerRadius = 4;
        pannel.layer.borderWidth = 0.5;
        pannel.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth(pannel.frame), 22)];
        [pannel addSubview:title];
        
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont boldSystemFontOfSize:20];
        title.textColor = [UIColor colorWithRed:0.1765f green:0.5765f blue:0.8627f alpha:1];
        title.text = @"发送到";
        
        _classTable = [[UITableView alloc] initWithFrame:CGRectMake(10, 40, CGRectGetWidth(pannel.frame)-20, 120) style:UITableViewStylePlain];
        [pannel addSubview:_classTable];
        
        _classTable.layer.cornerRadius = 6;
        _classTable.layer.masksToBounds = YES;
        _classTable.layer.borderWidth = 0.5;
        _classTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _classTable.delegate = self;
        _classTable.dataSource = self;
        
        UIButton *selectAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [pannel addSubview:selectAllBtn];
        
        selectAllBtn.layer.cornerRadius = 11;
        selectAllBtn.layer.masksToBounds = YES;
        selectAllBtn.frame = CGRectMake(CGRectGetWidth(pannel.frame)-70, 170, 60, 22);
        selectAllBtn.showsTouchWhenHighlighted = YES;
        selectAllBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        selectAllBtn.titleLabel.textColor = [UIColor whiteColor];
        selectAllBtn.backgroundColor = [UIColor colorWithRed:0.3529f green:0.7569f blue:0.7490f alpha:1.0f];
        [selectAllBtn setTitle: @"全 选" forState: UIControlStateNormal];
        [selectAllBtn addTarget:self action:@selector(onBtnSelectAll) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [pannel addSubview:confirmBtn];
        
        confirmBtn.frame = CGRectMake(10, CGRectGetHeight(ClientRect)-40, 100, 30);
        confirmBtn.layer.cornerRadius = 3;
        confirmBtn.layer.borderWidth = 0.5;
        confirmBtn.layer.borderColor = [UIColor blueColor].CGColor;
        confirmBtn.showsTouchWhenHighlighted = YES;
        confirmBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        confirmBtn.backgroundColor = [UIColor colorWithRed:0.1765f green:0.5765f blue:0.8627f alpha:1];
        [confirmBtn setTitle: @"确定" forState: UIControlStateNormal];
        [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [confirmBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
        [confirmBtn addTarget:self action:@selector(onBtnConfirm) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [pannel addSubview:cancelBtn];
        
        cancelBtn.frame = CGRectMake(CGRectGetWidth(ClientRect)-110, CGRectGetHeight(ClientRect)-40, 100, 30);
        cancelBtn.layer.cornerRadius = 3;
        cancelBtn.layer.borderWidth = 0.5;
        cancelBtn.layer.borderColor = [UIColor blackColor].CGColor;
        cancelBtn.backgroundColor = [UIColor lightGrayColor];
        cancelBtn.showsTouchWhenHighlighted = YES;
        cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cancelBtn setTitle: @"取消" forState: UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(onCancel) forControlEvents:UIControlEventTouchUpInside];
        
        for (int i = 0; i < [HttpService getInstance].userExtentInfo.babyArray.count; i++) {
            [self.stateDict setObject:@"0" forKey:[NSString stringWithFormat:@"%d", i]];
        }
    }
    
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [HttpService getInstance].userExtentInfo.babyArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"catgoryTableCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:@"catgoryTableCell"];
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.text = ((BabyInfo*)[HttpService getInstance].userExtentInfo.babyArray[indexPath.row]).className;
    
    NSString *state = [self.stateDict objectForKey:[NSString stringWithFormat:@"%ld", (long)[indexPath row]]];
    
    if ([state isEqualToString:@"1"]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *state = [self.stateDict objectForKey:[NSString stringWithFormat:@"%ld", (long)[indexPath row]]];
    
    if ([state isEqualToString:@"1"]) {
        [self.stateDict setObject:@"0" forKey:[NSString stringWithFormat:@"%ld", (long)[indexPath row]]];
    }
    else
    {
        [self.stateDict setObject:@"1" forKey:[NSString stringWithFormat:@"%ld", (long)[indexPath row]]];
    }
    
    [tableView reloadData];
}

- (void)onCancel
{
    [self removeFromSuperview];
}

- (void)onBtnConfirm
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *destDateString = [dateFormatter stringFromDate:[NSDate date]];
    
    NewsItem *item = [NewsItem new];
    item.textContent = _textContent;
    item.imageArray = _imagesArray;
    item.updateTime = destDateString;
    item.serverUrl = _serverUrl;
    item.picHashCode = @"";
    item.targetId = @"";
    item.open = [[NSUserDefaults standardUserDefaults] boolForKey:@"publicTopic"];
    
    for (int i = 0; i < [HttpService getInstance].userExtentInfo.babyArray.count; i++) {
        
        NSString *state = [self.stateDict objectForKey:[NSString stringWithFormat:@"%d", i]];
        
        if ([state isEqualToString:@"1"])
        {
            if (item.targetId.length > 0) {
                item.targetId = [item.targetId stringByAppendingString:[NSString stringWithFormat:@",%@", ((BabyInfo*)[HttpService getInstance].userExtentInfo.babyArray[i]).classId]];
            }
            else
            {
                item.targetId = ((BabyInfo*)[HttpService getInstance].userExtentInfo.babyArray[i]).classId;
            }
        }
    }
    
    if (item.targetId.length == 0) {
        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"提示" message:@"还没有选择班级" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertV show];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"处理中...";
    
    [[HttpService getInstance] publishNewsMessage:item messageType:_messageType andBlock:^(int retValue) {
        
        [MBProgressHUD hideHUDForView:self animated:YES];
        
        if (retValue != 200)
        {
            NSString *tipMessage = [utilityFunction getErrorString:retValue];
            UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"提示" message:tipMessage delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertV show];
        }
        else
        {
            [self removeFromSuperview];
            navtiveBlock();
        }
    }];
}

- (void)onBtnSelectAll
{
    _hasSelected = !_hasSelected;
    
    for (int i = 0; i < [HttpService getInstance].userExtentInfo.babyArray.count; i++) {
        
        if (_hasSelected)
        {
            [self.stateDict setObject:@"1" forKey:[NSString stringWithFormat:@"%d", i]];
        }
        else
        {
            [self.stateDict setObject:@"0" forKey:[NSString stringWithFormat:@"%d", i]];
        }
    }
    
    [_classTable reloadData];
}

+(void)showPublishCatgory:(UIView*)parent content:(NSString*)content images:(NSMutableArray*)imageArray serverUrl:(NSString*)url messageType:(NSString*)type andBlock:(publicCatgorytBlock)block
{
    publishCatgory *tipV = [[publishCatgory alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [parent addSubview:tipV];
    
    tipV.textContent = content;
    tipV.imagesArray = imageArray;
    tipV.serverUrl = url;
    tipV.messageType = type;
    navtiveBlock = block;
}

+(void)hidePublishCatgory:(UIView*)parent
{
    publishCatgory *tipV = nil;
    Class publishCatgoryClass = [publishCatgory class];
    NSEnumerator *subviewsEnum = [parent.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:publishCatgoryClass]) {
            tipV = (publishCatgory *)subview;
            break;
        }
    }
    
    if (tipV) {
        [tipV removeFromSuperview];
    }
}

@end
