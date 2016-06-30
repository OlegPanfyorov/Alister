//
//  ANStorageLog.h
//  Alister
//
//  Created by Oksana Kovalchuk on 7/1/16.
//  Copyright © 2016 Oksana Kovalchuk. All rights reserved.
//

#ifndef ANStorageLog_h
#define ANStorageLog_h

#ifdef ANStorageLog
#define ANStorageLog(s, ...) NSLog(s, ##__VA_ARGS__)
#else
#define ANStorageLog(s, ...)
#endif

#endif /* ANStorageLog_h */
