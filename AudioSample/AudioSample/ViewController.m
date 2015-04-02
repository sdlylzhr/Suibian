//
//  ViewController.m
//  AudioSample
//
//  Created by lizhongren on 15/3/24.
//  Copyright (c) 2015年 lizhongren. All rights reserved.
//

#import "ViewController.h"
#import "STKAudioPlayer.h"
#import "SampleQueueId.h"

@interface ViewController () <STKAudioPlayerDelegate>

@property (nonatomic, strong) STKAudioPlayer *player;

@property (weak, nonatomic) IBOutlet UISlider *processSlider;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) NSTimer *timer;

- (IBAction)beginAction:(id)sender;
- (IBAction)seekSlider:(id)sender;
- (IBAction)stopAction:(id)sender;
- (IBAction)pauseAction:(id)sender;
- (IBAction)volumeSlider:(id)sender;
- (IBAction)muteSwich:(id)sender;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    

    self.player = [[STKAudioPlayer alloc] initWithOptions:(STKAudioPlayerOptions){ .flushQueueOnSeek = YES, .enableVolumeMixer = YES, .equalizerBandFrequencies = {50, 100, 200, 400, 800, 1600, 2600, 16000} }];
    

    self.player.delegate = self;
    self.player.volume = 1;
    self.player.meteringEnabled = YES;
    

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  点击播放音乐, 生成一个播放数据源, 添加到播放器中
 *
 */
- (IBAction)beginAction:(id)sender {
    
    NSURL* url = [NSURL URLWithString:@"http://file.qianqian.com//data2/music/124123084/124123084.mp3?xcode=8e2cde6bcc8650c84a103777e8608e53fdf4f5300ec2a5f3"];
    
    
    STKDataSource *dataSource = [STKAudioPlayer dataSourceFromURL:url];
    
    [self.player setDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0]];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(track) userInfo:nil repeats:YES];
    
}


/**
 *  每秒更新slider和label显示时间, timer方法
 */
- (void)track
{
    if (_processSlider) {
        _processSlider.maximumValue = self.player.duration;
        _processSlider.value = self.player.progress;
        
        
        NSInteger proMin = (NSInteger)self.player.progress / 60;
        NSInteger proSec = (NSInteger)self.player.progress % 60;
        
        NSInteger durMin = (NSInteger)self.player.duration / 60;
        NSInteger durSec = (NSInteger)self.player.duration % 60;
        
        _timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld / %02ld:%02ld", proMin, proSec, durMin, durSec];
    }
}

/**
 *  进度条的方法, 改变播放器的播放进度
 *
 *  @param sender slider参数
 */
- (IBAction)seekSlider:(id)sender {
    
    if (_player) {
        UISlider *processSlider = sender;
        [self.player seekToTime:processSlider.value];
    }
}

// 停止播放
- (IBAction)stopAction:(id)sender {
    [_player stop];
}

// 暂停按钮
- (IBAction)pauseAction:(id)sender {
    
    NSLog(@"%d", _player.state);
    UIButton *button = sender;
    

    if (_player.state == STKAudioPlayerStatePaused) {
        [button setTitle:@"pause" forState:UIControlStateNormal];
        [_player resume];
    } else if (_player.state == STKAudioPlayerStatePlaying) {
        [button setTitle:@"resume" forState:UIControlStateNormal];
        [_player pause];
    } else if (_player.state == STKAudioPlayerStateReady) {
        
        [button setTitle:@"pause" forState:UIControlStateNormal];

        [self beginAction:nil];
    }
}

// 音量按钮
- (IBAction)volumeSlider:(id)sender {
    UISlider *slider = sender;
    NSLog(@"%f", slider.value);
    [_player setVolume:slider.value];
}

// 静音
- (IBAction)muteSwich:(id)sender {
    
    _player.muted = ![(UISwitch *)sender isOn];
}


#pragma mark - 播放器协议方法
/// Raised when an item has started playing


-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId
{
    NSLog(@"开始播放");
}
/// Raised when an item has finished buffering (may or may not be the currently playing item)
/// This event may be raised multiple times for the same item if seek is invoked on the player
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId
{
    NSLog(@"完成加载");
}
/// Raised when the state of the player has changed
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState
{
    NSLog(@"播放状态改变");
}
/// Raised when an item has finished playing

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration
{
    NSLog(@"结束播放");
    NSLog(@"结束原因: %d, progress: %f, duration: %f", stopReason, progress, duration);
}
/// Raised when an unexpected and possibly unrecoverable error has occured (usually best to recreate the STKAudioPlauyer)
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode
{
    NSLog(@"错误原因: %d", errorCode);
}


/// Optionally implemented to get logging information from the STKAudioPlayer (used internally for debugging)
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer logInfo:(NSString*)line
{
    NSLog(@"信息: %@", line);
}
/// Raised when items queued items are cleared (usually because of a call to play, setDataSource or stop)
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didCancelQueuedItems:(NSArray*)queuedItems
{
    NSLog(@"未知");
}

@end
