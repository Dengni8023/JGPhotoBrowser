#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "JGSourceBase.h"
#import "JGSBase.h"
#import "JGSBaseUtils.h"
#import "JGSLogFunction.h"
#import "JGSStringURLUtils.h"
#import "JGSWeakStrong.h"
#import "NSDictionary+JGSBase.h"
#import "NSObject+JGS_JSON.h"
#import "UIColor+JGSBase.h"

FOUNDATION_EXPORT double JGSourceBaseVersionNumber;
FOUNDATION_EXPORT const unsigned char JGSourceBaseVersionString[];

