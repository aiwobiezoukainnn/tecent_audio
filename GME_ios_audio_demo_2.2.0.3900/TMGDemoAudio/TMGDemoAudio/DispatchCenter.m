//
//  DispatchCenter.m
//  TMGDemoAudio
//
//  Created by signcheng on 2018/7/13.
//  Copyright © 2018年 tobinchen. All rights reserved.
//

#import "DispatchCenter.h"

@implementation DispatchCenter
static DispatchCenter *dispatchCenter;
+(instancetype)getInstance
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        dispatchCenter = [[DispatchCenter alloc] init];
    });
    
    return dispatchCenter;
}

-(void)addDelegate:(NSObject<ITMGDelegate>*) delegate
{
    @synchronized(_DelegateArray)
    {
        [_DelegateArray addObject:delegate];
    }
}

-(void)removeDelegate:(NSObject<ITMGDelegate>*) delegate
{
    @synchronized(_DelegateArray)
    {
        [_DelegateArray removeObject:delegate];
    }
}
-(instancetype)init
{
    self = [super init];
    
    if (self)
    {
       ITMGContext* _context = [ITMGContext GetInstance];
         _DelegateArray = [[NSMutableArray alloc] init];
        _context.TMGDelegate = self;
    }
    return self;
}

- (void)OnEvent:(ITMG_MAIN_EVENT_TYPE)eventType data:(NSDictionary*)data
{
    @synchronized(_DelegateArray)
    {
        for (int i = 0; i<[_DelegateArray count]; i++)
        {
            NSObject<ITMGDelegate> *object = [_DelegateArray objectAtIndex:i];
            [object OnEvent:eventType data:data];
        }
        
    }
}

@end
