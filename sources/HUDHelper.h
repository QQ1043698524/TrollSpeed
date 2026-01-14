//
//  HUDHelper.h
//  TrollSpeed
//
//  Created by Lessica on 2024/1/24.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

OBJC_EXTERN BOOL IsHUDEnabled(void);
OBJC_EXTERN void SetHUDEnabled(BOOL isEnabled);
OBJC_EXTERN UIImage * _Nullable HUDCaptureScreen(void);

#if DEBUG
OBJC_EXTERN void SimulateMemoryPressure(void);
#endif

OBJC_EXTERN NSUserDefaults *GetStandardUserDefaults(void);

NS_ASSUME_NONNULL_END
