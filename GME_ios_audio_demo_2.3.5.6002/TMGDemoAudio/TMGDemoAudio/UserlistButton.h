//
//  UserlistButton.h
//  TMGDemoAudio
//
//  Created by signcheng on 2018/12/16.
//  Copyright © 2018 tobinchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserListView.h"

@interface UserlistButton : UIView
{
    UISwitch  *_sheildSwitch;
    UILabel   *_OpenidLabel;
    UILabel   *_StateLabel;
}
@property(nonatomic,assign) UserListView *_fatherListView;
-(void)setSheildStates:(BOOL)isSheild userID:(NSString *)userid isSpeaking:(BOOL)isSpeaking;
- (instancetype)initWithFrame:(CGRect)frame;

@end


