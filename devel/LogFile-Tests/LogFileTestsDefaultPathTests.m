//
//
// LogFileTestsDefaultPathTests.m
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


@interface LogFileTestsDefaultPathTests : SenTestCase {
    
}

@end


@implementation LogFileTestsDefaultPathTests

- (void)testDefaultPathComponentWithPathAndFileBundle {
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.yourcompany.yourapplication"];
    
    STAssertEqualObjects([LCLLogFile defaultPathComponentFromPathBundle:bundle fileBundle:bundle],
                         @"YourApplication/YourApplication.log", nil);
}

- (void)testDefaultPathComponentWithNilPathBundle {
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.yourcompany.yourapplication"];
    
    NSString *expectedPath = [NSString stringWithFormat:@"YourApplication/YourApplication.%u.log",
                              getpid()];
    STAssertEqualObjects([LCLLogFile defaultPathComponentFromPathBundle:nil fileBundle:bundle],
                         expectedPath, nil);
}

- (void)testDefaultPathComponentWithNilFileBundle {
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.yourcompany.yourapplication"];
    
    STAssertTrue([LCLLogFile defaultPathComponentFromPathBundle:bundle fileBundle:nil] == nil, nil);
}

- (void)testDefaultPathComponentWithNilBundles {
    STAssertTrue([LCLLogFile defaultPathComponentFromPathBundle:nil fileBundle:nil] == nil, nil);
}

- (void)testDefaultPathWithPathPrefixWithMainBundle {
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.yourcompany.yourapplication"];
    [NSBundle setMainBundle:bundle];
    
    NSString *expectedPath = @"prefix/YourApplication/YourApplication.log";
    STAssertEqualObjects([LCLLogFile defaultPathWithPathPrefix:@"prefix"], expectedPath, nil);
}

- (void)testDefaultPathWithPathPrefixWithoutPrefix {
    STAssertTrue([LCLLogFile defaultPathWithPathPrefix:nil] == nil, nil);
}

- (void)testDefaultPathInHomeLibraryLogsWithMainBundle {
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.yourcompany.yourapplication"];
    [NSBundle setMainBundle:bundle];
    
    NSString *expectedPath = [NSHomeDirectory() stringByAppendingPathComponent:
                              @"Library/Logs/YourApplication/YourApplication.log"];
    STAssertEqualObjects([LCLLogFile defaultPathInHomeLibraryLogs], expectedPath, nil);
}

- (void)testDefaultPathInHomeLibraryLogsWithFallbackForMainBundle {
    [NSBundle setMainBundle:nil];
    
    NSString *expectedPath = [NSHomeDirectory() stringByAppendingPathComponent:
                              [NSString stringWithFormat:@"Library/Logs/YourApplication/YourApplication.%u.log",
                               getpid()]];
    STAssertEqualObjects([LCLLogFile defaultPathInHomeLibraryLogs], expectedPath, nil);
}

@end

