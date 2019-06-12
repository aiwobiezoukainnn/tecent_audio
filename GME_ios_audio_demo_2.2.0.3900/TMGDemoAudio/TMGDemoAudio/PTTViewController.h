//
//  PTTViewController.h
//  TMGDemoAudio
//
//  Created by signcheng on 2018/6/20.
//  Copyright © 2018年 tobinchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTTViewController : UIViewController<UITextFieldDelegate>
{

    NSArray *_ContainArray;
    NSString *recordfilePath;
    NSString *donwLoadUrlPath;
    NSString *donwLoadLocalPath;
    
    
}
@property(nonatomic,strong)NSString *_appid;
@property(nonatomic,strong)NSString *_openId;
@end
