//
//  VoiceRecognizer.h
//  TX-EYE
//
//  Created by CoreCat on 2017/4/18.
//  Copyright © 2017年 CoreCat. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OpenEars/OEEventsObserver.h>


@protocol VoiceRecognizerDelegate;


@interface VoiceRecognizer : NSObject <OEEventsObserverDelegate>

/* Properties */
@property (weak) id<VoiceRecognizerDelegate> delegate;

/* Methods */
+ (instancetype)sharedInstance;

- (void)startListening;
- (void)stopListening;

@end


/* Voice command action */
typedef NS_OPTIONS(NSInteger, VoiceRecognizerCommand) {
    VoiceRecognizerCommandForward,
    VoiceRecognizerCommandBackward,
    VoiceRecognizerCommandLeft,
    VoiceRecognizerCommandRight,
    VoiceRecognizerCommandTakeoff,
    VoiceRecognizerCommandLanding,
};

/* Voice command delegate */
@protocol VoiceRecognizerDelegate <NSObject>

@optional

- (void)voiceRecognizerDidStartListening;

- (void)voiceRecognizerDidSuspendRecognition;

- (void)voiceRecognizerDidReceiveCommand:(VoiceRecognizerCommand)command text:(NSString *)text;

- (void)voiceRecognizerErrorOccurred;

@end
