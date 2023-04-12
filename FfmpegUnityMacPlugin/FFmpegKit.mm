#import <Foundation/Foundation.h>
#import <ffmpegkit/FFmpegKit.h>
#import <ffmpegkit/FFmpegKitConfig.h>
#import <ffmpegkit/FFprobeKit.h>
#import <ffmpegkit/Session.h>
#import <ffmpegkit/FFmpegSession.h>
#import <ffmpegkit/Statistics.h>
#import <ffmpegkit/ReturnCode.h>

static NSMutableSet* runningSessions = [NSMutableSet set];

extern "C"
{
    void ffmpeg_setup()
    {
        [FFmpegKitConfig ignoreSignal:SignalXcpu];
    }

    void* ffmpeg_executeAsync(const char* command)
    {
        id<Session> ret = [FFmpegKit executeAsync:@(command)
            withCompleteCallback:^(FFmpegSession* session){
                [runningSessions removeObject:(id<Session>)session];
            }];
        [runningSessions addObject:ret];
        return (__bridge void*)ret;
    }

    void ffmpeg_cancel(void* session)
    {
        [(__bridge id<Session>)session cancel];
    }

    int ffmpeg_getOutputLength(void* session)
    {
        NSString* outputStr = [(__bridge id<Session>)session getOutput];
        return (int)[outputStr length];
    }

    void ffmpeg_getOutput(void* session, int startIndex, char* output, int outputLength)
    {
        NSString* outputStr = [(__bridge id<Session>)session getOutput];
        outputStr = [outputStr substringWithRange:NSMakeRange(startIndex, outputLength - 1)];
        strcpy(output, [outputStr UTF8String]);
        output[outputLength - 1] = '\0';
    }

    bool ffmpeg_isRunnning(void* session)
    {
        id<Session> sessionId = (__bridge id<Session>)session;
        return (bool)[runningSessions containsObject:sessionId];
    }
    
    void* ffmpeg_ffprobeExecuteAsync(const char* command)
    {
        id<Session> ret = [FFprobeKit executeAsync:@(command)
            withCompleteCallback:^(FFprobeSession* session){
                [runningSessions removeObject:(id<Session>)session];
            }];
        [runningSessions addObject:ret];
        return (__bridge void*)ret;
    }

    void ffmpeg_mkpipe(char* output, int outputLength)
    {
        NSString* pipeNameStr = [FFmpegKitConfig registerNewFFmpegPipe];
        if (outputLength - 1 >= [pipeNameStr length])
        {
            strcpy(output, [pipeNameStr UTF8String]);
            output[outputLength - 1] = '\0';
        }
    }

    void ffmpeg_closePipe(const char* pipeName)
    {
        [FFmpegKitConfig closeFFmpegPipe:@(pipeName)];
    }

    float ffmpeg_getTime(void* session)
    {
        Statistics* statistics = [(__bridge FFmpegSession*)session getLastReceivedStatistics];
        float fps = [statistics getVideoFps];
        if (fps > 0.0f)
        {
            return [statistics getVideoFrameNumber] / fps;
        }
        return [statistics getTime] / 1000.0f;
    }

    double ffmpeg_getSpeed(void* session)
    {
        Statistics* statistics = [(__bridge FFmpegSession*)session getLastReceivedStatistics];
        return [statistics getSpeed];
    }

    int ffmpeg_getReturnCode(void* session)
    {
        ReturnCode* returnCode = [(__bridge id<Session>)session getReturnCode];
        if (returnCode == NULL)
        {
            return 0;
        }
        return [returnCode getValue];
    }
}
