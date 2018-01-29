/**
 *  2014-7-15   上午11:14:21
 *  Created By niexiaoqiang
 */

package com.bankeys.capture;

import java.io.IOException;

import com.bankeys.capture.MyFinderView.OnQRDecodeListener;
import com.bankeys.ebankqrcode.R;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.hardware.Camera;
import android.hardware.Camera.AutoFocusCallback;
import android.hardware.Camera.PreviewCallback;
import android.hardware.Camera.Size;
import android.os.AsyncTask;
import android.os.Handler;
import android.util.AttributeSet;
import android.util.Log;
import android.view.SurfaceHolder;
import android.view.View;

import android.opengl.GLSurfaceView;

/**
 * 查找框
 * 
 * @author niexiaoqiang,jamesliu
 */
public class FinderView extends View implements SurfaceHolder.Callback {
	private static String TAG = "FinderView";
	
	private Context mContext =null;
	private SurfaceHolder mHolder= null;
	private static OnQRDecodeListener s_OnQRDecodeListener = null;
	
	private static final long ANIMATION_DELAY = 30;
	private Paint mFinderMaskPaint= null;
	private int mMeasureedWidth;
	private int mMeasureedHeight;
	private boolean mRun = true;

	private Camera mCamera= null;
	private Handler mAutoFocusHandler= null;
	private boolean mPreviewing = true;
	private AsyncDecode mAsyncDecode;
	
	private Rect topRect = new Rect();
	private Rect bottomRect = new Rect();
	private Rect rightRect = new Rect();
	private Rect leftRect = new Rect();
	private Rect middleRect = new Rect();

	private Rect lineRect = new Rect();
	private Drawable zx_code_kuang;
	private Drawable zx_code_line;
	private int lineHeight;

	private Drawable zx_code_title;
	private Rect titleRect = new Rect();
	
	public FinderView(Context context, GLSurfaceView surface_view) {
		super(context);

		mHolder = surface_view.getHolder();
		mHolder.setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);
		mHolder.addCallback(this);

		mContext = context;
		
		mAutoFocusHandler = new Handler();
		mAsyncDecode = new AsyncDecode();
		
		init(context);
	}

	public FinderView(Context context, AttributeSet attrs) {
		super(context, attrs);
		
		mContext = context;
		
		mAutoFocusHandler = new Handler();
		mAsyncDecode = new AsyncDecode();
		
		init(context);
	}

	@Override
	protected void onDraw(Canvas canvas) {
		super.onDraw(canvas);
		
		if(!mRun){
			return;
		}
		
		//标题
		zx_code_title.setBounds(titleRect);
		zx_code_title.draw(canvas);
		
		//半透底色
		canvas.drawRect(leftRect, mFinderMaskPaint);
		canvas.drawRect(topRect, mFinderMaskPaint);
		canvas.drawRect(rightRect, mFinderMaskPaint);
		canvas.drawRect(bottomRect, mFinderMaskPaint);
		// 画框
		zx_code_kuang.setBounds(middleRect);
		zx_code_kuang.draw(canvas);
		if (lineRect.bottom < middleRect.bottom) {
			zx_code_line.setBounds(lineRect);
			lineRect.top = lineRect.top + lineHeight / 2;
			lineRect.bottom = lineRect.bottom + lineHeight / 2;
		} else {
			lineRect.set(middleRect);
			lineRect.bottom = lineRect.top + lineHeight;
			zx_code_line.setBounds(lineRect);
		}
		zx_code_line.draw(canvas);
		postInvalidateDelayed(ANIMATION_DELAY, middleRect.left, middleRect.top,
				middleRect.right, middleRect.bottom);
	}
	
	private void init(Context context) {
		int finder_mask = context.getResources().getColor(R.color.finder_mask);
		mFinderMaskPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
		mFinderMaskPaint.setColor(finder_mask);
		zx_code_kuang = context.getResources().getDrawable(
				R.drawable.zx_code_kuang);
		zx_code_line = context.getResources().getDrawable(
				R.drawable.zx_code_line);
		lineHeight = 30;
		
		zx_code_title = context.getResources().getDrawable(
				R.drawable.zx_code_16);
	}

	// ////////////新增该方法//////////////////////
	/**
	 * 根据图片size求出矩形框在图片所在位置，tip：相机旋转90度以后，拍摄的图片是横着的，所有传递参数时，做了交换
	 * 
	 * @param w
	 * @param h
	 * @return
	 */
	public Rect getScanImageRect(int w, int h) {
		// 先求出实际矩形
		Rect rect = new Rect();
		rect.left = middleRect.left;
		rect.right = middleRect.right;
		float temp = h / (float) mMeasureedHeight;
		rect.top = (int) (middleRect.top * temp);
		rect.bottom = (int) (middleRect.bottom * temp);
		return rect;
	}

	// //////////////////////////////////
	@Override
	protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
		super.onMeasure(widthMeasureSpec, heightMeasureSpec);
		mMeasureedWidth = MeasureSpec.getSize(widthMeasureSpec);
		mMeasureedHeight = MeasureSpec.getSize(heightMeasureSpec);
		setMeasuredDimension(mMeasureedWidth, mMeasureedHeight);
		Log.d(TAG, "measureedWidth  " + mMeasureedWidth);
		Log.d(TAG, "measureedHeight  " + mMeasureedHeight);

		int borderWidth = mMeasureedWidth / 2 + 100;
		middleRect.set((mMeasureedWidth - borderWidth) / 2,
				(mMeasureedHeight - borderWidth) / 2,
				(mMeasureedWidth - borderWidth) / 2 + borderWidth,
				(mMeasureedHeight - borderWidth) / 2 + borderWidth);
		lineRect.set(middleRect);
		lineRect.bottom = lineRect.top + lineHeight;
		leftRect.set(0, middleRect.top, middleRect.left, middleRect.bottom);
		topRect.set(0, 0, mMeasureedWidth, middleRect.top);
		rightRect.set(middleRect.right, middleRect.top, mMeasureedWidth,
				middleRect.bottom);
		bottomRect.set(0, middleRect.bottom, mMeasureedWidth, mMeasureedHeight);
		
		titleRect.set(0, 0, mMeasureedWidth, 60);
	}

	// ///////////////////////
	@Override
	public void surfaceChanged(SurfaceHolder arg0, int arg1, int arg2, int arg3) {
		// TODO Auto-generated method stub
		Log.d(TAG, "******FinderView::surfaceChanged****");

		if (mHolder.getSurface() == null) {
			return;
		}
		
		startCameraPreview();
	}

	@Override
	public void surfaceCreated(SurfaceHolder arg0) {
		// TODO Auto-generated method stub
		Log.d(TAG, "******FinderView::surfaceCreated****");
		getCamera();
		
		Log.d(TAG, "mCamera: " + mCamera);
		try {
			mCamera.setPreviewDisplay(arg0);
		} catch (IOException e) {
			Log.d(TAG, "Error setting camera preview: " + e.getMessage());
		}
	}

	@Override
	public void surfaceDestroyed(SurfaceHolder arg0) {
		// TODO Auto-generated method stub
		Log.d(TAG, "******surfaceDestroyed****");

		releaseCamera();
	}
	
	private void getCamera()
	{
		try {
			mCamera = Camera.open();
		} catch (Exception e) {
			mCamera = null;
		}
	}

	public void releaseCamera() {
		if (mCamera != null) {
			mPreviewing = false;
			mCamera.stopPreview();
			mCamera.setPreviewCallback(null);
			mCamera.release();
			mCamera = null;
		}
	}
	
	private void startCameraPreview()
	{
		try {
			mCamera.stopPreview();
			
			mCamera.setDisplayOrientation(90);
			//mCamera.setPreviewDisplay(mHolder);
			mCamera.setPreviewCallback(previewCb);
			mCamera.startPreview();
			mCamera.autoFocus(autoFocusCB);
		} catch (Exception e) {
			Log.d("DBG", "Error starting camera preview: " + e.getMessage());
		}
	}

	private Runnable doAutoFocus = new Runnable() {
		public void run() {
			if (mPreviewing)
				mCamera.autoFocus(autoFocusCB);
		}
	};

	PreviewCallback previewCb = new PreviewCallback() {
		public void onPreviewFrame(byte[] data, Camera camera) {

			if (mAsyncDecode.isStoped()) {
				
				Camera.Parameters parameters = camera.getParameters();
				Size size = parameters.getPreviewSize();

				Log.d(TAG, "******onPreviewFrame****");
				Log.d(TAG, "******data::" + data);
				if (data == null) {
					Log.d(TAG, "******bad data****");
					return;
				}

				CaptureImage img = new CaptureImage(data, size);
				mAsyncDecode = new AsyncDecode();
				mAsyncDecode.execute(img);
				
				/*int nRet = nativeScanImage(data, size.width,
						size.height);
				Log.d(TAG, "******nRet::" + nRet);
				if(nRet == 1)
				{
					mPreviewing = false;
					
				}*/
				
				
			}
		}
	};

	// Mimic continuous auto-focusing
	AutoFocusCallback autoFocusCB = new AutoFocusCallback() {
		public void onAutoFocus(boolean success, Camera camera) {
			mAutoFocusHandler.postDelayed(doAutoFocus, 1000);
		}
	};

	// 使用AsyncTask类，以下是几条必须遵守的准则：
	// Task的实例必须在UI thread中创建；
	// execute方法必须在UI thread中调用；
	// 不要手动的调用onPreExecute(), onPostExecute(Result)，doInBackground(Params...),
	// onProgressUpdate(Progress...)这几个方法；
	// 该task只能被执行一次，否则多次调用时将会出现异常；
	private class AsyncDecode extends AsyncTask<CaptureImage, Void, Integer> {
		private boolean stoped = true;

		// 后台执行，比较耗时的操作都可以放在这里。注意这里不能直接操作UI。此方法在后台线程执行，完成任务的主要工作，通常需要较长的时间。在执行过程中可以调用publicProgress(Progress…)来更新任务的进度。
		@Override
		protected Integer doInBackground(CaptureImage... params) {
			stoped = false;
			CaptureImage img = params[0];
			int nRet = nativeScanImage(img.data, img.size.width,
					img.size.height);

			Log.d(TAG, "******nRet::" + nRet);

			return nRet;
		}

		// 相当于Handler 处理UI的方式，在这里面可以使用在doInBackground 得到的结果处理操作UI。
		// 此方法在主线程执行，任务执行的结果作为此方法的参数返回
		@Override
		protected void onPostExecute(Integer result) {
			super.onPostExecute(result);
			Log.d(TAG, "******onPostExecute******");
			stoped = true;
			
			if (result == 1) {
				
				releaseCamera();
	
				if (s_OnQRDecodeListener != null) {
					s_OnQRDecodeListener.onResult(1);
				}
			}
		}

		public boolean isStoped() {
			return stoped;
		}
	}

	/**
	 * 照相机抓拍数据
	 * @author liuyong
	 */
	private class CaptureImage {
		public byte[] data;
		public Size size;

		public CaptureImage(final byte[] _data, final Size _size) {
			data = _data;
			size = _size;
		}
	}
	
	
	
	/**
	 * 设置扫码监听器
	 * @param listener
	 */
	public static void setOnQRDecodeListener(OnQRDecodeListener listener)
	{
		s_OnQRDecodeListener = listener;
	}
	
	/**
	 * C++调用此方法
	 */
	public static void ReQRDecoder(){
		s_OnQRDecodeListener.onReDecoder();
	}
	
	/**
	 * JAVA调用此方法
	 */
	public void reQRDecoder()
	{
		getCamera();
		
		startCameraPreview();
	}
	
	/**
	 * JAVA调用此方法
	 */
	public void stopRun()
	{
		mRun = false;
	}
	
	/**
	 * JAVA调用此方法
	 */
	public void showTipDialog(String szTitle,String szContent)
	{
		new AlertDialog.Builder(mContext)
				.setTitle(szTitle)
				// 设置对话框标题
				.setMessage(szContent)
				// 设置显示的内容
				.setPositiveButton("确定", new DialogInterface.OnClickListener() {// 添加确定按钮
							@Override
							public void onClick(DialogInterface dialog,
									int which) {// 确定按钮的响应事件
								// TODO Auto-generated method stub
								s_OnQRDecodeListener.onExitQRDecode();
							}
						})
				.setNegativeButton("返回", new DialogInterface.OnClickListener() {// 添加返回按钮
							@Override
							public void onClick(DialogInterface dialog,
									int which) {// 响应事件
								// TODO Auto-generated method stub
								Log.i("alertdialog", " 请保存数据！");
							}

						}).show();// 在按键响应事件中显示此对话框
	}
	
	/**
	 * JAVA调用此方法
	 */
	public static native int nativeScanImage(byte[] imageData, int nWidth,
			int nHeight);
	
	/**
	 * JAVA调用此方法
	 */
	public static native int nativeProcessScanResult();
	
}
