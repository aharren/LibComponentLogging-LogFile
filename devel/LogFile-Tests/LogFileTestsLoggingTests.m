//
//
// LogFileTestsLoggingTests.m
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


@interface LogFileTestsLoggingTests : SenTestCase {
    
}

@end


@implementation LogFileTestsLoggingTests

- (void)setUp {
    // configure the logger
    [LogFileTestsLoggerConfiguration initialize];
    [LogFileTestsLoggerConfiguration setAppendToExistingLogFile:NO];
    [LogFileTestsLoggerConfiguration setMirrorMessagesToStdErr:NO];
    [LCLLogFile initialize];
    
    // reset log file
    [LCLLogFile reset];
    STAssertEquals([LCLLogFile size], (size_t)0, nil);
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path]], nil);
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path0]], nil);
    
    // create existing log file
    [@"content of existing log file\n" writeToFile:[LCLLogFile path] atomically:NO encoding:NSUTF8StringEncoding error:NULL];
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path]], nil);
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path0]], nil);
    STAssertEqualObjects([NSString stringWithContentsOfFile:[LCLLogFile path] encoding:NSUTF8StringEncoding error:NULL], @"content of existing log file\n", nil);
    
    // enable logging for component Main
    lcl_configure_by_name("*", lcl_vOff);
    lcl_configure_by_component(lcl_cMain, lcl_vDebug);
}

- (void)testLoggingWithExplicitOpenAndClose {
    STAssertEquals([LCLLogFile appendsToExistingLogFile], NO, @"precondition");
    
    // open log file manually
    [LCLLogFile open];
    STAssertEquals([LCLLogFile size], (size_t)0, nil);
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path]], nil);
    STAssertEqualObjects([NSString stringWithContentsOfFile:[LCLLogFile path] encoding:NSUTF8StringEncoding error:NULL], @"", nil);
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path0]], nil);
    
    // write log entry
    [LCLLogFile logWithIdentifier:_lcl_component_header[lcl_cMain] level:lcl_vCritical path:"path1" line:100 function:"function1" format:@"message after open, %d", 1];
    STAssertTrue(0 < [LCLLogFile size], nil);
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path]], nil);
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path0]], nil);
    
    // check log file
    NSString *firstLog = nil;
    {
        NSString *currentLog = [NSString stringWithContentsOfFile:[LCLLogFile path] encoding:NSUTF8StringEncoding error:NULL];
        NSArray *logLines = [currentLog componentsSeparatedByString:@"\n"];
        STAssertTrue(0 < [logLines count], nil);
        STAssertEquals([logLines count] - 1, (NSUInteger)1, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"C Main"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"path1"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"100"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"function1"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"message after open, 1"].location, nil);
        
        firstLog = currentLog;
    }
    
    // close log file manually
    [LCLLogFile close];
    STAssertEquals([LCLLogFile size], (size_t)0, nil);
    
    // check log file (unchanged)
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path]], nil);
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path0]], nil);
    STAssertEqualObjects([NSString stringWithContentsOfFile:[LCLLogFile path] encoding:NSUTF8StringEncoding error:NULL], firstLog, nil);
    
    // write log entry (not written)
    [LCLLogFile logWithIdentifier:_lcl_component_header[lcl_cMain] level:lcl_vCritical path:"path2" line:200 function:"function2" format:@"message after close, %d", 2];
    STAssertEquals([LCLLogFile size], (size_t)0, nil);
    
    // check log file (unchanged)
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path]], nil);
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path0]], nil);    
    STAssertEqualObjects([NSString stringWithContentsOfFile:[LCLLogFile path] encoding:NSUTF8StringEncoding error:NULL], firstLog, nil);
}

- (void)testLoggingWithAutomaticOpen {
    STAssertEquals([LCLLogFile appendsToExistingLogFile], NO, @"precondition");
    
    // write log entry
    [LCLLogFile logWithIdentifier:_lcl_component_header[lcl_cMain] level:lcl_vCritical path:"path3" line:300 function:"function3" format:@"message after automatic open, %d", 1];
    STAssertTrue(0 < [LCLLogFile size], nil);
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path]], nil);
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path0]], nil);
    
    // check log file
    {
        NSString *currentLog = [NSString stringWithContentsOfFile:[LCLLogFile path] encoding:NSUTF8StringEncoding error:NULL];
        NSArray *logLines = [currentLog componentsSeparatedByString:@"\n"];
        STAssertTrue(0 < [logLines count], nil);
        STAssertEquals([logLines count] - 1, (NSUInteger)1, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"C Main"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"path3"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"300"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"function3"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"message after automatic open, 1"].location, nil);
    }
}

- (void)testLoggingWithLogMacro {
    STAssertEquals([LCLLogFile appendsToExistingLogFile], NO, @"precondition");
    
    lcl_log(lcl_cMain, lcl_vInfo, @"message with macro, %d", 1);
    STAssertTrue(0 < [LCLLogFile size], nil);
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path]], nil);
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path0]], nil);
    
    // check log file
    {
        NSString *currentLog = [NSString stringWithContentsOfFile:[LCLLogFile path] encoding:NSUTF8StringEncoding error:NULL];
        NSArray *logLines = [currentLog componentsSeparatedByString:@"\n"];
        STAssertTrue(0 < [logLines count], nil);
        STAssertEquals([logLines count] - 1, (NSUInteger)1, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"I Main"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"LogFileTestsLoggingTests.m"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"140"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"-[LogFileTestsLoggingTests testLoggingWithLogMacro]"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"message with macro, 1"].location, nil);
    }
}

- (void)testLoggingWithVarArgsLogMethod {
    STAssertEquals([LCLLogFile appendsToExistingLogFile], NO, @"precondition");
    
    [LCLLogFile logWithIdentifier:"Main" level:lcl_vInfo path:"path" line:100 function:"function" format:@"format %d %@", 1, @"message"];
    
    // check log file
    {
        NSString *currentLog = [NSString stringWithContentsOfFile:[LCLLogFile path] encoding:NSUTF8StringEncoding error:NULL];
        NSArray *logLines = [currentLog componentsSeparatedByString:@"\n"];
        STAssertTrue(0 < [logLines count], nil);
        STAssertEquals([logLines count] - 1, (NSUInteger)1, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"I Main"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"path"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"100"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"function"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"format 1 message"].location, nil);
    }
}

- (void)loggingWithVaListVarArgsLogMethodHelper:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    [LCLLogFile logWithIdentifier:"Main" level:lcl_vInfo path:"path" line:200 function:"function" format:format args:args];
    va_end(args);
}

- (void)testLoggingWithVaListVarArgsLogMethod {
    STAssertEquals([LCLLogFile appendsToExistingLogFile], NO, @"precondition");
    
    [self loggingWithVaListVarArgsLogMethodHelper:@"message %d %@ %d", 2, @"abc", 3];
    
    // check log file
    {
        NSString *currentLog = [NSString stringWithContentsOfFile:[LCLLogFile path] encoding:NSUTF8StringEncoding error:NULL];
        NSArray *logLines = [currentLog componentsSeparatedByString:@"\n"];
        STAssertTrue(0 < [logLines count], nil);
        STAssertEquals([logLines count] - 1, (NSUInteger)1, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"I Main"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"path"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"200"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"function"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"message 2 abc 3"].location, nil);
    }
}

- (void)testLoggingWithMessage {
    STAssertEquals([LCLLogFile appendsToExistingLogFile], NO, @"precondition");
    
    [LCLLogFile logWithIdentifier:"Main" level:lcl_vInfo path:"path" line:300 function:"function" message:@"message %d %@"];
    
    // check log file
    {
        NSString *currentLog = [NSString stringWithContentsOfFile:[LCLLogFile path] encoding:NSUTF8StringEncoding error:NULL];
        NSArray *logLines = [currentLog componentsSeparatedByString:@"\n"];
        STAssertTrue(0 < [logLines count], nil);
        STAssertEquals([logLines count] - 1, (NSUInteger)1, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"I Main"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"path"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"300"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"function"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:0] rangeOfString:@"message %d %@"].location, nil);
    }
}

- (void)testLoggingWithAppendToExistingFile {
    // re-configure the logger
    [LogFileTestsLoggerConfiguration initialize];
    [LogFileTestsLoggerConfiguration setAppendToExistingLogFile:YES];
    [LCLLogFile initialize];
    
    STAssertEquals([LCLLogFile appendsToExistingLogFile], YES, @"precondition");
    
    // open log file manually
    [LCLLogFile open];
    STAssertEquals([LCLLogFile size], (size_t)29, nil);
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path]], nil);
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path0]], nil);
    
    // write log entry
    lcl_log(lcl_cMain, lcl_vInfo, @"message with append");
    STAssertTrue(29 < [LCLLogFile size], nil);
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path]], nil);
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path0]], nil);
    
    // check log file
    {
        NSString *currentLog = [NSString stringWithContentsOfFile:[LCLLogFile path] encoding:NSUTF8StringEncoding error:NULL];
        NSArray *logLines = [currentLog componentsSeparatedByString:@"\n"];
        STAssertTrue(0 < [logLines count], nil);
        STAssertEquals([logLines count] - 1, (NSUInteger)2, nil);
        STAssertEqualObjects([logLines objectAtIndex:0], @"content of existing log file", nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:1] rangeOfString:@"I Main"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:1] rangeOfString:@"message with append"].location, nil);
    }
}

- (void)testLoggingWithAppendToExistingFileWithReconfiguration {
    // re-configure the logger
    [LogFileTestsLoggerConfiguration initialize];
    [LogFileTestsLoggerConfiguration setAppendToExistingLogFile:NO];
    [LCLLogFile initialize];
    
    STAssertEquals([LCLLogFile appendsToExistingLogFile], NO, @"precondition");
    
    [LCLLogFile setAppendsToExistingLogFile:YES];
    
    STAssertEquals([LCLLogFile appendsToExistingLogFile], YES, @"precondition");
    
    // open log file manually
    [LCLLogFile open];
    STAssertEquals([LCLLogFile size], (size_t)29, nil);
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path]], nil);
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path0]], nil);
    
    // write log entry
    lcl_log(lcl_cMain, lcl_vInfo, @"message with append");
    STAssertTrue(29 < [LCLLogFile size], nil);
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path]], nil);
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:[LCLLogFile path0]], nil);
    
    // check log file
    {
        NSString *currentLog = [NSString stringWithContentsOfFile:[LCLLogFile path] encoding:NSUTF8StringEncoding error:NULL];
        NSArray *logLines = [currentLog componentsSeparatedByString:@"\n"];
        STAssertTrue(0 < [logLines count], nil);
        STAssertEquals([logLines count] - 1, (NSUInteger)2, nil);
        STAssertEqualObjects([logLines objectAtIndex:0], @"content of existing log file", nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:1] rangeOfString:@"I Main"].location, nil);
        STAssertTrue(NSNotFound != [[logLines objectAtIndex:1] rangeOfString:@"message with append"].location, nil);
    }
}

- (void)testLoggingWithShadowedLocalVariable {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    lcl_log(lcl_cMain, lcl_vCritical, @"message");
    
    [pool release];
}

@end

