ARCHS = arm64 arm64e
TARGET := iphone:clang:latest:11.0
INSTALL_TARGET_PROCESSES = SpringBoard

# 如果你的 Theos 没有设置环境变量，取消下面的注释并设置路径
# THEOS = /opt/theos

include $(THEOS)/makefiles/common.mk

# 强制使用系统 clang
CC := /usr/bin/clang
CXX := /usr/bin/clang++
LD := /usr/bin/clang

TWEAK_NAME = WangZheHelper

WangZheHelper_FILES = Tweak.x
WangZheHelper_CFLAGS = -fobjc-arc
WangZheHelper_FRAMEWORKS = UIKit StoreKit
WangZheHelper_PRIVATE_FRAMEWORKS = 

include $(THEOS_MAKE_PATH)/tweak.mk

# 设置 bundle
SUBPROJECTS += wzhelperprefs
include $(THEOS_MAKE_PATH)/aggregate.mk

# 自动安装后重启 SpringBoard
after-install::
	install.exec "killall -9 SpringBoard"

