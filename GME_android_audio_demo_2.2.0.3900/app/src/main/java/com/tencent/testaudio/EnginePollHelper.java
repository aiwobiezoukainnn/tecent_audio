package com.tencent.testaudio;
import android.content.Intent;
import android.media.midi.MidiManager;
import android.os.Handler;
import android.os.Message;
import android.util.Log;

import com.tencent.TMG.ITMGContext;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;


public class EnginePollHelper {

    private static EnginePollHelper s_enginePollHelper = null;
    private static boolean s_pollEnabled = true;

    public static void createEnginePollHelper() {
        if (s_enginePollHelper == null) {
            s_enginePollHelper = new EnginePollHelper();
            s_enginePollHelper.startTimer();
        }
    }

    public static void destroyEnginePollHelper() {
        if (s_enginePollHelper != null) {
            s_enginePollHelper.stopTimer();
            s_enginePollHelper = null;
        }
    }

    public static void pauseEnginePollHelper() {
        s_pollEnabled = false;
    }

    public static void resumeEnginePollHelper() {
        s_pollEnabled = true;
    }

    private Handler mhandler = new Handler();
    private Runnable mRunnable = new Runnable() {
        @Override
        public void run() {
            if (s_pollEnabled) {
                if (ITMGContext.GetInstance(null) != null)
                    ITMGContext.GetInstance(null).Poll();
            }
            mhandler.postDelayed(mRunnable, 33);
        }
    };

    EnginePollHelper() {

    }

    private void startTimer() {
        mhandler.postDelayed(mRunnable, 33);
    }

    private void stopTimer() {
        mhandler.removeCallbacks(mRunnable);
    }
}
