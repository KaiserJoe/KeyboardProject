#include "KeyboardContr.h"
#include "LogUtil.h"
USING_NS_CC;
SoftKeyboard* m_pSoftKeyboard;

#define font_default     "arial"
#define font_normal_size 34.0f
#define delay_time       0.02f

extern "C"
{
    void notifyApp();
    
    void nativeSdkFuntion(const char* pJson,int mode){

        auto scene = Director::getInstance()->getRunningScene();
        auto board = (KeyboardContr*)scene->getChildByTag(1999);
        
        if (board == nullptr) {
           
            // 'layer' is an autorelease object
            board = KeyboardContr::create();
            
            // add layer as a child to scene
            scene->addChild(board,0,1999);
        }
        
        Director::getInstance()->getScheduler()->performFunctionInCocosThread([&]()
                                                                              
        {
            
            ////////////////////// To Do Something !! ///////////////////////////////////////////
        });
        
        board->showKeyboard();
        
    }
    
}

Scene* KeyboardContr::createScene()
{
    // 'scene' is an autorelease object
    auto scene = Scene::create();
    
    // 'layer' is an autorelease object
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
    
 /*   Vec2 origin     = Director::getInstance()->getVisibleOrigin();
    float xOffset   = origin.x;
    float yOffset   = origin.y;
    
    m_pSoftKeyboard = SoftKeyboard::CreateWithDelet(this,1);
    m_pSoftKeyboard->setPosition(xOffset, yOffset);
    this->addChild(m_pSoftKeyboard);*/
    
    
    cocos2d::Size  m_BgSize  = Director::getInstance()->getWinSize();
    LayerColor*layer=LayerColor::create(Color4B(0xFF, 0x00, 0x00, 0x80));
    //新版中,用create新建新图层,建立的新图层只有一个颜色
    layer->ignoreAnchorPointForPosition(false);
    layer->setPosition(m_BgSize.width/2, m_BgSize.height/2);
    this->addChild(layer);
    
    LogUtil::NSLog("开始init");
    //获取设计窗口大小
    //Size desiSize    = Director::getInstance()->getOpenGLView()->getVisibleSize();
    //LogUtil::NSLog("高:%f 宽:%f", desiSize.height, desiSize.width);
    //键盘窗口大小
    //cocos2d::Size  m_BgSize = Size(desiSize .width, desiSize.height);
    //setContentSize(m_BgSize);
    
    //背景裁剪窗口
  /*  cocos2d::ui::ScrollView * m_pBgScrow = cocos2d::ui::ScrollView::create();
    m_pBgScrow->setContentSize(m_BgSize);
    m_pBgScrow->setPosition(Vec2(m_BgSize.width/2, m_BgSize.height/2));
    m_pBgScrow->setScrollBarWidth(4);
    m_pBgScrow->setScrollBarPositionFromCorner(Vec2(2, 2));
    m_pBgScrow->setScrollBarColor(Color3B::BLACK);
    m_pBgScrow->setTouchEnabled(false);
    this->addChild(m_pBgScrow);*/
    
    LogUtil::NSLog("完成控件");
    //密码键盘背景
    cocos2d::ui::ImageView* m_pBgSoftKeyboardInput = cocos2d::ui::ImageView::create("ebres/uis/sfk_06.png");
    //    m_SoftKeyboardBgSize = m_pBgSoftKeyboardInput->getContentSize();
    m_pBgSoftKeyboardInput->setAnchorPoint(Vec2(0.0f, 0.0f));
    m_pBgSoftKeyboardInput->setPosition(Vec2(0.0f, 0.0f));
    this->addChild(m_pBgSoftKeyboardInput);
    LogUtil::NSLog("完成控件");
    //密文密码背景
    cocos2d::ui::ImageView * m_pBgPwdText =cocos2d::ui::ImageView::create("ebres/uis/yanzhengma_03.png");
    m_pBgPwdText->setAnchorPoint(Vec2(0.5f, 0.5f));
    m_pBgPwdText->setPosition(Vec2(m_BgSize.width*0.5f, m_BgSize.height*0.62f));
    this->addChild(m_pBgPwdText);
    LogUtil::NSLog("完成控件");
    
    cocos2d::ui::Text* pTitle = cocos2d::ui::Text::create("输入密码", font_default, font_normal_size);//30.0f->
    pTitle->setAnchorPoint(Vec2(0.5f, 1.0f));
    pTitle->setPosition(Vec2(m_pBgPwdText->getContentSize().width*0.5f, m_pBgPwdText->getContentSize().height*0.93f));
    m_pBgPwdText->addChild(pTitle,1,1);
    
    LogUtil::NSLog("完成控件");
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
    
    notifyApp();
}

void KeyboardContr::menuCloseCallback(Ref* pSender)
{
    Director::getInstance()->end();

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    exit(0);
#endif
}
