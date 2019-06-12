//
//  runningTipsView.m
//  QAVSDKDemo
//
//  Created by xianhuanlin on 15/5/21.
//  Copyright (c) 2015年 TOBINCHEN. All rights reserved.
//

#import "RunningTipsView.h"

@implementation RunningTipsView
-(id)init{
    self = [super init];
    if(self)
    {
        _plabel = [[UILabel alloc]init];
        _plabel.numberOfLines = 0;
        _plabel.textColor = [UIColor blackColor];
        _plabel.font = [UIFont fontWithName:@"Helvetica" size:14];
        _plabel.textAlignment = NSTextAlignmentLeft;
        _plabel.backgroundColor = [UIColor clearColor];
        _plabel.accessibilityIdentifier = @"QAVSDKDemoTips";
        self.accessibilityIdentifier = @"QAVSDKDemoRunningTipsView";
        [self addSubview:_plabel];
        self.userInteractionEnabled = NO;
    }
    return self;
}

-(void)ShowInParent:(NSString*)msg parentView:(UIScrollView*)parent{
    if (self.superview == nil)
    {
        [parent addSubview:self];
        _parent = [parent retain];
    }
    
    CGRect appRect = [UIScreen mainScreen].applicationFrame;
    //  CGSize size = [msg sizeWithFont:_plabel.font constrainedToSize:appRect.size lineBreakMode:UILineBreakModeWordWrap];NSLineBreakModeWordWrap
    CGSize size = [msg sizeWithFont:_plabel.font constrainedToSize:CGSizeMake(appRect.size.width,MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
   

    [_plabel setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, size.height)];
    _plabel.text = msg;
    [parent setContentSize:CGSizeMake(size.width, size.height)];
}

+(void)Show:(NSString*)msg parentView:(UIScrollView*)parent {
    [[RunningTipsView Shared] ShowInParent:msg parentView:parent];
}

int count = 0;
clock_t g_lasttime = 0;

-(void)Actiondo:(id)sender{
    
   // [self hide];
}
+(RunningTipsView*)Shared{
    static RunningTipsView* pinit = nil;
    if (pinit == nil){
        pinit = [[RunningTipsView alloc]init];
    }
    return pinit;
}

+(void)hide; {
    [[RunningTipsView Shared]  removeFromSuperview];
    
}
@end
