//
//
// LogFileTestsFrameworkMain.m
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
#import "LogFileTestsFrameworkMain.h"


static LogFileTestsFrameworkMain *LogFileTestsFrameworkMain_sharedFrameworkMain = nil;

@implementation LogFileTestsFrameworkMain

// Initialize the class.
+ (void)initialize {
    // perform initialization only once
    if (self != [LogFileTestsFrameworkMain class])
        return;
    
    // create the shared instance
    LogFileTestsFrameworkMain_sharedFrameworkMain = [[LogFileTestsFrameworkMain alloc] init];
    
    // set log level for all components
    lcl_configure_by_name("*", lcl_vInfo);
}

// Returns the path of the framework's internal log file.
- (NSString *)loggerLogPath {
    return [LCLLogFile path];
}

// Resets the framework's internal log file.
- (void)resetLogFile {
    [LCLLogFile reset];
}

// Does something in the framework which also writes some messages to the
// framework's log file.
- (void)doSomething {
    // do something
    // ...
    lcl_log(lcl_cFramework, lcl_vInfo, @"message 1 from framework");
    
    // do something
    // ...
    lcl_log(lcl_cFramework, lcl_vError, @"message 2 from framework");
}

// Returns the shared instance.
+ (LogFileTestsFrameworkMain *)sharedFrameworkMain {
    return LogFileTestsFrameworkMain_sharedFrameworkMain;
}

@end

