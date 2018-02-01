package com.bankeys.view;

public interface OnSDKListener {
	/**
	 ** 退出插件回调函数 隐藏当前cocos2dx view
	 **/
	public void notifyApp(String szJson);

	public void notifyKeyInput(String result);
}
