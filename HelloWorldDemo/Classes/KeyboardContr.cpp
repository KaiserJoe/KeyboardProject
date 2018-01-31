#include "KeyboardContr.h"
#include "LogUtil.h"
USING_NS_CC;
SoftKeyboard* m_pSoftKeyboard;

#define font_default     "arial"
#define font_normal_size 34.0f
#define delay_time       0.02f

extern "C"
{
    void notifyApp(const char*Json);
    
    void nativeSdkFuntion(){

        auto scene = Director::getInstance()->getRunningScene();
        auto board = (KeyboardContr*)scene->getChildByTag(1999);
        
        if (board == nullptr) {
           
            // 'layer' is an autorelease object
            board = KeyboardContr::create();
            
            // add layer as a child to scene
            scene->addChild(board,0,1999);
        }        
        board->showKeyboard();
        
    }
    
}

Scene* KeyboardContr::createScene()
{
    // 'scene' is an autorelease object
    auto scene = Scene::create();
    
    // 'layer' is an autorelease objects
    auto layer = KeyboardContr::create();
    
    // add layer as a child to scene
    scene->addChild(layer,0,1999);

    // return the scenex
    return scene;
}

// on "init" you need to initialize your instance
bool KeyboardContr::init()
{
    if ( !Layer::init() )
    {
        return false;
    }
    
    return true;
}

void KeyboardContr::showKeyboard()
{
    LogUtil::NSLog("创建键盘");
    
    Vec2 origin     = Director::getInstance()->getVisibleOrigin();
    float xOffset   = origin.x;
    float yOffset   = origin.y;
    
    m_pSoftKeyboard = SoftKeyboard::CreateWithDelet(this,1);
    m_pSoftKeyboard->setPosition(xOffset, yOffset);
    this->addChild(m_pSoftKeyboard);
}

void KeyboardContr::_onSoftKeyboardDidBegin(void)
{
	
}
/**
 ** 键盘回传密码数据
 **/
 void KeyboardContr::_onSoftKeyboardInputDidRenturn(bool suc)
{
    removeKeyboard();
}
/**
 ** 键盘消失回调函数
 **/
 void KeyboardContr::_onSoftKeyboardDidHidden(void)
{
    removeKeyboard();
}

void KeyboardContr::removeKeyboard()
{
    if (m_pSoftKeyboard!=nullptr) {
        m_pSoftKeyboard->removeFromParentAndCleanup(true);
        m_pSoftKeyboard = nullptr;
    }
    this->removeFromParentAndCleanup(true);
    
    notifyApp("{\"code\": \"0000\",\"message\": \"操作完成\"}");
}

void KeyboardContr::menuCloseCallback(Ref* pSender)
{
    Director::getInstance()->end();

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    exit(0);
#endif
}
