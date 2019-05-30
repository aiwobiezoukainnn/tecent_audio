package com.tencent.testaudio;
import com.tencent.TMG.ITMGContext;
import com.tencent.av.sdk.AVError;
import com.tencent.av.sig.AuthBuffer;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;

import android.text.method.ScrollingMovementMethod;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RadioGroup;
import android.widget.SeekBar;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;

import java.io.File;

import java.io.FileOutputStream;
import java.io.InputStream;

public class RoomFragment extends Fragment implements View.OnClickListener,TMGDispatcherBase,CompoundButton.OnCheckedChangeListener,SeekBar.OnSeekBarChangeListener{
    private static final String TAG = "RoomFragment";
    private View root;

    EditText mEditRoomID = null;
    EditText mEditMaxMixCount = null;
    EditText mEditSongname = null;

    RadioGroup mRadioGroupRoomType = null;
    RadioGroup mRadioGroupStreamType = null;


    Button mBtnEnterRoom = null;
    Button mBtnExitRoom = null;

    Button mBtnChangeRoomType = null;
    Button mBtnGetQualityTips = null;
    Button mBtnLayoutClose = null;

    Switch mSwitchCapture = null;
    Switch mSwitchSend = null;
    Switch mSwitchPlayDevice = null;
    Switch mSwitchRecv = null;
    Switch mSwitchLoopback = null;
    Switch mSwtichAcc = null;
    Switch mSwitchVoicetype = null;

    LinearLayout mLayoutLogcat = null;

    TextView mTextLog = null;
    TextView mTextGetMicVolume = null;
    TextView mTextGetSpeakerVolume = null;

    SeekBar mBarSetMicVolume = null;
    SeekBar mBarSetSpeakVolume = null;

    String sdkAppId     =null;
    String key          =null;
    String identifier   =null;
    String strRoomID    =null;
    String strRoomType  =null;

    private Handler handler = new Handler();
    private Runnable task = new Runnable() {
        @Override
        public void run() {
            handler.postDelayed(this,2*1000);
            mTextLog.setText(ITMGContext.GetInstance(getActivity()).GetRoom().GetQualityTips());
        }
    };

    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        root = inflater.inflate(R.layout.fragment_room, container, false);

        mEditRoomID = (EditText)root.findViewById(R.id.edit_user_roomid);
        mEditRoomID.setText("201806");
        mEditMaxMixCount = (EditText)root.findViewById(R.id.edit_max_mix_count);
        mEditMaxMixCount.setText("6");
        mEditSongname = (EditText) root.findViewById(R.id.edit_song_name);
        mEditSongname.setText("song.mp3");

        mRadioGroupRoomType = (RadioGroup) root.findViewById(R.id.rgroup_roomtype);
        mRadioGroupRoomType.check(R.id.btn_roomType_1);
        mRadioGroupStreamType = (RadioGroup) root.findViewById(R.id.rgroup_streamtype);
        mRadioGroupStreamType.check(R.id.btn_streamType_0);

        mLayoutLogcat = (LinearLayout) root.findViewById(R.id.layout_logcat);
        mLayoutLogcat.setVisibility(View.GONE);

        mSwitchCapture = (Switch) root.findViewById(R.id.switch_capture);
        mSwitchSend = (Switch) root.findViewById(R.id.switch_send);
        mSwitchPlayDevice = (Switch) root.findViewById(R.id.switch_play);
        mSwitchRecv = (Switch) root.findViewById(R.id.switch_Recv);
        mSwitchLoopback = (Switch) root.findViewById(R.id.switch_loopback);
        mSwtichAcc = (Switch) root.findViewById(R.id.switch_acc);
        mSwitchVoicetype = (Switch) root.findViewById(R.id.switch_voicetype);

        mTextLog = (TextView) root.findViewById(R.id.textview_logcat);
        mTextLog.setMovementMethod(ScrollingMovementMethod.getInstance());

        mBtnEnterRoom = (Button) root.findViewById(R.id.btn_enter_room);
        mBtnExitRoom = (Button) root.findViewById(R.id.btn_exit_room);

        mBtnChangeRoomType = (Button) root.findViewById(R.id.btn_change_roomtype);
        mBtnGetQualityTips = (Button) root.findViewById(R.id.btn_quality);
        mBtnLayoutClose= (Button) root.findViewById(R.id.btn_layout_close);

        mBarSetMicVolume = (SeekBar) root.findViewById(R.id.seekBar_setMicVolume);
        mBarSetSpeakVolume = (SeekBar) root.findViewById(R.id.seekBar_setSpeVolume);

        mTextGetMicVolume = (TextView) root.findViewById(R.id.text_getMicVolume);
        mTextGetSpeakerVolume = (TextView) root.findViewById(R.id.text_getSpeVolume);

        TMGCallbackDispatcher.getInstance().AddDelegate(ITMGContext.ITMG_MAIN_EVENT_TYPE.ITMG_MAIN_EVNET_TYPE_USER_UPDATE, this);
        TMGCallbackDispatcher.getInstance().AddDelegate(ITMGContext.ITMG_MAIN_EVENT_TYPE.ITMG_MAIN_EVENT_TYPE_EXIT_ROOM, this);
        TMGCallbackDispatcher.getInstance().AddDelegate(ITMGContext.ITMG_MAIN_EVENT_TYPE.ITMG_MAIN_EVENT_TYPE_ROOM_DISCONNECT, this);
        TMGCallbackDispatcher.getInstance().AddDelegate(ITMGContext.ITMG_MAIN_EVENT_TYPE.ITMG_MAIN_EVNET_TYPE_USER_VOLUMES, this);
        TMGCallbackDispatcher.getInstance().AddDelegate(ITMGContext.ITMG_MAIN_EVENT_TYPE.ITMG_MAIN_EVENT_TYPE_ACCOMPANY_FINISH, this);
        TMGCallbackDispatcher.getInstance().AddDelegate(ITMGContext.ITMG_MAIN_EVENT_TYPE.ITMG_MAIN_EVENT_TYPE_CHANGE_ROOM_TYPE, this);

        try {
            String filePath = getActivity().getExternalFilesDir(null).toString()+"/song.mp3";

            InputStream is = getActivity().getApplicationContext().getAssets().open("song.mp3");

            FileOutputStream fos = new FileOutputStream(new File(filePath));
            byte[] buffer = new byte[1024];
            int byteCount=0;
            while((byteCount=is.read(buffer))!=-1) {
                fos.write(buffer, 0, byteCount);
            }
            fos.flush();//刷新缓冲区
            is.close();
            fos.close();
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return root;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);

        mBtnEnterRoom.setOnClickListener(this);
        mBtnExitRoom.setOnClickListener(this);
        mBtnChangeRoomType.setOnClickListener(this);
        mBtnGetQualityTips.setOnClickListener(this);
        mBtnLayoutClose.setOnClickListener(this);

        mSwitchCapture.setOnCheckedChangeListener(this);
        mSwitchSend.setOnCheckedChangeListener(this);
        mSwitchPlayDevice.setOnCheckedChangeListener(this);
        mSwitchRecv.setOnCheckedChangeListener(this);
        mSwitchLoopback.setOnCheckedChangeListener(this);
        mSwtichAcc.setOnCheckedChangeListener(this);
        mSwitchVoicetype.setOnCheckedChangeListener(this);

        mBarSetMicVolume.setOnSeekBarChangeListener(this);
        mBarSetSpeakVolume.setOnSeekBarChangeListener(this);

        ((Switch) root.findViewById(R.id.switch_keraoketype)).setOnCheckedChangeListener(this);
    }

    public void onClick(View v){
        switch (v.getId()){
            case R.id.btn_enter_room:
                Log.e(TAG,"btn_enter_room");
                if(MainActivity.isInit==false){
                    Toast.makeText(getActivity(), String.format("Init before enter room"), Toast.LENGTH_SHORT).show();
                    return;
                }
                TMGCallbackDispatcher.getInstance().AddDelegate(ITMGContext.ITMG_MAIN_EVENT_TYPE.ITMG_MAIN_EVENT_TYPE_ENTER_ROOM, this);
                //获取roomtype等参数
                strRoomType  = "1";
                switch (mRadioGroupRoomType.getCheckedRadioButtonId()){
                    case R.id.btn_roomType_1:
                        strRoomType = "1";
                        break;
                    case R.id.btn_roomType_2:
                        strRoomType = "2";
                        break;
                    case R.id.btn_roomType_3:
                        strRoomType = "3";
                        break;
                }
                Log.d(TAG,"strRoomType="+strRoomType);
                String strMaxMixCount = mEditMaxMixCount.getText().toString();
                String strSpeakerType = "0";
                switch (mRadioGroupStreamType.getCheckedRadioButtonId()){
                    case R.id.btn_streamType_0:
                        strSpeakerType = "0";
                        break;
                    case R.id.btn_streamType_1:
                        strSpeakerType = "1";
                        break;
                    case R.id.btn_streamType_2:
                        strSpeakerType = "2";
                        break;
                }
                Log.d(TAG,"strSpeakerType="+strSpeakerType);
                switch (mRadioGroupRoomType.getCheckedRadioButtonId()){
                    case R.id.btn_roomType_1:
                        strRoomType = "1";
                        break;
                    case R.id.btn_roomType_2:
                        strRoomType = "2";
                        break;
                    case R.id.btn_roomType_3:
                        strRoomType = "3";
                        break;
                }
                ITMGContext.GetInstance(getActivity()).SetRecvMixStreamCount(Integer.valueOf(strMaxMixCount));
                ITMGContext.GetInstance(getActivity()).SetAdvanceParams("SetSpeakerStreamType", strSpeakerType);

                strRoomID    = mEditRoomID.getText().toString();

                if(sdkAppId.isEmpty()==false){
                    //实时语音：4、进房鉴权。
                    byte[] authBuffer =  AuthBuffer.getInstance().genAuthBuffer(Integer.parseInt(sdkAppId), strRoomID, identifier, key);
                    //实时语音：5、实时语音进房，进房要在初始化SDK之后。
                    ITMGContext.GetInstance(getActivity()).EnterRoom(strRoomID, Integer.valueOf(strRoomType), authBuffer);
                }

                break;
            case R.id.btn_exit_room:
                //实时语音：11、退出房间。
                ITMGContext.GetInstance(getActivity()).ExitRoom();
                break;

            case R.id.btn_change_roomtype:
                switch (mRadioGroupRoomType.getCheckedRadioButtonId()){
                    case R.id.btn_roomType_1:
                        strRoomType = "1";
                        break;
                    case R.id.btn_roomType_2:
                        strRoomType = "2";
                        break;
                    case R.id.btn_roomType_3:
                        strRoomType = "3";
                        break;
                }
                //实时语音：10、实时语音房间类型修改，返回的结果参见回调（根据业务需求调用）。
                ITMGContext.GetInstance(getActivity()).GetRoom().ChangeRoomType(Integer.valueOf(strRoomType));

                break;
            case R.id.btn_quality:
                mLayoutLogcat.setVisibility(View.VISIBLE);
                handler.post(task);
                break;

            case R.id.btn_layout_close:
                mLayoutLogcat.setVisibility(View.GONE);
                handler.removeCallbacks(task);
                break;
        }



    }

    @Override
    public void onCheckedChanged(CompoundButton compoundButton, boolean b) {
        switch (compoundButton.getId()){
            case R.id.switch_capture:
                Log.d(TAG,"capture");
                //实时语音：6、实时语音采集设备开启。（进房成功后才可以操作设备）
                ITMGContext.GetInstance(getActivity()).GetAudioCtrl().EnableAudioCaptureDevice(b);
                break;
            case R.id.switch_send:
                Log.d(TAG,"send");
                //实时语音：7、实时语音上行开启。
                ITMGContext.GetInstance(getActivity()).GetAudioCtrl().EnableAudioSend(b);
                break;
            case R.id.switch_play:
                //实时语音：8、实时语音播放设备开启。
                ITMGContext.GetInstance(getActivity()).GetAudioCtrl().EnableAudioPlayDevice(b);
                break;
            case R.id.switch_Recv:
                //实时语音：9、实时语音下行开启。
                ITMGContext.GetInstance(getActivity()).GetAudioCtrl().EnableAudioRecv(b);
                break;
            case R.id.switch_loopback:
                //实时语音：开启耳返
                ITMGContext.GetInstance(getActivity()).GetAudioCtrl().EnableLoopBack(b);
                break;
            case R.id.switch_acc:
                Log.i(TAG,"startAcc");
                String filePath = getActivity().getExternalFilesDir(null).toString() + "/"+ mEditSongname.getText();
                if(b){
                    //实时语音：播放伴奏
                    ITMGContext.GetInstance(getActivity()).GetAudioEffectCtrl().StartAccompany(filePath, true, 1);
                }else{
                    ITMGContext.GetInstance(getActivity()).GetAudioEffectCtrl().StopAccompany(1);
                }
                break;
            case R.id.switch_voicetype:
                if(b){
                    //实时语音：设置变声特效
                    ITMGContext.GetInstance(getActivity()).GetAudioEffectCtrl().SetVoiceType(1);
                }else{
                    ITMGContext.GetInstance(getActivity()).GetAudioEffectCtrl().SetVoiceType(0);
                }
                break;

                case R.id.switch_keraoketype:
                if(b){
                    //实时语音：设置变声特效
                    ITMGContext.GetInstance(getActivity()).GetAudioEffectCtrl().SetKaraokeType(1);
                }else{
                    ITMGContext.GetInstance(getActivity()).GetAudioEffectCtrl().SetKaraokeType(0);
                }
                break;

        }

    }


    @Override
    public void OnEvent(ITMGContext.ITMG_MAIN_EVENT_TYPE type, Intent data) {
        if (ITMGContext.ITMG_MAIN_EVENT_TYPE.ITMG_MAIN_EVENT_TYPE_ENTER_ROOM == type)
        {
            int nErrCode = TMGCallbackHelper.ParseIntentParams2(data).nErrCode;
            String strMsg = TMGCallbackHelper.ParseIntentParams2(data).strErrMsg;

            //收到进房信令， 进房成功， 可以操作设备
            if (nErrCode == AVError.AV_OK)
            {
                Log.i(TAG,"EnterRoom success!");
                Toast.makeText(getActivity(), String.format("EnterRoomComplete"), Toast.LENGTH_SHORT).show();

                RefreshUI();
            }
            else
            {
                Toast.makeText(getActivity(), String.format("result=%d, errorInfo=%s", nErrCode, strMsg), Toast.LENGTH_SHORT).show();
            }
        }
        else if (ITMGContext.ITMG_MAIN_EVENT_TYPE.ITMG_MAIN_EVENT_TYPE_CHANGE_ROOM_TYPE == type)
        {
            //切换房间类型回调
            int code = data.getIntExtra("result", 0);
            String strErrInfo = data.getStringExtra("error_info");
            int nNewRoomType = data.getIntExtra("new_room_type", 0);
            int nSubEventType = data.getIntExtra("sub_event_type", 0);
            Log.i(TAG,"changeroomtype");
            switch (nSubEventType)
            {
                case ITMGContext.ITMG_ROOM_CHANGE_EVENT_ENTERROOM:
                    Toast.makeText(getActivity(), String.format("已经切换为原始房间类型:%d!", nNewRoomType), Toast.LENGTH_SHORT).show();
                    break;
                case ITMGContext.ITMG_ROOM_CHANGE_EVENT_START:
                    break;
                case ITMGContext.ITMG_ROOM_CHANGE_EVENT_COMPLETE:
                    Toast.makeText(getActivity(), String.format("房间已经被切换为:%d!", nNewRoomType), Toast.LENGTH_SHORT).show();
                    switch (nNewRoomType){
                        case 1:
                            mRadioGroupRoomType.check(R.id.btn_roomType_1);
                            break;
                        case 2:
                            mRadioGroupRoomType.check(R.id.btn_roomType_2);
                            break;
                        case 3:
                            mRadioGroupRoomType.check(R.id.btn_roomType_3);
                            break;
                    }
                    break;
                case ITMGContext.ITMG_ROOM_CHANGE_EVENT_REQUEST:
                    Toast.makeText(getActivity(), String.format("切换房间类型返回值:%d!", code), Toast.LENGTH_SHORT).show();
                    break;
            }
        }
        else if(ITMGContext.ITMG_MAIN_EVENT_TYPE.ITMG_MAIN_EVENT_TYPE_EXIT_ROOM == type){
            Toast.makeText(getActivity(), String.format("ExitRoomComplete"), Toast.LENGTH_SHORT).show();
            Log.i(TAG,"ExitRoomComplete");
            RefreshUI();
        }
        else if(ITMGContext.ITMG_MAIN_EVENT_TYPE.ITMG_MAIN_EVENT_TYPE_ROOM_DISCONNECT == type){
            Toast.makeText(getActivity(), String.format("房间网络原因断链"), Toast.LENGTH_SHORT).show();
            Log.i(TAG,"RoomDisconnect");

            RefreshUI();
        }
        else if ( ITMGContext.ITMG_MAIN_EVENT_TYPE.ITMG_MAIN_EVENT_TYPE_ACCOMPANY_FINISH == type){
            int code = data.getIntExtra("result", 0);
            boolean is_finished = data.getBooleanExtra("is_finished", false);

            if (code == 0){
                if (is_finished){
                    String filePath = getActivity().getExternalFilesDir(null).toString()+"/song.mp3";
                    ITMGContext.GetInstance(getActivity()).GetAudioEffectCtrl().StartAccompany(filePath,true,1);
                }
            }

            Log.i(TAG,String.format("is_finished:%b,code:%d",is_finished,code) );
        }
    }

    public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
        switch (seekBar.getId()){
            case R.id.seekBar_setMicVolume:
                ITMGContext.GetInstance(getActivity()).GetAudioCtrl().SetMicVolume(progress);
                mTextGetMicVolume.setText(Integer.toString(progress));
                break;
            case R.id.seekBar_setSpeVolume:
                ITMGContext.GetInstance(getActivity()).GetAudioCtrl().SetSpeakerVolume(progress);
                mTextGetSpeakerVolume.setText(Integer.toString(progress));
                break;
       }
    }//开始滑动

    public void onStartTrackingTouch(SeekBar seekBar) {

    }

    @Override
    public void onStopTrackingTouch(SeekBar seekBar) {

    }
    public void RefreshUI()
    {
        mSwitchCapture.setChecked(ITMGContext.GetInstance(getActivity()).GetAudioCtrl().IsAudioCaptureDeviceEnabled());
        mSwitchSend.setChecked(ITMGContext.GetInstance(getActivity()).GetAudioCtrl().IsAudioSendEnabled());
        mSwitchPlayDevice.setChecked(ITMGContext.GetInstance(getActivity()).GetAudioCtrl().IsAudioPlayDeviceEnabled());
        mSwitchRecv.setChecked(ITMGContext.GetInstance(getActivity()).GetAudioCtrl().IsAudioRecvEnabled());
        mSwitchLoopback.setChecked(false);
        mSwtichAcc.setChecked(false);
        int Micvolume = ITMGContext.GetInstance(getActivity()).GetAudioCtrl().GetMicVolume();
        mTextGetMicVolume.setText(Integer.toString(Micvolume));
        mBarSetMicVolume.setProgress(Micvolume);
        int Speakvolume = ITMGContext.GetInstance(getActivity()).GetAudioCtrl().GetSpeakerVolume();
        mTextGetSpeakerVolume.setText(Integer.toString(Speakvolume));
        mBarSetSpeakVolume.setProgress(Speakvolume);
        mSwitchVoicetype.setChecked(false);
    }

    public void RefreshAppInfo(String msdkAppId,String mkey,String midentifier){
        Log.e(TAG,"RefreshAppInfo");
        sdkAppId     =msdkAppId;
        key          =mkey;
        identifier   =midentifier;

    }

    @Override
    public void onDestroy(){
        //降低内存， 将无用的监听事件清理出去（看需求是否清除，业务逻辑判定）
        TMGCallbackDispatcher.getInstance().RemoveDelegate(ITMGContext.ITMG_MAIN_EVENT_TYPE.ITMG_MAIN_EVENT_TYPE_ENTER_ROOM, this);
        TMGCallbackDispatcher.getInstance().RemoveDelegate(ITMGContext.ITMG_MAIN_EVENT_TYPE.ITMG_MAIN_EVNET_TYPE_USER_UPDATE, this);
        TMGCallbackDispatcher.getInstance().RemoveDelegate(ITMGContext.ITMG_MAIN_EVENT_TYPE.ITMG_MAIN_EVENT_TYPE_EXIT_ROOM, this);
        TMGCallbackDispatcher.getInstance().RemoveDelegate(ITMGContext.ITMG_MAIN_EVENT_TYPE.ITMG_MAIN_EVENT_TYPE_ROOM_DISCONNECT, this);
        TMGCallbackDispatcher.getInstance().RemoveDelegate(ITMGContext.ITMG_MAIN_EVENT_TYPE.ITMG_MAIN_EVENT_TYPE_ACCOMPANY_FINISH, this);
        TMGCallbackDispatcher.getInstance().RemoveDelegate(ITMGContext.ITMG_MAIN_EVENT_TYPE.ITMG_MAIN_EVENT_TYPE_CHANGE_ROOM_TYPE, this);
        super.onDestroy();
    }
}
