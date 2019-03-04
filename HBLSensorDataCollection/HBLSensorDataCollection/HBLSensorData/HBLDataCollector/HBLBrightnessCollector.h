//
//  HBLBrightnessCollector.h
//  HBLSensorDataCollection
//
//  Created by benlinhuo on 2019/3/4.
//  Copyright © 2019 benlinhuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HBLBrightnessCollector : NSObject

- (void)startBrightnessRunning:(BOOL)isRestart brightnessResult:(void(^)(float brightness))resultBlock;

- (void)stopBrightnessRunning;

@end
