//
//
// LogFileTestsTemplatesTests.m
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


@interface LogFileTestsTemplatesTests : SenTestCase {
    
}

@end


@implementation LogFileTestsTemplatesTests

- (void)testConfigurationMaxLogFileSize {
    STAssertEquals([LCLLogFile maxSize], (size_t)(2 * 1024 * 1024), nil);
}

- (void)testConfigurationLogFilePaths {
    NSString *expectedPath = [NSHomeDirectory() stringByAppendingPathComponent:
                              [NSString stringWithFormat:@"Library/Logs/YourApplication/YourApplication.%u.log",
                               getpid()]];
    NSString *expectedPath0 = [NSHomeDirectory() stringByAppendingPathComponent:
                               [NSString stringWithFormat:@"Library/Logs/YourApplication/YourApplication.%u.log.0",
                                getpid()]];
    STAssertEqualObjects([LCLLogFile path], expectedPath, nil);
    STAssertEqualObjects([LCLLogFile path0], expectedPath0, nil);
}

- (void)testConfigurationAppendsToExistingLogFile {
    STAssertEquals((int)[LCLLogFile appendsToExistingLogFile], (int)YES, nil);
}

- (void)testConfigurationMirrorsToStdErr {
    STAssertEquals((int)[LCLLogFile mirrorsToStdErr], (int)NO, nil);
}

- (void)testConfigurationEscapesLineFeeds {
    STAssertEquals((int)[LCLLogFile escapesLineFeeds], (int)YES, nil);
}

- (void)testConfigurationMaxMessageSize {
    STAssertEquals([LCLLogFile maxMessageSize], (NSUInteger)0, nil);
}

- (void)testShowsFileNames {
    STAssertEquals((int)[LCLLogFile showsFileNames], (int)YES, nil);
}

- (void)testShowsLineNumbers {
    STAssertEquals((int)[LCLLogFile showsLineNumbers], (int)YES, nil);
}

- (void)testShowsFunctionNames {
    STAssertEquals((int)[LCLLogFile showsFunctionNames], (int)YES, nil);
}

@end

