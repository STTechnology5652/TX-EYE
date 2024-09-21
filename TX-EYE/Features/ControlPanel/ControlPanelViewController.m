//
//  ControlPanelViewController.m
//  TX-EYE
//
//  Created by CoreCat on 16/1/13.
//  Copyright © 2016年 CoreCat. All rights reserved.
//

#import "ControlPanelViewController.h"
#import "UIImage+Tint.h"
#import "RudderView.h"
#import <AudioToolbox/AudioToolbox.h>
#import "MediaLibraryViewController.h"
#import "Utilities.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "Settings.h"
#import "Config.h"
#import "TrackView.h"
#import "VoiceRecognizer.h"
#import "FreeSpaceMonitor.h"
#import "UIView+Toast.h"
#import "UIScreen+SafeArea.h"
#import <AVFoundation/AVFoundation.h>
#import "VisionProc/VisionProc.h"
#import "CountdownLabel.h"

@import Masonry;

#import "MessageCenter.h"
#import "CommClient.h"
#import "NSData+Conversion.h"

#define RECONNECTION_INTERVAL   0.5

#define SOUND_ID_SHUTTER        1108
#define SOUND_ID_PICTURE_TIME   1110
#define SOUND_ID_RECORD_START   1115
#define SOUND_ID_RECORD_STOP    1116
#define SOUND_ID_RECORD_FAIL    1109

@interface ControlPanelViewController () <RudderViewDelegate, TrackViewDelegate, VoiceRecognizerDelegate, IJKFFMoviePlayerDelegate, FreeSpaceMonitorDelegate, CountdownLabelDelegate, CommDelegate>
{
    UIImage *backingImage;
    UIImage *cameraDisabledImage;
    UIImage *cameraEnabledImage;
    UIImage *videoDisabledImage;
    UIImage *videoEnabledImage;
    UIImage *reviewNormalImage;
    UIImage *reviewHighlightView;
    UIImage *limitedSpeed30Image;
    UIImage *limitedSpeed60Image;
    UIImage *limitedSpeed100Image;
    UIImage *limitedHighDisabledImage;
    UIImage *limitedHighEnabledImage;
    UIImage *gravityDisabledImage;
    UIImage *gravityEnabledImage;
    UIImage *offImage;
    UIImage *onImage;
    UIImage *rotateScreenImage;
    UIImage *rotateScreenHighlightImage;
    UIImage *splitScreenImage;
    
    UIImage *detectObjectDisableImage;
    UIImage *detectObjectEnableImage;
    UIImage *trackObjectDisableImage;
    UIImage *trackObjectEnableImage;
    
    UIImage *settingsImage;
    UIImage *headlessDisabledImage;
    UIImage *headlessEnabledImage;
    UIImage *gyroCalibrateDisabledImage;
    UIImage *gyroCalibrateEnabledImage;
    UIImage *rollDisabledImage;
    UIImage *rollEnabledImage;
    UIImage *flyupDisabledImage;
    UIImage *flyupEnabledImage;
    UIImage *flydownDisabledImage;
    UIImage *flydownEnabledImage;
    UIImage *oneKeyStopDisabledImage;
    UIImage *oneKeyStopEnabledImage;
    UIImage *returnEnabledImage;
    UIImage *returnDisabledImage;
    UIImage *rotateEnableImage;
    UIImage *rotateDisableImage;
    UIImage *fixedDirectionRotateEnabledIamge;
    UIImage *fixedDirectionRotateDisabledImage;
    UIImage *trackDisabledImage;
    UIImage *trackEnabledImage;
    UIImage *lightDisabledImage;
    UIImage *lightEnabledImage;
    UIImage *voiceDisabledImage;
    UIImage *voiceEnabledImage;
    
    int videoRecordTime;
    UILabel *videoRecordTimeLabel;
    NSTimer *videoRecordTimer;
    
    BOOL autoRotation;
    UIDeviceOrientation orientation;
    
    NSTimer *controlTimer;
    Byte controlByteAIL;  // 副翼
    Byte controlByteELE;  // 升降舵
    Byte controlByteTHR;  // 油门
    Byte controlByteRUDD; // 方向舵
    Byte trimByteAIL;
    Byte trimByteELE;
    Byte trimByteRUDD;
    
    NSArray *topButtons;
    NSArray *leftButtons;
    NSArray *rightButtons;
    NSArray *extraButtons;
    NSTimer *buttonVisibleTimer;
    
    int speedValue;
    float speedValuef;
    BOOL flyupMode;
    BOOL flydownMode;
    BOOL returnMode;
    BOOL rotateMode;
    BOOL fixedDirectionRotateMode;
    BOOL headlessMode;
    BOOL rollMode;          // 按键状态，不代表触发状态
    BOOL triggeredRoll;     // 触发状态
    BOOL emergencyDownMode;
    BOOL gyroCalibrateMode;
    BOOL lightOn;
    BOOL voiceMode;
    BOOL _vrMode;
    
    NSTimer *flyupTimer;
    NSTimer *flydownTimer;
    NSTimer *emergencyDownTimer;
    NSTimer *gyroCalibrateTimer;
    NSTimer *voiceControlTimer;
    
    BOOL autosave;

    // Fake resolution
    BOOL isFakeResolution;
    int fakeWidth;
    int fakeHeight;
    // 分开拍照录像Fake分辨率，以前失误没有加上
    BOOL isBothFakeResolution;  // 置真优先级比isFakeResolution高
    int fakePhotoWidth;
    int fakePhotoHeight;
    int fakeVideoWidth;
    int fakeVideoHeight;

    // Debug
    // 打开右侧设置按钮，按住陀螺仪校准按钮，再长按打开右侧的设置按钮，即可打开帧数等信息。关闭方法重复操作一遍。
    BOOL touchDebug;
    
    UIView *debugView;
    UILabel *infoStrLabel;
    UILabel *infoHexLabel;
    UIButton *debugEnterButton;
    UILabel *debugDataLabel;
    
    BOOL shouldShowHudView;
    NSString *debugString;
    
    NSTimer *heartbeatTimer;
    NSTimer *repeatTimer;
    NSTimer *countdownTimer;
    CommClient *commClient;
    
    // MTCNN Trimming
    float detectThreshold;
    UILabel *detectThresholdLabel;
    UISlider *detectThresholdSlider;
}
@property (strong, nonatomic) UIView *interactiveView;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

// top
@property (strong, nonatomic) UIButton *backingButton;
@property (strong, nonatomic) UIButton *takePhotoButton;
@property (strong, nonatomic) UIButton *captureVideoButton;
@property (strong, nonatomic) UIButton *reviewButton;
@property (strong, nonatomic) UIButton *limitedSpeedButton;
@property (strong, nonatomic) UIButton *limitedHighButton;
@property (strong, nonatomic) UIButton *gravityControlButton;
@property (strong, nonatomic) UIButton *interfaceSwitchButton;
@property (strong, nonatomic) UIButton *rotateScreenButton;
@property (strong, nonatomic) UIButton *splitScreenButton;

// left
@property (strong, nonatomic) UIButton *cardPhotoButton;
@property (strong, nonatomic) UIButton *cardVideoButton;
@property (strong, nonatomic) UIButton *detectObjectButton;
@property (strong, nonatomic) UIButton *trackObjectButton;

// right and extra
@property (strong, nonatomic) UIButton *settingsButton;
@property (strong, nonatomic) UIButton *headlessButton;
@property (strong, nonatomic) UIButton *gyroCalibrateButton;
@property (strong, nonatomic) UIButton *rollButton;
@property (strong, nonatomic) UIButton *flyupButton;
@property (strong, nonatomic) UIButton *flydownButton;
@property (strong, nonatomic) UIButton *oneKeyStopButton;
@property (strong, nonatomic) UIButton *returnButton;
@property (strong, nonatomic) UIButton *rotateButton;
@property (strong, nonatomic) UIButton *fixedDirectionRotateButton;
@property (strong, nonatomic) UIButton *trackButton;
@property (strong, nonatomic) UIButton *lightButton;
@property (strong, nonatomic) UIButton *voiceButton;

@property (nonatomic, assign) int limitedSpeedValue;    // 0, 1, 2
@property (nonatomic, assign) BOOL limitedHigh;
@property (nonatomic, assign) BOOL usingGravity;
@property (nonatomic, assign) BOOL showControlInterface;
@property (nonatomic, assign) BOOL buttonsVisible;

@property (nonatomic, strong) RudderView *powerRudder;
@property (nonatomic, strong) RudderView *rangerRudder;
@property (nonatomic, assign) int videoRecordingTime;

@property (nonatomic, strong) TrackView *trackView;
@property (nonatomic, assign) BOOL trackMode;

@property (nonatomic, strong) VoiceRecognizer *voiceRecognizer;
@property (nonatomic, strong) UILabel *voiceGuideLabel;

@property (nonatomic, strong) FreeSpaceMonitor *freeSpaceMonitor;

@property (nonatomic, strong) ObjectDetector *detector;
@property (nonatomic, strong) ObjectDetectorHelper *photoPostureHelper;
@property (nonatomic, strong) ObjectDetectorHelper *videoPostureHelper;
@property (nonatomic, strong) ObjectTracker *tracker;
@property (nonatomic, strong) dispatch_queue_t vision_serial_queue;
@property (nonatomic, strong) CountdownLabel *takePhotoCDLabel;
@property (nonatomic, assign) BOOL enableDetectObject;
@property (nonatomic, assign) BOOL enableTrackObject;
@property (nonatomic, assign) int videoPostureCountDown;

// 拍照闪一下
@property (nonatomic, strong) UIView *flashView;
// 正在录像
@property (nonatomic, strong) NSTimer *recordingTimer;
@property (nonatomic, strong) UIImageView *recordingImageView;

@end

@implementation ControlPanelViewController

#pragma mark - Properties

- (ObjectDetector *)detector
{
    if (!_detector) {
        _detector = [[ObjectDetector alloc] init];
    }
    return _detector;
}

- (ObjectDetectorHelper *)photoPostureHelper
{
    if (!_photoPostureHelper) {
        _photoPostureHelper = [[ObjectDetectorHelper alloc] init];
        _photoPostureHelper.faceProbThreshold = 0.5;
        _photoPostureHelper.probThreshold = 0.80;
        _photoPostureHelper.triggerCount = 2;
    }
    return _photoPostureHelper;
}

- (ObjectDetectorHelper *)videoPostureHelper
{
    if (!_videoPostureHelper) {
        _videoPostureHelper = [[ObjectDetectorHelper alloc] init];
        _videoPostureHelper.faceProbThreshold = 0.5;
        _videoPostureHelper.probThreshold = 0.80;
        _videoPostureHelper.triggerCount = 2;
    }
    return _videoPostureHelper;
}

- (ObjectTracker *)tracker
{
    if (!_tracker) {
        _tracker = [[ObjectTracker alloc] init];
    }
    return _tracker;
}

/**
 *  设置限速值
 *
 *  @param limitedSpeedValue 限速值
 */
- (void)setLimitedSpeedValue:(int)limitedSpeedValue
{
    _limitedSpeedValue = limitedSpeedValue;
    
    UIImage *normalImage;
    switch (limitedSpeedValue) {
        case 0:
            normalImage = limitedSpeed30Image;
            break;
        case 1:
            normalImage = limitedSpeed60Image;
            break;
        case 2:
            normalImage = limitedSpeed100Image;
            break;
            
        default:
            normalImage = limitedSpeed30Image;
            break;
    }
    [self.limitedSpeedButton setImage:normalImage forState:UIControlStateNormal];
}

/**
 *  设置限高
 *
 *  @param limitedHigh 开关
 */
- (void)setLimitedHigh:(BOOL)limitedHigh
{
    _limitedHigh = limitedHigh;
    
    if (autosave)
        [Settings saveParameterForAltitudeHold:_limitedHigh];
    
    if (_showControlInterface) {
        _flyupButton.hidden = !_limitedHigh;
        _flydownButton.hidden = !_limitedHigh;
        _oneKeyStopButton.hidden = !_limitedHigh;
//        _returnButton.hidden = !_limitedHigh;
//        _fixedDirectionRotateButton.hidden = !_limitedHigh;
    }
    
    // Set Image
    UIImage *normalImage;
    if (_limitedHigh) {
        normalImage = limitedHighEnabledImage;
    } else {
        normalImage = limitedHighDisabledImage;
    }
    [self.limitedHighButton setImage:normalImage forState:UIControlStateNormal];
}

/**
 *  设置重力感应控制
 *
 *  @param usingGravity 开关
 */
- (void)setUsingGravity:(BOOL)usingGravity
{
    if (!usingGravity
        || ((usingGravity && !_trackMode) && (usingGravity && !voiceMode))) {
        _usingGravity = usingGravity;
        
        [self.gravityControlButton setImage:_usingGravity ? gravityEnabledImage : gravityDisabledImage
                                   forState:UIControlStateNormal];
    }
}

/**
 *  设置控制开关
 *
 *  @param showControlInterface 开关
 */
- (void)setShowControlInterface:(BOOL)showControlInterface
{
    _showControlInterface = showControlInterface;
    
    if (_showControlInterface) {
        controlTimer = [NSTimer scheduledTimerWithTimeInterval:CONTROL_INTERVAL
                                                        target:self
                                                      selector:@selector(sendFlyControlCommand)
                                                      userInfo:nil
                                                       repeats:YES];
    } else {
        [controlTimer invalidate];
        controlTimer = nil;
    }
    
    [self.interfaceSwitchButton setImage:_showControlInterface ? onImage : offImage
                                forState:UIControlStateNormal];
}

- (void)setTrackMode:(BOOL)trackMode
{
    _trackMode = trackMode;
    
    self.rangerRudder.hidden = _trackMode;
    self.trackView.hidden = !_trackMode;
    
    [self.trackButton setImage:_trackMode ? trackEnabledImage : trackDisabledImage
                      forState:UIControlStateNormal];
    
    if (_trackMode) {
        // 关闭重力
        self.usingGravity = NO;
        [self useGravity:NO];
        // 关闭语音控制
        [self toggleVoiceMode:NO];
    }
    else {
        [_trackView reset];     // 结束当前轨迹
    }
}

#pragma mark - Screen rotation & StatusBar Style

- (BOOL)shouldAutorotate
{
    return autoRotation;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - ViewController life-cycle

- (void)dealloc
{
    NSLog(@"ControlPanelViewController: dealloc");
    [self removePlayerNotificationObservers];
    
    // 移除全部通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    IJKFFMoviePlayerController *mpc = self.player;
    [mpc setDelegate:nil];
}

+ (void)presentFromViewController:(UIViewController *)viewController withTitle:(NSString *)title URL:(NSURL *)url completion:(void (^)())completion {
    viewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [viewController presentViewController:[[ControlPanelViewController alloc] initWithURL:url] animated:YES completion:completion];
}

- (instancetype)initWithURL:(NSURL *)url {
    self = [[ControlPanelViewController alloc] init];
    if (self) {
        self.url = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
//    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:NO];
    
    // get device orientation
    NSValue *value = [[UIDevice currentDevice] valueForKey:@"orientation"];
    [value getValue:&orientation];
    NSLog(@"Orientation: %ld", (long)orientation);
    if (orientation != UIDeviceOrientationLandscapeLeft) {
        orientation = UIDeviceOrientationLandscapeRight;
    }
    
    // set color and image of background
    self.view.backgroundColor = [UIColor blackColor];
    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"con_bg"]];
    [self.view insertSubview:self.backgroundImageView atIndex:0];
    // layout constraint
    [self.backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    // spinner
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.color = [UIColor blackColor];
    [self.spinner setHidesWhenStopped:YES];
    [self.view insertSubview:self.spinner aboveSubview:self.backgroundImageView];
    // layout constraint
    [self.spinner mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];

    // interactive view
    _interactiveView = [[UIView alloc] init];
    [self.view insertSubview:_interactiveView aboveSubview:_backgroundImageView];
    // layout constraint
    [_interactiveView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            // crash
//            make.edges.equalTo(self.view.mas_safeAreaLayoutGuide);
            // ok
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.edges.equalTo(self.view);
        }
    }];
    
    // 倒计时拍照
    [self initCountdownLabel];

    [self initTopButtons];
    [self createVideoRecordTimeLabel];
    [self initRudders];
    // Above the rudders
    [self initLeftButtons];
    [self initRightButtons];
    [self initExtraButtons];

    // 注册MessageCenter消息通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMessageCenterNotification:) name:kMessageCenterMessageNotification object:nil];
    
    // 卡拍照录像，默认隐藏
    [self.cardPhotoButton setHidden:YES];
    [self.cardVideoButton setHidden:YES];
    
    // 添加拍照闪一下效果
    [self addFlashView];
    // 添加录像表示
    [self addRecordingImageView];
    
    // 手势识别和物体追踪按键初始化隐藏
    [_detectObjectButton setHidden:YES];
    [_trackObjectButton setHidden:YES];
    
    // 参数自动保存
    autosave = [Settings getParameterForAutosave];
    
    // 3D模式使用
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(tapGesture:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    _buttonsVisible = YES;

    // init state
    if (autosave)
        self.limitedHigh = [Settings getParameterForAltitudeHold];
    else
        self.limitedHigh = NO;
    [self limiteHigh:self.limitedHigh];
    self.usingGravity = NO;
    self.showControlInterface = NO;
    
    // Init Right Buttons Visibility
    [self hideRightButtons:YES];
    // Init Extra Buttons Visibility
    [self hideExtraButtons:YES];
    
    if (autosave)
        self.limitedSpeedValue = (int)[Settings getParameterForSpeedLimit];  // Default is 0
    else
        self.limitedSpeedValue = 0;
    [self limitSpeed:self.limitedSpeedValue];
//    speedValue = 30;
//    speedValuef = 0.3f;
    flyupMode = NO;
    flydownMode = NO;
    returnMode = NO;
    rotateMode = NO;
    fixedDirectionRotateMode = NO;
    headlessMode = NO;
    rollMode = NO;
    triggeredRoll = NO;
    emergencyDownMode = NO;
    gyroCalibrateMode = NO;
    _trackMode = NO;
    lightOn = NO;
    voiceMode = NO;
    
    /* 暂时不需要的！！！ */
    _fixedDirectionRotateButton = nil;
    _rotateButton = nil;
    _returnButton = nil;
//    _oneKeyStopButton = nil;
    /* !!!!!! */
    
    // 任务队列，手势识别和物体追踪
    self.vision_serial_queue = dispatch_queue_create("Vision", DISPATCH_QUEUE_SERIAL);
    
    // 语音控制
    self.voiceRecognizer = [VoiceRecognizer sharedInstance];
    self.voiceRecognizer.delegate = self;
    // Voice guide label
    self.voiceGuideLabel = [[UILabel alloc] init];
    self.voiceGuideLabel.textColor = [UIColor redColor];
    [self resetDefaultVoiceGuide];
    [self.view addSubview:self.voiceGuideLabel];
    self.voiceGuideLabel.hidden = YES;

    // Cannot place in installMovieNotificationObservers, if so, it takes no effect
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:_player];

    // for debug, show framerate, etc
    [_gyroCalibrateButton addTarget:self action:@selector(debugTouchDown) forControlEvents:UIControlEventTouchDown];
    [_gyroCalibrateButton addTarget:self action:@selector(debugTouchUp) forControlEvents:UIControlEventTouchUpInside];
    [_gyroCalibrateButton addTarget:self action:@selector(debugTouchUp) forControlEvents:UIControlEventTouchUpOutside];
    [_gyroCalibrateButton addTarget:self action:@selector(debugTouchUp) forControlEvents:UIControlEventTouchCancel];
    [_settingsButton addTarget:self action:@selector(switchDebugView) forControlEvents:UIControlEventTouchUpInside];
    
    [self prepareDebugIfNecessary];
    
    // MTCNN Trimming
    [self setupMtcnnTrimmingControls];
    
    // fake resolution
    fakeWidth = -1;
    fakeHeight = -1;
}

- (void)openVideo {
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    [options setPlayerOptionIntValue:RtpJpegParsePacketMethodDrop forKey:@"rtp-jpeg-parse-packet-method"];
    [options setPlayerOptionIntValue:0 forKey:@"videotoolbox"];
    [options setPlayerOptionIntValue:5000 * 1000 forKey:@"readtimeout"]; // read packet timeout
    // Image type
    [options setPlayerOptionIntValue:PreferredImageTypeJPEG forKey:@"preferred-image-type"];
    // Image quality, available for lossy format (min and max are both from 1 to 51, 0 < min <= max, smaller is better, default is 2 and 31)
    [options setPlayerOptionIntValue:1 forKey:@"image-quality-min"];
    [options setPlayerOptionIntValue:1 forKey:@"image-quality-max"];
    // video
    [options setPlayerOptionIntValue:PreferredVideoTypeH264     forKey:@"preferred-video-type"];
    [options setPlayerOptionIntValue:1                          forKey:@"video-need-transcoding"];
    [options setPlayerOptionIntValue:MjpegPixFmtYUVJ420P        forKey:@"mjpeg-pix-fmt"];
    // Video quality, for MJPEG and MPEG4
    [options setPlayerOptionIntValue:2                          forKey:@"video-quality-min"];
    [options setPlayerOptionIntValue:20                         forKey:@"video-quality-max"];
    // x264 preset, tune and profile, for H264
    [options setPlayerOptionIntValue:X264OptionPresetUltrafast  forKey:@"x264-option-preset"];
    [options setPlayerOptionIntValue:X264OptionTuneZerolatency  forKey:@"x264-option-tune"];
    [options setPlayerOptionIntValue:X264OptionProfileMain      forKey:@"x264-option-profile"];
    [options setPlayerOptionValue:@"crf=23"                     forKey:@"x264-params"];
    // 录像时自动丢帧
    [options setPlayerOptionIntValue:3 forKey:@"auto-drop-record-frame"];
    // 检测到小错误就停止当前帧解码，避免图像异常
    [options setCodecOptionValue:@"explode" forKey:@"err_detect"];
    
    IJKFFMoviePlayerController *moviePlayerController = [[IJKFFMoviePlayerController alloc] initWithContentURL:self.url withOptions:options];
    moviePlayerController.delegate = self;

    self.player = moviePlayerController;
    self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.player.view.frame = self.view.bounds;
    self.player.scalingMode = IJKMPMovieScalingModeFill;
    self.player.shouldAutoplay = YES;
    
    self.view.autoresizesSubviews = YES;
    [self.view insertSubview:self.player.view aboveSubview:self.backgroundImageView];

    // put log setting here to make it fresh
#ifdef DEBUG
    [IJKFFMoviePlayerController setLogReport:YES];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
#else
    [IJKFFMoviePlayerController setLogReport:NO];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_SILENT];
#endif

    // [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
    // [IJKFFMoviePlayerController checkIfPlayerVersionMatch:YES major:1 minor:0 micro:0];
}

inline static IJKFFMoviePlayerController *ffplayerInstance(id<IJKMediaPlayback> player)
{
    return player;
}

inline static VideoRecordingStatus ffplayerVideoRecordingStatus(IJKFFMoviePlayerController *ffplayer)
{
    return ffplayer.videoRecordingStatus;
}

- (void)viewDidLayoutSubviews
{
    // 因为布局是根据AutoLayout之后，某些控件的位置去摆放，所以放在这里
    // 这个函数会重复调用，所以加个判断
    if (_trackView == nil) {
        // init trackView
        CGRect trackViewFrame;
        
        trackViewFrame = _rangerRudder.frame;
        _trackView = [[TrackView alloc] initWithFrame:trackViewFrame];
        [_interactiveView insertSubview:_trackView belowSubview:self.rangerRudder];
        // set delegate
        _trackView.delegate = self;
        
        [_trackView setSpeedLevel:self.limitedSpeedValue];
        
        // 一开始是隐藏的
        _trackView.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //用来初始化值吧
    [_powerRudder reset];
    [_rangerRudder reset];

    [self.spinner startAnimating];

    [self openVideo];
    [self installMovieNotificationObservers];
    [self.player prepareToPlay];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // 禁用自动锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.spinner stopAnimating];

    [self showControlInterface:NO];
    [self setShowControlInterface:NO];

    [self updateCaptureVideoButtonImage:NO];
    [videoRecordTimeLabel setHidden:YES];
    [videoRecordTimer invalidate];
    videoRecordTimer = nil;

    [self.player stopRecordVideo];

    [self.player shutdown];
    [self.player.view removeFromSuperview];
    [self removeMovieNotificationObservers];
    
    // DEBUG
    [self exitDebugMode];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    // 恢复自动锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (BOOL)isVisible
{
    return [self isViewLoaded] && self.view.window;
}

- (void)createVideoRecordTimeLabel
{
    UILabel *label = [[UILabel alloc] init];
    [label setTextColor:[UIColor redColor]];
    [self.view addSubview:label];

    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.captureVideoButton.mas_bottom);
        make.centerX.equalTo(self.captureVideoButton);
    }];
    
    videoRecordTimeLabel = label;
    [videoRecordTimeLabel setHidden:YES];
}

/**
 *  更新录像按键图像
 *
 *  @param on 开关
 */
- (void)updateCaptureVideoButtonImage:(BOOL)on
{
    [self.captureVideoButton setImage:(on ? videoEnabledImage : videoDisabledImage) forState:UIControlStateNormal];
}

#pragma mark - Buttons

/**
 *  初始化顶部按键
 */
- (void)initTopButtons
{
    self.backingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.captureVideoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.reviewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.limitedSpeedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.limitedHighButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.gravityControlButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.interfaceSwitchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    topButtons = @[
                   self.backingButton,
                   self.takePhotoButton,
                   self.captureVideoButton,
                   self.reviewButton,
                   self.limitedSpeedButton,
                   self.limitedHighButton,
                   self.gravityControlButton,
                   self.interfaceSwitchButton,
                   self.settingsButton,
                   ];
    
    // button image
    backingImage = [UIImage imageNamed:@"con_return"];
    cameraDisabledImage = [UIImage imageNamed:@"con_photo"];
    cameraEnabledImage = [UIImage imageNamed:@"con_photo_h"];
    videoDisabledImage = [UIImage imageNamed:@"con_video"];
    videoEnabledImage = [UIImage imageNamed:@"con_video_h"];
    reviewNormalImage = [UIImage imageNamed:@"con_media_library"];
    reviewHighlightView = [UIImage imageNamed:@"con_media_library_h"];
    limitedSpeed100Image = [UIImage imageNamed:@"con_speed_100"];
    limitedSpeed60Image = [UIImage imageNamed:@"con_speed_60"];
    limitedSpeed30Image = [UIImage imageNamed:@"con_speed_30"];
    limitedHighDisabledImage = [UIImage imageNamed:@"con_altitude_hold"];
    limitedHighEnabledImage = [UIImage imageNamed:@"con_altitude_hold_h"];
    gravityDisabledImage = [UIImage imageNamed:@"con_gravity_control"];
    gravityEnabledImage = [UIImage imageNamed:@"con_gravity_control_h"];
    offImage = [UIImage imageNamed:@"con_off"];
    onImage = [UIImage imageNamed:@"con_on"];
    settingsImage = [UIImage imageNamed:@"con_extra_settings"];
    
    // for state NORMAL
    [self.backingButton setImage:backingImage forState:UIControlStateNormal];
    [self.takePhotoButton setImage:cameraDisabledImage forState:UIControlStateNormal];
    [self.captureVideoButton setImage:videoDisabledImage forState:UIControlStateNormal];
    [self.reviewButton setImage:reviewNormalImage forState:UIControlStateNormal];
    [self.limitedSpeedButton setImage:limitedSpeed30Image forState:UIControlStateNormal];
    [self.limitedHighButton setImage:limitedHighDisabledImage forState:UIControlStateNormal];
    [self.gravityControlButton setImage:gravityDisabledImage forState:UIControlStateNormal];
    [self.interfaceSwitchButton setImage:offImage forState:UIControlStateNormal];
    [self.settingsButton setImage:settingsImage forState:UIControlStateNormal];
    
    // for state HIGHLIGHTED
    [self.takePhotoButton setImage:cameraEnabledImage forState:UIControlStateHighlighted];
    [self.reviewButton setImage:reviewHighlightView forState:UIControlStateHighlighted];
    
    for (UIButton *button in topButtons) {
        [button addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
        [_interactiveView addSubview:button];
    }

    // layout constraint
    CGFloat margin_lr = 4.0;
    CGFloat margin_top = is_iPhoneX ? 3.0 : 4.0;
    
    // 计算每个按键的平均水平间隔
    CGFloat sumWidth = 0;
    for (UIButton *button in topButtons) {
        [button sizeToFit];
        sumWidth += button.bounds.size.width;
    }
    
    CGFloat safeAreaWidth = [[UIScreen mainScreen] widthOfSafeArea];
    NSUInteger n = [topButtons count] - 1;
    CGFloat nWidth = (safeAreaWidth - sumWidth - margin_lr * 2) / n;
    
    [topButtons mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:nWidth leadSpacing:margin_lr tailSpacing:margin_lr];
    [topButtons mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(margin_top);
    }];
}

- (void)initLeftButtons
{
    UIView *containerView = _interactiveView;
    
    self.cardPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cardVideoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self.detectObjectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.trackObjectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    leftButtons = @[
                    self.cardPhotoButton,
                    self.cardVideoButton,
                    self.detectObjectButton,
                    self.trackObjectButton,
                    ];
    
    [self.cardPhotoButton setImage:[UIImage imageNamed:@"con_sd_photo"] forState:UIControlStateNormal];
    [self.cardPhotoButton setImage:[UIImage imageNamed:@"con_sd_photo_h"] forState:UIControlStateHighlighted];
    [self.cardVideoButton setImage:[UIImage imageNamed:@"con_sd_video"] forState:UIControlStateNormal];
    [self.cardVideoButton setImage:[UIImage imageNamed:@"con_sd_video_h"] forState:UIControlStateHighlighted];
    
    detectObjectDisableImage = [UIImage imageNamed:@"con_detect_object"];
    detectObjectEnableImage = [UIImage imageNamed:@"con_detect_object_h"];
    trackObjectDisableImage = [UIImage imageNamed:@"con_track_object"];
    trackObjectEnableImage = [UIImage imageNamed:@"con_track_object_h"];
    
    [self.detectObjectButton setImage:detectObjectDisableImage forState:UIControlStateNormal];
    [self.trackObjectButton setImage:trackObjectDisableImage forState:UIControlStateNormal];
    
    [containerView addSubview:self.cardPhotoButton];
    [containerView addSubview:self.cardVideoButton];
    
    [containerView addSubview:self.detectObjectButton];
    [containerView addSubview:self.trackObjectButton];
    
    [self.cardPhotoButton addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.cardVideoButton addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.detectObjectButton addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.trackObjectButton addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    
    // layout
    [self.cardVideoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.backingButton);
        make.bottom.mas_equalTo(containerView.mas_centerY).with.offset(-1.0);
    }];
    [self.cardPhotoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.backingButton);
        make.bottom.mas_equalTo(self.cardVideoButton.mas_top).with.offset(-1.0);
    }];
    [self.detectObjectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.backingButton);
        make.top.mas_equalTo(containerView.mas_centerY).with.offset(1.0);
    }];
    [self.trackObjectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.backingButton);
        make.top.mas_equalTo(self.detectObjectButton.mas_bottom).with.offset(1.0);
    }];
}

- (void)initRightButtons
{
    UIView *containerView = _interactiveView;
    
    self.rotateScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.splitScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.headlessButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.gyroCalibrateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.lightButton = [UIButton buttonWithType:UIButtonTypeCustom];

    rightButtons = @[
                     self.rotateScreenButton,
                     self.splitScreenButton,
                     self.lightButton,
                     self.headlessButton,
                     self.gyroCalibrateButton,
                     ];
    
    rotateScreenImage = [UIImage imageNamed:@"con_rotate_screen"];
    rotateScreenHighlightImage = [UIImage imageNamed:@"con_rotate_screen_h"];
    splitScreenImage = [UIImage imageNamed:@"con_3d"];
    headlessDisabledImage = [UIImage imageNamed:@"con_headless"];
    headlessEnabledImage = [UIImage imageNamed:@"con_headless_h"];
    gyroCalibrateDisabledImage = [UIImage imageNamed:@"con_gyroscope_calibrate"];
    gyroCalibrateEnabledImage = [UIImage imageNamed:@"con_gyroscope_calibrate_h"];
    lightDisabledImage = [UIImage imageNamed:@"con_light"];
    lightEnabledImage = [UIImage imageNamed:@"con_light_h"];
    
    // Image for Normal State
    [self.rotateScreenButton setImage:rotateScreenImage forState:UIControlStateNormal];
    [self.splitScreenButton setImage:splitScreenImage forState:UIControlStateNormal];
    [self.headlessButton setImage:headlessDisabledImage forState:UIControlStateNormal];
    [self.gyroCalibrateButton setImage:gyroCalibrateDisabledImage forState:UIControlStateNormal];
    [self.lightButton setImage:lightDisabledImage forState:UIControlStateNormal];
    
    // Image for Highlighted State
    [self.rotateScreenButton setImage:rotateScreenHighlightImage forState:UIControlStateHighlighted];
    [self.headlessButton setImage:headlessEnabledImage forState:UIControlStateHighlighted];
    [self.gyroCalibrateButton setImage:gyroCalibrateEnabledImage forState:UIControlStateHighlighted];
    
    [containerView addSubview:self.rotateScreenButton];
    [containerView addSubview:self.splitScreenButton];
    [containerView addSubview:self.headlessButton];
    [containerView addSubview:self.gyroCalibrateButton];
    [containerView addSubview:self.lightButton];
    
    [self.rotateScreenButton addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.splitScreenButton addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.headlessButton addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.gyroCalibrateButton addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.lightButton addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];

    // layout constraint, distribute views in y axis
    UIView *xRefView = self.settingsButton;
    UIView *prevView = self.settingsButton;
    for (UIButton *button in rightButtons) {
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            if (is_iPhoneX) {
                make.top.equalTo(prevView.mas_bottom).with.offset(-2.0);
            } else {
                make.top.equalTo(prevView.mas_bottom).with.offset(1.0);
            }
            make.centerX.equalTo(xRefView);
        }];
        prevView = button;
    }
}

- (void)initExtraButtons
{
    UIView *containerView = _interactiveView;
    
    self.rollButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.flyupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.flydownButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.oneKeyStopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rotateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.fixedDirectionRotateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.trackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];

    extraButtons = @[
                       self.rollButton,
                       self.flyupButton,
                       self.flydownButton,
                       self.oneKeyStopButton,
                       self.returnButton,
                       self.rotateButton,
                       self.fixedDirectionRotateButton,
                       self.trackButton,
                       self.voiceButton
                       ];
    
    rollDisabledImage = [UIImage imageNamed:@"con_roll"];
    rollEnabledImage = [UIImage imageNamed:@"con_roll_h"];
    flyupDisabledImage = [UIImage imageNamed:@"con_takeoff"];
    flyupEnabledImage = [UIImage imageNamed:@"con_takeoff_h"];
    flydownDisabledImage = [UIImage imageNamed:@"con_landon"];
    flydownEnabledImage = [UIImage imageNamed:@"con_landon_h"];
    oneKeyStopDisabledImage = [UIImage imageNamed:@"con_emergency_stop"];
    oneKeyStopEnabledImage = [UIImage imageNamed:@"con_emergency_stop_h"];
    returnDisabledImage = [UIImage imageNamed:@"con_go_home"];
    returnEnabledImage = [UIImage imageNamed:@"con_go_home_h"];
    rotateDisableImage = [UIImage imageNamed:@"con_rotate"];
    rotateEnableImage = [UIImage imageNamed:@"con_rotate_h"];
    fixedDirectionRotateDisabledImage = [UIImage imageNamed:@"con_rotate_direction"];
    fixedDirectionRotateEnabledIamge = [UIImage imageNamed:@"con_rotate_direction_h"];
    trackDisabledImage = [UIImage imageNamed:@"con_track"];
    trackEnabledImage = [UIImage imageNamed:@"con_track_h"];
    voiceDisabledImage = [UIImage imageNamed:@"con_voice"];
    voiceEnabledImage = [UIImage imageNamed:@"con_voice_h"];
    
    // Image for Normal State
    [self.rollButton setImage:rollDisabledImage forState:UIControlStateNormal];
    [self.flyupButton setImage:flyupDisabledImage forState:UIControlStateNormal];
    [self.flydownButton setImage:flydownDisabledImage forState:UIControlStateNormal];
    [self.oneKeyStopButton setImage:oneKeyStopDisabledImage forState:UIControlStateNormal];
    [self.returnButton setImage:returnDisabledImage forState:UIControlStateNormal];
    [self.rotateButton setImage:rotateDisableImage forState:UIControlStateNormal];
    [self.fixedDirectionRotateButton setImage:fixedDirectionRotateDisabledImage forState:UIControlStateNormal];
    [self.trackButton setImage:trackDisabledImage forState:UIControlStateNormal];
    [self.voiceButton setImage:voiceDisabledImage forState:UIControlStateNormal];
    
    // Image for Highlighted State
    [self.flyupButton setImage:flyupEnabledImage forState:UIControlStateHighlighted];
    [self.flydownButton setImage:flydownEnabledImage forState:UIControlStateHighlighted];
//    [self.oneKeyStopButton setImage:oneKeyStopEnabledImage forState:UIControlStateHighlighted];
    
    [containerView addSubview:self.rollButton];
    [containerView addSubview:self.flyupButton];
//    [containerView addSubview:self.flydownButton];
    [containerView insertSubview:self.flydownButton belowSubview:self.gyroCalibrateButton];  // 特殊处理
    [containerView addSubview:self.oneKeyStopButton];
    [containerView addSubview:self.returnButton];
    [containerView addSubview:self.rotateButton];
    [containerView addSubview:self.fixedDirectionRotateButton];
    [containerView addSubview:self.trackButton];
    [containerView addSubview:self.voiceButton];
    
    [self.rollButton addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.flyupButton addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.flydownButton addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.oneKeyStopButton addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.returnButton addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.rotateButton addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.fixedDirectionRotateButton addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.trackButton addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.voiceButton addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];

    // Buttons at centerX
    UIView *xRefView = containerView;
    [self.rotateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.limitedSpeedButton.mas_bottom).with.offset(1.0);
        make.right.equalTo(xRefView.mas_centerX).with.offset(-1.0);
    }];
    [self.fixedDirectionRotateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.limitedSpeedButton.mas_bottom).with.offset(1.0);
        make.left.equalTo(xRefView.mas_centerX).with.offset(1.0);
    }];
    [self.returnButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.rotateButton.mas_bottom).with.offset(1.0);
        make.centerX.equalTo(xRefView);
    }];
    [self.rollButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.limitedSpeedButton.mas_bottom).with.offset(1.0);
        make.centerX.equalTo(xRefView);
    }];
    [self.trackButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.rollButton.mas_bottom).with.offset(1.0);
        make.centerX.equalTo(xRefView);
    }];
    [self.voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.trackButton.mas_bottom).with.offset(1.0);
        make.centerX.equalTo(xRefView);
    }];
    // Buttons at bottom
    [self.flyupButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(containerView);
        make.left.equalTo(containerView).with.offset(4.0);
    }];
    [self.flydownButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(containerView);
        make.right.equalTo(containerView).with.offset(-4.0);
    }];
    [self.oneKeyStopButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(containerView);
        make.centerX.equalTo(containerView);
    }];
}

#pragma mark - Rudders

/**
 *  初始化控制台
 */
- (void)initRudders
{
    // 宽高
    CGFloat safeAreaWidth = [[UIScreen mainScreen] widthOfSafeArea];
    CGFloat safeAreaHeight = [[UIScreen mainScreen] heightOfSafeArea];
    // 计算Rudder坐标
    CGFloat topButtonBottom = self.takePhotoButton.frame.origin.y + self.takePhotoButton.frame.size.height;
    CGFloat rudderTop = topButtonBottom + 4;
    CGFloat rudderHeight = safeAreaHeight - rudderTop - 8;
    // 计算左右中心点
    CGPoint leftCenter = CGPointMake(safeAreaWidth / 4, rudderTop + rudderHeight / 2);
    CGPoint rightCenter = CGPointMake(safeAreaWidth * 3 / 4, rudderTop + rudderHeight / 2);
    
    // 初始化Power Rudder
    _powerRudder = [[RudderView alloc] initWithFrame:CGRectMake(0, rudderTop, rudderHeight, rudderHeight)];
    _powerRudder.rudderStyle = RudderStylePower;
    _powerRudder.delegate = self;
    _powerRudder.center = leftCenter;
    _powerRudder.hidden = !self.showControlInterface;
    [_interactiveView addSubview:_powerRudder];
    
    // 初始化Ranger Rudder
    _rangerRudder = [[RudderView alloc] initWithFrame:CGRectMake(safeAreaWidth / 2, rudderTop, rudderHeight, rudderHeight)];
    _rangerRudder.rudderStyle = RudderStyleRanger;
    _rangerRudder.delegate = self;
    _rangerRudder.center = rightCenter;
    _rangerRudder.hidden = !self.showControlInterface;
    _rangerRudder.useGravity = self.usingGravity;
    _rangerRudder.orientation = orientation;
    [_interactiveView addSubview:_rangerRudder];
    
    // 如果是右手模式
    BOOL isRightHandMode = [Settings getParameterForRightHandMode];
    if (isRightHandMode) {
        _powerRudder.center = rightCenter;
        _rangerRudder.center = leftCenter;
    }
    
    //用来初始化值吧
    [_powerRudder reset];
    [_rangerRudder reset];
}

#pragma mark - CountDownLabel

- (void)initCountdownLabel {
    UIView *containerView = _interactiveView;
    
    CountdownLabel *countdownLabel = [[CountdownLabel alloc] init];
    self.takePhotoCDLabel = countdownLabel;
    countdownLabel.delegate = self;
    countdownLabel.textAlignment = NSTextAlignmentCenter;
    countdownLabel.textColor = [UIColor whiteColor];
    countdownLabel.font = [UIFont systemFontOfSize:60];
    countdownLabel.count = 3; //设置倒计时时间，默认是3
    [containerView addSubview:countdownLabel];
    
    [countdownLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.and.height.mas_equalTo(@48);
        make.center.equalTo(containerView);
    }];
}

- (void)countdownEnded:(CountdownLabel *)cdLabel
{
    if (cdLabel == self.takePhotoCDLabel) {
        [self takeScreenshot:1];
    }
}

#pragma mark - Video Action Count Down

- (void)initVideoPostureCountDown
{
    self.videoPostureCountDown = 3; // 设定3秒内禁止动作
//    NSTimer *timer =
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(videoPostureCountdownEnded:)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)videoPostureCountdownEnded:(NSTimer *)timer
{
    self.videoPostureCountDown--;
    if (self.videoPostureCountDown == 0) {
        [timer invalidate];
    }
}

#pragma mark - Button Action

/**
 *  截图
 */
- (void)takeScreenshot:(int)number
{
    NSString *dirPath = [Utilities mediaDirPath];
    NSString *fileName = [Utilities mediaFileName];
    int width, height;

    if (isBothFakeResolution) {
        width = fakePhotoWidth;
        height = fakePhotoHeight;
    } else if (isFakeResolution) {
        width = fakeWidth;
        height = fakeHeight;
    } else {
        width = height = -1;
    }

    // take picture and wait for delegate method
    [self.player takePictureAtPath:dirPath withFileName:fileName width:width height:height number:number];
}

/**
 *  录制视频
 *
 */
- (void)recordVideo
{
    IJKFFMoviePlayerController *ffplayer = ffplayerInstance(self.player);
    VideoRecordingStatus status = ffplayerVideoRecordingStatus(ffplayer);
    
    // take recording action and wait for delegate method
    // if idle, start recording
    if (status == VideoRecordingStatusIdle) {
        _freeSpaceMonitor = [[FreeSpaceMonitor alloc] init];
        _freeSpaceMonitor.delegate = self;
        if ([_freeSpaceMonitor checkFreeSpace]) {
            [self doRecordVideo];
        }
        else {
            unsigned long long threshold = _freeSpaceMonitor.threshold;

            _freeSpaceMonitor.delegate = nil;
            _freeSpaceMonitor = nil;

            // 录像提示空间不足
            NSString *infoString = [NSString stringWithFormat:NSLocalizedString(@"INSUFFICIENT_STORAGE_CANNOT_START", @""), [Utilities memoryFormatter:threshold]];
            [self.player.view makeToast:infoString duration:2.0 position:CSToastPositionBottom];
        }
    }
    // if recording, stop it
    else if (status == VideoRecordingStatusRecording) {
        [self.player stopRecordVideo];
    }
    // if stopping, do nothing
    else {
        NSLog(@"Recording video: Do nothing");
    }
}

- (void)doRecordVideo
{
    NSString *dirPath = [Utilities mediaDirPath];
    NSString *fileName = [Utilities mediaFileName];
    int width, height;
    
    if (isBothFakeResolution) {
        width = fakeVideoWidth;
        height = fakeVideoHeight;
    } else if (isFakeResolution) {
        width = fakeWidth;
        height = fakeHeight;
    } else {
        width = height = -1;
    }
    
    [self.player startRecordVideoAtPath:dirPath withFileName:fileName width:width height:height];
}

/**
 *  更新录像时间
 *
 *  @param timer 定时器
 */
- (void)updateVideoRecordTime:(NSTimer *)timer
{
    videoRecordTime++;

    NSString *videoRecordTimeString;
    if (videoRecordTime >= 3600)
        videoRecordTimeString = [NSString stringWithFormat:@"%.2d:%.2d:%.2d", videoRecordTime / 3600, (videoRecordTime % 3600) / 60, videoRecordTime % 60];
    else
        videoRecordTimeString = [NSString stringWithFormat:@"%.2d:%.2d", videoRecordTime / 60, videoRecordTime % 60];

    dispatch_async(dispatch_get_main_queue(), ^{
        [videoRecordTimeLabel setText:videoRecordTimeString];
        [videoRecordTimeLabel sizeToFit];
    });
}

/**
 *  显示媒体库
 */
- (void)showMediaLibrary
{
    MediaLibraryViewController *vc = [[MediaLibraryViewController alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:NO completion:^{
        // 关闭手势识别和物体追踪
        if (self.enableDetectObject)
            [self detectObject:NO];
        if (self.enableTrackObject)
            [self trackObject:NO];
        // 隐藏卡拍照录像
        self.cardPhotoButton.hidden = YES;
        self.cardVideoButton.hidden = YES;
        // 隐藏手势识别和物体追踪按键
        self.detectObjectButton.hidden = YES;
        self.trackObjectButton.hidden = YES;
    }];
}

/**
 *  限速功能
 *
 *  @param speedValue 限速值
 */
- (void)limitSpeed:(int)sv
{
    int sl = sv;
    
    if (autosave)
        [Settings saveParameterForSpeedLimit:sl];
    
    switch (sl) {
        case 0:
            speedValue = 30;
            speedValuef = 0.3f;
            break;
        case 1:
            speedValue = 60;
            speedValuef = 0.6f;
            break;
        case 2:
            speedValue = 100;
            speedValuef = 1.0f;
            break;
            
        default:
            speedValue = 30;
            speedValuef = 0.3f;
            break;
    }
    
    // 设置飞行轨迹的速度级
    [_trackView setSpeedLevel:sl];
}

/**
 *  限高功能
 *
 *  @param limited 开关
 */
- (void)limiteHigh:(BOOL)limited
{
    if (limited) {
        [_powerRudder lockToHalfPowerMode];
    } else {
        [_powerRudder unlockHalfPowerMode];
    }
}

- (void)stepLimitSpeed
{
    self.limitedSpeedValue = ++self.limitedSpeedValue % 3;
    [self limitSpeed:self.limitedSpeedValue];
}

/**
 *  使用重力感应控制
 *
 *  @param use 开关
 */
- (void)useGravity:(BOOL)use
{
    if (!use
        || ((use && !_trackMode) && (use && !voiceMode))) {
        [_rangerRudder setUseGravity:use];
    }
}

/**
 *  使能控制
 *
 *  @param show 开关
 */
- (void)showControlInterface:(BOOL)en
{
    _powerRudder.hidden = !en;
    if (!_trackMode)
        _rangerRudder.hidden = !en;
    
    _rollButton.hidden = !en;
    _returnButton.hidden = !en;
    _rotateButton.hidden = !en;
    _fixedDirectionRotateButton.hidden = !en;
    _trackButton.hidden = !en;
    _voiceButton.hidden = !en;
    
    if (en) {
        if (self.limitedHigh) {
            _flyupButton.hidden = NO;
            _flydownButton.hidden = NO;
            _oneKeyStopButton.hidden = NO;
        }
        if (_trackMode) {
            _trackView.hidden = NO;
        }
    } else {
        _flyupButton.hidden = YES;
        _flydownButton.hidden = YES;
        _oneKeyStopButton.hidden = YES;
        _returnButton.hidden = YES;
        _rotateButton.hidden = YES;
        _fixedDirectionRotateButton.hidden = YES;
        _trackButton.hidden = YES;
        _voiceButton.hidden = YES;
        
        self.usingGravity = NO;
        [self useGravity:NO];
        
        _trackView.hidden = YES;
        [_trackView reset];     // 结束当前轨迹
        
        if (voiceMode)
            [self toggleVoiceMode:NO];
    }
}

/**
 *  屏幕旋转
 */
- (void)rotateScreen
{
    [self.player setRotation180:!self.player.isRotation180];
    [self hideRightButtons:YES];
}

/**
 *  切换3D视图
 
 */
- (void)switch3dMode
{
    // Set button image
    [self.player setVrMode:!self.player.isVrMode];
    if (self.player.isVrMode) {
        splitScreenImage = [UIImage imageNamed:@"con_flat"];
    } else {
        splitScreenImage = [UIImage imageNamed:@"con_3d"];
    }
    [self.splitScreenButton setImage:splitScreenImage forState:UIControlStateNormal];
    
    // Set buttons visibility timer
    if (self.player.isVrMode) {
        [self showControlInterface:NO];
        [self setShowControlInterface:NO];
        [self setButtonsInvisibleTimer];
    } else {
        [self setButtonsVisible];
    }
    
    _vrMode = self.player.isVrMode;
    self.player.view.userInteractionEnabled = self.player.isVrMode;
}

- (void)setButtonsInvisibleTimer
{
    buttonVisibleTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                          target:self
                                                        selector:@selector(setButtonsInvisible)
                                                        userInfo:nil
                                                         repeats:NO];
}

- (void)setButtonsInvisible
{
    [self hideTopButtons:YES];
    [self hideLeftButtons:YES];
    [self hideRightButtons:YES];
    
    if (buttonVisibleTimer != nil) {
        [buttonVisibleTimer invalidate];
        buttonVisibleTimer = nil;
    }
    
    _buttonsVisible = NO;
}

- (void)setButtonsVisible
{
    [self hideTopButtons:NO];
    [self hideLeftButtons:NO];
    [self hideRightButtons:NO];
    
    if (buttonVisibleTimer != nil) {
        [buttonVisibleTimer invalidate];
        buttonVisibleTimer = nil;
    }
    
    _buttonsVisible = YES;
}

- (void)hideTopButtons:(BOOL)hidden
{
    for (UIButton *button in topButtons)
        button.hidden = hidden;
}

- (void)hideLeftButtons:(BOOL)hidden
{
//    for (UIButton *button in leftButtons)
//        button.hidden = hidden;
    self.detectObjectButton.hidden = hidden;
}

- (void)hideRightButtons:(BOOL)hidden
{
    for (UIButton *button in rightButtons)
        button.hidden = hidden;
}

- (void)hideExtraButtons:(BOOL)hidden
{
    for (UIButton *button in extraButtons)
        button.hidden = hidden;
}

- (void)tapGesture:(UIGestureRecognizer *)r
{
    if (self.player.isVrMode) {
        if (_buttonsVisible) {
            [self setButtonsInvisible];
        } else {
            [self setButtonsVisible];
            [self setButtonsInvisibleTimer];
        }
    }
}

/**
 *  清除flyup模式
 */
- (void)clearFlyupMode
{
    // Clear flyup mode
    flyupMode = NO;
    
    [self resetDefaultVoiceGuide];
    
    // Invalidate timer and set to nil
    [flyupTimer invalidate];
    flyupTimer = nil;
}

/**
 *  清除flydown模式
 */
- (void)clearFlydownMode
{
    // Clear flydown mode
    flydownMode = NO;
    
    [self resetDefaultVoiceGuide];
    
    // Invalidate timer and set to nil
    [flydownTimer invalidate];
    flydownTimer = nil;
}

/**
 *  清除emergency down模式
 */
- (void)clearEmergencyDownMode
{
    // Clear emergency down mode
    emergencyDownMode = NO;
    [_oneKeyStopButton setImage:oneKeyStopDisabledImage forState:UIControlStateNormal];
    // Invalidate timer and set to nil
    [emergencyDownTimer invalidate];
    emergencyDownTimer = nil;
}

/**
 *  清除gyro calibrate mode
 */
- (void)clearGyroCalibrateMode
{
    // Clear gyro calibrate mode
    gyroCalibrateMode = NO;
    // Invalidate timer and set to nil
    [gyroCalibrateTimer invalidate];
    gyroCalibrateTimer = nil;
}

- (void)toggleVoiceMode:(BOOL)b
{
    if (b) {
        [self.voiceButton setImage:voiceEnabledImage forState:UIControlStateNormal];

        [self.voiceRecognizer startListening];

        // 关闭重力
        self.usingGravity = NO;
        [self useGravity:NO];
        // 关闭轨迹飞行
        if (_trackMode)
            self.trackMode = NO;
    } else {
        [self.voiceRecognizer stopListening];
        
        [self.voiceButton setImage:voiceDisabledImage forState:UIControlStateNormal];
    }
}

- (void)clearVoiceMode
{
    [_rangerRudder moveStickTo:CGPointMake(0, 0)];
    
    [self resetDefaultVoiceGuide];
    
    // set voice control timer to nil
    if (voiceControlTimer) {
        [voiceControlTimer invalidate];
        voiceControlTimer = nil;
    }
}

- (void)resetDefaultVoiceGuide
{
    self.voiceGuideLabel.text = NSLocalizedString(@"CONTROL_PANEL_VOICE_GUIDE", @"Voice guide text");
    [self.voiceGuideLabel sizeToFit];
    self.voiceGuideLabel.center = self.view.center;
}

/**
 * 手势识别和物体跟踪
 */

- (void)detectObject:(BOOL)enable
{
    if (enable == self.enableDetectObject)
        return;
    
    // 关闭物体追踪
    if (self.enableTrackObject) {
        [self trackObject:NO];
    }
    
    IJKFFMoviePlayerController *ffplayer = ffplayerInstance(self.player);
    
    if (enable) {
        [ffplayer setOutputVideo:YES];
        self.enableDetectObject = YES;
    } else {
        [ffplayer setOutputVideo:NO];
        self.enableDetectObject = NO;
    }
    
    [self.detectObjectButton setImage:self.enableDetectObject ? detectObjectEnableImage : detectObjectDisableImage
                             forState:UIControlStateNormal];
}

- (void)trackObject:(BOOL)enable
{
    if (enable == self.enableTrackObject)
        return;
    
    // 关闭手势识别
    if (self.enableDetectObject) {
        [self detectObject:NO];
    }
    
    IJKFFMoviePlayerController *ffplayer = ffplayerInstance(self.player);
    
    if (enable) {
        [ffplayer setOutputVideo:YES];
        self.enableTrackObject = YES;
    } else {
        [ffplayer setOutputVideo:NO];
        self.enableTrackObject = NO;
        
        // reset fly control
        controlByteELE = 0x80;
        controlByteAIL = 0x80;
    }
    
    [self.trackObjectButton setImage:self.enableTrackObject ? trackObjectEnableImage : trackObjectDisableImage
                            forState:UIControlStateNormal];
}

/**
 *  点击控制按键
 *
 *  @param button 按键实例
 */
- (void)tapButton:(UIButton *)button
{
    if (button == self.backingButton) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else if (button == self.takePhotoButton) {
        [self takeScreenshot:1];
    }
    else if (button == self.captureVideoButton) {
        [self recordVideo];
    }
    else if (button == self.reviewButton) {
        [self showMediaLibrary];
    }
    else if (button == self.limitedSpeedButton) {
        [self stepLimitSpeed];
    }
    else if (button == self.limitedHighButton) {
        self.limitedHigh = !self.limitedHigh;
        
        [self limiteHigh:self.limitedHigh];
    }
    else if (button == self.gravityControlButton) {
        if (self.showControlInterface) {
            self.usingGravity = !self.usingGravity;
            
            [self useGravity:self.usingGravity];
        }
    }
    else if (button == self.interfaceSwitchButton) {
        if (!self.player.isVrMode) {
            self.showControlInterface = !self.showControlInterface;
            [self showControlInterface:self.showControlInterface];
        }
    }
    else if (button == self.rotateScreenButton) {
        [self rotateScreen];
    }
    else if (button == self.splitScreenButton) {
        [self switch3dMode];
    }
    // --------------------------------------------
    else if (button == self.settingsButton) {
        [self hideRightButtons:!self.rotateScreenButton.hidden];
    }
    else if (button == self.headlessButton) {
        headlessMode = !headlessMode;
        if (headlessMode) {
            [self.headlessButton setImage:headlessEnabledImage forState:UIControlStateNormal];
        } else {
            [self.headlessButton setImage:headlessDisabledImage forState:UIControlStateNormal];
        }
    }
    else if (button == self.gyroCalibrateButton) {
        // GyroCalibrate
        if (!gyroCalibrateMode) {
            gyroCalibrateMode = YES;
            if (gyroCalibrateTimer == nil) {
                gyroCalibrateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                      target:self
                                                                    selector:@selector(clearGyroCalibrateMode)
                                                                    userInfo:nil
                                                                     repeats:NO];
            }
        }
    }
    else if (button == self.rollButton) {
        if (!(returnMode || _trackMode)) {
            if (!triggeredRoll) {
                rollMode = !rollMode;
                if (rollMode) {
                    [self.rollButton setImage:rollEnabledImage forState:UIControlStateNormal];
                } else {
                    [self.rollButton setImage:rollDisabledImage forState:UIControlStateNormal];
                }
            }
        }
    }
    else if (button == self.flyupButton) {
        if (!flyupMode) {
            flyupMode = YES;
            if (flyupTimer == nil) {
                flyupTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                              target:self
                                                            selector:@selector(clearFlyupMode)
                                                            userInfo:nil
                                                             repeats:NO];
            }
        }
    }
    else if (button == self.flydownButton) {
        if (!flydownMode) {
            flydownMode = YES;
            if (flydownTimer == nil) {
                flydownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                target:self
                                                              selector:@selector(clearFlydownMode)
                                                              userInfo:nil
                                                               repeats:NO];
            }
        }
        // 按一键下降后，紧急停止置0
        emergencyDownMode = NO;
        [_oneKeyStopButton setImage:oneKeyStopDisabledImage forState:UIControlStateNormal];
    }
    else if (button == self.oneKeyStopButton) {
        if (!emergencyDownMode) {
            // 油门百分比
            float fTHR = (float)controlByteTHR / 255.0;
            if (fTHR > 0.4) {
                emergencyDownMode = YES;
                [_oneKeyStopButton setImage:oneKeyStopEnabledImage forState:UIControlStateNormal];
                
                if (emergencyDownTimer == nil) {
                    emergencyDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                          target:self
                                                                        selector:@selector(clearEmergencyDownMode)
                                                                        userInfo:nil
                                                                         repeats:NO];
                }
            }
        } else {
            emergencyDownMode = NO;
            [_oneKeyStopButton setImage:oneKeyStopDisabledImage forState:UIControlStateNormal];
            
            if (emergencyDownTimer != nil) {
                [self clearEmergencyDownMode];
            }
        }
    }
    else if (button == self.returnButton) {
        if (!(rollMode || _trackMode)) {
            returnMode = !returnMode;
            if (returnMode) {
                [self.returnButton setImage:returnEnabledImage forState:UIControlStateNormal];
            } else {
                [self.returnButton setImage:returnDisabledImage forState:UIControlStateNormal];
            }
        }
    }
    else if (button == self.rotateButton) {
        rotateMode = !rotateMode;
        if (rotateMode) {
            [self.rotateButton setImage:rotateEnableImage forState:UIControlStateNormal];
        } else {
            [self.rotateButton setImage:rotateDisableImage forState:UIControlStateNormal];
        }
    }
    else if (button == self.fixedDirectionRotateButton) {
        fixedDirectionRotateMode = !fixedDirectionRotateMode;
        if (fixedDirectionRotateMode) {
            [self.fixedDirectionRotateButton setImage:fixedDirectionRotateEnabledIamge forState:UIControlStateNormal];
        } else {
            [self.fixedDirectionRotateButton setImage:fixedDirectionRotateDisabledImage forState:UIControlStateNormal];
        }
    }
    else if (button == self.trackButton) {
        if (!(returnMode || rollMode)) {
            self.trackMode = !self.trackMode;
        }
    }
    else if (button == self.lightButton) {
        lightOn = !lightOn;
        if (lightOn) {
            [self.lightButton setImage:lightEnabledImage forState:UIControlStateNormal];
        } else {
            [self.lightButton setImage:lightDisabledImage forState:UIControlStateNormal];
        }
    }
    else if (button == self.voiceButton) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    NSLog(@"Permission granted");
                    self.voiceButton.enabled = NO;
                    BOOL en = !voiceMode;
                    [self toggleVoiceMode:en];
                }
                else {
                    NSLog(@"Permission denied");
                    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                    // app名称
                    NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
                    // 临时先这样吧
                    if (@available(iOS 8.0, *)) {
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"CONTROL_PANEL_PERMISSION_DENIED", @"")
                                                                                                 message:[NSString stringWithFormat:NSLocalizedString(@"CONTROL_PANEL_REQUEST_RECORD_PERMISSION", @""), appName]
                                                                                          preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK"
                                                                               style:UIAlertActionStyleCancel
                                                                             handler:nil];
                        [alertController addAction:cancelAction];
                        [self presentViewController:alertController animated:YES completion:nil];
                    } else {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CONTROL_PANEL_PERMISSION_DENIED", @"")
                                                                            message:[NSString stringWithFormat:NSLocalizedString(@"CONTROL_PANEL_REQUEST_RECORD_PERMISSION", @""), appName]
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                        [alertView show];
                    }
                }
            });
        }];
    }
    // left side
    else if (button == self.detectObjectButton) {
        [self detectObject:!self.enableDetectObject];
    }
    else if (button == self.trackObjectButton) {
        [self trackObject:!self.enableTrackObject];
    }
    else if (button == self.cardPhotoButton) {
        [[MessageCenter sharedInstance] sendMessageTakePhoto];
    }
    else if (button == self.cardVideoButton) {
        [[MessageCenter sharedInstance] sendMessageRecordVideo:RECORD_VIDEO_TOGGLE];
    }
}

#pragma mark - RudderView Delegate

/**
 *  主控制器
 *
 *  @param rudderView 控制器实例
 *  @param point      偏移量
 */
- (void)rudderView:(RudderView *)rudderView basePointMovedTo:(CGPoint)point
{
//    NSLog(@"Base Point: (%f, %f)", point.x, point.y);
    
    CGFloat x = point.x; 
    CGFloat y = point.y;
    
    NSInteger intX = (x + 1.0f) * 0.5f * 0x100;
    NSInteger intY = (y + 1.0f) * 0.5f * 0x100;
    
    if (intX < 0) intX = 0;
    if (intX > 0xFF) intX = 0xFF;
    if (intY < 0) intY = 0;
    if (intY > 0xFF) intY = 0xFF;
    
    if (rudderView == _powerRudder) {
        controlByteTHR = intY;
        controlByteRUDD = intX;
        // 油门控制时，紧急停止置0
        emergencyDownMode = NO;
        [_oneKeyStopButton setImage:oneKeyStopDisabledImage forState:UIControlStateNormal];
    }
    else if (rudderView == _rangerRudder) {
        // 如果360度翻转开关打开
        if (rollMode) {
            // 如果还没有触发360度翻转
            if (!triggeredRoll) {
                if (intY > 0xC0) {
                    triggeredRoll = YES;
                    controlByteELE = 0xFF;
                    controlByteAIL = 0x80;  // 需要平衡位置？
                } else if (intY < 0x40) {
                    triggeredRoll = YES;
                    controlByteELE = 0x00;
                    controlByteAIL = 0x80;  // 需要平衡位置？
                } else {
                    controlByteELE = intY;
                }
                
                if (!triggeredRoll) {
                    if (intX > 0xC0) {
                        triggeredRoll = YES;
                        controlByteAIL = 0xFF;
                        controlByteELE = 0x80;  // 需要平衡位置？
                    } else if (intX < 0x40) {
                        triggeredRoll = YES;
                        controlByteAIL = 0x00;
                        controlByteELE = 0x80;  // 需要平衡位置？
                    } else {
                        controlByteAIL = intX;
                    }
                }
                
                // 设置300ms定时器
                if (triggeredRoll) {
                    [NSTimer scheduledTimerWithTimeInterval:0.3     // 翻滚模式持续300ms
                                                     target:self
                                                   selector:@selector(clearFlipStatus:)
                                                   userInfo:nil
                                                    repeats:NO];
                }
            }
        }
        // 如果360度翻转开关关闭
        else {
            controlByteELE = intY;
            controlByteAIL = intX;
        }
    }
    
//    NSLog(@"Control: (%.2X, %.2X, %.2X, %.2X)", controlByteAIL, controlByteELE, controlByteTHR, controlByteRUDD);
}

/**
 *  微调控制器
 *
 *  @param rudderView 控制器实例
 *  @param point      偏移量
 */
- (void)rudderView:(RudderView *)rudderView trimPointMovedTo:(CGPoint)point
{
//    NSLog(@"Trim Point: (%f, %f)", point.x, point.y);
    CGFloat x = point.x;
    CGFloat y = point.y;
    
//    NSInteger intX = (x + 1.0f) * 0.5f * 0x100;
//    NSInteger intY = (y + 1.0f) * 0.5f * 0x100;
//    
//    if (intX < 0) intX = 0;
//    if (intX > 0xFF) intX = 0xFF;
//    if (intY < 0) intY = 0;
//    if (intY > 0xFF) intY = 0xFF;
    
    NSInteger intX = round(x * RudderView.hScaleNum);
    NSInteger intY = round(y * RudderView.vScaleNum);
    
    if (rudderView == _powerRudder) {
        trimByteRUDD = intX;
    }
    else if (rudderView == _rangerRudder) {
        trimByteAIL = intX;
        trimByteELE = intY;
    }
}

#pragma makr - TrackView Delegate

- (void)trackViewBeginOutput:(TrackView *)trackView
{
    NSLog(@"trackViewBeginOutput");
    
    controlByteELE = 0x80;
    controlByteAIL = 0x80;
}

- (void)trackView:(TrackView *)trackView outputPoint:(CGPoint)point
{
//    NSLog(@">>> track point: ux = %f, uy = %f", point.x, point.y);
    
    CGFloat x = point.x;
    CGFloat y = point.y;
    
    NSInteger intX = (x + 1.0f) * 0.5f * 0x100;
    NSInteger intY = (y + 1.0f) * 0.5f * 0x100;
    
    if (intX < 0) intX = 0;
    if (intX > 0xFF) intX = 0xFF;
    if (intY < 0) intY = 0;
    if (intY > 0xFF) intY = 0xFF;
    
    // 飞控
    controlByteELE = intY;
    controlByteAIL = intX;
    
//    NSLog(@">>> control point: x = %.2X, y = %.2X", controlByteAIL, controlByteELE);
}

- (void)trackViewFinishOutput:(TrackView *)trackView
{
    NSLog(@"trackViewFinishOutput");
    
    controlByteELE = 0x80;
    controlByteAIL = 0x80;
}

#pragma mark - Voice recognizer delegate


- (void)voiceRecognizerDidStartListening
{
    voiceMode = YES;
    self.voiceButton.enabled = YES;
    
    // if control stopped
    if (!_showControlInterface) {
        [self toggleVoiceMode:NO];
    } else {
        self.voiceGuideLabel.hidden = NO;
    }
}

- (void)voiceRecognizerDidSuspendRecognition
{
    voiceMode = NO;
    self.voiceGuideLabel.hidden = YES;
    self.voiceButton.enabled = YES;
}

- (void)voiceRecognizerDidReceiveCommand:(VoiceRecognizerCommand)command text:(NSString *)text
{
    NSLog(@"Voice command: %ld, text: %@", (long)command, text);
    
    self.voiceGuideLabel.text = text;
    [self.voiceGuideLabel sizeToFit];
    self.voiceGuideLabel.center = self.view.center;
    
    BOOL needReset = NO;
    
    switch (command) {
        case VoiceRecognizerCommandForward:
            if (voiceControlTimer == nil) {
                [_rangerRudder moveStickTo:CGPointMake(0, 1.0)];
                needReset = YES;
            }
            break;
            
        case VoiceRecognizerCommandBackward:
            if (voiceControlTimer == nil) {
                [_rangerRudder moveStickTo:CGPointMake(0, -1.0)];
                needReset = YES;
            }
            break;
            
        case VoiceRecognizerCommandLeft:
            if (voiceControlTimer == nil) {
                [_rangerRudder moveStickTo:CGPointMake(-1.0, 0)];
                needReset = YES;
            }
            break;
            
        case VoiceRecognizerCommandRight:
            if (voiceControlTimer == nil) {
                [_rangerRudder moveStickTo:CGPointMake(1.0, 0)];
                needReset = YES;
            }
            break;
            
        case VoiceRecognizerCommandTakeoff:
            flyupMode = YES;
            if (flyupTimer == nil) {
                flyupTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                              target:self
                                                            selector:@selector(clearFlyupMode)
                                                            userInfo:nil
                                                             repeats:NO];
            }
            break;
            
        case VoiceRecognizerCommandLanding:
            flydownMode = YES;
            if (flydownTimer == nil) {
                flydownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                target:self
                                                              selector:@selector(clearFlydownMode)
                                                              userInfo:nil
                                                               repeats:NO];
            }
            break;
            
            
        default:
            break;
    }
    
    if (needReset) {
        if (voiceControlTimer == nil) {
            voiceControlTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                                 target:self
                                                               selector:@selector(clearVoiceMode)
                                                               userInfo:nil
                                                                repeats:NO];
        }
    }
}

- (void)voiceRecognizerErrorOccurred
{
    NSLog(@"voiceRecognizerErrorOccurred");
}


#pragma mark - Vehicle Control

- (void)clearFlipStatus:(NSTimer *)timer
{
    triggeredRoll = NO;
    rollMode = NO;
    [self.rollButton setImage:rollDisabledImage forState:UIControlStateNormal];
    
    controlByteELE = 0x80;
    controlByteAIL = 0x80;
    
    [timer invalidate];
    timer = nil;
}

// 命令长度
#define COMMAND_LENGTH  11

/**
 *  发送控制命令
 */
- (void)sendFlyControlCommand
{
    Byte controlBytes[COMMAND_LENGTH];
    
    Byte controlByteAIL_l = controlByteAIL;     // 副翼
    Byte controlByteELE_l = controlByteELE;     // 升降舵
    Byte controlByteTHR_l = controlByteTHR;     // 油门
    Byte controlByteRUDD_l = controlByteRUDD;   // 方向舵
    Byte trimByteAIL_l = trimByteAIL;
    Byte trimByteELE_l = trimByteELE;
    Byte trimByteRUDD_l = trimByteRUDD;
    
    if (!triggeredRoll) {
        // 速度限制（30%、60%、100%）
        // 按线性限定
        // AIL
        if (controlByteAIL_l < 0x80) {
            Byte deltaAIL = 0x80 - controlByteAIL_l;
            deltaAIL *= speedValuef;
            controlByteAIL_l = 0x80 - deltaAIL;
        } else if (controlByteAIL_l > 0x80) {
            Byte deltaAIL = controlByteAIL_l - 0x80;
            deltaAIL *= speedValuef;
            controlByteAIL_l = 0x80 + deltaAIL;
        }
        // ELE
        if (controlByteELE_l < 0x80) {
            Byte deltaELE = 0x80 - controlByteELE_l;
            deltaELE *= speedValuef;
            controlByteELE_l = 0x80 - deltaELE;
        } else if (controlByteELE_l > 0x80) {
            Byte deltaELE = controlByteELE_l - 0x80;
            deltaELE *= speedValuef;
            controlByteELE_l = 0x80 + deltaELE;
        }
    }
    // 科瑞通有客户在30%不能360°翻转，加这个
    else {
        if (controlByteAIL_l < 0x80) {
            controlByteAIL_l = 0;
        } else if (controlByteAIL_l > 0x80) {
            controlByteAIL_l = 0xFF;
        }
        // ELE
        if (controlByteELE_l < 0x80) {
            controlByteELE_l = 0;
        } else if (controlByteELE_l > 0x80) {
            controlByteELE_l = 0xFF;
        }
    }
    
    // 如果是限高模式，则油门值始终为0x80
//    if (self.limitedHigh) controlByteTHR_l = 0x80;  // 客户要求限高还是可以调油门，松手后回中点，所以注释掉
    // 方向键移动超过一半，则ROTATE清零
//    if (controlByteRUDD_l < 0x40 || controlByteRUDD_l > 0xC0) {
//        rotateMode = NO;
//        [self.rotateButton setImage:rotateDisableImage forState:UIControlStateNormal];
//    }
    
    // 定高
    Byte bitAltitudeHold = self.limitedHigh ? 1 : 0;
    
    // 一键起飞
    Byte bitFlyup = flyupMode ? 1 : 0;
    // 一键下降
    Byte bitFlydown = flydownMode ? 1 : 0;
    // 一键返回
    Byte bitReturnMode = returnMode ? 1 : 0;
    // 一键Rotate
    Byte bitRotate = rotateMode ? 1 : 0;
    // 一键固定方向Rotate
    Byte bitFixedDirectionRotate = fixedDirectionRotateMode ? 1 : 0;
    // 无头模式
    Byte bitHeadless = headlessMode ? 1 : 0;
    // 一键Roll
//    Byte bitRoll = rollMode ? 1 : 0;
    Byte bitRoll = triggeredRoll ? 1 : 0;
    // 紧急降落
    Byte bitEmergencyDown = emergencyDownMode ? 1 : 0;
    
    // 校正陀螺仪
    Byte bitGyroCalibrate = gyroCalibrateMode ? 1 : 0;
    
    // 灯光控制
    Byte bitLightOn = lightOn ? 1 : 0;
    
//    controlBytes[0] = 0x66;
//    controlBytes[1] = controlByteAIL_l;
//    controlBytes[2] = controlByteELE_l;
//    controlBytes[3] = controlByteTHR_l;
//    controlBytes[4] = controlByteRUDD_l;
//    controlBytes[5] = bitAltitudeHold       // bit0 = Altitude Hold
//                    | (speedValue << 1);    // bit1-7 = Limited Speed (0-100)
//    controlBytes[6] = controlBytes[1]
//                    ^ controlBytes[2]
//                    ^ controlBytes[3]
//                    ^ controlBytes[4]
//                    ^ controlBytes[5];
//    controlBytes[7] = 0x99;
//    controlBytes[8] = trimByteELE_l;
//    controlBytes[9] = trimByteAIL_l;
//    controlBytes[10] = trimByteRUDD_l;
//    controlBytes[11] = bitFlyup                         // bit0 = Flyup
//                    | (bitFlydown << 1)                 // bit1 = Flydown
//                    | (bitReturnMode << 2)              // bit2 = Return Mode
//                    | (bitFixedDirectionRotate << 3)    // bit3 = Fixed Direction Rotate Mode
//                    | (bitHeadless << 4)                // bit4 = Headless Mode
//                    | (bitRotate << 5)                  // bit5 = Rotate Mode
//                    | (bitEmergencyDown << 6)           // bit6 = Emergency Down Mode
//                    | (bitGyroCalibrate << 7)           // bit7 = Gyro Calibrate Mode
//    ;
//    controlBytes[12] = bitRoll                          // bit0 = Roll Mode
//                    | (bitLightOn << 1);                // bit1 = Light Control
    
    controlBytes[0] = 0x66;
    controlBytes[1] = controlByteAIL_l;
    controlBytes[2] = controlByteELE_l;
    controlBytes[3] = controlByteTHR_l;
    controlBytes[4] = controlByteRUDD_l;
    controlBytes[5] = trimByteAIL_l;
    controlBytes[6] = trimByteELE_l;
    controlBytes[7] = trimByteRUDD_l;
    controlBytes[8] = bitFlyup                          // bit0 = Flyup
                    | (bitFlydown << 1)                 // bit1 = Flydown
//                    | (bitReturnMode << 2)              // bit2 = Return Mode
                    | (bitEmergencyDown << 2)           // bit2 = emergency stop
                    | (bitRoll << 3)                  // bit3 = Roll Mode
                    | (bitHeadless << 4)                // bit4 = Headless Mode
                    | (bitRotate << 5)                    // bit5 = Rotate Mode
                    | (bitLightOn << 6)                 // bit6 = Light Control
                    | (bitGyroCalibrate << 7)           // bit7 = Gyro Calibrate Mode
    ;
    controlBytes[9] = controlBytes[1]
                    ^ controlBytes[2]
                    ^ controlBytes[3]
                    ^ controlBytes[4]
                    ^ controlBytes[5]
                    ^ controlBytes[6]
                    ^ controlBytes[7]
                    ^ controlBytes[8];
    controlBytes[10] = 0x99;
    
//    NSData *controlCommandData = [NSData dataWithBytes:controlBytes length:COMMAND_LENGTH];
//
////    NSLog(@"Send Control Command: %@", controlCommandData);
////    for (int i = 0; i < COMMAND_LENGTH; i++) {
////        printf("0x%.2X ", controlBytes[i]);
////    }
////    printf("\n");
//
//    [self.player sendRtcpRrData:controlCommandData];
    
    Byte bytes[COMMAND_LENGTH + 1];
    bytes[0] = 3; // 3 = fly control
    memcpy(&bytes[1], controlBytes, COMMAND_LENGTH);
    NSData *flyData = [NSData dataWithBytes:bytes length:COMMAND_LENGTH + 1];
    [self debugSend:flyData];
}

#pragma mark FreeSpaceMonitorDelegate

- (void)freeSpaceThresholdExceeded:(FreeSpaceMonitor *)monitor
{
    NSLog(@"ControlPanelViewController: freeSpaceThresholdExceeded");
    
    [self.player stopRecordVideo];
}

#pragma mark - Device Function

// Device Function
- (void)checkDeviceFunction
{
    BOOL isSupportCardPhoto = [[MessageCenter sharedInstance] isDeviceSupportFunction:DEVICE_FUNCTION_CARD_PHOTO];
    [self.cardPhotoButton setHidden:!isSupportCardPhoto];
    
    BOOL isSupportCardVideo = [[MessageCenter sharedInstance] isDeviceSupportFunction:DEVICE_FUNCTION_CARD_VIDEO];
    [self.cardVideoButton setHidden:!isSupportCardVideo];
}

#pragma mark - Message Center Notification

- (void)didReceiveMessageCenterNotification:(NSNotification *)notification
{
    TCPMessage *message = [notification object];
    uint8_t messageId = message.messageId;
    NSData *contentData = message.content;
    
    if (messageId == MSG_ID_REPORT) {
        [self processReport:contentData];
    } else {
        [self processMessage:messageId content:contentData];
    }
}

/**
 * 处理设备报告
 * @param content 报告内容
 */
- (void)processReport:(NSData *)content
{
    // 目前一个ID对应的设置值均为1Byte，所以这里固定按照两个字节分离
    if ([content length] > 1) {
        uint8_t *contentBytes = (uint8_t *)[content bytes];
        uint8_t messageId = contentBytes[0];
        NSData *contentData = [content subdataWithRange:NSMakeRange(1, 1)];
        [self processMessage:messageId content:contentData];
        
        // 递归调用
        NSData *subData = [content subdataWithRange:NSMakeRange(2, [content length] - 2)];
        [self processReport:subData];
    }
    // 检查设备功能
    [self checkDeviceFunction];
}

/**
 * 处理除设备报告之外的消息
 * @param messageId     消息ID
 * @param contentData   消息内容
 */
- (void)processMessage:(uint8_t)messageId content:(NSData *)contentData
{
    uint8_t *contentBytes = (uint8_t *)[contentData bytes];
    
    switch (messageId) {
        case MSG_ID_DEVICE_STATUS:
            if (contentData.length > 0) [self checkDeviceStatus:contentBytes[0]];
            break;
            
        case MSG_ID_RECORD_VIDEO:
            if (contentData.length > 0) [self updateRecordVideo:contentBytes[0]];
            break;
        case MSG_ID_TAKE_PHOTO:
            if (contentData.length > 0) [self updateTakePhoto:contentBytes[0]];
            break;
            
        case MSG_ID_RECORD_VIDEO_ON_PHONE:
            [self recordVideo];
            break;
        case MSG_ID_TAKE_PHOTO_ON_PHONE:
            [self takeScreenshot:1];
            break;
            
        // 修改拍照和录像分辨率，科锐通客户
        case 0x80:
            if (contentData.length == 8) [self processResolution:contentData];
            break;
            
        default:
//            NSLog(@"PreviewerViewController: Unhandled message %d from MessageCenter", messageId);
            break;
    }
}

// 修改拍照和录像分辨率，科锐通客户
- (void)processResolution:(NSData *)contentData
{
    uint8_t *d = (uint8_t *)[contentData bytes];
    
    fakePhotoWidth = (d[0] << 8) | d[1];
    fakePhotoHeight = (d[2] << 8) | d[3];
    fakeVideoWidth = (d[4] << 8) | d[5];
    fakeVideoHeight = (d[6] << 8) | d[7];
    isBothFakeResolution = YES;
}

// Device Status
- (void)checkDeviceStatus:(uint8_t)value
{
    switch (value) {
        case DEVICE_STATUS_BUSY:
            [self.view makeToast:NSLocalizedString(@"DEVICE_IS_BUSY", nil) duration:1.0 position:CSToastPositionBottom];
            break;
        case DEVICE_STATUS_NO_CARD:
            [self.view makeToast:NSLocalizedString(@"NO_CARD_INSERTED", nil) duration:1.0 position:CSToastPositionBottom];
            break;
        case DEVICE_STATUS_INSUFFICIENT_STORAGE:
            [self.view makeToast:NSLocalizedString(@"DEVICE_INSUFFICIENT_STORAGE", nil) duration:1.0 position:CSToastPositionBottom];
            break;
            
        default:
            break;
    }
}

// Record Video
- (void)updateRecordVideo:(uint8_t)value
{
    switch (value) {
            case RECORD_VIDEO_START: {
                if (_recordingTimer) {
                    [_recordingTimer invalidate];
                }
                // 先让REC显示出来
                _recordingImageView.hidden = NO;
                // 设置闪烁定时器
                _recordingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                   target:self
                                                                 selector:@selector(flashingRecordingVideo)
                                                                 userInfo:nil
                                                                  repeats:YES];
                break;
            }
            case RECORD_VIDEO_STOP:
            [self stopFlashingRecordingVideo];
            break;
    }
}

// Take Photo
- (void)updateTakePhoto:(uint8_t)value
{
    if (value == 0) {
        // Play default camera shutter sound
        AudioServicesPlaySystemSound(1108);
//        // 隐藏倒计时
//        [_countdownLabel setText:@""];
//        [_countdownLabel setHidden:YES];
        // 拍照画面闪一下
        [_flashView setAlpha:0.5];
        [UIView animateWithDuration:0.5 animations:^{
            [self.flashView setAlpha:0];
        }];
    } else {
//        // 显示倒计时
//        NSString *countdownText = [NSString stringWithFormat:@"%d", value];
//        [_countdownLabel setText:countdownText];
//        [_countdownLabel setHidden:NO];
    }
}

- (void)addFlashView
{
    UIView *flashView = [[UIView alloc] init];
    _flashView = flashView;
//    [self.view insertSubview:flashView atIndex:0];
    [self.view insertSubview:flashView aboveSubview:_backgroundImageView];
    
    [flashView setBackgroundColor:[UIColor whiteColor]];
    [flashView setAlpha:0];
    
    [flashView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)addRecordingImageView
{
    UIImageView *recordingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"previewer_video_recording"]];
    _recordingImageView = recordingImageView;
    [self.view addSubview:recordingImageView];
    
    // 默认隐藏
    [recordingImageView setHidden:YES];
    
    [recordingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(8);
        make.top.equalTo(self.view).with.offset(48);
    }];
}

- (void)flashingRecordingVideo
{
    _recordingImageView.hidden = !_recordingImageView.hidden;
}

- (void)stopFlashingRecordingVideo
{
    // 停掉定时器
    [_recordingTimer invalidate];
    _recordingTimer = nil;
    // 隐藏REC
    _recordingImageView.hidden = YES;
}

#pragma mark - Hardware Action & Settings

#define HW_ACTION_SIGNATURE_BYTE_1  0x0f
#define HW_ACTION_SIGNATURE_BYTE_2  0x5a
#define HW_ACTION_SIGNATURE_BYTE_3  0x1e
#define HW_ACTION_SIGNATURE_BYTE_4  0x69

#define HW_ACTION_CLASS_TAKE_PHOTO      0x00
#define HW_ACTION_COMMAND_TAKE_PHOTO    0x01

#define HW_ACTION_CLASS_RECORD_VIDEO    0x01
#define HW_ACTION_COMMAND_RECORD_VIDEO  0x01

#define SETTING_CLASS_SET_FAKE_720P     0x02
#define SETTING_COMMAND_SET_FAKE_720P   0x01

- (void)doHwAction:(uint8_t)cls command:(uint8_t)command
{
    switch (cls) {
        case HW_ACTION_CLASS_TAKE_PHOTO:
            if (command == HW_ACTION_COMMAND_TAKE_PHOTO) {
                [self takeScreenshot:1];
            }
            break;
        case HW_ACTION_CLASS_RECORD_VIDEO:
            if (command == HW_ACTION_COMMAND_RECORD_VIDEO) {
                [self recordVideo];
            }
            break;
        case SETTING_CLASS_SET_FAKE_720P:
            if (command == SETTING_COMMAND_SET_FAKE_720P) {
                fakeWidth = 1280;
                fakeHeight = 720;
                isFakeResolution = YES;
            }
            break;
            
        default:
            break;
    }
}

- (BOOL)checkIfIsValidHwActionCommand:(NSData *)data
{
    if (data.length >= 7) {
        const uint8_t *d = (const uint8_t *)[data bytes];
        if (d[0] == HW_ACTION_SIGNATURE_BYTE_1 &&
            d[1] == HW_ACTION_SIGNATURE_BYTE_2 &&
            d[2] == HW_ACTION_SIGNATURE_BYTE_3 &&
            d[3] == HW_ACTION_SIGNATURE_BYTE_4) { // sign
            //            uint8_t commandClass = d[4];    // index
            uint8_t commandLength = d[5];   // len
            //            uint8_t command = d[6];         // data
            
            if (data.length == commandLength) {
                return YES;
            }
        }
    }
    return NO;
}

#pragma makr IJKFFMoviePlayerDelegate

-(void)player:(IJKFFMoviePlayerController *)player didReceiveRtcpSrData:(NSData *)data
{
//    NSLog(@"IJKFFMoviePlayerDelegate: didReceiveRtcpSrData");
//    NSLog(@">>>>>>: %@", data);
    
    if ([self checkIfIsValidHwActionCommand:data]) {
        const uint8_t *d = (const uint8_t *)[data bytes];
        uint8_t commandClass = d[4];    // index
        uint8_t command = d[6];         // data
        
        [self doHwAction:commandClass command:command];
    }
}

-(void)player:(IJKFFMoviePlayerController *)player didReceiveData:(NSData *)data
{
    // work with firmware api -> wifi_data_send
    
    const uint8_t *d = (const uint8_t *)[data bytes];
    switch (d[0]) {
        case 0x01:
            fakeWidth = (d[1] << 8) | d[2];
            fakeHeight = (d[3] << 8) | d[4];
            isFakeResolution = YES;
            break;
        case 0x02:
            fakePhotoWidth = (d[1] << 8) | d[2];
            fakePhotoHeight = (d[3] << 8) | d[4];
            fakeVideoWidth = (d[5] << 8) | d[6];
            fakeVideoHeight = (d[7] << 8) | d[8];
            isBothFakeResolution = YES;
            break;
            
        default:
            break;
    }
}

-(void)playerDidTakePicture:(IJKFFMoviePlayerController *)player resultCode:(int)resultCode fileName:(NSString *)fileName
{
    NSLog(@"IJKFFMoviePlayerDelegate: playerDidTakePicture");
    if (resultCode == 1) {
        // Play default camera shutter sound
        AudioServicesPlaySystemSound(SOUND_ID_SHUTTER);
        // 拍照成功提示
        NSString *infoString = NSLocalizedString(@"TAKE_PICTURE_SUCCESS", @"");
        [self.player.view makeToast:infoString duration:2.0 position:CSToastPositionBottom];
    }
    else if (resultCode == 0 && fileName != nil) {
        NSLog(@"Picture is saved to %@", fileName);
    }
    else if (resultCode < 0) {
        // 拍照失败提示
        NSString *infoString = NSLocalizedString(@"TAKE_PICTURE_FAIL", @"");
        [self.player.view makeToast:infoString duration:2.0 position:CSToastPositionBottom];
    }
}

-(void)playerDidRecordVideo:(IJKFFMoviePlayerController *)player resultCode:(int)resultCode fileName:(NSString *)fileName
{
    NSLog(@"IJKFFMoviePlayerDelegate: playerDidRecordVideo");
    if (resultCode < 0) {
        // 停止监控剩余空间
        _freeSpaceMonitor.delegate = nil;
        [_freeSpaceMonitor stop];
        _freeSpaceMonitor = nil;
        
        // 播放录像失败声音
        AudioServicesPlaySystemSound(SOUND_ID_RECORD_FAIL);

        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateCaptureVideoButtonImage:NO];
            
            [videoRecordTimeLabel setHidden:YES];
            [videoRecordTimer invalidate];
            videoRecordTimer = nil;
        });

        // 录像失败提示
        NSString *infoString = NSLocalizedString(@"RECORD_VIDEO_FAIL", @"");
        [self.player.view makeToast:infoString duration:2.0 position:CSToastPositionBottom];
    }
    else if (resultCode == 0) {
        [self updateCaptureVideoButtonImage:YES];
        
        // 播放录像开始声音
        AudioServicesPlaySystemSound(SOUND_ID_RECORD_START);

        // 录像开始提示
        NSString *infoString = NSLocalizedString(@"RECORD_VIDEO_BEGIN", @"");
        [self.player.view makeToast:infoString duration:2.0 position:CSToastPositionBottom];

        dispatch_async(dispatch_get_main_queue(), ^{
            // TimedText
            if (videoRecordTimer) {
                [videoRecordTimer invalidate];
                videoRecordTimer = nil;
            }
            videoRecordTime = 0;
            videoRecordTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                target:self
                                                              selector:@selector(updateVideoRecordTime:)
                                                              userInfo:nil
                                                               repeats:YES];
            NSString *videoRecordTimeString = [NSString stringWithFormat:@"%.2d:%.2d", videoRecordTime/60, videoRecordTime % 60];
            [videoRecordTimeLabel setText:videoRecordTimeString];
            [videoRecordTimeLabel sizeToFit];
            [videoRecordTimeLabel setHidden:NO];
        });

        // 开始监控剩余空间
        [_freeSpaceMonitor start];
    }
    else {
        // 停止监控剩余空间
        _freeSpaceMonitor.delegate = nil;
        [_freeSpaceMonitor stop];
        _freeSpaceMonitor = nil;

        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateCaptureVideoButtonImage:NO];
            
            [videoRecordTimeLabel setHidden:YES];
            [videoRecordTimer invalidate];
            videoRecordTimer = nil;
        });
        
        // 播放录像停止声音
        AudioServicesPlaySystemSound(SOUND_ID_RECORD_STOP);

        // 录像成功提示
        NSString *infoString = NSLocalizedString(@"RECORD_VIDEO_SUCCESS", @"");
        [self.player.view makeToast:infoString duration:2.0 position:CSToastPositionBottom];
    }
}

- (void)playerOnNotifyDeviceConnected:(IJKFFMoviePlayerController *)player
{
    if (!([self isBeingDismissed] || [self isMovingFromParentViewController])) {
        __weak UIViewController *weakSelf = self;
        NSString *message = NSLocalizedString(@"DEVICE_IN_USE", @"");
        [weakSelf.view makeToast:message duration:0.5 position:CSToastPositionBottom];
    }
}

- (void)playerDidReceivedFrameData:(NSData *)frameData width:(int)width height:(int)height pixelFormat:(int)pixelFormat
{
    // 识别手势
    if (self.enableDetectObject) {
        // 如果识别空闲，且没在倒计时
        if (!self.detector.isBusy && (!self.takePhotoCDLabel.isCountingDown || self.videoPostureCountDown == 0)) {
            dispatch_async(self.vision_serial_queue, ^{
                // 如果没在倒计时
                if (!self.takePhotoCDLabel.isCountingDown || self.videoPostureCountDown == 0) {
                    // 送入图像数据进行识别
                    NSArray<DetectedObject *> *objs = [self.detector detectObjectWithYUV420p:(void *)[frameData bytes] width:width height:height];
#if 0
                    static char *objString[] = {"Background", "Face", "OK", "Yes", "Palm"};
                    NSLog(@">>>>>>>>>>>>>>>>");
                    for (DetectedObject *obj in objs) {
                        NSLog(@"label: %s, prob: %.3f", objString[obj.label], obj.prob);
                    }
                    NSLog(@"<<<<<<<<<<<<<<<<");
#endif
                    // 拍照没在倒计时
                    if (!self.takePhotoCDLabel.isCountingDown) {
                        // 查找拍照手势
                        if ([self.photoPostureHelper findObjectWithFace:OBJECT_LABEL_OK inObjects:objs]) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                AudioServicesPlaySystemSound(SOUND_ID_PICTURE_TIME);
                                [self.takePhotoCDLabel startCount];
                            });
                        }
                    }
                    
                    // 视频没在倒计时
                    if (self.videoPostureCountDown == 0) {
                        // 查找录像手势
                        if ([self.videoPostureHelper findObjectWithFace:OBJECT_LABEL_YES inObjects:objs]) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self initVideoPostureCountDown];
                                [self recordVideo];
                            });
                        }
                    }
                }
            });
        }
    }
    // 物体跟踪，测试代码
    else if (self.enableTrackObject) {
        // todo: track object
        
        float speedFactor = 1.5;
        
        dispatch_async(self.vision_serial_queue, ^{
            NSValue *vectorValue = [self.tracker trackObjectWithYUV420p:(void *)[frameData bytes] width:width height:height];
            if (vectorValue) {
                CGVector vector = [vectorValue CGVectorValue];
                float x = vector.dx;
                float y = vector.dy;
                
                if (fabsf(x) < 0.05) x = 0;
                if (fabsf(y) < 0.05) y = 0;
                
                NSInteger intX = (x + 1.0f) * 0.5f * 0x100;
                NSInteger intY = (y + 1.0f) * 0.5f * 0x100;
                
                if (intX < 0) intX = 0;
                if (intX > 0xFF) intX = 0xFF;
                if (intY < 0) intY = 0;
                if (intY > 0xFF) intY = 0xFF;
                
                controlByteELE = 0x80;
//                controlByteAIL = intX * speedFactor;
            } else {
                // 如果返回nil，则物体追踪失败
                // 此时关闭物体追踪，需要手动打开
                dispatch_async(dispatch_queue_create("disable_track_object", 0), ^{
                    [self trackObject:NO];
                });
            }
        });
    }
}

#pragma mark Handle Notification

- (void)loadStateDidChange:(NSNotification*)notification
{
    //    MPMovieLoadStateUnknown        = 0,
    //    MPMovieLoadStatePlayable       = 1 << 0,
    //    MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
    //    MPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started
    
    IJKMPMovieLoadState loadState = _player.loadState;
    
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: %d\n", (int)loadState);
    } else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
    } else {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    //    MPMovieFinishReasonPlaybackEnded,
    //    MPMovieFinishReasonPlaybackError,
    //    MPMovieFinishReasonUserExited
    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    
    switch (reason)
    {
        case IJKMPMovieFinishReasonPlaybackEnded:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonUserExited:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonPlaybackError:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
            // Player stopped but have not release resources
            // So, we must shut it down manually
            // And wait for delegate method
            [self.player shutdown]; 
            [self.player.view removeFromSuperview];
            [self.spinner startAnimating];
            
            // DEBUG
            [self exitDebugMode];
            break;
            
        default:
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
    NSLog(@"ControlPanelViewController: mediaIsPreparedToPlayDidChange\n");
    [self.spinner stopAnimating];
    // 卡存储按键
    [self checkDeviceFunction];
    // 显示手势识别和物体追踪按键
    [self.detectObjectButton setHidden:NO];
//    [self.trackObjectButton setHidden:NO];
    
    // DEBUG INFO
    IJKFFMoviePlayerController *player = self.player;
    player.shouldShowHudView = shouldShowHudView;
    
    // Connection
    BOOL useTcp = [Settings isDebugOverTCP];
    NSInteger port = [Settings getDebugPort];
    NSInteger timeout = [Settings getDebugTcpTimeout];
    
    commClient = [[CommClient alloc] init];
    commClient.delegate = self;
    [commClient connectToHost:REMOTE_HOST onPort:(uint16_t)port withTimeout:timeout useTcp:useTcp];
    
    // 开启各种任务
    [self startHeartbeat];
    
    if ([Settings getDebugSendTimeSwitch]) {
        NSInteger time = [Settings getDebugSendTime];
        [self countdownSend:(NSTimeInterval) time / 1000]; // ms -> s
    }
    if ([Settings getDebugSendPeriodSwitch]) {
        NSInteger period = [Settings getDebugSendPeriod];
        [self repeatSend: (NSTimeInterval) period / 1000]; // ms -> s
    }
}

- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
    //    MPMoviePlaybackStateStopped,
    //    MPMoviePlaybackStatePlaying,
    //    MPMoviePlaybackStatePaused,
    //    MPMoviePlaybackStateInterrupted,
    //    MPMoviePlaybackStateSeekingForward,
    //    MPMoviePlaybackStateSeekingBackward
    
    switch (_player.playbackState)
    {
        case IJKMPMoviePlaybackStateStopped: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePlaying: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePaused: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateInterrupted: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
            break;
        }
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
            break;
        }
    }
}

- (void)moviePlayerDidShutdown:(NSNotification*)notification
{
    NSLog(@"IJKFFMoviePlayerDelegate: playerDidShutdown");
    IJKFFMoviePlayerController *mpc = self.player;
    [mpc setDelegate:nil];
    
    // DEBUG
    [self exitDebugMode];

    // 隐藏卡存储按键
    [self.cardPhotoButton setHidden:YES];
    [self.cardVideoButton setHidden:YES];
    
    // 隐藏手势识别和物体追踪按键
    [self.detectObjectButton setHidden:YES];
    [self.trackObjectButton setHidden:YES];
    
    [self.player.view removeFromSuperview];
    [self removeMovieNotificationObservers];
    [self performSelector:@selector(doReconnect) withObject:self afterDelay:RECONNECTION_INTERVAL];
    
    // 为使用初始值
    [_powerRudder reset];
    [_rangerRudder reset];

    // reset
    isFakeResolution = NO;
    fakeWidth = -1;
    fakeHeight = -1;
    isBothFakeResolution = NO;
    fakePhotoWidth = -1;
    fakePhotoHeight = -1;
    fakeVideoWidth = -1;
    fakeVideoHeight = -1;
}

- (void)moviePlayerFirstVideoFrameDidRender:(NSNotification*)notification
{
    // Restore VR mode setting
    IJKFFMoviePlayerController *ffplayer = ffplayerInstance(self.player);
    [ffplayer setVrMode:_vrMode withStretch:NO];
    self.player.view.userInteractionEnabled = ffplayer.isVrMode;
}

- (void)doReconnect
{
    if ([self isVisible]) {
        NSLog(@"doReconnect");
        [self openVideo];
        [self installMovieNotificationObservers];
        [self.player prepareToPlay];
    }
}

- (void)willResignActive:(NSNotification *)notification
{
    NSLog(@"ControlPanelViewController:willResignActive");
    
    // 关闭手势识别和物体追踪
    if (self.enableDetectObject)
        [self detectObject:NO];
    if (self.enableTrackObject)
        [self trackObject:NO];

    [self.player stopRecordVideo];
}

#pragma mark Install Movie Notifications

/* Register observers for the various movie object notifications. */
-(void)installMovieNotificationObservers
{
    NSLog(@"installMovieNotificationObservers");

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerDidShutdown:)
                                                 name:IJKMPMoviePlayerDidShutdownNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerFirstVideoFrameDidRender:)
                                                 name:IJKMPMoviePlayerFirstVideoFrameRenderedNotification
                                               object:_player];
}

#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationObservers
{
    NSLog(@"removeMovieNotificationObservers");
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackDidFinishNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerDidShutdownNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerFirstVideoFrameRenderedNotification object:_player];
}

-(void)removePlayerNotificationObservers
{
    NSLog(@"removePlayerNotificationObservers");
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillResignActiveNotification object:_player];
}

#pragma mark Network DEBUG

- (void)prepareDebugIfNecessary
{
    if ([Settings getDebugOn]) {
        shouldShowHudView = [Settings isHudOn];
        debugString = [Settings getDebugString];
        
        [self setupDebugView];
    }
}

- (void)clickDebugEnterButton
{
    debugString = debugDataLabel.text;
    [Settings setDebugString:debugString];
    // Send
    [self sendDebugString];
}

- (void)clickDebugData
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:@"输入需要发送的字符串"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        debugDataLabel.text = alert.textFields.firstObject.text;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = debugDataLabel.text;
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)setupDebugView
{
    UIView *containerView = _interactiveView;
    
    debugView = [[UIView alloc] init];
    [containerView addSubview:debugView];
    [containerView sendSubviewToBack:debugView];
    // 布局，占左下
    [debugView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(containerView);
        make.left.and.bottom.equalTo(containerView);
        make.right.equalTo(containerView.mas_centerX);
    }];
    
    // 显示的信息
    infoStrLabel = [[UILabel alloc] init];
    infoStrLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
    infoStrLabel.textAlignment = NSTextAlignmentLeft;
    [debugView addSubview:infoStrLabel];
    
    infoHexLabel = [[UILabel alloc] init];
    infoHexLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
    infoHexLabel.textAlignment = NSTextAlignmentLeft;
    [debugView addSubview:infoHexLabel];
    
    // 输入调试发送信息
    debugEnterButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [debugEnterButton setTitle:@"保存并发送数据 ->" forState:UIControlStateNormal];
    [debugEnterButton sizeToFit];
    [debugEnterButton addTarget:self action:@selector(clickDebugEnterButton) forControlEvents:UIControlEventTouchUpInside];
    [debugView addSubview:debugEnterButton];
    
    debugDataLabel = [[UILabel alloc] init];
    [debugDataLabel setTextColor:[UIColor redColor]];
    [debugDataLabel setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.3]];
    [debugDataLabel setText:debugString];
    [debugDataLabel sizeToFit];
    [debugView addSubview:debugDataLabel];
    // add touch
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickDebugData)];
    [debugDataLabel setUserInteractionEnabled:YES];
    [debugDataLabel addGestureRecognizer:tap];
    
    // 布局
    [debugEnterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.bottom.equalTo(debugView);
    }];
    
    [debugDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(debugEnterButton.mas_right).with.offset(1);
        make.right.equalTo(debugView);
        make.centerY.equalTo(debugEnterButton);
    }];
    
    [infoStrLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(debugView);
        make.bottom.equalTo(debugEnterButton.mas_top).with.offset(-1);
    }];
    
    [infoHexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(debugView);
        make.bottom.equalTo(infoStrLabel.mas_top).with.offset(-1);
    }];
    
//    [infoStrLabel setText:@"111"];
//    [infoHexLabel setText:@"222"];
}

- (void)client:(CommClient *)client onReceiveData:(NSData *)data
{
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (string == nil || [string isEqualToString:@""]) {
        string = @" ";
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        infoStrLabel.text = string;
    });
    
    NSString *hex = [data hexString];
    dispatch_async(dispatch_get_main_queue(), ^{
        infoHexLabel.text = hex;
    });
}

- (void)exitDebugMode
{
    @synchronized (self) {
        if (commClient) {
            [commClient disconnect];
            commClient = nil;
        }
    }
    
    if (heartbeatTimer) {
        [heartbeatTimer invalidate];
        heartbeatTimer = nil;
    }
    if (countdownTimer) {
        [countdownTimer invalidate];
        countdownTimer = nil;
    }
    if (repeatTimer) {
        [repeatTimer invalidate];
        repeatTimer = nil;
    }
}

- (void)debugSend:(NSData *)data
{
    // TCP/UDP send
//    NSLog(@"====== send data: %@", data);
    
    @synchronized (self) {
        if (commClient) {
            [commClient sendData:data];
        }
    }
}

- (void)sendDebugString
{
    if (debugString != nil && ![debugString isEqualToString:@""]) {
        NSData *data = [debugString dataUsingEncoding:NSUTF8StringEncoding];
        [self debugSend:data];
    }
}

- (void)sendHeartbeat
{
    Byte d[2] = { 1, 1 };
    NSData *data = [NSData dataWithBytes:d length:2];
    [self debugSend:data];
}

- (void)cancelHeartbeatTimer
{
    if (heartbeatTimer != nil) {
        [heartbeatTimer invalidate];
        heartbeatTimer = nil;
    }
}

- (void)startHeartbeat
{
    [self cancelHeartbeatTimer];
    heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(sendHeartbeat) userInfo:nil repeats:YES];
}

- (void)cancelCountdownTimer
{
    if (countdownTimer != nil) {
        [countdownTimer invalidate];
        countdownTimer = nil;
    }
}

- (void)countdownSend:(NSTimeInterval)tv
{
    [self cancelCountdownTimer];
    countdownTimer = [NSTimer scheduledTimerWithTimeInterval:tv target:self selector:@selector(sendDebugString) userInfo:nil repeats:NO];
}

- (void)cancelRepeatTimer
{
    if (repeatTimer != nil) {
        [repeatTimer invalidate];
        repeatTimer = nil;
    }
}

- (void)repeatSend:(NSTimeInterval)tv
{
    [self cancelRepeatTimer];
    repeatTimer = [NSTimer scheduledTimerWithTimeInterval:tv target:self selector:@selector(sendDebugString) userInfo:nil repeats:YES];
}

#pragma mark DEBUG Info

- (void)debugTouchDown
{
    touchDebug = YES;
}

- (void)debugTouchUp
{
    touchDebug = NO;
}

- (void)switchDebugView
{
    if (touchDebug) {
        IJKFFMoviePlayerController *player = self.player;
        player.shouldShowHudView = !player.shouldShowHudView;
        // show mtcnn trimming
        [self showMtcnnTrimmingControls:player.shouldShowHudView];
    }
}

#pragma mark MTCNN TRIM

- (void)setupMtcnnTrimmingControls
{
    // 因为UISlider的Value设置太小，则滑动调整粒度不够细
    // 所以先乘以100，使用的时候再除以100
    
    detectThreshold = 0.9;
    
    UIView *containerView = _interactiveView;
    
    detectThresholdSlider = [[UISlider alloc] init];
    detectThresholdSlider.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
    detectThresholdSlider.minimumValue = 0.5 * 100;
    detectThresholdSlider.maximumValue = 1.0 * 100;
    detectThresholdSlider.continuous = YES;
    detectThresholdSlider.value = detectThreshold * 100;
    [detectThresholdSlider addTarget:self action:@selector(detectThresholdValueChanged:) forControlEvents:UIControlEventValueChanged];
    [containerView addSubview:detectThresholdSlider];
    
    detectThresholdLabel = [[UILabel alloc] init];
    detectThresholdLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
    detectThresholdLabel.textAlignment = NSTextAlignmentCenter;
    detectThresholdLabel.text = @"00.00";
    [detectThresholdLabel sizeToFit];
    CGFloat labelWidth = detectThresholdLabel.bounds.size.width;
    detectThresholdLabel.text = [NSString stringWithFormat:@"%.2f", detectThresholdSlider.value / 100];
    [containerView addSubview:detectThresholdLabel];
    
    /* o first, p last */
    
    [detectThresholdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.bottom.equalTo(containerView);
        make.width.mas_equalTo(@(labelWidth));
    }];
    
    [detectThresholdSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(detectThresholdLabel.mas_right);
        make.right.equalTo(containerView.mas_centerX);
        make.top.and.bottom.equalTo(detectThresholdLabel);
    }];
    
    // Hide first
    [self showMtcnnTrimmingControls:NO];
}

- (void)showMtcnnTrimmingControls:(BOOL)show
{
    detectThresholdSlider.hidden = !show;
    detectThresholdLabel.hidden = !show;
}

- (void)detectThresholdValueChanged:(UISlider *)slider
{
    detectThresholdLabel.text = [NSString stringWithFormat:@"%.2f", slider.value / 100];
    
    detectThreshold = slider.value / 100;
    [self.photoPostureHelper setProbThreshold:detectThreshold];
    [self.videoPostureHelper setProbThreshold:detectThreshold];
}

@end
