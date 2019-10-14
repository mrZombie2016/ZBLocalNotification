//
//  ZBLocalNotification.m
//  Backlog
//
//  Created by Zombie on 2018/11/1.
//  Copyright © 2018 Zombie. All rights reserved.
//

#import "ZBLocalNotification.h"

ZBLocalNotificationKey const ZBNotificationFireDate = @"ZBNotificationFireDate";
ZBLocalNotificationKey const ZBNotificationAlertTitle = @"ZBNotificationAlertTitle";
ZBLocalNotificationKey const ZBNotificationAlertBody = @"ZBNotificationAlertBody";
ZBLocalNotificationKey const ZBNotificationAlertAction = @"ZBNotificationAlertAction";
ZBLocalNotificationKey const ZBNotificationSoundName = @"ZBNotificationSoundName";
ZBLocalNotificationKey const ZBNotificationUserInfoName = @"ZBNotificationUserInfoName";
ZBLocalNotificationKey const ZBNotificationPriority = @"ZBNotificationPriority";
ZBLocalNotificationKey const ZBNotificationRepeat = @"ZBNotificationRepeat";

//可替换声音或者新建声音属性
ZBLocalNotificationSoundName const ZBNotificationSoundAlarm = @"alarmSound.caf";
ZBLocalNotificationSoundName const ZBNotificationSoundOther = @"other.caf";

@implementation ZBLocalNotification

+ (NSString *)notificationBaseName:(NSString *)name index:(NSInteger )index {
    return [NSString stringWithFormat:@"%@[%ld]",name,index];
}

#ifdef NSFoundationVersionNumber_iOS_9_x_Max

+ (void)requestUNUserNotificationAuthorization {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    //请求获取通知权限（角标，声音，弹框）
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge |
                                             UNAuthorizationOptionSound |
                                             UNAuthorizationOptionAlert)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            //获取用户是否同意开启通知
            NSLog(@"request authorization successed!");

        }
    }];

}
//#endif


+ (void)createLocalNotificationWithAttribute:(NSDictionary *)attribute {
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = attribute[ZBNotificationAlertTitle];
//    content.subtitle = @"本地通知副标题";
    content.body = attribute[ZBNotificationAlertBody];
    content.badge = @1;
    content.userInfo = attribute;

    UNNotificationSound *sound = [UNNotificationSound soundNamed:attribute[ZBNotificationSoundName]];//[UNNotificationSound defaultSound];
    content.sound = sound;


    NSDateComponents * resultComponents = [[NSDateComponents alloc]init];

    NSDateComponents * components = [[NSCalendar currentCalendar]
                                     components:NSCalendarUnitYear |
                                     NSCalendarUnitMonth |
                                     NSCalendarUnitWeekday |
                                     NSCalendarUnitDay |
                                     NSCalendarUnitHour |
                                     NSCalendarUnitMinute |
                                     NSCalendarUnitSecond
                                     fromDate:attribute[ZBNotificationFireDate]];
    resultComponents.hour = components.hour;
    resultComponents.minute = components.minute;
    resultComponents.second = components.second;
    
    BOOL isRepeat = YES;

    switch ([attribute[ZBNotificationRepeat] intValue]) {
        case ZBLocalNotificationRepeatNone:
        {
            isRepeat = NO;
            resultComponents = components;
        }
            break;
        case ZBLocalNotificationRepeatEveryDay:
        {

        }
            break;
        case ZBLocalNotificationRepeatEveryWeek:
        {
            resultComponents.weekday = components.weekday;
        }
            break;
        case ZBLocalNotificationRepeatEveryMonth:
        {
            resultComponents.day = components.day;
        }
            break;
        case ZBLocalNotificationRepeatEveryYear:
        {
            resultComponents.month = components.month;
            resultComponents.day = components.day;
        }
            break;
        case ZBLocalNotificationRepeatEveryWorkDay:
        {
            for (NSInteger i = 2; i <= 6; i++) {
                resultComponents.weekday = i;
                [self addLocalNotificationWithContent:content dateComponents:resultComponents isRepeat:isRepeat requestIdentifer:[self notificationBaseName:attribute[ZBNotificationUserInfoName] index:i-2]];
            }
            return;
        }
            break;

        default:
            break;
    }



    [self addLocalNotificationWithContent:content dateComponents:resultComponents isRepeat:isRepeat requestIdentifer:attribute[ZBNotificationUserInfoName]];

}

+ (void)addLocalNotificationWithContent:(UNMutableNotificationContent *)content dateComponents:(NSDateComponents *)components isRepeat:(BOOL)repeat requestIdentifer:(NSString *)identifer{

    UNCalendarNotificationTrigger * trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:repeat];

    // 4.设置UNNotificationRequest
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifer content:content trigger:trigger];

    //5.把通知加到UNUserNotificationCenter, 到指定触发点会被触发
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"通知添加失败:%@",error);
        } else {
            NSLog(@"通知添加成功");
        }
    }];

}

+ (void)cancelLocalNotificationWithName:(NSString *)notificationName {
    NSMutableArray * names = [[NSMutableArray alloc]initWithObjects:notificationName, nil];

    for (NSInteger i = 0; i < 5; i++) {
        NSString * name = [self notificationBaseName:notificationName index:i];
        [names addObject:name];
    }

    [[UNUserNotificationCenter currentNotificationCenter] removePendingNotificationRequestsWithIdentifiers:names];
}


#else

+ (void)createLocalNotificationWithAttribute:(NSDictionary *)attribute {
    
    NSMutableDictionary *mulAttribute = [[NSMutableDictionary alloc]initWithDictionary:attribute];
    
    NSCalendarUnit calendarUnit = 0;
    switch ([attribute[ZBNotificationRepeat] intValue]) {
        case ZBLocalNotificationRepeatNone:
        {

        }
            break;
        case ZBLocalNotificationRepeatEveryDay:
        {
            calendarUnit =  NSCalendarUnitDay;
        }
            break;
        case ZBLocalNotificationRepeatEveryWeek:
        {
            calendarUnit =  NSCalendarUnitWeekday;
        }
            break;
        case ZBLocalNotificationRepeatEveryMonth:
        {
            calendarUnit =  NSCalendarUnitMonth;
        }
            break;
        case ZBLocalNotificationRepeatEveryYear:
        {
            calendarUnit =  NSCalendarUnitYear;
        }
            break;
        case ZBLocalNotificationRepeatEveryWorkDay:
        {
            calendarUnit =  NSCalendarUnitWeekday;
            for (NSInteger i = 2; i <= 6; i++) {
               NSDateComponents * components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:attribute[ZBNotificationFireDate]];
                components.weekday = i;
                NSDate * date = [[NSCalendar currentCalendar] dateFromComponents:components];
                mulAttribute[ZBNotificationUserInfoName] = [self notificationBaseName:attribute[ZBNotificationUserInfoName] index:i];
                [self createLocalNotificationWithAttribute:mulAttribute repeatInterval:calendarUnit alertDate:date];
            }
            return;
        }
            break;
            
        default:
            break;
    }
    
    [self createLocalNotificationWithAttribute:attribute repeatInterval:calendarUnit alertDate:attribute[ZBNotificationFireDate]];
}

+ (void)createLocalNotificationWithAttribute:(NSDictionary *)attribute repeatInterval:(NSCalendarUnit)repeatInterval alertDate:(NSDate *)date{
    UILocalNotification *localNotification = [[UILocalNotification alloc]init];
    
    // 设置触发时间
    localNotification.fireDate = date;
    // 设置时区  以当前手机运行的时区为准
    localNotification.timeZone = [NSTimeZone localTimeZone];
    // 设置推送 显示的内容
    localNotification.alertTitle = attribute[ZBNotificationAlertTitle];
    localNotification.alertBody = attribute[ZBNotificationAlertBody];
    localNotification.alertAction = attribute[ZBNotificationAlertAction];
    //是否显示额外的按钮，为no时alertAction消失
    //    localNotification.hasAction = YES;
    // 设置 icon小红点个数
    localNotification.applicationIconBadgeNumber = 1;
    // 不设置此属性，则默认不重复
    localNotification.repeatInterval =  repeatInterval;
    
    // 设置推送的声音
    localNotification.soundName = attribute[ZBNotificationSoundName] ? : UILocalNotificationDefaultSoundName;
    
    
    localNotification.userInfo = attribute;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}


+ (void)cancelLocalNotificationWithName:(NSString *)notificationName {
    NSArray * localNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification * notification in localNotifications) {
        if ([notification.userInfo[ZBNotificationUserInfoName] hasPrefix:notificationName]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];

        }
    }
}

#endif

@end
