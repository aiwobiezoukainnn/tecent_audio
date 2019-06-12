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
#import "UserListView.h"

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
    IBOutlet UITextField* _KaraokeTypefield;
    IBOutlet UITextField* _voiceTypeText;
    
    IBOutlet UIView* _inRoomOperation;
    IBOutlet UIButton*  _pttButton;
    IBOutlet UIButton* _karaokebutton;
    IBOutlet UIButton* _voiceTypeButton;
    
    IBOutlet UISwitch* _micSwitch;
    IBOutlet UISwitch* _sendSwitch;
    IBOutlet UISwitch* _recvSwitch;
    IBOutlet UISwitch* _speakerSwitch;
    IBOutlet UISwitch* _loopbackSwitch;
    IBOutlet UISwitch* _accompanySwitch;
    IBOutlet UISwitch* _playBackSwitch;
    IBOutlet UISwitch* _testENVSwitch;
    IBOutlet UISwitch* _autoPauseSwitch;
    
    IBOutlet UISegmentedControl* _streamTypeSegmented;
    IBOutlet UISegmentedControl* _roomTypeSegmented;
    
    IBOutlet UITextView* _logText;
    
    IBOutlet UITextField* _accFileNameText;
    
    IBOutlet UIButton *_usrlistButton;
    
    NSTimer*_timerUpdateTips;
    UIScrollView * _tipsScrollView;
    
    NSString* _appId;
    NSString* _openId;
    NSString* _roomId;
    NSString* _key;
    
    UserListView *_userListView;

    
    IBOutlet UISlider *_micSlider;
    IBOutlet UISlider *_speSlider;
    
    IBOutlet UITextField *_micVolume;
    IBOutlet UITextField *_speVolume;
    
    NSMutableDictionary *_userMutableDic;
    
    
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
    NSMutableDictionary *_temple =  (NSMutableDictionary*)[[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULT_USERLIST];
    if (_temple == NULL) {
        [[NSUserDefaults standardUserDefaults] setObject:[[NSMutableDictionary alloc]initWithCapacity:20] forKey:USERDEFAULT_USERLIST];
    }
     [[NSUserDefaults standardUserDefaults] synchronize];
    _userMutableDic = [[NSMutableDictionary alloc] initWithCapacity:10];
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
    
    [_micSlider addTarget:self action:@selector(micSliderValueChange:) forControlEvents:UIControlEventValueChanged];
    [_speSlider addTarget:self action:@selector(speSliderValueChange:) forControlEvents:UIControlEventValueChanged];
    [EnginePollHelper createEnginePollHelper];
    
    _userListView = [[UserListView alloc] initWithCGPoint:CGPointMake(0, _usrlistButton.frame.origin.y-200)];
    _userListView.hidden = YES;
    _userListView.dataSource = _userMutableDic;
    [self.view addSubview:_userListView];
}

-(void)resetUIStatus{
    _micSwitch.on = NO;
    _speakerSwitch.on = NO;
    _sendSwitch.on = NO;
    _recvSwitch.on = NO;
    _loopbackSwitch.on = NO;
    _accompanySwitch.on = NO;
    _micVolume.text = @"100";
    _speVolume.text = @"100";
    _micSlider.value = 100;
    _speSlider.value = 100;
    [_userMutableDic removeAllObjects];
    [_userListView upDate];
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
    _openId = _userIdText.text;
    _appId = _appIdText.text;

    
    [[ITMGContext GetInstance] SetAppVersion:@"Native Demo"]; //// Just for Test
    [[ITMGContext GetInstance] SetTestEnv:_testENVSwitch.isOn];  //// warning : never call this API for any reason, it's only for internal use
    [[ITMGContext GetInstance] InitEngine:_appId openID:_openId];
    [[ITMGContext GetInstance] SetDefaultAudienceAudioCategory:_playBackSwitch.isOn ? ITMG_CATEGORY_PLAYBACK : ITMG_CATEGORY_AMBIENT];
    
    NSString* streamType = [NSString stringWithFormat:@"%zd", _streamTypeSegmented.selectedSegmentIndex];
    [[ITMGContext GetInstance] SetAdvanceParams:@"SetSpeakerStreamType" value:streamType];
    [[ITMGContext GetInstance] SetRecvMixStreamCount:_mixCountText.text.intValue];
    
   int result = [[ITMGContext GetInstance] CheckMicPermission];
    NSLog(@"================  %d",result);
}

- (IBAction)uninit:(id)sender {
    [[ITMGContext GetInstance] Uninit];
}

-(IBAction)enterRoom:(id)sender{
    _roomId = _roomIdText.text;
    _appId = _appIdText.text;
    _key = _KeyText.text;
    NSData* authBuffer = [QAVAuthBuffer GenAuthBuffer:_appId.intValue roomID:_roomId openID:_openId key:_key];
    
    [[ITMGContext GetInstance] EnterRoom:_roomId roomType:(int)_roomTypeSegmented.selectedSegmentIndex + 1 authBuffer:authBuffer];
}

-(IBAction)exitRoom:(id)sender{
    int nRet = [[ITMGContext GetInstance] ExitRoom];
    printf("nRet=%d", nRet);
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



-(IBAction)usrlistButtonPressed:(id)sender
{
    _userListView.hidden = !_userListView.hidden;
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
        
        NSString *str = _accFileNameText.text;
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

-(IBAction)VoiceTypeButton
{
    NSString *VoiceType = _voiceTypeText.text;
    
    if (VoiceType != NULL ) {
        [[[ITMGContext GetInstance] GetAudioEffectCtrl]SetVoiceType:(ITMG_VOICE_TYPE)VoiceType.integerValue];
    }
}

-(void)micSliderValueChange:(UISlider *)slider
{
    [[[ITMGContext GetInstance]GetAudioCtrl]SetMicVolume:slider.value];
    int _intVolum = [[[ITMGContext GetInstance]GetAudioCtrl]GetMicVolume];
    _micVolume.text =  [NSString stringWithFormat:@"%d",_intVolum];
}
-(void)speSliderValueChange:(UISlider *)slider
{
    [[[ITMGContext GetInstance]GetAudioCtrl]SetSpeakerVolume:slider.value];
    int _intVolum = [[[ITMGContext GetInstance]GetAudioCtrl]GetSpeakerVolume];
    _speVolume.text =  [NSString stringWithFormat:@"%d",_intVolum];
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
    NSLog(@"====%@====",log);
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
                _voiceTypeText.hidden = NO;
                _KaraokeTypefield.keyboardType = UIKeyboardTypeNumberPad;
                _voiceTypeText.keyboardType = UIKeyboardTypeNumberPad;
                _karaokebutton.hidden = NO;
                _voiceTypeButton.hidden = NO;
                [[[ITMGContext GetInstance] GetAudioCtrl] TrackingVolume:2.1] ;
            }
            [self resetUIStatus];
        }
            break;
        case ITMG_MAIN_EVENT_TYPE_EXIT_ROOM:
        case ITMG_MAIN_EVENT_TYPE_ROOM_DISCONNECT:
        {
            [self showLog:[NSString stringWithFormat:@"EXIT_ROOM"]];
            _inRoomOperation.hidden = YES;
            _KaraokeTypefield.hidden = YES;
            _karaokebutton.hidden = YES;
            _voiceTypeText.hidden = YES;
            _voiceTypeButton.hidden = YES;
            [[[ITMGContext GetInstance] GetAudioCtrl] StopTrackingVolume];
            
            [self resetUIStatus];
        }
            break;
            
        case ITMG_EVENT_ID_USER_HAS_AUDIO:
        {
           
        }
             break;
        case ITMG_EVENT_ID_USER_NO_AUDIO:
        {
            
        }
            break;

        case ITMG_MAIN_EVNET_TYPE_USER_UPDATE:
        {
            ITMG_EVENT_ID_USER event_id=((NSNumber*)[data objectForKey:@"event_id"]).intValue;
            NSMutableArray* uses = [NSMutableArray arrayWithArray: [data objectForKey:@"user_list"]];
            [self showLog:[NSString stringWithFormat:@"OnEndpointsUpdateInfo endpoints:%d endpoints:%@", (int)event_id, uses]];
            switch (event_id) {
                case ITMG_EVENT_ID_USER_ENTER:
                    [self handleUserUpdate:uses enter:YES];
                    break;
                case ITMG_EVENT_ID_USER_EXIT:
                     [self handleUserUpdate:uses enter:NO];
                    break;
                case ITMG_EVENT_ID_USER_HAS_AUDIO:
                    [self handleAudioEventUpdate:uses hasAudio:YES];
                    break;
                case ITMG_EVENT_ID_USER_NO_AUDIO:
                    [self handleAudioEventUpdate:uses hasAudio:NO];
                    break;
                default:
                break;
            }
             [_userListView upDate];
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
            int newRoomType = ((NSNumber*) [data objectForKey:@"new_room_type"]).intValue;
            int subEventType = ((NSNumber*) [data objectForKey:@"sub_event_type"]).intValue;
            switch (subEventType)
            {
                case ITMG_ROOM_CHANGE_EVENT_ENTERROOM:
                    [_roomTypeSegmented setSelectedSegmentIndex:newRoomType - 1];
                    break;
                case ITMG_ROOM_CHANGE_EVENT_COMPLETE:
                    [_roomTypeSegmented setSelectedSegmentIndex:newRoomType - 1];
                    break;
                default:
                    break;
            }
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

-(void)handleAudioEventUpdate:(NSArray*)uses hasAudio:(BOOL)HasAudio
{
    for (int i = 0; i<uses.count; i++)
    {
        NSString *userid = [uses objectAtIndex:i];
        if ([userid isEqualToString:_openId]) {
            continue;
        }
        
        UserListItem *_item = [_userMutableDic objectForKey:userid];
        if (_item)
        {
            _item.isSpeakIng = HasAudio;
        }
    }
}


-(void)handleUserUpdate:(NSArray*)uses enter:(BOOL)enerroom
{
    if (enerroom) {
        for (int i = 0; i<uses.count; i++)
        {
            NSString *userid = [uses objectAtIndex:i];
            if ([userid isEqualToString:_openId]) {
                continue;
            }
            NSString *isSheiled = [[[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULT_USERLIST] objectForKey:userid];
            
            UserListItem *_item = [[UserListItem alloc] init];
            if ([isSheiled isEqualToString:@"YES"]) {
                _item.isSheilded = YES;
                [[[ITMGContext GetInstance] GetAudioCtrl] AddAudioBlackList:userid];
            }
            else{
                _item.isSheilded = NO;
                [[[ITMGContext GetInstance] GetAudioCtrl] RemoveAudioBlackList:userid];
            }
            _item.isSpeakIng = false;
            _item.UserID = userid;
            [_userMutableDic setObject:_item forKey:userid];
        }
    }
    else
    {
        for (int i = 0; i<uses.count; i++)
        {
            NSString *userid = [uses objectAtIndex:i];
            if ([userid isEqualToString:_openId]) {
                continue;
            }
            [_userMutableDic removeObjectForKey:userid];
        }
    }
    
}
- (void) onApplicationWillResignActive:(NSNotification*)notification;
{
    if (_autoPauseSwitch.isOn) {
        // Just For Test, ignore this function
        [EnginePollHelper pauseEnginePollHelper];
        [[ITMGContext GetInstance] Pause];
    }
}

- (void) onApplicationDidBecomeActive:(NSNotification*)notification;
{
    if (_autoPauseSwitch.isOn) {
        // Just For Test, ignore this function
        [EnginePollHelper resumeEnginePollHelper];
        [[ITMGContext GetInstance] Resume];
    }
}

@end
