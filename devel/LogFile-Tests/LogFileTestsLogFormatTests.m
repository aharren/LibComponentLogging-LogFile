//
//
// LogFileTestsLogFormatTests.m
//
//
// Copyright (c) 2008-2009 Arne Harren <ah@0xc0.de>
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


@interface LogFileTestsLogFormatTests : SenTestCase {
    
}

@end


@implementation LogFileTestsLogFormatTests

- (void)setUp {
    // reset log file
    [LCLLogFile reset];
    
    // enable logging for component Main
    lcl_configure_by_name("*", lcl_vOff);
    lcl_configure_by_component(lcl_cMain, lcl_vDebug);
}

- (NSString *)logLineWithoutTimeProcessAndThread:(NSString *)logLine {
    NSUInteger timeLength = 24;
    NSString *processAndThread = [NSString stringWithFormat:@"%u:%x ",
                                  getpid(),
                                  mach_thread_self()];
    NSUInteger processAndThreadLength = [processAndThread length];
    NSString *logLineWithProcessAndThread = [logLine substringFromIndex:timeLength];
    STAssertEqualObjects([logLineWithProcessAndThread substringToIndex:processAndThreadLength],
                         processAndThread, nil);
    
    return [logLineWithProcessAndThread substringFromIndex:processAndThreadLength];
}

- (void)testLogFormatWithFullFormat {
    [LogFileTestsLoggerConfiguration initialize];
    [LogFileTestsLoggerConfiguration setAppendToExistingLogFile:NO];
    [LogFileTestsLoggerConfiguration setShowFileNames:YES];
    [LogFileTestsLoggerConfiguration setShowLineNumbers:YES];
    [LogFileTestsLoggerConfiguration setShowFunctionNames:YES];
    [LCLLogFile initialize];
    
    lcl_log(lcl_cMain, lcl_vInfo, @"message %s %d %@", "cstring", 123, @"NSString *");
    {
        NSString *currentLog = [NSString stringWithContentsOfFile:[LCLLogFile path] encoding:NSUTF8StringEncoding error:NULL];
        NSArray *logLines = [currentLog componentsSeparatedByString:@"\n"];
        STAssertTrue(0 < [logLines count], nil);
        STAssertEquals([logLines count] - 1, (NSUInteger)1, nil);
        STAssertEqualObjects([self logLineWithoutTimeProcessAndThread:[logLines objectAtIndex:0]],
                             @"I Main:LogFileTestsLogFormatTests.m:71:-[LogFileTestsLogFormatTests testLogFormatWithFullFormat] message cstring 123 NSString *", nil);
    }
}

- (void)testLogFormatWithComponentOnly {
    [LogFileTestsLoggerConfiguration initialize];
    [LogFileTestsLoggerConfiguration setAppendToExistingLogFile:NO];
    [LogFileTestsLoggerConfiguration setShowFileNames:NO];
    [LogFileTestsLoggerConfiguration setShowLineNumbers:NO];
    [LogFileTestsLoggerConfiguration setShowFunctionNames:NO];
    [LCLLogFile initialize];
    
    lcl_log(lcl_cMain, lcl_vInfo, @"message %s %d %@", "cstring", 123, @"NSString *");
    {
        NSString *currentLog = [NSString stringWithContentsOfFile:[LCLLogFile path] encoding:NSUTF8StringEncoding error:NULL];
        NSArray *logLines = [currentLog componentsSeparatedByString:@"\n"];
        STAssertTrue(0 < [logLines count], nil);
        STAssertEquals([logLines count] - 1, (NSUInteger)1, nil);
        STAssertEqualObjects([self logLineWithoutTimeProcessAndThread:[logLines objectAtIndex:0]],
                             @"I Main message cstring 123 NSString *", nil);
    }
}

- (void)testLogFormatWithComponentAndFileName {
    [LogFileTestsLoggerConfiguration initialize];
    [LogFileTestsLoggerConfiguration setAppendToExistingLogFile:NO];
    [LogFileTestsLoggerConfiguration setShowFileNames:YES];
    [LogFileTestsLoggerConfiguration setShowLineNumbers:NO];
    [LogFileTestsLoggerConfiguration setShowFunctionNames:NO];
    [LCLLogFile initialize];
    
    lcl_log(lcl_cMain, lcl_vInfo, @"message %s %d %@", "cstring", 123, @"NSString *");
    {
        NSString *currentLog = [NSString stringWithContentsOfFile:[LCLLogFile path] encoding:NSUTF8StringEncoding error:NULL];
        NSArray *logLines = [currentLog componentsSeparatedByString:@"\n"];
        STAssertTrue(0 < [logLines count], nil);
        STAssertEquals([logLines count] - 1, (NSUInteger)1, nil);
        STAssertEqualObjects([self logLineWithoutTimeProcessAndThread:[logLines objectAtIndex:0]],
                             @"I Main:LogFileTestsLogFormatTests.m message cstring 123 NSString *", nil);
    }
}

- (void)testLogFormatWithComponentAndLineNumber {
    [LogFileTestsLoggerConfiguration initialize];
    [LogFileTestsLoggerConfiguration setAppendToExistingLogFile:NO];
    [LogFileTestsLoggerConfiguration setShowFileNames:NO];
    [LogFileTestsLoggerConfiguration setShowLineNumbers:YES];
    [LogFileTestsLoggerConfiguration setShowFunctionNames:NO];
    [LCLLogFile initialize];
    
    lcl_log(lcl_cMain, lcl_vInfo, @"message %s %d %@", "cstring", 123, @"NSString *");
    {
        NSString *currentLog = [NSString stringWithContentsOfFile:[LCLLogFile path] encoding:NSUTF8StringEncoding error:NULL];
        NSArray *logLines = [currentLog componentsSeparatedByString:@"\n"];
        STAssertTrue(0 < [logLines count], nil);
        STAssertEquals([logLines count] - 1, (NSUInteger)1, nil);
        STAssertEqualObjects([self logLineWithoutTimeProcessAndThread:[logLines objectAtIndex:0]],
                             @"I Main:128 message cstring 123 NSString *", nil);
    }
}

- (void)testLogFormatWithComponentAndFunctionName {
    [LogFileTestsLoggerConfiguration initialize];
    [LogFileTestsLoggerConfiguration setAppendToExistingLogFile:NO];
    [LogFileTestsLoggerConfiguration setShowFileNames:NO];
    [LogFileTestsLoggerConfiguration setShowLineNumbers:NO];
    [LogFileTestsLoggerConfiguration setShowFunctionNames:YES];
    [LCLLogFile initialize];
    
    lcl_log(lcl_cMain, lcl_vInfo, @"message %s %d %@", "cstring", 123, @"NSString *");
    {
        NSString *currentLog = [NSString stringWithContentsOfFile:[LCLLogFile path] encoding:NSUTF8StringEncoding error:NULL];
        NSArray *logLines = [currentLog componentsSeparatedByString:@"\n"];
        STAssertTrue(0 < [logLines count], nil);
        STAssertEquals([logLines count] - 1, (NSUInteger)1, nil);
        STAssertEqualObjects([self logLineWithoutTimeProcessAndThread:[logLines objectAtIndex:0]],
                             @"I Main:-[LogFileTestsLogFormatTests testLogFormatWithComponentAndFunctionName] message cstring 123 NSString *", nil);
    }
}

- (void)testLogFormatWithComponentFileNameAndLineNumber {
    [LogFileTestsLoggerConfiguration initialize];
    [LogFileTestsLoggerConfiguration setAppendToExistingLogFile:NO];
    [LogFileTestsLoggerConfiguration setShowFileNames:YES];
    [LogFileTestsLoggerConfiguration setShowLineNumbers:YES];
    [LogFileTestsLoggerConfiguration setShowFunctionNames:NO];
    [LCLLogFile initialize];
    
    lcl_log(lcl_cMain, lcl_vInfo, @"message %s %d %@", "cstring", 123, @"NSString *");
    {
        NSString *currentLog = [NSString stringWithContentsOfFile:[LCLLogFile path] encoding:NSUTF8StringEncoding error:NULL];
        NSArray *logLines = [currentLog componentsSeparatedByString:@"\n"];
        STAssertTrue(0 < [logLines count], nil);
        STAssertEquals([logLines count] - 1, (NSUInteger)1, nil);
        STAssertEqualObjects([self logLineWithoutTimeProcessAndThread:[logLines objectAtIndex:0]],
                             @"I Main:LogFileTestsLogFormatTests.m:166 message cstring 123 NSString *", nil);
    }
}

- (void)testLogFormatWithNULLFileNameAndFunctionName {
    [LogFileTestsLoggerConfiguration initialize];
    [LogFileTestsLoggerConfiguration setAppendToExistingLogFile:NO];
    [LogFileTestsLoggerConfiguration setShowFileNames:YES];
    [LogFileTestsLoggerConfiguration setShowLineNumbers:YES];
    [LogFileTestsLoggerConfiguration setShowFunctionNames:YES];
    [LCLLogFile initialize];
    
    [LCLLogFile logWithComponent:_lcl_component_header[lcl_cMain] level:lcl_vInfo path:NULL line:0 function:NULL format:@"message %s %d %@", "cstring", 123, @"NSString *"];
    {
        NSString *currentLog = [NSString stringWithContentsOfFile:[LCLLogFile path] encoding:NSUTF8StringEncoding error:NULL];
        NSArray *logLines = [currentLog componentsSeparatedByString:@"\n"];
        STAssertTrue(0 < [logLines count], nil);
        STAssertEquals([logLines count] - 1, (NSUInteger)1, nil);
        STAssertEqualObjects([self logLineWithoutTimeProcessAndThread:[logLines objectAtIndex:0]],
                             @"I Main:(null):0:(null) message cstring 123 NSString *", nil);
    }
}

- (void)testLogFormatLogLevels {
    [LogFileTestsLoggerConfiguration initialize];
    [LogFileTestsLoggerConfiguration setAppendToExistingLogFile:NO];
    [LogFileTestsLoggerConfiguration setShowFileNames:NO];
    [LogFileTestsLoggerConfiguration setShowLineNumbers:NO];
    [LogFileTestsLoggerConfiguration setShowFunctionNames:NO];
    [LCLLogFile initialize];
    
    [LCLLogFile logWithComponent:_lcl_component_header[lcl_cMain] level:0 path:NULL line:0 function:NULL format:@"message"];
    [LCLLogFile logWithComponent:_lcl_component_header[lcl_cMain] level:lcl_vCritical path:NULL line:0 function:NULL format:@"message"];
    [LCLLogFile logWithComponent:_lcl_component_header[lcl_cMain] level:lcl_vError path:NULL line:0 function:NULL format:@"message"];
    [LCLLogFile logWithComponent:_lcl_component_header[lcl_cMain] level:lcl_vWarning path:NULL line:0 function:NULL format:@"message"];
    [LCLLogFile logWithComponent:_lcl_component_header[lcl_cMain] level:lcl_vInfo path:NULL line:0 function:NULL format:@"message"];
    [LCLLogFile logWithComponent:_lcl_component_header[lcl_cMain] level:lcl_vDebug path:NULL line:0 function:NULL format:@"message"];
    [LCLLogFile logWithComponent:_lcl_component_header[lcl_cMain] level:lcl_vTrace path:NULL line:0 function:NULL format:@"message"];
    [LCLLogFile logWithComponent:_lcl_component_header[lcl_cMain] level:7 path:NULL line:0 function:NULL format:@"message"];
    [LCLLogFile logWithComponent:_lcl_component_header[lcl_cMain] level:8 path:NULL line:0 function:NULL format:@"message"];
    [LCLLogFile logWithComponent:_lcl_component_header[lcl_cMain] level:18 path:NULL line:0 function:NULL format:@"message"];
    {
        NSString *currentLog = [NSString stringWithContentsOfFile:[LCLLogFile path] encoding:NSUTF8StringEncoding error:NULL];
        NSArray *logLines = [currentLog componentsSeparatedByString:@"\n"];
        STAssertTrue(0 < [logLines count], nil);
        STAssertEquals([logLines count] - 1, (NSUInteger)10, nil);
        STAssertEqualObjects([self logLineWithoutTimeProcessAndThread:[logLines objectAtIndex:0]],
                             @"- Main message", nil);
        STAssertEqualObjects([self logLineWithoutTimeProcessAndThread:[logLines objectAtIndex:1]],
                             @"C Main message", nil);
        STAssertEqualObjects([self logLineWithoutTimeProcessAndThread:[logLines objectAtIndex:2]],
                             @"E Main message", nil);
        STAssertEqualObjects([self logLineWithoutTimeProcessAndThread:[logLines objectAtIndex:3]],
                             @"W Main message", nil);
        STAssertEqualObjects([self logLineWithoutTimeProcessAndThread:[logLines objectAtIndex:4]],
                             @"I Main message", nil);
        STAssertEqualObjects([self logLineWithoutTimeProcessAndThread:[logLines objectAtIndex:5]],
                             @"D Main message", nil);
        STAssertEqualObjects([self logLineWithoutTimeProcessAndThread:[logLines objectAtIndex:6]],
                             @"T Main message", nil);
        STAssertEqualObjects([self logLineWithoutTimeProcessAndThread:[logLines objectAtIndex:7]],
                             @"7 Main message", nil);
        STAssertEqualObjects([self logLineWithoutTimeProcessAndThread:[logLines objectAtIndex:8]],
                             @"8 Main message", nil);
        STAssertEqualObjects([self logLineWithoutTimeProcessAndThread:[logLines objectAtIndex:9]],
                             @"18 Main message", nil);
    }
}

@end

