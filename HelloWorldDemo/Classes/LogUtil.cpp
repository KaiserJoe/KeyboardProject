#include "LogUtil.h"
#include "cocos2d.h"

USING_NS_CC;

void LogUtil::NSLog(const char *format, ...)
{
    va_list args;
    va_start(args, format);
    
    char buf[MAX_LOG_LENGTH];
    
    vsnprintf(buf, MAX_LOG_LENGTH-3, format, args);
    strcat(buf, "\n");
    
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    __android_log_print(ANDROID_LOG_DEBUG, "cocos2d-x log info:",  "%s", buf);
    
#elif CC_TARGET_PLATFORM ==  CC_PLATFORM_WIN32
    WCHAR wszBuf[MAX_LOG_LENGTH] = {0};
    MultiByteToWideChar(CP_UTF8, 0, buf, -1, wszBuf, sizeof(wszBuf));
    OutputDebugStringW(wszBuf);
    WideCharToMultiByte(CP_ACP, 0, wszBuf, -1, buf, sizeof(buf), NULL, FALSE);
    printf("cocos2d debug info:%s", buf);
    
#else
    // Linux, Mac, iOS, etc
    fprintf(stdout, "cocos2d log info:%s", buf);
    fflush(stdout);
#endif
    
    Director::getInstance()->getConsole()->log(buf);
    
    
    va_end(args);
}

