

#import "EnginePollHelper.h"
#import "GMESDK/TMGEngine.h"

static EnginePollHelper *s_enginePollHelper = nil;
static bool s_pollEnabled = true;

@implementation EnginePollHelper

+(void)createEnginePollHelper;
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_enginePollHelper = [EnginePollHelper new];
        [s_enginePollHelper startTimer];
    });
}

+(void)destroyEnginePollHelper;
{
    [s_enginePollHelper stopTimer];
    s_enginePollHelper = nil;
}

+(void)pauseEnginePollHelper;
{
    s_pollEnabled = false;
}

+(void)resumeEnginePollHelper;
{
    s_pollEnabled = true;
}

- (void) startTimer;
{
    _pollTimer = [[NSTimer scheduledTimerWithTimeInterval:1.000/30 target:self selector:@selector(doPoll:) userInfo:nil repeats:YES] retain];
}

- (void) doPoll:(id)obj {
    if (s_pollEnabled) {
        [[ITMGContext GetInstance] Poll];
    }
}

- (void) stopTimer;
{
    [_pollTimer invalidate];
    [_pollTimer release];
    _pollTimer = nil;
}

- (id) init;
{
    if (self = [super init]) {
        
    }
    return self;
}

-(void)dealloc
{
    [self stopTimer];
    [super dealloc];
}

@end

