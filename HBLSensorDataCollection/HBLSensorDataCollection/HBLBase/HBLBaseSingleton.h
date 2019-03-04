//
//  HBLBaseSingleton.h
//  HBLSensorDataCollection
//
//  Created by benlinhuo on 2019/3/4.
//  Copyright © 2019 benlinhuo. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface HBLBaseSingleton : NSObject

+ (instancetype)shared;
+ (instancetype)sharedInstance;

@end
