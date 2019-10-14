//
//  ZBLocalNotification.h
//  Backlog
//
//  Created by Zombie on 2018/11/1.
//  Copyright © 2018 Zombie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

typedef NS_ENUM(NSInteger, ZBLocalNotificationRepeat) {
    ZBLocalNotificationRepeatNone,
    ZBLocalNotificationRepeatEveryDay,
    ZBLocalNotificationRepeatEveryWeek,
    ZBLocalNotificationRepeatEveryMonth,
    ZBLocalNotificationRepeatEveryYear,
    ZBLocalNotificationRepeatEveryWorkDay
};

typedef NSString * ZBLocalNotificationKey;
typedef NSString * ZBLocalNotificationSoundName;

extern ZBLocalNotificationKey const ZBNotificationFireDate;
extern ZBLocalNotificationKey const ZBNotificationAlertTitle;
extern ZBLocalNotificationKey const ZBNotificationAlertBody;
extern ZBLocalNotificationKey const ZBNotificationAlertAction;
extern ZBLocalNotificationKey const ZBNotificationSoundName;
extern ZBLocalNotificationKey const ZBNotificationUserInfoName;
extern ZBLocalNotificationKey const ZBNotificationPriority;
extern ZBLocalNotificationKey const ZBNotificationRepeat;
extern ZBLocalNotificationSoundName const ZBNotificationSoundAlarm;
extern ZBLocalNotificationSoundName const ZBNotificationSoundOther;

@interface ZBLocalNotification : NSObject

/**
 创建本地通知

 @param attribute 通知的属性
 */
+ (void)createLocalNotificationWithAttribute:(NSDictionary *)attribute;

/**
 取消通知

 @param notificationName 通知名字
 */
+ (void)cancelLocalNotificationWithName:(NSString *)notificationName;

#ifdef NSFoundationVersionNumber_iOS_9_x_Max

/**
 注册通知
 */
+ (void)requestUNUserNotificationAuthorization;

#endif

@end

