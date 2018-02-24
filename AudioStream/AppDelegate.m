//
//  AppDelegate.m
//  AudioStream
//
//  Created by 吴孜健 on 2018/2/22.
//  Copyright © 2018年 吴孜健. All rights reserved.
//

#import "AppDelegate.h"
#import "ZJAudioFileStream.h"
@interface AppDelegate ()<ZJAudioFileStreamDelegate>

@property (nonatomic, strong) ZJAudioFileStream *audioFileStream;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"deadwithlife" ofType:@"flac"];
    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:path];
    unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize];
    NSError *error = nil;
    _audioFileStream = [[ZJAudioFileStream alloc]initWithFileType:kAudioFileFLACType fileSize:fileSize error:&error];
    _audioFileStream.delegate = self;
    
    if (error) {
        _audioFileStream = nil;
        NSLog(@"create file stream failed ,error : %@",[error description]);
    }else{
        NSLog(@"audio file open");
        if (file) {
            NSUInteger lengthPerRead = 10000;
            while (fileSize > 0) {
                NSData *data = [file readDataOfLength:lengthPerRead];
                fileSize -= [data length];
                [_audioFileStream parseData:data error:&error];
                if (error) {
                    if (error.code == kAudioFileStreamError_NotOptimized) {
                        NSLog(@"audio not  optimized");
                    }
                    break;
                }
            }
            
            NSLog(@"audio format: bitrate = %zd, duration = %lf.",_audioFileStream.bitRate,_audioFileStream.duration);
            [_audioFileStream close];
            _audioFileStream = nil;
            NSLog(@"xxxxxxxxx_________xxxxxxxxxx");
            [file closeFile];
        }
    }
    
    
    return YES;
}


- (void)audioFileStreamReadyToProducePackets:(ZJAudioFileStream *)audioFileStream
{
    NSLog(@"audio ready to produce packets");
}

- (void)audioFileStream:(ZJAudioFileStream *)audioFileStream audioDataParsed:(NSArray *)audioData
{
    NSLog(@"data parse");
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
