//
//  HBLDataUpload.h
//  HBLSensorDataCollection
//
//  Created by benlinhuo on 2019/3/4.
//  Copyright © 2019 benlinhuo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^RequestCompletionBlock)(BOOL isRequestSuccess);

@interface HBLDataUpload : NSObject

- (void)sendRequestWithData:(NSArray *)dataList CompletionBlock:(RequestCompletionBlock)completionBlock;

@end
