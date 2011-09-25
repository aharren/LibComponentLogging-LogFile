//
//
// LogFileTestsSetPathTests.m
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


@interface LogFileTestsSetPathTests : SenTestCase {
    
}

@end


@implementation LogFileTestsSetPathTests

- (void)setUp {
    // configure the logger
    [LogFileTestsLoggerConfiguration initialize];
    [LogFileTestsLoggerConfiguration setAppendToExistingLogFile:YES];
    [LogFileTestsLoggerConfiguration setMirrorMessagesToStdErr:NO];
    [LCLLogFile initialize];
    
    // enable logging for all components
    lcl_configure_by_name("*", lcl_vDebug);
}

- (void)testSetPathWithExistingLogFile {
    STAssertTrue([LCLLogFile appendsToExistingLogFile], @"precondition");
    
    // reset log file
    [LCLLogFile reset];
    STAssertEquals([LCLLogFile size], (size_t)0, nil);
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path]], nil);
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path0]], nil);
    
    // create existing log file
    NSString* oldPath = [[LCLLogFile path] copy];
    NSString* oldPath0 = [[LCLLogFile path0] copy];
    [@"content of existing log file\n" writeToFile:oldPath atomically:NO encoding:NSUTF8StringEncoding error:NULL];
    [@"content of existing backup log file\n" writeToFile:oldPath0 atomically:NO encoding:NSUTF8StringEncoding error:NULL];
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:oldPath], nil);
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:oldPath0], nil);
    STAssertEqualObjects([NSString stringWithContentsOfFile:oldPath encoding:NSUTF8StringEncoding error:NULL], @"content of existing log file\n", nil);
    STAssertEqualObjects([NSString stringWithContentsOfFile:oldPath0 encoding:NSUTF8StringEncoding error:NULL], @"content of existing backup log file\n", nil);
    
    // write log
    STAssertEquals([LCLLogFile size], (size_t)0, nil);
    [LCLLogFile logWithIdentifier:_lcl_component_header[lcl_cMain] level:lcl_vCritical path:"path1" line:100 function:"function1" format:@"message after open, %d", 1];
    STAssertTrue([LCLLogFile size] > (size_t)0, nil);
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:oldPath], nil);
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:oldPath0], nil);
    
    // set path
    NSString* newPath = [oldPath stringByAppendingString:@"_new"];
    [LCLLogFile setPath:newPath];
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:oldPath], nil);
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:oldPath0], nil);
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:newPath], nil);
    
    // write log
    STAssertEquals([LCLLogFile size], (size_t)0, nil);
    [LCLLogFile logWithIdentifier:_lcl_component_header[lcl_cMain] level:lcl_vCritical path:"path1" line:100 function:"function1" format:@"message after open, %d", 1];
    STAssertTrue([LCLLogFile size] > (size_t)0, nil);
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:oldPath], nil);
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:oldPath0], nil);
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:newPath], nil);
}

@end

