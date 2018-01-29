//
//  SoftKeyboard.cpp
//  SafeModule
//
//  Created by liuyong on 16/1/5.
//
//

#include "SoftKeyboard.h"
#include "LogUtil.h"

#define font_default     "arial"
#define font_normal_size 34.0f
#define delay_time       0.02f
USING_NS_CC;
using namespace ui;
using namespace extension;

extern "C"
{
    void notifyKeyInput(const char*resutStr);
}

    //图片缩放比例
    float nImageScalRate = 1.4f;

	SoftKeyboard::SoftKeyboard():m_BgSize(Size::ZERO),m_SoftKeyboardBgSize(Size::ZERO),m_pBgPwdText(nullptr),m_pBgSoftKeyboardInput(nullptr),m_pBgScrow(nullptr),m_nTotalPwdCount(6),m_pCurPwdTextIndicate(nullptr),m_pSoftKeyboardDelete(nullptr),m_nWorkMode(0),m_pRefreshVerificationBtn(nullptr),m_pInputTimeImg(nullptr)
	{
		//LogUtil::NSLog("SoftKeyboard");
	}
	
	SoftKeyboard::~SoftKeyboard()
	{
		//LogUtil::NSLog("~SoftKeyboard");
	}
	
	
    void Swap(short &a, short &b)
    {
        // 有可能swap同一变量，不能用异或版本
        int t = a;
        a = b;
        b = t;
    }
    
    void RandomShuffle(short a[], int n)
    {
        srand( (unsigned int)time(0) );
        for(int i=0; i<n; ++i)
        {
            int j = rand() % (n-i) + i;// 产生i到n-1间的随机数
            Swap(a[i], a[j]);
        }
    }
	
    
    SoftKeyboard* SoftKeyboard::CreateWithDelet(SoftKeyboardDelete* pSoftKeyboardDelete,int nWorkMode)
    {
        SoftKeyboard *pRet = new SoftKeyboard();
        if (pRet && pRet->init(pSoftKeyboardDelete,nWorkMode))
        {
            pRet->autorelease();
            return pRet;
        }
        else
        {
            delete pRet;
            pRet = NULL;
            return NULL;
        }
    }
	bool SoftKeyboard::init(SoftKeyboardDelete* pSoftKeyboardDelete,int nWorkMode)
	{
		if(!Layer::init())
		{
			return false;
		}
		
        
		m_pSoftKeyboardDelete = pSoftKeyboardDelete;
		
        LogUtil::NSLog("开始init");
		//获取设计窗口大小
		Size desiSize    = Director::getInstance()->getOpenGLView()->getVisibleSize();
        LogUtil::NSLog("高:%f 宽:%f", desiSize.height, desiSize.width);
		//键盘窗口大小
		m_BgSize = Size(desiSize .width, desiSize.height);
		setContentSize(m_BgSize);
		
        //密码键盘背景
        /*cocos2d::ui::ImageView * m_pBgSoftKeyboardInput = cocos2d::ui::ImageView::create("ebres/uis/sfk_06.png");
        
        m_pBgSoftKeyboardInput->setAnchorPoint(Vec2(0.0f, 0.0f));
        m_pBgSoftKeyboardInput->setPosition(Vec2(0.0f, 0.0f));
        this->addChild(m_pBgSoftKeyboardInput);*/
        

       
		//背景裁剪窗口
		/*m_pBgScrow = ui::ScrollView::create();
		m_pBgScrow->setContentSize(m_BgSize);
		m_pBgScrow->setPosition(cocos2d::Point(0.0f,0.0));
		m_pBgScrow->setScrollBarWidth(4);
		m_pBgScrow->setScrollBarPositionFromCorner(Vec2(2, 2));
		m_pBgScrow->setScrollBarColor(Color3B::BLACK);
		m_pBgScrow->setTouchEnabled(false);
        addChild(m_pBgScrow);*/
		LogUtil::NSLog("完成控件");
		//密码键盘背景
		m_pBgSoftKeyboardInput = ImageView::create("ebres/uis/sfk_06.png");
		m_SoftKeyboardBgSize = m_pBgSoftKeyboardInput->getContentSize();
		m_pBgSoftKeyboardInput->setAnchorPoint(Vec2(0.0f, 0.0f));
		m_pBgSoftKeyboardInput->setPosition(Vec2(0.0f, 0.0f));
		this->addChild(m_pBgSoftKeyboardInput);
		LogUtil::NSLog("完成控件");
		//密文密码背景
		m_pBgPwdText = ImageView::create("ebres/uis/yanzhengma_03.png");
		m_pBgPwdText->setAnchorPoint(Vec2(0.5f, 0.5f));
		m_pBgPwdText->setPosition(Vec2(m_BgSize.width*0.5f, m_BgSize.height*0.62f));
		this->addChild(m_pBgPwdText);
		LogUtil::NSLog("完成控件");

		auto pTitle = Text::create("输入密码", font_default, font_normal_size);//30.0f->
		pTitle->setAnchorPoint(Vec2(0.5f, 1.0f));
		pTitle->setPosition(Vec2(m_pBgPwdText->getContentSize().width*0.5f, m_pBgPwdText->getContentSize().height*0.93f));
		m_pBgPwdText->addChild(pTitle,1,1);
		
        LogUtil::NSLog("完成控件");
		//键盘布局随机排布
		//resetSoftKeyView(0);
		
		return true;
	}
	
    void SoftKeyboard::resetSoftKeyView(int nCurInputTime)
    {
        LogUtil::NSLog("键盘布局");
        int n     = 10;
        short a[] = {0,1, 2, 3, 4, 5, 6, 7, 8, 9};
        RandomShuffle(a, n);
		
        //重置明文密码键
        m_PwdValueVec.clear();
        for(int i=0; i<n; ++i)
        {
            m_PwdValueVec.push_back(a[i]);
        }
        
        //清空按键纪录
        resetSelectedPwdInfor();
		
        //清理明文密码所有按键
        m_pBgSoftKeyboardInput->removeAllChildrenWithCleanup(true);
        
        //添加明文密码按键
        float nRate = 1;
        float nTouchFlagDistanceX = m_SoftKeyboardBgSize.width/3.0f;
        float nTouchFlagDistanceY = m_SoftKeyboardBgSize.height/4.0f;
        
        nImageScalRate = nImageScalRate*nRate;
        
        float nFirstX = nTouchFlagDistanceX/2.0f;
        float nFirstY = nTouchFlagDistanceY*1.5f ;
        
        for (int i = 0; i < 9; ++i)
        {
            float nPosX = nFirstX+i%3*nTouchFlagDistanceX;
            float nPosY = nFirstY+i/3*nTouchFlagDistanceY;
            
            //数字键背景
            auto pSpriteTip = Widget::create();
            pSpriteTip->setContentSize(Size(nTouchFlagDistanceX, nTouchFlagDistanceY));
            //pSpriteTip->setScale(nImageScalRate);
            int nPosDataIndex = m_PwdValueVec[i];
            pSpriteTip->setTag(nPosDataIndex);
            pSpriteTip->setAnchorPoint(Vec2(0.5f, 0.5f));
            pSpriteTip->setPosition(Vec2(nPosX, nPosY));
            m_pBgSoftKeyboardInput->addChild(pSpriteTip);
            
            //数字键
            auto pText = Text::create(StringUtils::format("%d",nPosDataIndex), "arial", font_normal_size);
            pText->setAnchorPoint(Vec2(0.5f, 0.5f));
            pText->setPosition(Vec2(pSpriteTip->getContentSize().width/2, pSpriteTip->getContentSize().height/2));
            pText->setColor(Color3B::WHITE);
            pSpriteTip->addChild(pText);
            
            //绑定键盘事件
            pSpriteTip->setTouchEnabled(true);
            pSpriteTip->addClickEventListener(CC_CALLBACK_1(SoftKeyboard::onClickSoftKey,this));
        }
		
		        LogUtil::NSLog("布局1111111111111");
		
        //第10个软键盘
        //数字键背景
        auto pSpriteTip   = Widget::create();
        pSpriteTip->setContentSize(Size(nTouchFlagDistanceX, nTouchFlagDistanceY));
        int nPosDataIndex = m_PwdValueVec[9];
        pSpriteTip->setTag(nPosDataIndex);
        pSpriteTip->setAnchorPoint(Vec2(0.5f, 0.5f));
        pSpriteTip->setPosition(Vec2(nFirstX+nTouchFlagDistanceX, nTouchFlagDistanceY/2.0f));
        m_pBgSoftKeyboardInput->addChild(pSpriteTip);
        
        //数字键
        auto pText = Text::create(StringUtils::format("%d",nPosDataIndex), "arial", font_normal_size);
        pText->setAnchorPoint(Vec2(0.5f, 0.5f));
        pText->setPosition(Vec2(pSpriteTip->getContentSize().width/2, pSpriteTip->getContentSize().height/2));
        pText->setColor(Color3B::WHITE);
        pSpriteTip->addChild(pText);
        //绑定键盘事件
        pSpriteTip->setTouchEnabled(true);
        pSpriteTip->addClickEventListener(CC_CALLBACK_1(SoftKeyboard::onClickSoftKey,this));
        
		
		
		
        //退出键盘按钮
        auto pBackBtnBg = Widget::create();
        pBackBtnBg->setContentSize(Size(nTouchFlagDistanceX, nTouchFlagDistanceY));
        pBackBtnBg->setAnchorPoint(Vec2(0.5f, 0.5f));
        pBackBtnBg->setPosition(Vec2(nFirstX, nTouchFlagDistanceY/2.0f));
        m_pBgSoftKeyboardInput->addChild(pBackBtnBg);
        //取消文本
        auto pBackBtn = Text::create("取消", /*Tools::GetResFontPath("arial.ttf")*/font_default, font_normal_size);
        pBackBtn->setColor(Color3B::WHITE);
        pBackBtn->setAnchorPoint(Vec2(0.5f, 0.5f));
        pBackBtn->setPosition(Vec2(pBackBtnBg->getContentSize().width/2.0f, pBackBtnBg->getContentSize().height/2.0f));
        pBackBtnBg->addChild(pBackBtn);
        //绑定键盘事件
        pBackBtnBg->setTouchEnabled(true);
        pBackBtnBg->addClickEventListener(CC_CALLBACK_1(SoftKeyboard::onClickSoftKeyBack,this));
		
		
		LogUtil::NSLog("布局按钮完成");
		
        //撤销键盘按钮
        auto pDeletBtnBg = Widget::create();
        pDeletBtnBg->setContentSize(Size(nTouchFlagDistanceX, nTouchFlagDistanceY));
        pDeletBtnBg->setAnchorPoint(Vec2(0.5f, 0.5f));
        pDeletBtnBg->setPosition(Vec2(nFirstX+nTouchFlagDistanceX*2.0f, nTouchFlagDistanceY/2.0f));
        m_pBgSoftKeyboardInput->addChild(pDeletBtnBg);
		
		//撤销图片
        auto pDeletBtn = ImageView::create("ebres/uis/sfk_05.png");
        pDeletBtn->setAnchorPoint(Vec2(0.5f, 0.5f));
        pDeletBtn->setPosition(Vec2(pDeletBtnBg->getContentSize().width/2.0f, pDeletBtnBg->getContentSize().height/2.0f));
        pDeletBtnBg->addChild(pDeletBtn);
        //绑定键盘事件
        pDeletBtnBg->setTouchEnabled(true);
        pDeletBtnBg->addClickEventListener(CC_CALLBACK_1(SoftKeyboard::onClickSoftKeyDelet,this));
        
        LogUtil::NSLog("2222222222222");
        
        //键盘布局弹出动画
        //playKeyboardAppearAni();
        
        
    }
    
	

    
    void SoftKeyboard::onEnter()
    {
        Layer::onEnter();

        auto listener = EventListenerTouchOneByOne::create();
        listener->setSwallowTouches(true);
        
        listener->onTouchBegan     = CC_CALLBACK_2(SoftKeyboard::onTouchBegan,this);
        listener->onTouchMoved     = CC_CALLBACK_2(SoftKeyboard::onTouchMoved,this);
        listener->onTouchEnded     = CC_CALLBACK_2(SoftKeyboard::onTouchEnded,this);
        listener->onTouchCancelled = CC_CALLBACK_2(SoftKeyboard::onTouchCancelled,this);

        auto eventDispatcher = Director::getInstance()->getEventDispatcher();
        eventDispatcher->addEventListenerWithSceneGraphPriority(listener, this);
    }
    
    void SoftKeyboard::onExit()
    {
        Layer::onExit();
    }
    
    bool SoftKeyboard::onTouchBegan(cocos2d::Touch *touch, cocos2d::Event *unused_event)
    {
        //LogUtil::NSLog("SoftKeyboard::onTouchBegan");
        
        //本触摸区判断[m_bgSize区域]
        auto size                = this->getContentSize();
        auto anchorPointInPoints = this->getAnchorPoint();
        auto rect                = cocos2d::Rect(-anchorPointInPoints.x*size.width , -anchorPointInPoints.y*size.height, size.width, size.height);
        auto localPos            = this->convertTouchToNodeSpaceAR(touch);
        if(!rect.containsPoint(localPos))
        {
            return false;
        }
        
        return true;
    }
    
    void SoftKeyboard::onTouchMoved(cocos2d::Touch *touch, cocos2d::Event *unused_event)
    {
    }
    
    void SoftKeyboard::onTouchEnded(cocos2d::Touch *touch, cocos2d::Event *unused_event)
    {
        if(m_SelectedPwdValueVec.size() >= m_nTotalPwdCount)
        {
            return;
        }
        
        //密码输满时禁止退出键盘
        playKeyboardDisAppearAni();
    }
    
    void SoftKeyboard::onTouchCancelled(cocos2d::Touch *touch, cocos2d::Event *unused_event)
    {

    }
    
    void SoftKeyboard::setInputPasCount(short nCount)
    {
        if(nCount <=0 || nCount >10)
            return;
        
        m_nTotalPwdCount = nCount;
    }
	
	/**
	 *  @author Kaiser
	 *
	 *  展开动画
	 */
    void SoftKeyboard::playKeyboardAppearAni(void)
    {
        LogUtil::NSLog("弹出1111111111111");
        
        m_pBgSoftKeyboardInput->setPosition(cocos2d::Point(0.0f,0.0f));
        
        //背景弹出动画
        auto pMove = MoveTo::create(0.3f, cocos2d::Point(0.0f,0.0f));
		
        auto pCallback = CallFunc::create([this](){
            if(m_pSoftKeyboardDelete != nullptr){
                m_pSoftKeyboardDelete->_onSoftKeyboardDidBegin();
            }
        });
        
        auto pAction = Sequence::create(pMove,pCallback, NULL);
        m_pBgScrow->runAction(pAction);
    }
	
	/**
	 *  @author Kaiser
	 *
	 *  消失动画
	 */
    void SoftKeyboard::playKeyboardDisAppearAni(void)
    {
        auto pMove = MoveTo::create(0.3f, cocos2d::Point(0.0f,-m_BgSize.height));
        
        auto pCallback = CallFunc::create([this](){
            if(m_pSoftKeyboardDelete != nullptr){
                m_pSoftKeyboardDelete->_onSoftKeyboardDidHidden();
            }
        });
        
        auto pAction = Sequence::create(pMove,pCallback, NULL);
        m_pBgScrow->runAction(pAction);
    }
    
    void SoftKeyboard::playPwdTextAppearAni(void)
    {
        
    }
    
    void SoftKeyboard::playPwdTextDisAppearAni(void)
    {
        
    }
    
	
	/**
	 *  @author Kaiser
	 *
	 *  清空显示及密码记录
	 */
    void SoftKeyboard::removePwdText(void)
    {
        if(m_SelectedPwdValueVec.size() <= 0)
        {
            return;
        }
        
        m_SelectedPwdValueVec.erase(m_SelectedPwdValueVec.end() -1);
        
        int nLastPwdIndex = (int)(m_SelectedPwdTextVec.size() -1);
        auto pPwd         = m_SelectedPwdTextVec[nLastPwdIndex];
        pPwd->removeFromParentAndCleanup(true);
        
        m_SelectedPwdTextVec.erase(m_SelectedPwdTextVec.end()-1);
        
        float nFirstX    = m_pBgPwdText->getContentSize().width*0.13f-2;
        float nFirstY    = m_pBgPwdText->getContentSize().height*0.4f-1;
        float nDistanceX = 71.0f;
        float nPosX      = nFirstX+(m_SelectedPwdValueVec.size()-1)*nDistanceX;
        float nPosY      = m_pBgPwdText->getContentSize().height*0.4f;
        float nIndicateY = m_pBgPwdText->getContentSize().height*0.4f;
		
        if(m_nWorkMode == 0 ||m_nWorkMode == 1 ||m_nWorkMode == 2)
		{
            nFirstX    = m_pBgPwdText->getContentSize().width*0.13f-2;
            nFirstY    = m_pBgPwdText->getContentSize().height*0.465f-1;
            nDistanceX = 71.0f;
            nPosX      = nFirstX+(m_SelectedPwdValueVec.size()-1)*nDistanceX;
            nPosY      = nFirstY;
            nIndicateY = m_pBgPwdText->getContentSize().height*0.465f;
        }else
		{
            nFirstX    = m_pBgPwdText->getContentSize().width*0.13f-2;
            nFirstY    = m_pBgPwdText->getContentSize().height*0.456f-1;
            nDistanceX = 71.0f;
            nPosX      = nFirstX+(m_SelectedPwdValueVec.size()-1)*nDistanceX;
            nPosY      = nFirstY;
            nIndicateY = m_pBgPwdText->getContentSize().height*0.456f;
        }
        
        if(m_SelectedPwdTextVec.size() >0)
        {
            m_pCurPwdTextIndicate->setPosition(Vec2(nPosX,nIndicateY ));
        }
        else
        {
            m_pCurPwdTextIndicate->removeFromParentAndCleanup(true);
            m_pCurPwdTextIndicate = nullptr;
        }
    }
    
    void SoftKeyboard::resetSelectedPwdInfor(void)
    {
        m_SelectedPwdValueVec.clear();
        
        for (int i = 0; i<m_SelectedPwdTextVec.size(); ++i)
        {
            auto pSelectedPwdText = m_SelectedPwdTextVec[i];
            pSelectedPwdText->removeFromParentAndCleanup(true);
            
        }
        m_SelectedPwdTextVec.clear();
        
        if(m_pCurPwdTextIndicate != nullptr)
        {
            m_pCurPwdTextIndicate->removeFromParentAndCleanup(true);
            m_pCurPwdTextIndicate = nullptr;
        }
    }
	
	/**
	 *  @author Kaiser
	 *
	 *  键盘按下事件
	 *
	 *  @param pRef 点击控件
	 */
    void SoftKeyboard::onClickSoftKey(cocos2d::Ref* pRef)
    {
        auto pKey = (Widget*)pRef;
        int nPosDataIndex = pKey->getTag();
        
        if(m_SelectedPwdValueVec.size() >= m_nTotalPwdCount)
        {
            return;
        }
        
//当前输入的明文
        std::string curPwd = StringUtils::format("%d",nPosDataIndex);
		
        notifyKeyInput(curPwd.c_str());
		
        m_SelectedPwdValueVec.push_back('*');
	
        //显示当前选中的密文密码
        addPwdText();
        
        //密码输入完毕处理
        if(m_SelectedPwdValueVec.size() == m_nTotalPwdCount)
        {
            doPINFinal("",0);
        }
    }
	
	/**
	 *  @author Kaiser
	 *
	 *  密文显示动画
	 */
	void SoftKeyboard::addPwdText(void)
	{
		float nFirstX    = m_pBgPwdText->getContentSize().width*0.158f;
		float nFirstY    = m_pBgPwdText->getContentSize().height*0.44f;
		float nDistanceX = 71.0f;
		float nPosX      = nFirstX+(m_SelectedPwdValueVec.size()-1)*nDistanceX;
		float nPosY      = nFirstY;
		float nIndicateY = m_pBgPwdText->getContentSize().height*0.46f;
		
		if(m_nWorkMode == 0 ||m_nWorkMode == 1 ||m_nWorkMode == 2)
		{
			nFirstX    = m_pBgPwdText->getContentSize().width*0.158f;
			nFirstY    = m_pBgPwdText->getContentSize().height*0.44f;
			nDistanceX = 71.0f;
			nPosX      = nFirstX+(m_SelectedPwdValueVec.size()-1)*nDistanceX;
			nPosY      = nFirstY;
			nIndicateY = m_pBgPwdText->getContentSize().height*0.46f;
		}else
		{
			nFirstX    = m_pBgPwdText->getContentSize().width*0.158f;
			nFirstY    = m_pBgPwdText->getContentSize().height*0.44f;
			nDistanceX = 71.0f;
			nPosX      = nFirstX+(m_SelectedPwdValueVec.size()-1)*nDistanceX;
			nPosY      = nFirstY;
			nIndicateY = m_pBgPwdText->getContentSize().height*0.46f;
		}
		
		//显示密文
		auto pPwdText = ImageView::create("ebres/uis/sfk_02.png");
		pPwdText->setAnchorPoint(Vec2(0.5f, 0.5f));
		pPwdText->setPosition(Vec2(nPosX, nPosY));
		pPwdText->setColor(Color3B::GRAY);
		m_pBgPwdText->addChild(pPwdText);
		
		//显示当前操作的密文索引指示
		if(m_pCurPwdTextIndicate == nullptr)
		{
			m_pCurPwdTextIndicate = ImageView::create("ebres/uis/sfk_03.png");
			m_pCurPwdTextIndicate->setAnchorPoint(Vec2(0.5f, 0.5f));
			m_pCurPwdTextIndicate->setPosition(Vec2(nPosX, nIndicateY));
			m_pCurPwdTextIndicate->setColor(Color3B::GRAY);
			m_pBgPwdText->addChild(m_pCurPwdTextIndicate);
		}
		else
		{
			m_pCurPwdTextIndicate->setPosition(Vec2(nPosX, nIndicateY));
		}
		
		//替换上一个密文图片
		if(m_SelectedPwdTextVec.size() >=1)
		{
			ImageView* pLastPwdText = m_SelectedPwdTextVec[m_SelectedPwdTextVec.size()-1];
			pLastPwdText->loadTexture("ebres/uis/sfk_04.png");
		}
		
		//加入容器
		m_SelectedPwdTextVec.push_back(pPwdText);
	}
	

    void SoftKeyboard::onClickSoftKeyBack(cocos2d::Ref* pRef)
    {
        //退出键盘
        playKeyboardDisAppearAni();
        //清空按键纪录
        resetSelectedPwdInfor();
    }
	
	/**
	 *  @author Kaiser
	 *
	 *  键盘删除按键
	 */
    void SoftKeyboard::onClickSoftKeyDelet(cocos2d::Ref* pRef)
    {
        //LogUtil::NSLog("onClickSoftKeyDelet");
        size_t nCount = m_SelectedPwdValueVec.size();
        for (int i = 0; i < nCount; i++) {
            removePwdText();
        }
    }
	
	/**
	 *  @author Kaiser
	 *
	 *  输入完成
	 *
	 *  @param finger
	 *  @param len
	 */
    void SoftKeyboard::doPINFinal(const char* finger,int len){

        //修复输入完六个按钮还能继续输入bug
        auto pAction = Sequence::create(DelayTime::create(delay_time),CallFunc::create([this](){
            if(m_pSoftKeyboardDelete != nullptr){
                m_pSoftKeyboardDelete->_onSoftKeyboardInputDidRenturn(true);
            }
        }), NULL);
        Director::getInstance()->getRunningScene()->runAction(pAction);
    }

