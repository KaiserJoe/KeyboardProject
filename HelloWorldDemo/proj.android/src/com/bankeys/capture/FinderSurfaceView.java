/**
 *  2014-7-15   上午11:14:21
 *  Created By niexiaoqiang
 */

package com.bankeys.capture;

import android.content.Context;
import android.util.AttributeSet;
import android.util.Log;
import android.view.SurfaceHolder;
import android.opengl.GLSurfaceView;

/**
 * capture surfaceView
 * @author jamesliu
 */
public class FinderSurfaceView extends GLSurfaceView{
	private static String TAG = "FinderSurfaceView";
	
	public FinderSurfaceView(Context context) {
		super(context);
	}

	public FinderSurfaceView(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	@Override
	public void surfaceChanged(SurfaceHolder arg0, int arg1, int arg2, int arg3) {
		// TODO Auto-generated method stub
		Log.d(TAG, "******FinderSurfaceView::surfaceChanged****");	
	}

	@Override
	public void surfaceCreated(SurfaceHolder arg0) {
		// TODO Auto-generated method stub
		Log.d(TAG, "******FinderSurfaceView::surfaceCreated****");	
	}

	@Override
	public void surfaceDestroyed(SurfaceHolder arg0) {
		// TODO Auto-generated method stub
		Log.d(TAG, "******FinderSurfaceView::surfaceDestroyed****");	
	}
}
