//
// Created by lihong on 15/11/19.
// Copyright (c) 2016
//

#ifndef __SLOGGER_H__
#define __SLOGGER_H__

#define SLogFunc() (NSLog(@"%s", __PRETTY_FUNCTION__))
#define SLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ## __VA_ARGS__)

#define SAssertFalse NSAssert(NO, @"You should not call this.")

#define STICK   NSDate *sStartTime = [NSDate date]
#define STOCK   SLog(@"Time: %f", -[sStartTime timeIntervalSinceNow])

#endif
