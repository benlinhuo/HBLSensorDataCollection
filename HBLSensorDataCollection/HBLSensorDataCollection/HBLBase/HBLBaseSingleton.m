//
//  HBLBaseSingleton.m
//  HBLSensorDataCollection
//
//  Created by benlinhuo on 2019/3/4.
//  Copyright © 2019 benlinhuo. All rights reserved.
//

#import "HBLBaseSingleton.h"

static NSMutableDictionary *singleDictionary = nil;

@implementation HBLBaseSingleton

+ (id)placeHolderIdentiferForSynchronization
{
    return @"HBLBaseSingleton";
}

+ (instancetype) shared
{
    return [self sharedInstance];
}

+ (instancetype)sharedInstance
{
    @synchronized([self placeHolderIdentiferForSynchronization])
    {
        if (singleDictionary == nil)
        {
            singleDictionary = [[NSMutableDictionary alloc] init];
        }
        
        NSString *classObjectDescription = NSStringFromClass([self class]);
        id object = [singleDictionary objectForKey:classObjectDescription];
        if (object == nil)
        {
            object = [[super alloc] init];
            [singleDictionary setObject:object forKey:classObjectDescription];
        }
        return object;
    }
}

@end
