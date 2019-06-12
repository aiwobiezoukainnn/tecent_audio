//
//  ViewController.m
//  TMGDemo
//
//  Created by tobinchen on 30/10/2017.
//  Copyright © 2017 tobinchen. All rights reserved.
//

#import "TMGDemoViewController.h"
#import "GMESDK/TMGEngine.h"
#import "GMESDK/QAVAuthBuffer.h"
#import "EnginePollHelper.h"
#import "RunningTipsView.h"
#import "PTTViewController.h"
#import "DispatchCenter.h"
#import <AVFoundation/AVFoundation.h>

#define SDKAPPID3RD @"1400216419"
#define AUTHKEY @"G8Gt4RrmDDriMDtp"

@interface TMGDemoViewController ()<ITMGDelegate>{
    IBOutlet UILabel *_sdkVersionText;
    IBOutlet UITextField* _userIdText;
    IBOutlet UITextField* _appIdText;
    IBOutlet UITextField* _roomIdText;
    IBOutlet UITextField* _mixCountText;
    IBOutlet UITextField* _KeyText;
    
    IBOutlet UIView* _inRoomOperation;
    IBOutlet UIButton*  _pttButton;
    
    IBOutlet UISwitch* _micSwitch;
    IBOutlet UISwitch* _sendSwitch;
    IBOutlet UISwitch* _recvSwitch;
    IBOutlet UISwitch* _speakerSwitch;
    IBOutlet UISwitch* _loopbackSwitch;
    IBOutlet UISwitch* _accompanySwitch;
    IBOutlet UISwitch* _playBackSwitch;
    IBOutlet UISwitch* _testENVSwitch;
    IBOutlet UISwitch* _autoPauseSwitch;
    IBOutlet UISwitch* _changeVoiceSwitch;
    
    IBOutlet UISegmentedControl* _streamTypeSegmented;
    IBOutlet UISegmentedControl* _roomTypeSegmented;
    
    IBOutlet UITextView* _logText;
    
    IBOutlet UITextField* _accFileNameText;
    
    ITMGContext* _context;
    
    NSTimer*_timerUpdateTips;
    UIScrollView * _tipsScrollView;
    
    NSString* _appId;
    NSString* _openId;
    NSString* _roomId;
    NSString* _key;
    
    IBOutlet UITextField *_KaraokeTypefield;
    IBOutlet UIButton *_karaokebutton;
}
@end

@implementation TMGDemoViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder;
{
    if (self = [super initWithCoder:aDecoder])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    
    return self;
}

- (void) dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _sdkVersionText.text = [[ITMGContext GetInstance] GetSDKVersion];
    _appIdText.text = SDKAPPID3RD;
    _KeyText.text = AUTHKEY;
   
    self.view.backgroundColor = [UIColor whiteColor];
    [[DispatchCenter getInstance] addDelegate:self];
    
    UITapGestureRecognizer* gestureRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    _inRoomOperation.hidden = YES;
    _pttButton.hidden = YES;
    srand((unsigned)time(NULL));
    int openid = 20000 + rand() % 10000;
    
    _userIdText.text = [NSString stringWithFormat:@"%d", openid];
    _roomIdText.text = @"201806";
    
     _logText.layoutManager.allowsNonContiguousLayout = NO;
#ifdef TMG_NO_PTT_SUPPORT
    _pttButton.hidden = YES;
#else
    _pttButton.hidden = NO;
#endif
    [self resetUIStatus];


    [EnginePollHelper createEnginePollHelper];
}

-(void)resetUIStatus{
    _micSwitch.on = NO;
    _speakerSwitch.on = NO;
    _sendSwitch.on = NO;
    _recvSwitch.on = NO;
    _loopbackSwitch.on = NO;
    _accompanySwitch.on = NO;
    _changeVoiceSwitch.on = NO;

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)endEditing{
    [self.view endEditing:YES];
}

-(void) viewWillAppear:(BOOL)animated {

}

-(IBAction)initTMG:(id)sender {
    _context = [ITMGContext GetInstance];
    _openId = _userIdText.text;
    _appId = _appIdText.text;
    [_context SetAppVersion:@"Engine: Native"]; //// Just for Test
    [_context SetTestEnv:_testENVSwitch.isOn];  //// warning : never call this API for any reason, it's only for internal use
    [_context InitEngine:_appId openID:_openId];
    
    [_context SetDefaultAudienceAudioCategory:_playBackSwitch.isOn ? ITMG_CATEGORY_PLAYBACK : ITMG_CATEGORY_AMBIENT];
    
    int selectedSegmentIndexid = _streamTypeSegmented.selectedSegmentIndex;
    NSString* streamType = [NSString stringWithFormat:@"%zd", selectedSegmentIndexid];
    [_context SetAdvanceParams:@"SetSpeakerStreamType" value:streamType];
    int maxValue = _mixCountText.text.intValue;
    [_context SetRecvMixStreamCount:maxValue];
}

- (IBAction)uninit:(id)sender {
    [_context Uninit];
}

-(IBAction)enterRoom:(id)sender{
    _roomId = _roomIdText.text;
    _appId = _appIdText.text;
    _key = _KeyText.text;
    NSData* authBuffer = [QAVAuthBuffer GenAuthBuffer:_appId.intValue roomID:_roomId openID:_openId key:_key];
    
    int roomid = (int)_roomTypeSegmented.selectedSegmentIndex + 1;
    [_context EnterRoom:_roomId roomType:roomid authBuffer:authBuffer];
}

-(IBAction)exitRoom:(id)sender{
    [_context ExitRoom];
}

- (IBAction)enableMic:(UISwitch*)sender {
    [[[ITMGContext GetInstance] GetAudioCtrl] EnableAudioCaptureDevice:sender.on];
}

-(IBAction)enableAudioSend:(UISwitch*)sender{
    [[[ITMGContext GetInstance] GetAudioCtrl] EnableAudioSend:sender.on];
}

-(IBAction)enableAudioRecv:(UISwitch*)sender{
    [[[ITMGContext GetInstance] GetAudioCtrl] EnableAudioRecv:sender.on];
}
- (IBAction)enableSpeaker:(UISwitch*)sender {
    [[[ITMGContext GetInstance] GetAudioCtrl] EnableAudioPlayDevice:sender.on];
}

-(IBAction)audioLoopback:(UISwitch*)sender{
    [[[ITMGContext GetInstance] GetAudioCtrl] EnableLoopBack:sender.on];
}

-(IBAction)changeRoomType:(UISwitch*)sender{
    [[[ITMGContext GetInstance] GetRoom] ChangeRoomType:(int)_roomTypeSegmented.selectedSegmentIndex + 1];
}


-(IBAction)pttButtonPressed:(id)sender{
    
#ifndef TMG_NO_PTT_SUPPORT
    PTTViewController *_pttViewController = [[PTTViewController alloc] init];
    _pttViewController._openId = _userIdText.text;
    _appId = _appIdText.text;
    _pttViewController._appid = _appId;
    _key = _KeyText.text;
    NSData* authBuffer =   [QAVAuthBuffer GenAuthBuffer:(unsigned int)_appId.integerValue roomID:nil openID:_openId key:_key];
    [[[ITMGContext GetInstance] GetPTT] ApplyPTTAuthbuffer:authBuffer];
    [self presentViewController:_pttViewController animated:YES completion:^{
    }];

#endif
}

    
-(IBAction)accompany:(UISwitch*)sender{
    
    if(sender.on){
        NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)[0];
        
        NSString* songPath = [docDir stringByAppendingPathComponent:_accFileNameText.text];
        BOOL isDir = YES;
        if( ![[NSFileManager defaultManager] fileExistsAtPath:songPath isDirectory:&isDir]  || isDir){
            songPath =[[NSBundle mainBundle] pathForResource:@"song" ofType:@"mp3"];
        }
        
        [[[ITMGContext GetInstance] GetAudioEffectCtrl] StartAccompany:songPath loopBack:YES loopCount:1];
    }else{
        [[[ITMGContext GetInstance] GetAudioEffectCtrl] StopAccompany:0];
    }
}

    
-(IBAction)ChangeVoice:(UISwitch*)sender{
    if(sender.on){
        [[[ITMGContext GetInstance] GetAudioEffectCtrl] SetVoiceType:ITMG_VOICE_TYPE_LOLITA];
    }else{
         [[[ITMGContext GetInstance] GetAudioEffectCtrl] SetVoiceType:ITMG_VOICE_TYPE_ORIGINAL_SOUND];
    }
}

- (IBAction)onToggleTips:(UISwitch*)sender {
    if (sender.on) {
        if (!_tipsScrollView)
        {
            _tipsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 30, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-120)];
            _tipsScrollView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.9];
            [self.view addSubview:_tipsScrollView];
        }
        
        _timerUpdateTips = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(OnRefreshTips:) userInfo:self repeats:YES];
        [self OnRefreshTips:_timerUpdateTips];
        
    } else {
        [RunningTipsView hide];
        if (_tipsScrollView) {
            [_tipsScrollView removeFromSuperview];
            _tipsScrollView = nil;
        }
        [_timerUpdateTips invalidate];
        _timerUpdateTips = nil;
    }
}

-(IBAction)KaraokeTypeButton
{
    NSString *karaokeType = _KaraokeTypefield.text;
    
    if (karaokeType != NULL ) {
        [[[ITMGContext GetInstance] GetAudioCtrl] SetKaraokeType:(ITMG_KARAOKE_TYPE)karaokeType.integerValue];
    }
}

- (void)OnRefreshTips:(NSTimer *)timer{
    NSString *tips = [[[ITMGContext GetInstance] GetRoom] GetQualityTips];
    [RunningTipsView Show:tips parentView:_tipsScrollView];
}

-(void)showLog:(NSString*)log{
//    NSString* text = _logText.text;
//    if(_logText.text.length >1024*10){
//        text = @"log:";
//    }
    static int i=0;
    NSString* text = _logText.text;
    if(i<3){
        log = [text stringByAppendingFormat:@"\n%@",log];
        i++;
    }else{
        log = log;
        i=0;
    }
    
    _logText.text = log;
    
//    NSLog(@"%@",log);
//    [_logText scrollRangeToVisible:NSMakeRange(_logText.text.length, 1)];
}

-(void)OnEvent:(ITMG_MAIN_EVENT_TYPE)eventType data:(NSDictionary *)data{
    NSString* log =[NSString stringWithFormat:@"OnEvent:%d,data:%@", (int)eventType, data];
    [self showLog:log];
    
    switch (eventType) {
        case ITMG_MAIN_EVENT_TYPE_ENTER_ROOM:
        {
            int result = ((NSNumber*)[data objectForKey:@"result"]).intValue;
            NSString* error_info = [data objectForKey:@"error_info"];
            
            [self showLog:[NSString stringWithFormat:@"OnEnterRoomComplete:%d msg:(%@)",result,error_info]];

            if (result == 0)
            {
                _inRoomOperation.hidden = NO;
                _KaraokeTypefield.hidden = NO;
                _KaraokeTypefield.keyboardType = UIKeyboardTypeNumberPad;
                _karaokebutton.hidden = NO;
                [[[ITMGContext GetInstance] GetAudioCtrl] TrackingVolume:2.1] ;
            }
        }
            break;
        case ITMG_MAIN_EVENT_TYPE_EXIT_ROOM:
        case ITMG_MAIN_EVENT_TYPE_ROOM_DISCONNECT:
        {
            [self showLog:[NSString stringWithFormat:@"EXIT_ROOM"]];
            _inRoomOperation.hidden = YES;
            _KaraokeTypefield.hidden = YES;
            _karaokebutton.hidden = YES;
            [[[ITMGContext GetInstance] GetAudioCtrl] StopTrackingVolume];
            
            [self resetUIStatus];
        }
            break;
        case ITMG_MAIN_EVNET_TYPE_USER_UPDATE:
        {
            NSMutableArray* uses = [NSMutableArray arrayWithArray: [data objectForKey:@"user_list"]];
            ITMG_EVENT_ID_USER event_id=((NSNumber*)[data objectForKey:@"event_id"]).intValue;
            
            [self showLog:[NSString stringWithFormat:@"OnEndpointsUpdateInfo endpoints:%d endpoints:%@", (int)event_id, uses]];
        }
            break;

            case ITMG_MAIN_EVNET_TYPE_PTT_PLAY_COMPLETE:
        {
            int result = ((NSNumber*)[data objectForKey:@"result"]).intValue;
            NSString* file_path = [data objectForKey:@"file_path"];
            
            NSLog(@"PlayRecordedFile:%@ result:%x",file_path,result);
        }
            break;
        case ITMG_MAIN_EVENT_TYPE_ACCOMPANY_FINISH:
        {
            int result = ((NSNumber*)[data objectForKey:@"result"]).intValue;
            NSString* file_path = [data objectForKey:@"file_path"];
            NSNumber* is_finished = [data objectForKey:@"is_finished"];
            
            NSLog(@"ITMG_MAIN_EVENT_TYPE_ACCOMPANY_FINISH:%@ result:%x",file_path,result);
            
            if(is_finished.boolValue){
                NSString* songPath =[[NSBundle mainBundle] pathForResource:@"song" ofType:@"mp3"];
                [[[ITMGContext GetInstance] GetAudioEffectCtrl] StartAccompany:songPath loopBack:YES loopCount:1];
            }else{
                [self showLog:@"停止播放"];
            }
        }
        break;
            
        case ITMG_MAIN_EVNET_TYPE_USER_VOLUMES:
        {
            NSLog(@"ITMG_MAIN_EVNET_TYPE_USER_VOLUMES:%@ ",data);
            
            NSString* msg=[NSString stringWithFormat:@"vol:%@",data];
            msg = [msg stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            [self showLog:msg];
        }
            break;
            
        case ITMG_MAIN_EVENT_TYPE_CHANGE_ROOM_TYPE:
        {
            NSLog(@"ITMG_MAIN_EVENT_TYPE_CHANGE_ROOM_TYPE:%@ ",data);
            int result = ((NSNumber*)[data objectForKey:@"result"]).intValue;
            
            NSString* msg=[NSString stringWithFormat:@"change room Type:%d msg:%@",result,data];
            [self showLog:msg];
        }
            break;
            
        case ITMG_MAIN_EVENT_TYPE_CHANGE_ROOM_QUALITY:
        {
            NSLog(@"ITMG_MAIN_EVENT_TYPE_CHANGE_ROOM_QUALITY:%@ ", data);
            int nWeight = ((NSNumber*)[data objectForKey:@"weight"]).intValue;
            float fLoss = ((NSNumber*)[data objectForKey:@"loss"]).floatValue;
            int nDelay = ((NSNumber*)[data objectForKey:@"delay"]).intValue;
            NSString* msg=[NSString stringWithFormat:@"Weight=%d, Loss=%f, Delay=%d", nWeight, fLoss, nDelay];
            [self showLog:msg];
            break;
        }
        default:
            break;
    }
}

- (void) onApplicationWillResignActive:(NSNotification*)notification;
{
    if (_autoPauseSwitch.isOn || [AVAudioSession sharedInstance].category == AVAudioSessionCategoryAmbient) {
        // Just For Test, ignore this function
        [EnginePollHelper pauseEnginePollHelper];
        [[ITMGContext GetInstance] Pause];
    }
}

- (void) onApplicationDidBecomeActive:(NSNotification*)notification;
{
    if (_autoPauseSwitch.isOn || [AVAudioSession sharedInstance].category == AVAudioSessionCategoryAmbient) {
        // Just For Test, ignore this function
        [EnginePollHelper resumeEnginePollHelper];
        [[ITMGContext GetInstance] Resume];
    }
}

@end
