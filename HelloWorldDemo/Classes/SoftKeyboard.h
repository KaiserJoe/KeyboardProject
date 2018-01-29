//
//  SoftKeyboard.h
//  SafeModule
//
//  Created by liuyong on 16/1/5.
//
//

#ifndef SoftKeyboard_h
#define SoftKeyboard_h

#include "cocos2d.h"
#include "ui/CocosGUI.h"
#include "extensions/cocos-ext.h"
    
    class SoftKeyboardDelete
    {
    public:
        /**
         ** 键盘展开回调函数
         **/
        virtual void _onSoftKeyboardDidBegin(void) = 0;
        
        /**
         ** 键盘回传密码数据
         **/
        virtual void _onSoftKeyboardInputDidRenturn(bool suc) = 0;
        
        /**
         ** 键盘消失回调函数
         **/
        virtual void _onSoftKeyboardDidHidden(void) = 0;
    };
    
    //图形验证码
    class GraphicVerificationView;
    
    class SoftKeyboard:public cocos2d::Layer
    {
    public:
        /**
         **  创建软键盘
         **  size[窗口大小]
         **  bgColor[背景颜色]
         **/
        static SoftKeyboard* CreateWithDelet(SoftKeyboardDelete* pSoftKeyboardDelete,int nWorkMode = 0);
        
        /**
         ** 按键随机复位
         **/
        void resetSoftKeyView(int nCurInputTime);
        
    private:
        SoftKeyboard();
        
        ~SoftKeyboard();
        
         virtual bool init(SoftKeyboardDelete* pSoftKeyboardDelete,int nWorkMode);
        
        /**
         * Event callback that is invoked every time when Node enters the 'stage'.
         * If the Node enters the 'stage' with a transition, this event is called when the transition starts.
         * During onEnter you can't access a "sister/brother" node.
         * If you override onEnter, you shall call its parent's one, e.g., Node::onEnter().
         * @lua NA
         */
        virtual void onEnter();
        
        /**
         * Event callback that is invoked every time the Node leaves the 'stage'.
         * If the Node leaves the 'stage' with a transition, this event is called when the transition finishes.
         * During onExit you can't access a sibling node.
         * If you override onExit, you shall call its parent's one, e.g., Node::onExit().
         * @lua NA
         */
        virtual void onExit();
        
        /** Callback function for touch began.
         *
         * @param touch Touch infomation.
         * @param unused_event Event information.
         * @return if return false, onTouchMoved, onTouchEnded, onTouchCancelled will never called.
         * @js NA
         */
        virtual bool onTouchBegan(cocos2d::Touch *touch, cocos2d::Event *unused_event);
        /** Callback function for touch moved.
         *
         * @param touch Touch infomation.
         * @param unused_event Event information.
         * @js NA
         */
        virtual void onTouchMoved(cocos2d::Touch *touch, cocos2d::Event *unused_event);
        /** Callback function for touch ended.
         *
         * @param touch Touch infomation.
         * @param unused_event Event information.
         * @js NA
         */
        virtual void onTouchEnded(cocos2d::Touch *touch, cocos2d::Event *unused_event);
        /** Callback function for touch cancelled.
         *
         * @param touch Touch infomation.
         * @param unused_event Event information.
         * @js NA
         */
        virtual void onTouchCancelled(cocos2d::Touch *touch, cocos2d::Event *unused_event);
        
        /**
         ** 键盘推入动画
         **/
        void playKeyboardAppearAni(void);
        
        /**
         ** 键盘退出动画
         **/
        void playKeyboardDisAppearAni(void);
        
        /**
         **  设置待输入密码个数
         **/
        void setInputPasCount(short nCount);
        
        /**
         ** 密文密码文本推入动画
         **/
        void playPwdTextAppearAni(void);
        
        /**
         ** 密文密码文本退出动画
         **/
        void playPwdTextDisAppearAni(void);
        
        /**
         ** 添加密文密码文本
         **/
        void addPwdText(void);
        
        /**
         ** 删除密文密码文本
         **/
        void removePwdText(void);
        
        /**
         ** 重置选中的密码信息
         **/
        void resetSelectedPwdInfor(void);
        
        /**
         **  键盘按键响应事件
         **  pRef[按键]
         **/
        void onClickSoftKey(cocos2d::Ref* pRef);
        
        /**
         **  键盘退出按键响应事件
         **  pRef[按键]
         **/
        void onClickSoftKeyBack(cocos2d::Ref* pRef);
        
        /**
         **  键盘撤销按键响应事件
         **  pRef[按键]
         **/
        void onClickSoftKeyDelet(cocos2d::Ref* pRef);
        
        
    public:
        /**
         ** 处理最后一位密码
         **/
        void doPINFinal(const char* finger,int len);
        
    private:
        cocos2d::Size m_BgSize;								//整个软键盘背景区域大小
        
        cocos2d::Size m_SoftKeyboardBgSize;                 //密码键盘背景图片大小
        
        cocos2d::ui::ImageView* m_pBgPwdText;				//密文密码背景图片
        
        cocos2d::ui::ImageView* m_pBgSoftKeyboardInput;		//密码键盘背景图片
        
        cocos2d::ui::ScrollView* m_pBgScrow;
        
        short m_nTotalPwdCount;								//密码个数，默认6个，图形验证码是4个
        
        std::vector<short> m_PwdValueVec;					//纪录随机密码位，一密一变
        
        std::vector<unsigned char> m_SelectedPwdValueVec;	//纪录选中的明文密码
        
        std::vector<cocos2d::ui::ImageView*> m_SelectedPwdTextVec;      //纪录密文密码文本，默认*
        
        cocos2d::ui::ImageView* m_pCurPwdTextIndicate;      //当前操作的密码索引指示图片
        
        SoftKeyboardDelete* m_pSoftKeyboardDelete;			//键盘事件代理
        
        int m_nWorkMode;									//软键盘工作模式[0:图形验证码 1:录入1次密码 2:录入2次密码 3:录入三次密码]
        
        cocos2d::ui::ImageView* m_pRefreshVerificationBtn;
        
        cocos2d::ui::ImageView* m_pInputTimeImg;
    };



#endif /* SoftKeyboard_h */
