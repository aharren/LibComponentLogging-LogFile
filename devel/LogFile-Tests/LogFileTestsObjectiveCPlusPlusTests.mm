//
//
// LogFileTestsObjectiveCPlusPlusTests.mm
//
//
// Copyright (c) 2008-2012 Arne Harren <ah@0xc0.de>
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


class LogFileTestsObjectiveCPlusPlusTestsClass {
    
public:
    static void logAtLevelInfo(int i, NSString *t);
    static void logAtLevelInfo(int i, NSString *t, NSString *s);
    
};

void LogFileTestsObjectiveCPlusPlusTestsClass::logAtLevelInfo(int i, NSString *t) {
    lcl_log(lcl_cMain, lcl_vInfo, @"message %s %d %@", "cstring", i, t);
}

void LogFileTestsObjectiveCPlusPlusTestsClass::logAtLevelInfo(int i, NSString *t, NSString *s) {
    lcl_log(lcl_cMain, lcl_vInfo, @"message %s %d %@ %@", "cstring", i, t, s);
}


@interface LogFileTestsObjectiveCPlusPlusTests : SenTestCase {
    
}

@end


@implementation LogFileTestsObjectiveCPlusPlusTests

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

- (void)testLogFormatWithComponentLineNumberAndFunctionName {
    [LogFileTestsLoggerConfiguration initialize];
    [LogFileTestsLoggerConfiguration setAppendToExistingLogFile:NO];
    [LogFileTestsLoggerConfiguration setShowFileNames:NO];
    [LogFileTestsLoggerConfiguration setShowLineNumbers:YES];
    [LogFileTestsLoggerConfiguration setShowFunctionNames:YES];
    [LCLLogFile initialize];
    
    LogFileTestsObjectiveCPlusPlusTestsClass::logAtLevelInfo(123, @"NSString X");
    {
        NSString *currentLog = [NSString stringWithContentsOfFile:[LCLLogFile path] encoding:NSUTF8StringEncoding error:NULL];
        NSArray *logLines = [currentLog componentsSeparatedByString:@"\n"];
        STAssertTrue(0 < [logLines count], nil);
        STAssertEquals([logLines count] - 1, (NSUInteger)1, nil);
        NSString *line = [[self logLineWithoutTimeProcessAndThread:[logLines objectAtIndex:0]]
                          stringByReplacingOccurrencesOfString:@"NSString*" withString:@"NSString *"];
#       if !__has_feature(objc_arc)
        STAssertEqualObjects(line,
                             @"I Main:41:static void LogFileTestsObjectiveCPlusPlusTestsClass::logAtLevelInfo(int, NSString *) message cstring 123 NSString X", nil);
#       else
        STAssertEqualObjects(line,
                             @"I Main:41:static void LogFileTestsObjectiveCPlusPlusTestsClass::logAtLevelInfo(int, NSString *__strong) message cstring 123 NSString X", nil);
#       endif
    }
}

@end

