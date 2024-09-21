//
//  VoiceRecognizer.m
//  TX-EYE
//
//  Created by CoreCat on 2017/4/18.
//  Copyright © 2017年 CoreCat. All rights reserved.
//

#import "VoiceRecognizer.h"
#import <OpenEars/OEPocketsphinxController.h>
#import <OpenEars/OELanguageModelGenerator.h>
//#import <OpenEars/OELogging.h>
#import <OpenEars/OEAcousticModel.h>

@interface VoiceRecognizer ()

@property (nonatomic, strong) OEEventsObserver *openEarsEventsObserver;
@property (nonatomic, strong) OEPocketsphinxController *pocketsphinxController;

@property (nonatomic, copy) NSString *pathToLanguageModel;
@property (nonatomic, copy) NSString *pathToDictionary;
@property (nonatomic, copy) NSString *pathToAcousticModel;
@property (nonatomic, copy) NSArray *dictionary;

@end

@implementation VoiceRecognizer

+ (instancetype)sharedInstance
{
    static VoiceRecognizer *instance = nil;
    
    if (instance == nil) {
        instance = [[VoiceRecognizer alloc] init];
    }
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        [self setupRecognizer];
    }
    
    return self;
}

- (void)setupRecognizer
{
    self.openEarsEventsObserver = [[OEEventsObserver alloc] init];
    self.openEarsEventsObserver.delegate = self;
    
//    [OELogging startOpenEarsLogging]; // Uncomment me for OELogging

    [[OEPocketsphinxController sharedInstance] setActive:TRUE error:nil]; // Call this before setting any OEPocketsphinxController characteristics
    
    [[OEPocketsphinxController sharedInstance] setVadThreshold:3.0];
    
//    [OEPocketsphinxController sharedInstance].verbosePocketSphinx = TRUE; // Uncomment this for much more verbose speech recognition engine output
    
    if ([self isChineseLocale]) {
        self.pathToAcousticModel = [OEAcousticModel pathToModel:@"AcousticModelChinese"];
        self.pathToLanguageModel = [NSString stringWithFormat:@"%@/%@", self.pathToAcousticModel, @"zh.lm"];
        self.pathToDictionary = [NSString stringWithFormat:@"%@/%@", self.pathToAcousticModel, @"zh.dict"];
        
        self.dictionary = @[@"前进",
                            @"后退",
                            @"左侧飞",
                            @"右侧飞",
                            @"起飞",
                            @"降落"];
    } else {
        self.pathToAcousticModel = [OEAcousticModel pathToModel:@"AcousticModelEnglish"];
        self.pathToLanguageModel = [NSString stringWithFormat:@"%@/%@", self.pathToAcousticModel, @"en.lm"];
        self.pathToDictionary = [NSString stringWithFormat:@"%@/%@", self.pathToAcousticModel, @"en.dict"];
        
        self.dictionary = @[@"forward",
                            @"backward",
                            @"left",
                            @"right",
                            @"takeoff",
                            @"landing"];
    }
}

- (void)startListening
{
     // Start speech recognition if we aren't already listening.
    if(![OEPocketsphinxController sharedInstance].isListening) {
        dispatch_async(dispatch_queue_create("start listening", 0), ^{
            [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:self.pathToLanguageModel
                                                                            dictionaryAtPath:self.pathToDictionary
                                                                         acousticModelAtPath:self.pathToAcousticModel
                                                                         languageModelIsJSGF:FALSE];
        });
    }
}

- (void)stopListening
{
    if ([OEPocketsphinxController sharedInstance].isListening) {
        dispatch_async(dispatch_queue_create("stop listening", 0), ^{
            [[OEPocketsphinxController sharedInstance] stopListening];
        });
    }
}

- (void)recognizerDidListening
{
    if ([self.delegate respondsToSelector:@selector(voiceRecognizerDidStartListening)]) {
        [self.delegate voiceRecognizerDidStartListening];
    }
}

- (void)recognizerDidReceiveHypothesis:(NSString *)hypothesis
{
    if ([self.delegate respondsToSelector:@selector(voiceRecognizerDidReceiveCommand:text:)]) {
        NSUInteger index = [self.dictionary indexOfObject:hypothesis];
        if (index != NSNotFound) {
            VoiceRecognizerCommand command = index;
            [self.delegate voiceRecognizerDidReceiveCommand:command text:hypothesis];
        }
    }
}

- (void)recognizerDidSuspendRecognition
{
    if ([self.delegate respondsToSelector:@selector(voiceRecognizerDidSuspendRecognition)]) {
        [self.delegate voiceRecognizerDidSuspendRecognition];
    }
}

- (void)recognizerErrorOccurred
{
    if ([self.delegate respondsToSelector:@selector(voiceRecognizerErrorOccurred)]) {
        [self.delegate voiceRecognizerErrorOccurred];
    }
}

#pragma mark -
#pragma mark OEEventsObserver delegate methods

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
    NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
    
    [self recognizerDidReceiveHypothesis:hypothesis];
}

- (void) pocketsphinxDidStartListening {
    NSLog(@"Pocketsphinx is now listening.");
    
    [self recognizerDidListening];
}

- (void) pocketsphinxDidDetectSpeech {
    NSLog(@"Pocketsphinx has detected speech.");
}

- (void) pocketsphinxDidDetectFinishedSpeech {
    NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
}

- (void) pocketsphinxDidStopListening {
    NSLog(@"Pocketsphinx has stopped listening.");
    
    [self recognizerDidSuspendRecognition];
}

- (void) pocketsphinxDidSuspendRecognition {
    NSLog(@"Pocketsphinx has suspended recognition.");
    
    [self recognizerDidSuspendRecognition];
}

- (void) pocketsphinxDidResumeRecognition {
    NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
    NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void) pocketSphinxContinuousSetupDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Listening setup wasn't successful and returned the failure reason: %@", reasonForFailure);
    
    [self recognizerErrorOccurred];
}

- (void) pocketSphinxContinuousTeardownDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Listening teardown wasn't successful and returned the failure reason: %@", reasonForFailure);
    
    [self recognizerErrorOccurred];
}

- (void) testRecognitionCompleted {
    NSLog(@"A test file that was submitted for recognition is now complete.");
}

#pragma mark -
#pragma mark Utils

- (BOOL)isChineseLocale
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLanguage = [languages objectAtIndex:0];
    
    return [currentLanguage rangeOfString:@"zh-Han"].location != NSNotFound;
}

@end
