//
//  runningTipsView.h
//  QAVSDKDemo
//
//  Created by xianhuanlin on 15/5/21.
//  Copyright (c) 2015年 TOBINCHEN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RunningTipsView : UIView{

    UILabel*_plabel;
//    UIView*_parent;
    UIScrollView *_parent;
   
}

+(RunningTipsView*)Shared;
+(void)Show:(NSString*)msg parentView:(UIScrollView*)parent;
+(void)hide;

-(id)init;
-(void)ShowInParent:(NSString*)msg parentView:(UIScrollView*)parent;

@end
