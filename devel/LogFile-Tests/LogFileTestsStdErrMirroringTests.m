//
//
// LogFileTestsStdErrMirroringTests.m
//
//
// Copyright (c) 2008-2011 Arne Harren <ah@0xc0.de>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "lcl.h"
#import <SenTestingKit/SenTestingKit.h>
#include <unistd.h>
#include <mach/mach_init.h>


@interface LogFileTestsStdErrMirroringTests : SenTestCase {
    
}

@end


@implementation LogFileTestsStdErrMirroringTests

- (void)setUp {
    // reset log file
    [LCLLogFile reset];
    
    // enable logging for component Main
    lcl_configure_by_name("*", lcl_vOff);
    lcl_configure_by_component(lcl_cMain, lcl_vDebug);
}

- (NSString *)logLineWithoutTimeProcessAndThread:(NSString *)logLine {
    NSUInteger timePrefixLength = 24;
    NSString *timePrefix = [logLine substringToIndex:timePrefixLength-1];
    NSPredicate *timePrefixPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES '[0-9]{4}?\\-[0-9]{2}?\\-[0-9]{2}?\\ [0-9]{2}?\\:[0-9]{2}?\\:[0-9]{2}?\\.[0-9]{3}?'"];
    STAssertTrue([timePrefixPredicate evaluateWithObject:timePrefix], nil);
    
    NSString *processAndThreadPrefix = [NSString stringWithFormat:@"%u:%x ",
                                        getpid(),
                                        mach_thread_self()];
    NSUInteger processAndThreadPrefixLength = [processAndThreadPrefix length];
    NSString *logLineWithProcessAndThreadPrefix = [logLine substringFromIndex:timePrefixLength];
    STAssertEqualObjects([logLineWithProcessAndThreadPrefix substringToIndex:processAndThreadPrefixLength],
                         processAndThreadPrefix, nil);
    
    return [logLineWithProcessAndThreadPrefix substringFromIndex:processAndThreadPrefixLength];
}

- (void)testStdErrMirroringLogFileAndStdErr {
    // configure the logger
    [LogFileTestsLoggerConfiguration initialize];
    [LogFileTestsLoggerConfiguration setMirrorMessagesToStdErr:YES];
    [LCLLogFile initialize];
    
    // set stderr
    NSString *stderrPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"LogFile-Tests.stderr"];
    LogFileTestsInjections_stderr = fopen([stderrPath fileSystemRepresentation], "w");
    
    // log and check
    lcl_log(lcl_cMain, lcl_vInfo, @"message");
    {
        NSString *currentLog = [NSString stringWithContentsOfFile:[LCLLogFile path] encoding:NSUTF8StringEncoding error:NULL];
        NSArray *logLines = [currentLog componentsSeparatedByString:@"\n"];
        STAssertTrue(0 < [logLines count], nil);
        STAssertEquals([logLines count] - 1, (NSUInteger)1, nil);
        STAssertEqualObjects([self logLineWithoutTimeProcessAndThread:[logLines objectAtIndex:0]],
                             @"I Main:LogFileTestsStdErrMirroringTests.m:78:-[LogFileTestsStdErrMirroringTests testStdErrMirroringLogFileAndStdErr] message", nil);
    }
    
    fflush(LogFileTestsInjections_stderr);
    {
        NSString *currentLog = [NSString stringWithContentsOfFile:stderrPath encoding:NSUTF8StringEncoding error:NULL];
        NSArray *logLines = [currentLog componentsSeparatedByString:@"\n"];
        STAssertTrue(0 < [logLines count], nil);
        STAssertEquals([logLines count] - 1, (NSUInteger)1, nil);
        STAssertEqualObjects([self logLineWithoutTimeProcessAndThread:[logLines objectAtIndex:0]],
                             @"I Main:LogFileTestsStdErrMirroringTests.m:78:-[LogFileTestsStdErrMirroringTests testStdErrMirroringLogFileAndStdErr] message", nil);
    }
    
    // reset stderr
    fclose(LogFileTestsInjections_stderr);
    LogFileTestsInjections_stderr = stderr;
}

- (void)testStdErrMirroringBadLogFilePathAndFallbackToStdErr {
    // configure the logger
    [LogFileTestsLoggerConfiguration initialize];
    [LogFileTestsLoggerConfiguration setLogFilePath:@"bad-file-path"];
    [LogFileTestsLoggerConfiguration setMirrorMessagesToStdErr:NO];
    [LCLLogFile initialize];
    
    // set stderr
    NSString *stderrPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"LogFile-Tests.stderr"];
    LogFileTestsInjections_stderr = fopen([stderrPath fileSystemRepresentation], "w");
    
    // log and check
    lcl_log(lcl_cMain, lcl_vInfo, @"message");
    {
        NSString *currentLog = [NSString stringWithContentsOfFile:[LCLLogFile path] encoding:NSUTF8StringEncoding error:NULL];
        NSArray *logLines = [currentLog componentsSeparatedByString:@"\n"];
        STAssertEquals([logLines count], (NSUInteger)0, nil);
    }
    
    fflush(LogFileTestsInjections_stderr);
    {
        NSString *currentLog = [NSString stringWithContentsOfFile:stderrPath encoding:NSUTF8StringEncoding error:NULL];
        NSArray *logLines = [currentLog componentsSeparatedByString:@"\n"];
        STAssertTrue(0 < [logLines count], nil);
        STAssertEquals([logLines count] - 1, (NSUInteger)1, nil);
        STAssertEqualObjects([self logLineWithoutTimeProcessAndThread:[logLines objectAtIndex:0]],
                             @"I Main:LogFileTestsStdErrMirroringTests.m:115:-[LogFileTestsStdErrMirroringTests testStdErrMirroringBadLogFilePathAndFallbackToStdErr] message", nil);
    }
    
    // reset stderr
    fclose(LogFileTestsInjections_stderr);
    LogFileTestsInjections_stderr = stderr;
}

@end

