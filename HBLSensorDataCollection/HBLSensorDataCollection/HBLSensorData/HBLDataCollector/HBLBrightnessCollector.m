//
//  HBLBrightnessCollector.m
//  HBLSensorDataCollection
//
//  Created by benlinhuo on 2019/3/4.
//  Copyright © 2019 benlinhuo. All rights reserved.
//

@import AVFoundation;
#import "HBLBrightnessCollector.h"
#import <ImageIO/ImageIO.h>

@interface HBLBrightnessCollector () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) dispatch_queue_t gcdQueue;
@property (nonatomic, copy) void(^brightnessResultBlock)(float brightness);

@end

@implementation HBLBrightnessCollector

- (instancetype)init {
    self = [super init];
    if (self) {
        self.gcdQueue = dispatch_queue_create("com.hbl.brightness", DISPATCH_QUEUE_CONCURRENT);
        //        [self initCaptureDevice];
    }
    return self;
}

// 通过摄像头获取光感
- (void)initCaptureDevice { // 会影响耗电量
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:device error:nil];
    AVCaptureVideoDataOutput *output = [AVCaptureVideoDataOutput new];
    [output setSampleBufferDelegate:self queue:self.gcdQueue];
    
    self.session = [AVCaptureSession new];
    [self.session setSessionPreset: AVCaptureSessionPresetHigh];// 高质量采集率
    if ([self.session canAddInput:input]) {
        [self.session addInput:input];
    }
    if ([self.session canAddOutput:output]) {
        [self.session addOutput:output];
    }
}

- (void)startBrightnessRunning:(BOOL)isRestart brightnessResult:(void(^)(float brightness))resultBlock {
    self.brightnessResultBlock = resultBlock;
    if (isRestart) {
        [self.session stopRunning];
    }
    [self initCaptureDevice];
    [self.session startRunning];
}

- (void)stopBrightnessRunning {
    [self.session stopRunning];
    _session = nil;
}

#pragma mark- AVCaptureVideoDataOutputSampleBufferDelegate的方法
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    
    if (self.brightnessResultBlock) {
        self.brightnessResultBlock(brightnessValue);
    }
}

@end

