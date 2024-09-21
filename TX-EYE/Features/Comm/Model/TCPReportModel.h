//
//  TCPReportModel.h
//  GoTrack
//
//  Created by CoreCat on 2019/1/3.
//  Copyright © 2019年 CoreCat. All rights reserved.
//

#import <JSONModel/JSONModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface TCPReportModel : JSONModel

@property (nonatomic) NSInteger code;

@property (nonatomic) NSInteger power;

@property (nonatomic) NSInteger previewResolution;
@property (nonatomic) NSInteger previewQuality;

@property (nonatomic) NSInteger videoResolution;
@property (nonatomic) NSInteger videoQuality;

@property (nonatomic) NSInteger photoResolution;
@property (nonatomic) NSInteger photoQuality;
@property (nonatomic) NSInteger photoBurst;
@property (nonatomic) NSInteger photoTimelapse;

@property (nonatomic) NSInteger buttonSound;
@property (nonatomic) NSInteger screenSaver;
@property (nonatomic) NSInteger autoShutdown;
@property (nonatomic) NSInteger language;

@property (nonatomic) NSInteger cyclicRecord;
@property (nonatomic) NSInteger videoSound;
@property (nonatomic) NSInteger exposureCompensation;
@property (nonatomic) NSInteger whiteBalance;
@property (nonatomic) NSInteger motionDetection;
@property (nonatomic) NSInteger dateStamp;

@end

NS_ASSUME_NONNULL_END
