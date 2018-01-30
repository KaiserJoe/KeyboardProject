#ifndef __HELLOWORLD_SCENE_H__
#define __HELLOWORLD_SCENE_H__

#include "cocos2d.h"
#include "SoftKeyboard.h"



class KeyboardContr : public cocos2d::Layer, private SoftKeyboardDelete
{
public:
    
    KeyboardContr(){};
    
    ~KeyboardContr(){};
    
    static cocos2d::Scene* createScene();

    virtual bool init();
    
    // a selector callback
    void menuCloseCallback(cocos2d::Ref* pSender);
    
    // implement the "static create()" method manually
    CREATE_FUNC(KeyboardContr);

    void showKeyboard();
    
    void removeKeyboard();
    
private:
    
	/**
	 ** SoftKeyboardDelete fun
	 ** 回传密码数据
	 **/
	virtual void _onSoftKeyboardDidBegin(void);
	
	/**
	 ** SoftKeyboardDelete fun
	 ** 回传密码数据
	 **/
	virtual void _onSoftKeyboardInputDidRenturn(bool suc);
	
	/**
	 ** SoftKeyboardDelete fun
	 ** 键盘消失回调函数
	 ** 隐藏当前cocos2dx view
	 **/
	virtual void _onSoftKeyboardDidHidden(void);
};

#endif // __HELLOWORLD_SCENE_H__
