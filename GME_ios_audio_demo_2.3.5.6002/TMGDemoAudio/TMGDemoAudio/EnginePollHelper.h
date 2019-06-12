

#import <Foundation/Foundation.h>

@interface EnginePollHelper : NSObject {
    NSTimer* _pollTimer;
}

+(void) createEnginePollHelper;
+(void) destroyEnginePollHelper;

+(void) pauseEnginePollHelper;      // Just for Test, ignore this function
+(void) resumeEnginePollHelper;      // Just for Test, ignore this function

@end
