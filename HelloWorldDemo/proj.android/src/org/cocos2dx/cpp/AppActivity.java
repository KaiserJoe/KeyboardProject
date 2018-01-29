/****************************************************************************
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2011      Zynga Inc.
Copyright (c) 2013-2014 Chukong Technologies Inc.
 
http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
 ****************************************************************************/
package org.cocos2dx.cpp;

import org.cocos2dx.lib.Cocos2dxActivity;

import com.bankeys.capture.MyFinderView;

import android.os.Bundle;
import android.os.Handler;
import android.util.DisplayMetrics;
import android.util.Log;

public class AppActivity extends Cocos2dxActivity implements MyFinderView.OnQRDecodeListener  {

	private static String TAG = "debug";
    
	MyFinderView mFinderView = null;
	private Handler mHandler = new Handler();
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
         
		showQRDecodeView();
	}
	
	@Override
	protected void onPause()
	{
		 super.onPause();
		 Log.d(TAG, "********onPause********");
	}
	
	@Override
	protected void onResume()
	{
		super.onResume();
		
		Log.d(TAG, "********onResume********");
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		
		Log.d(TAG, "********onDestroy********");
	}
	 
	public void showQRDecodeView()
	{
		// 添加扫描视图
		DisplayMetrics dm = new DisplayMetrics();

		this.getWindowManager().getDefaultDisplay().getMetrics(dm);
		float screenWidth = dm.widthPixels;
		float screenHeight = dm.heightPixels;
		int w = (int) (screenWidth * 1.0);
		int h = (int) (screenHeight * 1.0);
		Log.d(TAG, "screenWidth::" + screenWidth);
		Log.d(TAG, "screenHeight::" + screenHeight);
		Log.d(TAG, "w::" + w);
		Log.d(TAG, "h::" + h);
				
		mFinderView = new MyFinderView(this,w,h);
		mFinderView.setOnQRDecodeListener(this);
		mFinderView.showFinderView();
	}

	//MyFinderView.OnQRDecodeListener start
	@Override
	public void onResult(int nCount) {
		// TODO Auto-generated method stub
		if(nCount == 1)
		{
			//((ViewGroup)mFinderView.getParent()).removeView(mFinderView);
			//mFinderView = null;
			//mFinderView.nativeProcessScanResult();
			mFinderView.stopRun();
			mFinderView.showQRDecodeTip("系统提示","扫码成功啦");
		}
	}

	@Override
	public void onReDecoder() {
		// TODO Auto-generated method stub
		mHandler.post(new Runnable() {
			public void run() {
				//showQRDecodeView(m_surfaceView);
				//mFinderView.reQRDecoder();
			}
		});
		
		
	}

	@Override
	public void onExitQRDecode() {
		// TODO Auto-generated method stub
		finish();
	}
	//MyFinderView.OnQRDecodeListener end
}
