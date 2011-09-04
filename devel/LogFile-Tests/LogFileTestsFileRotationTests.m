//
//
// LogFileTestsFileRotationTests.m
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


@interface LogFileTestsFileRotationTests : SenTestCase {
    
}

@end


@implementation LogFileTestsFileRotationTests

- (void)setUp {
    // configure the logger
    [LogFileTestsLoggerConfiguration initialize];
    [LogFileTestsLoggerConfiguration setMaxLogFileSizeInBytes:(size_t)(64 * 1024)];
    [LogFileTestsLoggerConfiguration setAppendToExistingLogFile:NO];
    [LogFileTestsLoggerConfiguration setMirrorMessagesToStdErr:NO];
    [LCLLogFile initialize];
    
    // don't append to an existing log file
    STAssertEquals([LCLLogFile appendsToExistingLogFile], NO, nil);
    
    // reset log file
    [LCLLogFile reset];
    STAssertEquals([LCLLogFile size], (size_t)0, nil);
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path]], nil);
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path0]], nil);
    
    // enable logging for component Main and Main2
    lcl_configure_by_name("*", lcl_vOff);
    lcl_configure_by_component(lcl_cMain, lcl_vTrace);
    lcl_configure_by_component(lcl_cMain2, lcl_vTrace);
}

- (void)testFileRotation {
    STAssertEquals([LCLLogFile maxSize], (size_t)64 * 1024, @"precondition");
    
    size_t fileSizeInitial;
    size_t fileSize;
    size_t lineSize;
    NSUInteger lineNum;
    
    // fill the log file until it will rotate on the next entry
    fileSizeInitial = 0;
    fileSize = [LCLLogFile size];
    lineSize = 0;
    lineNum = 0;
    do {
        lcl_log(lcl_cMain, lcl_vError, @"message 1");
        if (lineSize == 0) {
            lineSize = [LCLLogFile size] - fileSize;
        }
        STAssertTrue(lineSize > 10, nil);
        STAssertEquals([LCLLogFile size] - fileSize, lineSize, @"expecting constant line sizes");
        lineNum++;
        fileSize = [LCLLogFile size];
    } while ([LCLLogFile size] + lineSize < [LCLLogFile maxSize] && lineNum < 7000);
    
    // rotation shouldn't have happened yet
    STAssertEquals([LCLLogFile size], (size_t)(lineSize * lineNum) + fileSizeInitial, nil);
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path]], nil);
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path0]], nil);
    
    // write a new log entry and check rotation
    lcl_log(lcl_cMain, lcl_vCritical, @"message 2");
    STAssertTrue([LCLLogFile size] > 0, nil);
    STAssertTrue([LCLLogFile size] < 2 * lineSize, nil);
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path]], nil);
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path0]], nil);
    // check current log file
    {
        NSString *currentLog = [NSString stringWithContentsOfFile:[LCLLogFile path] encoding:NSUTF8StringEncoding error:NULL];
        NSArray *logLines = [currentLog componentsSeparatedByString:@"\n"];
        STAssertTrue(0 < [logLines count], nil);
        STAssertEquals([logLines count] - 1, (NSUInteger)1, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"C Main:"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"message 2"].location, nil);
    }
    // check backup log file
    {
        NSString *backupLog = [NSString stringWithContentsOfFile:[LCLLogFile path0] encoding:NSUTF8StringEncoding error:NULL];
        NSArray *logLines = [backupLog componentsSeparatedByString:@"\n"];
        STAssertTrue(0 < [logLines count], nil);
        STAssertEquals([logLines count] - 1, lineNum, nil);
        for (NSUInteger i = 0; i < lineNum; i++) {
            STAssertTrue(NSNotFound != [[logLines objectAtIndex:i] rangeOfString:@"E Main:"].location, nil);
            STAssertTrue(NSNotFound != [[logLines objectAtIndex:i] rangeOfString:@"message 1"].location, nil);
        }
    }
    
    // fill the log file, again
    fileSizeInitial = [LCLLogFile size];
    fileSize = [LCLLogFile size];
    lineSize = 0;
    lineNum = 1;
    do {
        lcl_log(lcl_cMain2, lcl_vError, @"message 1");
        if (lineSize == 0) {
            lineSize = [LCLLogFile size] - fileSize;
        }
        STAssertTrue(lineSize > 10, nil);
        STAssertEquals([LCLLogFile size] - fileSize, lineSize, @"expecting constant line sizes");
        lineNum++;
        fileSize = [LCLLogFile size];
    } while ([LCLLogFile size] + lineSize < [LCLLogFile maxSize] && lineNum < 7000);
    
    // rotation shouldn't have happened yet (backup still exists)
    STAssertEquals([LCLLogFile size], (size_t)(lineSize * (lineNum - 1)) + fileSizeInitial, nil);
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path]], nil);
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path0]], nil);
    
    // write a new log entry and check rotation
    lcl_log(lcl_cMain2, lcl_vInfo, @"message 2");
    STAssertTrue([LCLLogFile size] > 0, nil);
    STAssertTrue([LCLLogFile size] < 2 * lineSize, nil);
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path]], nil);
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path0]], nil);
    // check current log file
    {
        NSString *currentLog = [NSString stringWithContentsOfFile:[LCLLogFile path] encoding:NSUTF8StringEncoding error:NULL];
        NSArray *logLines = [currentLog componentsSeparatedByString:@"\n"];
        STAssertTrue(0 < [logLines count], nil);
        STAssertEquals([logLines count] - 1, (NSUInteger)1, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"I Main2:"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"message 2"].location, nil);
    }
    // check backup log file
    {
        NSString *backupLog = [NSString stringWithContentsOfFile:[LCLLogFile path0] encoding:NSUTF8StringEncoding error:NULL];
        NSArray *logLines = [backupLog componentsSeparatedByString:@"\n"];
        STAssertTrue(0 < [logLines count], nil);
        STAssertEquals([logLines count] - 1, lineNum, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"C Main:"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"message 2"].location, nil);
        for (NSUInteger i = 1; i < lineNum; i++) {
            STAssertTrue(NSNotFound != [[logLines objectAtIndex:i] rangeOfString:@"E Main2:"].location, nil);
            STAssertTrue(NSNotFound != [[logLines objectAtIndex:i] rangeOfString:@"message 1"].location, nil);
        }
    }
}

@end

