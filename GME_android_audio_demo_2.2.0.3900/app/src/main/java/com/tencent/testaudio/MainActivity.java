package com.tencent.testaudio;
import android.Manifest;
import android.app.Activity;
import android.app.Application;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;

import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.util.Log;
import android.view.*;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;

import com.tencent.TMG.ITMGContext;
import com.tencent.av.sdk.AVError;
import com.tencent.av.sig.AuthBuffer;

import java.net.URL;
import java.net.URLConnection;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;


public class MainActivity extends FragmentActivity implements View.OnClickListener{
	private static final String TAG = "MainActivity";
	private PttFragment pttFragment;
	private RoomFragment roomFragment;
	Button mBtnPtt = null;
	Button mBtnRealtime = null;
	Switch mAutoPause = null;
	FragmentManager fm;

	EditText mEditAppID = null;
	EditText mEditKey = null;
	EditText mEditUserID = null;


	Switch mSwitchTestEnv = null;

	Button mBtnInit = null;
	Button mBtnUninit = null;

	String sdkAppId     =null;
	String key          =null;
	String identifier   =null;

	static boolean isInit = false;

	static String g_TestEnv = "0";
	static long mUserId = 0;

	static {
		mUserId = System.currentTimeMillis() % 1000000;
	}


	@Override
	protected void onPause() {
		super.onPause();
		if (mAutoPause.isChecked()) {
			// Just For Test, ignore this function
			EnginePollHelper.pauseEnginePollHelper();
        	ITMGContext.GetInstance(this).Pause();
		}
	}

	@Override
	protected void onResume() {
		super.onResume();
		if (mAutoPause.isChecked()) {
			// Just For Test, ignore this function
			EnginePollHelper.resumeEnginePollHelper();
			ITMGContext.GetInstance(this).Resume();
		}
	}

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        //初始化fragment
		fm = getSupportFragmentManager();
		setTabSelection(1);
		Log.d(TAG,"oncreate");

		mAutoPause = (Switch) findViewById(R.id.switch_AutoPause);

		mBtnPtt = (Button) findViewById(R.id.btn_ptt);
		mBtnPtt.setOnClickListener(this);

		mBtnRealtime = (Button) findViewById(R.id.btn_realtime);
		mBtnRealtime.setOnClickListener(this);

		mEditAppID = (EditText) findViewById(R.id.edit_app_id);
		mEditAppID.setText("1400089356");

		mEditUserID = (EditText) findViewById(R.id.edit_user_id);
		mEditUserID.setText(mUserId+ "");

		mEditKey = (EditText) findViewById(R.id.edit_app_key);
		mEditKey.setText("1cfbfd2a1a03a53e");

		mSwitchTestEnv = (Switch) findViewById(R.id.switch_TestEnv);
		mSwitchTestEnv.setChecked(false);

		mBtnInit = (Button) findViewById(R.id.btn_Init);
		mBtnInit.setOnClickListener(this);

		mBtnUninit =(Button) findViewById(R.id.btn_Uninit);
		mBtnUninit.setOnClickListener(this);

		((TextView)findViewById(R.id.text_sdk_version)).setText("Version: " + ITMGContext.GetInstance(this).GetSDKVersion());

		if (Build.VERSION.SDK_INT >= 23) {
			int REQUEST_CODE_CONTACT = 101;
			String[] permissions = {Manifest.permission.INTERNET, Manifest.permission.RECORD_AUDIO, Manifest.permission.WRITE_EXTERNAL_STORAGE};
			//验证是否许可权限
			for (String str : permissions) {
				if (this.checkSelfPermission(str) != PackageManager.PERMISSION_GRANTED) {
					//申请权限
					this.requestPermissions(permissions, REQUEST_CODE_CONTACT);
				}
			}
		}
    }

    //用于fragment切换
	private void setTabSelection(int index){
		FragmentTransaction ft = fm.beginTransaction();
		if(pttFragment==null){
			pttFragment = new PttFragment();
			ft.add(R.id.container, pttFragment,"pttFragment");
		}
		if(roomFragment==null){
			roomFragment = new RoomFragment();
			ft.add(R.id.container, roomFragment,"roomFragment");
		}
		hideFragment(ft);
		switch (index) {
			case 0:
//				if(isInit == false){
//					//使用ptt前需要初始化SDK
//					Toast.makeText(this, String.format("Init before use PTT"), Toast.LENGTH_SHORT).show();
//					return;
//				}
				ft.show(pttFragment);
				break;
			case 1:
				ft.show(roomFragment);
				break;
		}
		ft.commit();
	}

	//用于隐藏fragment
	private void hideFragment(FragmentTransaction ft){
		if(pttFragment!=null){
			ft.hide(pttFragment);
		}if(roomFragment!=null){
			ft.hide(roomFragment);
		}
	}

	@Override
	public void onClick(View v) {
		switch(v.getId()){
			case R.id.btn_ptt: {
				setTabSelection(0);
			}
			break;
			case R.id.btn_realtime: {
				setTabSelection(1);
				break;
			}
			case R.id.btn_Init:{
				Log.i(TAG, "start context...");

				//获取相关信息
				sdkAppId     = mEditAppID.getText().toString();
				key          = mEditKey.getText().toString();
				identifier   = mEditUserID.getText().toString();
				//1、初始化SDK，使用SDK必须先调用此接口。
				ITMGContext.GetInstance(this).Init(sdkAppId, identifier);
				//2、设置Poll，请周期性的调用Poll接口以保证接口正常使用。
				EnginePollHelper.createEnginePollHelper();
				//3、设置委托。
				ITMGContext.GetInstance(this).SetTMGDelegate(TMGCallbackDispatcher.getInstance().getItmgDelegate());
				//测试时调用
				ITMGContext.GetInstance(this).SetAppVersion("Engine: Native");

				String strTestEnv = "0";
				//设置是否测试环境（业务层无需调用）
				if (mSwitchTestEnv.isChecked()) {
					strTestEnv = "1";
				} else {
					strTestEnv = "0";
				}
				g_TestEnv = strTestEnv;
				if (strTestEnv.compareTo("1") == 0)
				{
					Toast.makeText(this, String.format("进入测试环境"), Toast.LENGTH_SHORT).show();
				}
				else
				{
					Toast.makeText(this, String.format("进入正式环境"), Toast.LENGTH_SHORT).show();
				}
				ITMGContext.GetInstance(this).SetAdvanceParams("TestEnv", strTestEnv);

				RoomFragment mroomFragment = (RoomFragment) getSupportFragmentManager().findFragmentByTag("roomFragment");
				mroomFragment.RefreshAppInfo(sdkAppId,key,identifier);

				PttFragment mpttFragment = (PttFragment) getSupportFragmentManager().findFragmentByTag("pttFragment");
				mpttFragment.RefreshAppInfo(sdkAppId,key,identifier);
				//离线语音：4、离线语音鉴权，离线语音鉴权时roomID必须为0。
                if(sdkAppId.isEmpty()==false){
                    byte[] authBuffer =  AuthBuffer.getInstance().genAuthBuffer(Integer.parseInt(sdkAppId), "0", identifier, key);
                    ITMGContext.GetInstance(this).GetPTT().ApplyPTTAuthbuffer(authBuffer);
                }

				Toast.makeText(this, String.format("InitComplete"), Toast.LENGTH_SHORT).show();

				isInit  = true;
				break;
			}
			case R.id.btn_Uninit: {
				Log.d(TAG, "UninitComplete");
				ITMGContext.GetInstance(this).Uninit();
				isInit = false;
				break;
			}
			default:
				break;
		}
	}
    
    @Override
    protected void onDestroy(){
    	super.onDestroy();
    }

    public void onBackPressed(){
		super.onBackPressed();
		System.exit(0);
		Log.e(TAG,"onBackPressed");
	}
}
