TARGET := iphone:clang:latest:14.0
INSTALL_PACKAGE_FORMAT = deb
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AdBlocker

AdBlocker_FILES = Tweak.x
AdBlocker_CFLAGS = -fobjc-arc
AdBlocker_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk
