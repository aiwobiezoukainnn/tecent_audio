//
//  UserlistButton.m
//  TMGDemoAudio
//
//  Created by signcheng on 2018/12/16.
//  Copyright © 2018 tobinchen. All rights reserved.
//

#import "UserlistButton.h"
#import "GMESDK/TMGEngine.h"
@implementation UserlistButton

- (instancetype)initWithFrame:(CGRect)frame
{
   self =[super initWithFrame:frame];
    if (self) {
        
        _sheildSwitch  = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 51, 31)];
        [_sheildSwitch addTarget:self action:@selector(sheildUser:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_sheildSwitch];
        
        _OpenidLabel  = [[UILabel alloc] initWithFrame:CGRectMake(51, 0, 65, 31)];
        _OpenidLabel.text = @"";
        _OpenidLabel.font = [UIFont systemFontOfSize:12];
        _OpenidLabel.textColor = [UIColor blackColor];
        [self addSubview:_OpenidLabel];
        
        _StateLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, 35, 31)];
        _StateLabel.text = @"";
        _StateLabel.font = [UIFont systemFontOfSize:10];
        _StateLabel.textColor = [UIColor blackColor];
        [self addSubview:_StateLabel];
        self._fatherListView = NULL;
        
    }
    
    return self;
}

-(void)setSheildStates:(BOOL)isSheild userID:(NSString *)userid isSpeaking:(BOOL)isSpeaking
{
    [_sheildSwitch setOn:isSheild animated:NO];
    [_OpenidLabel setText:userid];
    [_StateLabel setText:isSpeaking?@"说话中":@""];
}

- (void)sheildUser:(UISwitch*)sender
{
    if (sender.on) {
        [[[ITMGContext GetInstance] GetAudioCtrl] AddAudioBlackList:_OpenidLabel.text];
    }
    else
    {
        [[[ITMGContext GetInstance] GetAudioCtrl] RemoveAudioBlackList:_OpenidLabel.text];
    }
    
    NSMutableDictionary *_templeDic = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULT_USERLIST];
    NSMutableDictionary *sheildDic = [[NSMutableDictionary alloc] initWithDictionary:_templeDic];
    [sheildDic setValue:sender.on?@"YES":@"NO" forKey:_OpenidLabel.text];
    [[NSUserDefaults standardUserDefaults] setValue:sheildDic forKey:USERDEFAULT_USERLIST];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (self._fatherListView)
    {
        UserListItem *_templeItem =  [self._fatherListView.dataSource objectForKey:_OpenidLabel.text];
        if (_templeItem) {
            _templeItem.isSheilded = sender.on;
        }
    }
}
@end
