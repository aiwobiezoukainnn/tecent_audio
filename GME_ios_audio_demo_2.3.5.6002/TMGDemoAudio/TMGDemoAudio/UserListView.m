//
//  UserListView.m
//  TMGDemoAudio
//
//  Created by signcheng on 2018/12/16.
//  Copyright © 2018 tobinchen. All rights reserved.
//

#import "UserListView.h"
#import "UserlistButton.h"

@implementation UserListItem
@synthesize UserID;
-(instancetype)init
{
    self = [super init];
    if (self) {
        _isSheilded = NO;
        _isSpeakIng = NO;
        self.UserID = @"";
    }
    return self;
}

@end

@implementation UserListView
@synthesize dataSource;

-(void)upDate
{
    for (int i = 0; i<10; i++)
    {
        UserlistButton *_uesrListButton = [self viewWithTag:i+100];
        _uesrListButton.hidden = YES;
    }
   NSArray *userArray = [dataSource allKeys];
    for (int i = 0; i<userArray.count; i++) {
        NSString *_userid = [userArray objectAtIndex:i];
        UserListItem *_item = [dataSource objectForKey:_userid];
        UserlistButton *_uesrListButton = [self viewWithTag:i+100];
        _uesrListButton.hidden = NO;
        [_uesrListButton setSheildStates:_item.isSheilded userID:_item.UserID isSpeaking:_item.isSpeakIng];
    }
}

- (instancetype)initWithCGPoint:(CGPoint)poit
{
    self =[super initWithFrame:CGRectMake(poit.x, poit.y, [UIScreen mainScreen].bounds.size.width, 200)];
    if (self) {
        for (int i = 0; i<5; i++)
        {
            UserlistButton *temple = [[UserlistButton alloc] initWithFrame:CGRectMake(0, i*40, 160, 31)];
            temple.hidden = YES;
            temple.tag = i*2+100;
            temple._fatherListView = self;
            [self addSubview:temple];
            
            temple = [[UserlistButton alloc] initWithFrame:CGRectMake(160, i*40, 160, 31)];
            temple.tag = i*2+1+100;
            temple.hidden = YES;
            temple._fatherListView = self;
            [self addSubview:temple];
        }
        self.backgroundColor = [UIColor grayColor];
    }
    return self;
}
@end
