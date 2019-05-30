package com.tencent.testaudio;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import com.tencent.TMG.ITMGContext;
import com.tencent.av.sig.AuthBuffer;

public class PttFragment extends Fragment implements View.OnClickListener,View.OnTouchListener,TMGDispatcherBase{

    String recordfilePath = null;
    String donwLoadUrlPath = null;
    String donwLoadLoacalPath = null;
    final  String TARGET ="PTTACTIVITY";
    int  index = 1;
    Boolean isPlaying = false;
    String sdkAppId = null;
    String identifier = null;
    String key = null;
    View root;
    boolean bIsRecording = false;

    EditText mEditTextfiletoupload = null;
    EditText mEditTextDownloadurl = null;
    EditText mEditTextfiletoplay = null;
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

        root = inflater.inflate(R.layout.fragment_ptt, container, false);

        ITMGContext.GetInstance(getActivity()).SetTMGDelegate(TMGCallbackDispatcher.getInstance().getItmgDelegate());

        TMGCallbackDispatcher.getInstance().AddDelegate(ITMGContext.ITMG_MAIN_EVENT_TYPE.ITMG_MAIN_EVNET_TYPE_PTT_UPLOAD_COMPLETE, this);
        TMGCallbackDispatcher.getInstance().AddDelegate(ITMGContext.ITMG_MAIN_EVENT_TYPE.ITMG_MAIN_EVNET_TYPE_PTT_RECORD_COMPLETE, this);
        TMGCallbackDispatcher.getInstance().AddDelegate(ITMGContext.ITMG_MAIN_EVENT_TYPE.ITMG_MAIN_EVNET_TYPE_PTT_DOWNLOAD_COMPLETE, this);
        TMGCallbackDispatcher.getInstance().AddDelegate(ITMGContext.ITMG_MAIN_EVENT_TYPE.ITMG_MAIN_EVNET_TYPE_PTT_PLAY_COMPLETE, this);
        TMGCallbackDispatcher.getInstance().AddDelegate(ITMGContext.ITMG_MAIN_EVENT_TYPE.ITMG_MAIN_EVNET_TYPE_PTT_SPEECH2TEXT_COMPLETE, this);
        TMGCallbackDispatcher.getInstance().AddDelegate(ITMGContext.ITMG_MAIN_EVENT_TYPE.ITMG_MAIN_EVNET_TYPE_PTT_STREAMINGRECOGNITION_COMPLETE,this);

        //Intent  intent = getIntent();

        //RoomFragment roomFragment = (RoomFragment) getActivity().getSupportFragmentManager().findFragmentByTag("roomFragment");
        //EditText mEditAppid= (EditText) roomFragment.getView().findViewById(R.id.edit_app_id);
        //SDKAPPID3RD = mEditAppid.getText().toString();
        //EditText mEditUserid= (EditText) roomFragment.getView().findViewById(R.id.edit_user_id);
        //USERID = mEditUserid.getText().toString();
        //EditText mEditKey= (EditText) roomFragment.getView().findViewById(R.id.edit_app_key);
        //key = mEditKey.getText().toString();

        Button mBtnLogin = (Button)root.findViewById(R.id.button_audio_record);
        mBtnLogin.setOnClickListener(this);
        mBtnLogin.setOnTouchListener(this);

        mBtnLogin = (Button)root.findViewById(R.id.button_audio_upload);
        mBtnLogin.setOnClickListener(this);

        mBtnLogin = (Button)root.findViewById(R.id.button_audio_dowload);
        mBtnLogin.setOnClickListener(this);

        mBtnLogin = (Button)root.findViewById(R.id.button_audio_play);
        mBtnLogin.setOnClickListener(this);

        mBtnLogin = (Button)root.findViewById(R.id.button_audio_text);
        mBtnLogin.setOnClickListener(this);

        mBtnLogin = (Button)root.findViewById(R.id.button_audio_length);
        mBtnLogin.setOnClickListener(this);

        mBtnLogin = (Button)root.findViewById(R.id.button_audio_clean);
        mBtnLogin.setOnClickListener(this);

        mBtnLogin = (Button)root.findViewById(R.id.button_audio_clean);
        mBtnLogin.setOnClickListener(this);

        mBtnLogin = (Button)root.findViewById(R.id.button_audio_streaming);
        mBtnLogin.setOnClickListener(this);

        mBtnLogin = (Button)root.findViewById(R.id.button_audio_streaming_finish);
        mBtnLogin.setOnClickListener(this);

        mBtnLogin = (Button)root.findViewById(R.id.button_audio_streaming_cancel);
        mBtnLogin.setOnClickListener(this);

        mBtnLogin = (Button)root.findViewById(R.id.button_audio_playLocal);
        mBtnLogin.setOnClickListener(this);

        mEditTextfiletoupload = (EditText)root.findViewById(R.id.edit_audiofile_to_upload);
        mEditTextDownloadurl  = (EditText)root.findViewById(R.id.edit_download_url);
        mEditTextfiletoplay = (EditText) root.findViewById(R.id.edit_audiofile_to_play);
        return root;
    }

    @Override
    public boolean onTouch(View v, MotionEvent event)
    {

        switch (v.getId()) {
            case R.id.button_audio_record: {
                if(event.getAction() == MotionEvent.ACTION_UP)
                {

                    int[] location = new int[2];
                    v.getLocationOnScreen(location);

                    int CenterX= (v.getRight()+v.getLeft())/2;
                    int  CenterY = (v.getTop()+v.getBottom())/2;
                    if (Math.abs(CenterX - event.getX())>100||Math.abs(CenterY - event.getY())>100)
                    {
                        ITMGContext.GetInstance(getActivity()).GetPTT().CancelRecording();
                        bIsRecording = false;
                        recordfilePath = null;
                        donwLoadUrlPath = null;
                        donwLoadLoacalPath = null;

                        mEditTextfiletoupload.setText(String.format(""));
                    }
                    else
                    {
                        //离线语音：6、停止录音
                        ITMGContext.GetInstance(getActivity()).GetPTT().StopRecording();
                    }


                }
                if(event.getAction() == MotionEvent.ACTION_DOWN)
                {
                    //离线语音：5、开始录音（在初始化SDK及鉴权成功之后），语音最长60秒。业务上如有流式需求，参考StartRecordingWithStreamingRecognition
                    recordfilePath = getActivity().getExternalFilesDir(null).getAbsolutePath() + "/test_"+(index++)+".ptt";
                    ITMGContext.GetInstance(getActivity()).GetPTT().StartRecording(recordfilePath);
                    bIsRecording = true;
                }
            }
            break;
        }

        return  false;
    }

    @Override
    public void onPause() {
        //清空回调函数
        //清空多余事件，保证内存， 完成一次通话以及结束事件。回到原始状态
        if(bIsRecording)
        {
            ITMGContext.GetInstance(getActivity()).GetPTT().CancelRecording();
        }

        super.onPause();
    }

    @Override
    public  void onClick(View v)
    {
        switch (v.getId())
        {
            case R.id.button_audio_record:
            {

            }
            break;
            case R.id.button_audio_playLocal:
            {


                if (!isPlaying)
                {
                    isPlaying = true;

                    //离线语音播放本地语音
                    ITMGContext.GetInstance(getActivity()).GetPTT().PlayRecordedFile(recordfilePath);
                }
                else
                {
                    //离线语音暂停播放本地语音
                    ITMGContext.GetInstance(getActivity()).GetPTT().StopPlayFile();
                }

            }
            break;
            case R.id.button_audio_upload:
            {
                //离线语音：7、上传录音文件
                String _uploadPath =  mEditTextfiletoupload.getText().toString();
                if(!_uploadPath.isEmpty()) {
                    ITMGContext.GetInstance(getActivity()).GetPTT().UploadRecordedFile(_uploadPath);
                }
            }
            break;
            case R.id.button_audio_dowload:
            {
                //离线语音：8、下载录音文件（上传成功之后）
                String templedownload = getActivity().getExternalFilesDir(null).getAbsolutePath()+ "/downLoad_"+(index++)+".ptt";
                String _downloadurl =  mEditTextDownloadurl.getText().toString();
                if(!_downloadurl.isEmpty()) {
                    ITMGContext.GetInstance(getActivity()).GetPTT().DownloadRecordedFile(_downloadurl, templedownload);
                }
            }
            break;
            case R.id.button_audio_play:
            {
                    if (!isPlaying)
                    {
                        String _downloadlocalpath =  mEditTextfiletoplay.getText().toString();
                        if(!_downloadlocalpath.isEmpty()) {
                            ITMGContext.GetInstance(getActivity()).GetPTT().PlayRecordedFile(_downloadlocalpath);
                            isPlaying = true;
                        }
                    }
                    else
                    {
                        ITMGContext.GetInstance(getActivity()).GetPTT().StopPlayFile();
                    }

                }
                break;
            case R.id.button_audio_text:
            {
                    //离线语音：9、语音转文字（上传成功之后），文字回调中返回。
                String _downloadurl =  mEditTextDownloadurl.getText().toString();
                if(!_downloadurl.isEmpty()) {
                    ITMGContext.GetInstance(getActivity()).GetPTT().SpeechToText(_downloadurl);
                }
            }
            break;
            case R.id.button_audio_length:
            {
                    EditText _editText = (EditText) root.findViewById(R.id.edit_audio_length);
                String _downloadlocalpath =  mEditTextfiletoplay.getText().toString();
                if(!_downloadlocalpath.isEmpty()) {
                    _editText.setText(String.format("%f", ITMGContext.GetInstance(getActivity()).GetPTT().GetVoiceFileDuration(_downloadlocalpath) / 1000.0));
                }
            }
            break;
            case R.id.button_audio_streaming:
            {
                    //离线语音：5、开始流式录音翻译（在初始化SDK及鉴权成功之后）。翻译的内容在回调中提供。
                    String  temple = getActivity().getExternalFilesDir(null).getAbsolutePath() + "/test_"+(index++)+".ptt";
                    ITMGContext.GetInstance(getActivity()).GetPTT().StartRecordingWithStreamingRecognition(temple,"cmn-Hans-CN");
            }
            break;
            case R.id.button_audio_streaming_finish:
            {
                ITMGContext.GetInstance(getActivity()).GetPTT().StopRecording();
                break;
            }
            case R.id.button_audio_streaming_cancel:
            {
                ITMGContext.GetInstance(getActivity()).GetPTT().CancelRecording();
                break;
            }
            case R.id.button_audio_clean:
            {

                recordfilePath = null;
                donwLoadUrlPath = null;
                donwLoadLoacalPath = null;

                EditText _editText = (EditText)root.findViewById(R.id.edit_audiofile_to_upload);
                _editText.setText(String.format(""));

                _editText = (EditText)root.findViewById(R.id.edit_download_url);
                _editText.setText(String.format(""));

                _editText = (EditText)root.findViewById(R.id.edit_audiofile_to_play);
                _editText.setText(String.format(""));

                _editText = (EditText)root.findViewById(R.id.edit_audio_to_text);
                _editText.setText(String.format(""));

                _editText = (EditText)root.findViewById(R.id.edit_audio_length);
                _editText.setText(String.format(""));

            }
            break;
        }
    }


    @Override
    public void OnEvent(ITMGContext.ITMG_MAIN_EVENT_TYPE type, Intent data) {
        final int nErrCode =  data.getIntExtra("result",-2);
        final  Intent templeData = data;
        switch (type)
        {
            case ITMG_MAIN_EVNET_TYPE_PTT_STREAMINGRECOGNITION_COMPLETE:
            {
                //流式离线语音回调。
                Handler mainHander = new Handler(Looper.getMainLooper());
                mainHander.post(new Runnable() {
                    @Override
                    public void run() {
                if (nErrCode ==0) {

                    String textString = templeData.getStringExtra("text");
                    EditText _editText = (EditText) root.findViewById(R.id.edit_audio_to_text);
                    _editText.setText(textString);

                    recordfilePath = templeData.getStringExtra("file_path");
                    mEditTextfiletoupload.setText(recordfilePath);

                    donwLoadUrlPath = templeData.getStringExtra("file_id");
                    mEditTextDownloadurl.setText(donwLoadUrlPath);

                    Log.e(TARGET, "STREAMINGRECOGNITION" + "nErrCode=" + nErrCode + ", content=" + textString+"recordfilePath"+recordfilePath+"donwLoadUrlPath"+donwLoadUrlPath);
                }
                else
                {

                    Toast.makeText(getActivity(), String.format("流式语音转文本失败，错误代码：%d",nErrCode), Toast.LENGTH_SHORT).show();
                    Log.e(TARGET, "流式语音转文本失败,错误代码"+nErrCode);
                }
                    }
                });

            }
                break;
            case ITMG_MAIN_EVNET_TYPE_PTT_RECORD_COMPLETE:
            {
                bIsRecording = false;
                Handler mainHander = new Handler(Looper.getMainLooper());
                mainHander.post(new Runnable() {
                    @Override
                    public void run() {
                        Log.e(TARGET,String.format("ITMG_MAIN_EVNET_TYPE_PTT_RECORD_COMPLETE_  errorcode:%d",nErrCode));
                        if (nErrCode ==0)
                        {
                            recordfilePath = templeData.getStringExtra("file_path");
                            mEditTextfiletoupload.setText(recordfilePath);
                        }
                        else
                        {
                            recordfilePath = null;
                            Toast.makeText(getActivity(), String.format("录制文件失败，错误代码：%d",nErrCode), Toast.LENGTH_SHORT).show();
                        }
                    }
                });

            }
            break;
            case ITMG_MAIN_EVNET_TYPE_PTT_UPLOAD_COMPLETE:
            {

                Handler mainHander = new Handler(Looper.getMainLooper());
                mainHander.post(new Runnable() {
                    @Override
                    public void run() {
                        if (nErrCode ==0)
                        {
                            donwLoadUrlPath = templeData.getStringExtra("file_id");
                            mEditTextDownloadurl.setText(donwLoadUrlPath);
                        }
                        else
                        {
                            donwLoadUrlPath = null;
                            Toast.makeText(getActivity(), String.format("上传文件失败，错误代码：%d",nErrCode), Toast.LENGTH_SHORT).show();
                        }
                    }
                });


            }
            break;
            case  ITMG_MAIN_EVNET_TYPE_PTT_DOWNLOAD_COMPLETE:
            {

                Handler mainHander = new Handler(Looper.getMainLooper());
                mainHander.post(new Runnable() {
                    @Override
                    public void run() {
                        if (nErrCode == 0) {
                            donwLoadLoacalPath = templeData.getStringExtra("file_path");
                            mEditTextfiletoplay.setText(donwLoadLoacalPath);

                        } else {
                            donwLoadLoacalPath = null;
                            Toast.makeText(getActivity(), String.format("下载失败，错误代码：%d", nErrCode), Toast.LENGTH_SHORT).show();
                        }
                    }
                });

            }

            break;

            case ITMG_MAIN_EVNET_TYPE_PTT_PLAY_COMPLETE:
            {
                isPlaying = false;


                Handler mainHander = new Handler(Looper.getMainLooper());
                mainHander.post(new Runnable() {
                    @Override
                    public void run() {
                        if (nErrCode == 0) {

                            Toast.makeText(getActivity(), String.format("播放成功" ), Toast.LENGTH_SHORT).show();
                        } else {

                            Toast.makeText(getActivity(), String.format("播放失败" ), Toast.LENGTH_SHORT).show();
                        }
                    }
                });

            }
            break;
            case ITMG_MAIN_EVNET_TYPE_PTT_SPEECH2TEXT_COMPLETE:
            {

                Handler mainHander = new Handler(Looper.getMainLooper());
                mainHander.post(new Runnable() {
                    @Override
                    public void run() {
                        if (nErrCode ==0)
                        {
                            //离线语音：10、语音转文字成功。
                            String textString=templeData.getStringExtra("text");
                            EditText _editText = (EditText)root.findViewById(R.id.edit_audio_to_text);
                            _editText.setText(textString);
                        }
                        else
                        {
                            Toast.makeText(getActivity(), String.format("语音转文本失败，错误代码：%d",nErrCode), Toast.LENGTH_SHORT).show();
                        }
                    }
                });
            }
            break;

        }

    }

    public void onDestroy(){
        super.onDestroy();
    }

    public void RefreshAppInfo(String msdkAppId,String mkey,String midentifier){
        sdkAppId     =msdkAppId;
        key          =mkey;
        identifier   =midentifier;

    }

}
