//
//
// LogFileTestsFrameworkTests.m
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
#import "Framework/LogFileTestsFramework.h"


@interface LogFileTestsFrameworkTests : SenTestCase {
    
}

@end


@implementation LogFileTestsFrameworkTests

- (void)setUp {
}

- (void)testFrameworkLogPaths {
    LogFileTestsFrameworkMain *frameworkMain = [LogFileTestsFrameworkMain sharedFrameworkMain];
    
    NSString *expectedPath = [NSTemporaryDirectory() stringByAppendingPathComponent:
                              @"Library/Logs/YourApplication/com.yourcompany.yourframework.log"];
    STAssertEqualObjects([frameworkMain loggerLogPath], expectedPath, nil);
    
    // we have a different log file path
    STAssertFalse([[LCLLogFile path] isEqualToString:expectedPath], nil);
}

- (void)testFrameworkLogging {
    // reset the application logger
    [LCLLogFile reset];
    
    // reset the framework logger
    LogFileTestsFrameworkMain *frameworkMain = [LogFileTestsFrameworkMain sharedFrameworkMain];
    [frameworkMain resetLogFile];
    
    // get the log paths
    NSString *frameworkLogPath = [frameworkMain loggerLogPath];
    NSString *applicationLogPath = [LCLLogFile path];
    
    // write some log messages
    lcl_configure_by_name("*", lcl_vError);
    lcl_log(lcl_cMain, lcl_vError, @"message 1 from application");
    [frameworkMain doSomething];
    lcl_log(lcl_cMain, lcl_vCritical, @"message 2 from application");
    [frameworkMain doSomething];
    
    // check application log file
    {
        NSString *currentLog = [NSString stringWithContentsOfFile:applicationLogPath encoding:NSUTF8StringEncoding error:NULL];
        NSArray *logLines = [currentLog componentsSeparatedByString:@"\n"];
        STAssertTrue(0 < [logLines count], nil);
        STAssertEquals([logLines count] - 1, (NSUInteger)2, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"E Main"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"message 1 from application"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:1] rangeOfString:@"C Main"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:1] rangeOfString:@"message 2 from application"].location, nil);
    }
    // check framework log file
    {
        NSString *currentLog = [NSString stringWithContentsOfFile:frameworkLogPath encoding:NSUTF8StringEncoding error:NULL];
        NSArray *logLines = [currentLog componentsSeparatedByString:@"\n"];
        STAssertTrue(0 < [logLines count], nil);
        STAssertEquals([logLines count] - 1, (NSUInteger)4, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"I Framework"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"message 1 from framework"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:1] rangeOfString:@"E Framework"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:1] rangeOfString:@"message 2 from framework"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:2] rangeOfString:@"I Framework"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:2] rangeOfString:@"message 1 from framework"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:3] rangeOfString:@"E Framework"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:3] rangeOfString:@"message 2 from framework"].location, nil);
    }
}

@end

