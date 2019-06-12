//
//  PTTViewController.m
//  TMGDemoAudio
//
//  Created by signcheng on 2018/6/20.
//  Copyright © 2018年 tobinchen. All rights reserved.
//

#import "PTTViewController.h"
#import <objc/runtime.h>
#import "GMESDK/TMGEngine.h"
#import "GMESDK/QAVAuthBuffer.h"
#import "DispatchCenter.h"
#define PTT_LOCALFILE @"_localFileField"
#define PTT_DONWLOADURL @"_donwloadUrlField"
#define PTT_AUDIOFILE_TO_PLAY @"_audiofileToPlayField"
#define PTT_AUDIO_TO_TEXT @"_audiotoTextField"
#define PTT_AUDIOFILE_LENGTH @"_audiofileLength"
#define PTT_AUDIO_LEVEL @"_audioLevel"
#define USERDEFAULT_USERLIST @"NSUserDefaults_USEERLIST"

@interface PTTViewController ()<ITMGDelegate>
{
    UIActivityIndicatorView *_indicator;
    BOOL  isPlaying;
    BOOL  isMonitorMic;
    UITextField *_localFileField ;
    UITextField *_donwloadUrlField;
    UITextField *_audiofileToPlayField;
}

@end

@implementation PTTViewController
@synthesize _openId;
-(instancetype)init
{
    self = [super init];
    if (self)
    {
        recordfilePath = nil;
        self._openId = NULL;
        self._appid = NULL;
        self._timerMonitor = NULL;
        self._monitorMicLevel = false;
        donwLoadUrlPath = NULL;
        donwLoadLocalPath = NULL;
        isPlaying = false;
        isMonitorMic = false;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    _indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //设置显示位置
    _indicator.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    //将这个控件加到父容器中。
    [self.view addSubview:_indicator];
    
    UIButton *backButton =[[UIButton alloc] initWithFrame:CGRectMake(20, 40, 50, 50)];
    [self.view addSubview:backButton];
    
    [backButton setBackgroundColor:[UIColor colorWithRed:51.0/255.0 green:123.0/255 blue:246.0/255.0 alpha:1.0]];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(BackButtonPresse) forControlEvents:UIControlEventTouchUpInside];
    
   _ContainArray = @[@[@"本地音频文件:",PTT_LOCALFILE],@[@"下载链接:",PTT_DONWLOADURL],@[@"下载音频下载:",PTT_AUDIOFILE_TO_PLAY],@[@"语音转文本结果:",PTT_AUDIO_TO_TEXT],@[@"下载音频时长:",PTT_AUDIOFILE_LENGTH]];

    for (int i = 0; i<_ContainArray.count; i++)
    {
        UILabel *templeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100+(20+40)*i, [UIScreen mainScreen].bounds.size.width, 20)];
        [self.view addSubview:templeLabel];
        templeLabel.textAlignment = NSTextAlignmentCenter;
        templeLabel.text =_ContainArray[i][0];
        
        NSString *templeString = _ContainArray[i][1];
        UITextField * value = [[UITextField alloc] initWithFrame:CGRectMake(10, 125+(20+40)*i, [UIScreen mainScreen].bounds.size.width-20, 30)];
        value.delegate = self;
        value.borderStyle = UITextBorderStyleRoundedRect;
        objc_setAssociatedObject(self,[templeString UTF8String],value,OBJC_ASSOCIATION_RETAIN);
        [self.view addSubview:value];

    }
    
    //add volume uilabel
    self._pttDeviceLevel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100+(20+40)*(_ContainArray.count), [UIScreen mainScreen].bounds.size.width, 20)];
    [self.view addSubview:self._pttDeviceLevel];
    self._pttDeviceLevel.textAlignment = NSTextAlignmentCenter;
    self._pttDeviceLevel.text = @" ";
    
    //add buttons
    NSArray *buttonNameArray = @[@"录制",@"上传",@"下载",@"播下载",@"转文本",@"时长",@"流式",@"播本地",@"停录音",@"取消"];
    for ( int i = 0; i<buttonNameArray.count; i++)
    {
        int buttonWidht = 60;
       float width = ([UIScreen mainScreen].bounds.size.width-60*3)/4;
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(width+(buttonWidht+width)*(i%3), 425+(i/3)*60, buttonWidht, 50)];
        [button setTitle:buttonNameArray[i] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor colorWithRed:51.0/255.0 green:123.0/255 blue:246.0/255.0 alpha:1.0]];
        button.tag = i;
        [self.view addSubview:button];
        [button addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(buttonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    }

    [[DispatchCenter getInstance] addDelegate:self];
    UIButton *cleanButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2-30, 600, 60, 40)];
    [cleanButton setBackgroundColor:[UIColor colorWithRed:51.0/255.0 green:123.0/255 blue:246.0/255.0 alpha:1.0]];
    [cleanButton addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    cleanButton.tag = 10;
    [cleanButton setTitle:@"清空" forState:UIControlStateNormal];
    [self.view addSubview:cleanButton];
    
    _localFileField=(UITextField*)objc_getAssociatedObject(self, [PTT_LOCALFILE UTF8String]);
    _donwloadUrlField=(UITextField*)objc_getAssociatedObject(self, [PTT_DONWLOADURL UTF8String]);
    _audiofileToPlayField = (UITextField*)objc_getAssociatedObject(self, [PTT_AUDIOFILE_TO_PLAY UTF8String]);
    // Do any additional setup after loading the view.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;
}

- (void)OnEvent:(ITMG_MAIN_EVENT_TYPE)eventType data:(NSDictionary*)data
{
    if (eventType ==  ITMG_MAIN_EVNET_TYPE_PTT_PLAY_COMPLETE) {
        static int i = 0;
        NSLog(@"播放完成。%d",i);
        i++;
    }
    [_indicator stopAnimating];
    
        NSNumber *number = [data objectForKey:@"result"];
    if (![number isEqualToNumber:@(0)]&& (int)eventType != ITMG_MAIN_EVNET_TYPE_USER_VOLUMES &&eventType!=ITMG_MAIN_EVNET_TYPE_USER_VOLUMES&&eventType !=ITMG_MAIN_EVENT_TYPE_CHANGE_ROOM_QUALITY &&eventType != ITMG_MAIN_EVNET_TYPE_USER_UPDATE)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"操作失败" message:[NSString stringWithFormat:@"eventType %d error code ,%@",(int)eventType,number] delegate:NULL cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
       NSLog(@"%@",[NSString stringWithFormat:@"操作失败:eventType %d error code ,%@",(int)eventType,number]);
       
    }
    
    switch (eventType)
    {
        case ITMG_MAIN_EVNET_TYPE_PTT_RECORD_COMPLETE:
        {
//            UITextField *_localFileField =(UITextField*)objc_getAssociatedObject(self, [PTT_LOCALFILE UTF8String]);
            recordfilePath = [data objectForKey:@"file_path"];
            _localFileField.text = recordfilePath;
        }
            break;
        case ITMG_MAIN_EVNET_TYPE_PTT_UPLOAD_COMPLETE:
        {
            if (data != NULL &&[[data objectForKey:@"result"] intValue]== 0)
            {
                
                _donwloadUrlField.text = [data objectForKey:@"file_id"] ;
                donwLoadUrlPath = [data objectForKey:@"file_id"] ;
            }
        }
            break;
            case ITMG_MAIN_EVNET_TYPE_PTT_DOWNLOAD_COMPLETE:
        {
            if (data != NULL &&[[data objectForKey:@"result"] intValue]== 0)
            {
                
                _audiofileToPlayField.text = [data objectForKey:@"file_path"] ;
                donwLoadLocalPath = [data objectForKey:@"file_path"];
            }
            else
            {
                donwLoadLocalPath = NULL;
            }
        }
            break;
            case ITMG_MAIN_EVNET_TYPE_PTT_STREAMINGRECOGNITION_COMPLETE:
        {
            if (data != NULL &&[[data objectForKey:@"result"] intValue]== 0)
            {
                donwLoadUrlPath = data[@"file_id"];
                
                recordfilePath = [data objectForKey:@"file_path"];
                _localFileField.text = recordfilePath;
                
                _donwloadUrlField.text = [data objectForKey:@"file_id"] ;
                
                UITextField *_audiotoTextField =(UITextField*)objc_getAssociatedObject(self, [PTT_AUDIO_TO_TEXT UTF8String]);
                _audiotoTextField.text = [data objectForKey:@"text"] ;
            }
       
        }
            break;
            case ITMG_MAIN_EVNET_TYPE_PTT_SPEECH2TEXT_COMPLETE:
        {
            if (data != NULL &&[[data objectForKey:@"result"] intValue]== 0)
            {
                UITextField *_audiotoTextField =(UITextField*)objc_getAssociatedObject(self, [PTT_AUDIO_TO_TEXT UTF8String]);
                _audiotoTextField.text = [data objectForKey:@"text"] ;
            }
            else
            {
                
            }
        }
            break;
            case ITMG_MAIN_EVNET_TYPE_PTT_PLAY_COMPLETE:
        {
            isPlaying = false;
            [self StopMonitor];
        }
            break;
        default:
            break;
    }
    
}

- (void)StartMonitor : (BOOL) bMonitorMic {
    [super viewDidLoad];
   
    self._timerMonitor = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(Timered:) userInfo:nil repeats:YES];
    self._monitorMicLevel = bMonitorMic;
}

-(void)StopMonitor
{
    if (self._timerMonitor != NULL) {
        [self._timerMonitor invalidate];
    }
    
    self._pttDeviceLevel.text = @" ";
}

- (void)Timered:(NSTimer*)timer {
    if (self._monitorMicLevel) {
        self._pttDeviceLevel.text = [NSString stringWithFormat:@"audioRecording level:%d", [[[ITMGContext GetInstance]GetPTT]GetMicLevel]];
    }
    else
    {
        self._pttDeviceLevel.text = [NSString stringWithFormat:@"audioPlaying level:%d", [[[ITMGContext GetInstance]GetPTT]GetSpeakerLevel]];
    }
}



-(void)buttonTouchDown:(UIButton *)sender{
    
   
    if (sender.tag ==0)
    { [_indicator startAnimating];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [paths objectAtIndex:0];

        
        static int index = 0;
        
         recordfilePath =[docDir stringByAppendingFormat:@"/test_%d.ptt",index++];
        
        if([fileManager fileExistsAtPath:recordfilePath]){
            [fileManager removeItemAtPath:recordfilePath error:nil];
        }
#ifndef TMG_NO_PTT_SUPPORT
        [[[ITMGContext GetInstance] GetPTT] StartRecording:recordfilePath];
        [self StartMonitor:true];
#endif
    }
    if (sender.tag == 6) {
         [_indicator startAnimating];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [paths objectAtIndex:0];
        
        
        static int index = 0;
        
        recordfilePath = [docDir stringByAppendingFormat:@"/test_%d.ptt",index++];
        
        if([fileManager fileExistsAtPath:recordfilePath]){
            [fileManager removeItemAtPath:recordfilePath error:nil];
        }
#ifndef TMG_NO_PTT_SUPPORT
        [[[ITMGContext GetInstance] GetPTT] StartRecordingWithStreamingRecognition:recordfilePath language:@"cmn-Hans-CN"];
         [self StartMonitor:true];
#endif
    }

}

-(void)buttonTouchUpInside:(UIButton*)sender{
    
    switch (sender.tag)
    {
#ifndef TMG_NO_PTT_SUPPORT
//        case 0: //开始录制
//        case 6: //停止录制
        case 8:
        {
            NSLog(@"=================121212");
            [[[ITMGContext GetInstance] GetPTT] StopRecording];
            [self StopMonitor];
            NSLog(@"=================141414");
            break;
           
        }
        case 9:
        {
            [_indicator stopAnimating];
            [[[ITMGContext GetInstance] GetPTT] CancelRecording];
            [self StopMonitor];
            _localFileField.text = @"录音取消";
        }
            
            break;
        case 1: //上传
        {
        
        [[[ITMGContext GetInstance] GetPTT] UploadRecordedFile:_localFileField.text];
        [_indicator startAnimating];

        }
            break;
        case 2://下载
        {
           
                [_indicator startAnimating];
                
                NSFileManager *fileManager = [NSFileManager defaultManager];
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *docDir = [paths objectAtIndex:0];
                
                static int index = 0;
                
                donwLoadLocalPath =[docDir stringByAppendingFormat:@"/download_%d.ptt",index++];
                
                if([fileManager fileExistsAtPath:donwLoadLocalPath]){
                    [fileManager removeItemAtPath:donwLoadLocalPath error:nil];
                }
                [[[ITMGContext GetInstance] GetPTT] DownloadRecordedFile: _donwloadUrlField.text  filePath:donwLoadLocalPath];
        }
            break;
            case 3://播放
            
        {
              //  if(!isPlaying)
                {
                    isPlaying = true;
                    [self StartMonitor:false];
                    [[[ITMGContext GetInstance] GetPTT] PlayRecordedFile:_audiofileToPlayField.text];
                   
                }
//                else
//                {
//                     [[[ITMGContext GetInstance] GetPTT] StopPlayFile];
//                }
        }
            break;
            case 4://转文本
        {
                [_indicator startAnimating];
            
                [[[ITMGContext GetInstance] GetPTT] SpeechToText:_donwloadUrlField.text];
      
        }
            break;
            
            case 5://时长
        {

                UITextField *_audiofileLength =(UITextField*)objc_getAssociatedObject(self, [PTT_AUDIOFILE_LENGTH UTF8String]);
                _audiofileLength.text = [NSString stringWithFormat:@"文件时长:%f", [[[ITMGContext GetInstance] GetPTT] GetVoiceFileDuration:_audiofileToPlayField.text]/1000.0f] ;

        }
            break;
            case 7://播放本地文件
            {

                    if(!isPlaying)
                    {
                        isPlaying = true;
                        [self StartMonitor:false];
                        [[[ITMGContext GetInstance] GetPTT] PlayRecordedFile:_localFileField.text];
                    }
                    else
                    {
                        [[[ITMGContext GetInstance] GetPTT] StopPlayFile];
                    }
            }
            break;
            case 10:
        {
            recordfilePath = NULL;
            donwLoadUrlPath = NULL;
            donwLoadLocalPath = NULL;
            for (int i = 0; i<5; i++)
            {
                NSString *templeString = _ContainArray[i][1];
                UITextField * value =  objc_getAssociatedObject(self,[templeString UTF8String]);
                value.text = @"";
            }
        }
        default:
            break;
    }
#endif

}

-(void)buttonTouchUpOutside:(UIButton*)sender{
        if (sender.tag == 0||sender.tag == 6) {
#ifndef TMG_NO_PTT_SUPPORT
        [_indicator stopAnimating];
        [[[ITMGContext GetInstance] GetPTT] CancelRecording];
            //UITextField *_localFileField =(UITextField*)objc_getAssociatedObject(self, [PTT_LOCALFILE UTF8String]);
            _localFileField.text = @"录音取消";
#endif
        }
}



-(void)BackButtonPresse
{
    [[DispatchCenter getInstance] removeDelegate:self];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
