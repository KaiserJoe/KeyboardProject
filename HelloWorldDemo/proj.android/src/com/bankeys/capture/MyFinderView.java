/**
 *  2014-7-15   上午11:14:21
 *  Created By niexiaoqiang
 */

package com.bankeys.capture;

import android.app.Activity;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.RelativeLayout;

/**
 * QR扫码
 * @author jamesliu
 */
public class MyFinderView {
	private static String TAG = "MyFinderView";
	
	private Activity mContext =null;
	private int mScreenWidth;
	private int mScreenHeight;
	private FinderView mFinderView = null;
	
	public MyFinderView(Activity context,int w,int h) {
		mContext = context;
		mScreenWidth = w;
		mScreenHeight = h;
	}
	
	public void showFinderView(){
        FinderSurfaceView _surfaceView = new FinderSurfaceView(mContext);//getGLSurfaceView();
		
        //capture view
		FrameLayout.LayoutParams params = new FrameLayout.LayoutParams( mScreenWidth, mScreenHeight);
		params.gravity = Gravity.CENTER;
		mContext.addContentView(_surfaceView, params);
		
        //decode view
		mFinderView = new FinderView(mContext,_surfaceView);
		FrameLayout.LayoutParams params2 = new FrameLayout.LayoutParams( mScreenWidth, mScreenHeight);
		params2.gravity = Gravity.CENTER;
		mContext.addContentView(mFinderView, params2);
		
		//cancle button
		Button cancleBtn= new Button(mContext);
		cancleBtn.setText("取消");
		cancleBtn.setTextColor(android.graphics.Color.WHITE);
		cancleBtn.getBackground().setAlpha(0);//0~255透明度值
		cancleBtn.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) {
				Log.d(TAG, "******cancleBtn.setOnClickListener****");
				mFinderView.releaseCamera();
				stopRun();
				showQRDecodeTip("系统提示","扫码取消啦");
			}
		});
		RelativeLayout rl = new RelativeLayout(mContext); 
		RelativeLayout.LayoutParams params3 = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
		params3.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
		params3.addRule(RelativeLayout.CENTER_HORIZONTAL);
		rl.addView(cancleBtn, params3 );    
		
		FrameLayout.LayoutParams params4 = new FrameLayout.LayoutParams( mScreenWidth, mScreenHeight);
		mContext.addContentView(rl, params4);
	}
	
	public void stopRun(){
		mFinderView.stopRun();
	}
	
	public void showQRDecodeTip(String szTitle,String szContent){
		mFinderView.showTipDialog(szTitle,szContent);
	}
	
	public void nativeProcessScanResult(){
		FinderView.nativeProcessScanResult();
	}
	
	public void setOnQRDecodeListener(OnQRDecodeListener listener)
	{
		FinderView.setOnQRDecodeListener(listener);
	}
	
	/**
	 * 扫码监听器接口
	 * @author liuyong
	 */
	public interface OnQRDecodeListener {
		public void onResult(int nCount);
		
		public void onReDecoder();
		
		public void onExitQRDecode();
	}
	
}
