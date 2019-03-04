//
//  HBLDataUpload.m
//  HBLSensorDataCollection
//
//  Created by benlinhuo on 2019/3/4.
//  Copyright © 2019 benlinhuo. All rights reserved.
//

#import "HBLDataUpload.h"

@interface HBLDataUpload ()

//@property (nonatomic, strong) HBLSensorDataRequest *sensorRequest;
@property (nonatomic, copy) RequestCompletionBlock completionBlock;

@end

@implementation HBLDataUpload

- (void)sendRequestWithData:(NSArray *)dataList CompletionBlock:(RequestCompletionBlock)completionBlock {
    self.completionBlock = completionBlock;
    
    // 此次做 api 请求
    
//    HBLSensorDataRequestData *requestData = [[HBLSensorDataRequestData alloc] init];
//    requestData.sensorJsonData = dataList;
//    self.sensorRequest.requestData = requestData;
//    [self.sensorRequest sendRequest];
}

@end

