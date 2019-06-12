//
//  UserListView.h
//  TMGDemoAudio
//
//  Created by signcheng on 2018/12/16.
//  Copyright © 2018 tobinchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#define USERDEFAULT_USERLIST @"NSUserDefaults_USEERLIST"
NS_ASSUME_NONNULL_BEGIN



@interface UserListItem : NSObject
@property(nonatomic,assign) BOOL isSheilded;
@property(nonatomic,assign) BOOL isSpeakIng;
@property(nonatomic,strong) NSString *UserID;

@end

@interface UserListView : UIView
@property (nonatomic,assign) NSMutableDictionary *dataSource;
- (instancetype)initWithCGPoint:(CGPoint)poit;
-(void)upDate;
@end

NS_ASSUME_NONNULL_END
