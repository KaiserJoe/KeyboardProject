LOCAL_PATH := $(call my-dir)

#########otherlibs########
include $(CLEAR_VARS)

LOCAL_MODULE := cocos_crypto_static      # name it whatever
LOCAL_SRC_FILES := otherlibs/libcrypto.a

include $(PREBUILT_STATIC_LIBRARY)

################

include $(CLEAR_VARS)

$(call import-add-path,$(LOCAL_PATH)/../../cocos2d)
$(call import-add-path,$(LOCAL_PATH)/../../cocos2d/external)
$(call import-add-path,$(LOCAL_PATH)/../../cocos2d/cocos)

LOCAL_MODULE := cocos2dcpp_shared

LOCAL_MODULE_FILENAME := libEBankLib

#LOCAL_SRC_FILES := hellocpp/main.cpp \
#                   ../../Classes/AppDelegate.cpp \
#                   ../../Classes/HelloWorldScene.cpp

#LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../Classes

# 遍历目录及子目录的函数 
define walk 
$(wildcard $(1)) $(foreach e, $(wildcard $(1)/*), $(call walk, $(e))) 
endef 
# 遍历Classes目录 
ALLFILES = $(call walk, $(LOCAL_PATH)/../../Classes) 
FILE_LIST := hellocpp/main.cpp 
# 从所有文件中提取出所有.cpp文件
FILES_SUFFIX := %.cpp %.c %.cc
FILE_LIST += $(filter ${FILES_SUFFIX}, $(ALLFILES))
#FILE_LIST += $(filter %.cpp, $(ALLFILES)) 
LOCAL_SRC_FILES := $(FILE_LIST:$(LOCAL_PATH)/%=%) 

FILE_INCLUDES := $(shell find $(LOCAL_PATH)/../../Classes -type d) 
LOCAL_C_INCLUDES := $(FILE_INCLUDES)

# _COCOS_HEADER_ANDROID_BEGIN
# _COCOS_HEADER_ANDROID_END


LOCAL_STATIC_LIBRARIES := cocos2dx_static
LOCAL_STATIC_LIBRARIES += lssl
LOCAL_STATIC_LIBRARIES += cocos_crypto_static

# _COCOS_LIB_ANDROID_BEGIN
# _COCOS_LIB_ANDROID_END

include $(BUILD_SHARED_LIBRARY)

$(call import-module,.)

# _COCOS_LIB_IMPORT_ANDROID_BEGIN
# _COCOS_LIB_IMPORT_ANDROID_END
