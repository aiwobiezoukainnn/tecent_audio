package com.tencent.testaudio;


import android.content.Intent;

import com.tencent.TMG.ITMGContext;

/**
 * Created by baixs on 2017/11/20.
 */

public interface TMGDispatcherBase {
    public void OnEvent(ITMGContext.ITMG_MAIN_EVENT_TYPE type, Intent data);
}
