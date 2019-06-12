//
//  DispatchCenter.h
//  TMGDemoAudio
//
//  Created by signcheng on 2018/7/13.
//  Copyright © 2018年 tobinchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMESDK/TMGEngine.h"
@interface DispatchCenter : NSObject<ITMGDelegate>
{
    NSMutableArray *_DelegateArray;
}

+(instancetype)getInstance;
-(void)addDelegate:(NSObject<ITMGDelegate>*) delegate;
-(void)removeDelegate:(NSObject<ITMGDelegate>*) delegate;

@end
