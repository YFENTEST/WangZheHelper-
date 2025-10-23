include $(THEOS)/makefiles/common.mk

# 强制使用系统 clang
CC := /usr/bin/clang
CXX := /usr/bin/clang++
LD := /usr/bin/clang

BUNDLE_NAME = WZHelperPrefs

WZHelperPrefs_FILES = WZHelperPrefsRootListController.m
WZHelperPrefs_FRAMEWORKS = UIKit
WZHelperPrefs_PRIVATE_FRAMEWORKS = Preferences
WZHelperPrefs_INSTALL_PATH = /Library/PreferenceBundles
WZHelperPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

