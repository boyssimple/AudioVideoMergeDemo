//
//  ViewController.m
//  AudioVideoMergeDemo
//
//  Created by 杜顺 on 2018/11/28.
//  Copyright © 2018 杜顺. All rights reserved.
//

#import "ViewController.h"
#import <AVKit/AVKit.h>

@interface ViewController ()

@property (nonatomic, strong) AVPlayer *player;
@property (weak, nonatomic) IBOutlet UIView *playerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.player = [AVPlayer playerWithPlayerItem:nil];


}

//播放音频 A
- (IBAction)playAAAAA:(id)sender {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"aaa" ofType:@"m4r"];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:url];
    [self.player replaceCurrentItemWithPlayerItem:item];
    [self.player play];
}

//播放音频 B
- (IBAction)playBBBBB:(id)sender {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"bbb" ofType:@"m4r"];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:url];
    [self.player replaceCurrentItemWithPlayerItem:item];
    [self.player play];
}

//播放短视频呢
- (IBAction)playShortVideo:(id)sender {
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ccc" ofType:@"mp4"];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:url];
    [self.player replaceCurrentItemWithPlayerItem:item];
    
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    layer.frame = self.playerView.bounds;
    [self.playerView.layer addSublayer:layer];
    
    [self.player play];
}

//播放两个音频的合并
- (IBAction)playAAAAAMergerBBBBB:(id)sender {
    
    /*
     注意点：
     1、tracksWithMediaType 类型要和 asset 的类型匹配
     2、在 AVAssetExportSession 中。文件导出的名字 、 presetName 、outputFileType 要一直
     */
    
    
    //可变音频组合器
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    
    //音频1轨道插入
    NSString *filePath1 = [[NSBundle mainBundle] pathForResource:@"aaa" ofType:@"m4r"];
    AVURLAsset *asset1 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:filePath1]];
    AVMutableCompositionTrack *track1 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
    [track1 insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset1.duration) ofTrack:[asset1 tracksWithMediaType:AVMediaTypeAudio].firstObject atTime:kCMTimeZero error:nil];
    
    
    //音频2轨道插入
    NSString *filePath2 = [[NSBundle mainBundle] pathForResource:@"bbb" ofType:@"m4r"];
    AVURLAsset *asset2 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:filePath2]];
    AVMutableCompositionTrack *track2 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
    [track2 insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset2.duration) ofTrack:[asset2 tracksWithMediaType:AVMediaTypeAudio].firstObject atTime:kCMTimeZero error:nil];

    
    //设置导出的路径
    NSString *mergerAudioFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    mergerAudioFilePath = [mergerAudioFilePath stringByAppendingPathComponent:@"mergerAudio.m4a"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:mergerAudioFilePath]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:mergerAudioFilePath error:&error];
        if (error) {
            NSLog(@"error = %@",error);
        }
    }
    
    //导出的位置、格式、导出完成的操作
    AVAssetExportSession *session = [[AVAssetExportSession alloc]initWithAsset:composition presetName:AVAssetExportPresetAppleM4A];
    session.outputURL = [NSURL fileURLWithPath:mergerAudioFilePath];
    session.outputFileType = @"com.apple.m4a-audio";
    session.shouldOptimizeForNetworkUse = YES;
    
    [session exportAsynchronouslyWithCompletionHandler:^{
        
        NSLog(@"合并结束");
        if ([[NSFileManager defaultManager] fileExistsAtPath:mergerAudioFilePath]) {
            NSLog(@"合并成功");
            NSURL *url = [NSURL fileURLWithPath:mergerAudioFilePath];
            AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:url];
            [self.player replaceCurrentItemWithPlayerItem:item];
            [self.player play];
        } else {
            NSLog(@"合并失败");
        }
    }];
    
}

//播放短视频和音频 A 的合成视频
- (IBAction)playShortVideoMergeAAAAA:(id)sender {
    
    
    
    //可变音频组合器
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    
    //音频1轨道插入
    NSString *filePath1 = [[NSBundle mainBundle] pathForResource:@"aaa" ofType:@"m4r"];
    AVURLAsset *asset1 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:filePath1]];
    AVMutableCompositionTrack *track1 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
    [track1 insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset1.duration) ofTrack:[asset1 tracksWithMediaType:AVMediaTypeAudio].firstObject atTime:kCMTimeZero error:nil];
    
    //短视频中音频轨道
    NSString *filePath2 = [[NSBundle mainBundle] pathForResource:@"ccc" ofType:@"mp4"];
    AVURLAsset *asset2 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:filePath2]];
    AVMutableCompositionTrack *track2 = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:0];
    [track2 insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset2.duration) ofTrack:[asset2 tracksWithMediaType:AVMediaTypeVideo].firstObject atTime:kCMTimeZero error:nil];
    
    AVMutableCompositionTrack *track3 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
    [track3 insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset2.duration) ofTrack:[asset2 tracksWithMediaType:AVMediaTypeAudio].firstObject atTime:kCMTimeZero error:nil];
    
    
    //设置导出的路径
    NSString *mergerAudioFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    mergerAudioFilePath = [mergerAudioFilePath stringByAppendingPathComponent:@"mergerVideo.mp4"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:mergerAudioFilePath]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:mergerAudioFilePath error:&error];
        if (error) {
            NSLog(@"error = %@",error);
        }
    }
    
    //导出的位置、格式、导出完成的操作
    AVAssetExportSession *session = [[AVAssetExportSession alloc]initWithAsset:composition presetName:AVAssetExportPreset640x480];
    session.outputURL = [NSURL fileURLWithPath:mergerAudioFilePath];
    session.outputFileType = AVFileTypeMPEG4;
    session.shouldOptimizeForNetworkUse = YES;
    
    [session exportAsynchronouslyWithCompletionHandler:^{
        
        NSLog(@"合并结束");
        if ([[NSFileManager defaultManager] fileExistsAtPath:mergerAudioFilePath]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"合并成功");
                NSURL *url = [NSURL fileURLWithPath:mergerAudioFilePath];
                AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:url];
                [self.player replaceCurrentItemWithPlayerItem:item];
                
                AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
                layer.frame = self.playerView.bounds;
                [self.playerView.layer addSublayer:layer];
                
                [self.player play];
                
            });
        
        } else {
            NSLog(@"合并失败");
        }
    }];
    
    
}

@end
