//
//
// LogFileTestsLoggerConfiguration.m
//
//
// Copyright (c) 2008-2013 Arne Harren <ah@0xc0.de>
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

#import "LogFileTestsLoggerConfiguration.h"


static NSString *LogFileTestsLoggerConfiguration_logFilePath = nil;
static BOOL LogFileTestsLoggerConfiguration_appendToExistingLogFile = NO;
static size_t LogFileTestsLoggerConfiguration_maxLogFileSizeInBytes = 0;
static BOOL LogFileTestsLoggerConfiguration_mirrorMessagesToStdErr = NO;
static BOOL LogFileTestsLoggerConfiguration_escapeLineFeeds = NO;
static BOOL LogFileTestsLoggerConfiguration_maxMessageSize = 0;
static BOOL LogFileTestsLoggerConfiguration_showFileNames = NO;
static BOOL LogFileTestsLoggerConfiguration_showLineNumbers = NO;
static BOOL LogFileTestsLoggerConfiguration_showFunctionNames = NO;

@implementation LogFileTestsLoggerConfiguration

+ (void)initialize {
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"LogFile-Tests.log"];
#   if !__has_feature(objc_arc)
    [LogFileTestsLoggerConfiguration_logFilePath release];
#   endif
    LogFileTestsLoggerConfiguration_logFilePath = [path copy];
    LogFileTestsLoggerConfiguration_appendToExistingLogFile = NO;
    LogFileTestsLoggerConfiguration_maxLogFileSizeInBytes = 0;
    LogFileTestsLoggerConfiguration_mirrorMessagesToStdErr = NO;
    LogFileTestsLoggerConfiguration_escapeLineFeeds = NO;
    LogFileTestsLoggerConfiguration_maxMessageSize = 0;
    LogFileTestsLoggerConfiguration_showFileNames = YES;
    LogFileTestsLoggerConfiguration_showLineNumbers = YES;
    LogFileTestsLoggerConfiguration_showFunctionNames = YES;
}

+ (NSString *)logFilePath {
    return LogFileTestsLoggerConfiguration_logFilePath;
}

+ (void)setLogFilePath:(NSString *)path {
#   if !__has_feature(objc_arc)
    [LogFileTestsLoggerConfiguration_logFilePath release];
#   endif
    LogFileTestsLoggerConfiguration_logFilePath = [path copy];
}

+ (BOOL)appendToExistingLogFile {
    return LogFileTestsLoggerConfiguration_appendToExistingLogFile;
}

+ (void)setAppendToExistingLogFile:(BOOL)append {
    LogFileTestsLoggerConfiguration_appendToExistingLogFile = append;
}

+ (size_t)maxLogFileSizeInBytes {
    return LogFileTestsLoggerConfiguration_maxLogFileSizeInBytes;
}

+ (void)setMaxLogFileSizeInBytes:(size_t)size {
    LogFileTestsLoggerConfiguration_maxLogFileSizeInBytes = size;
}

+ (BOOL)mirrorMessagesToStdErr {
    return LogFileTestsLoggerConfiguration_mirrorMessagesToStdErr;
}

+ (void)setMirrorMessagesToStdErr:(BOOL)mirror {
    LogFileTestsLoggerConfiguration_mirrorMessagesToStdErr = mirror;
}

+ (BOOL)maxMessageSize {
    return LogFileTestsLoggerConfiguration_maxMessageSize;
}

+ (void)setMaxMessageSize:(NSUInteger)size {
    LogFileTestsLoggerConfiguration_maxMessageSize = size;
}

+ (BOOL)escapeLineFeeds {
    return LogFileTestsLoggerConfiguration_escapeLineFeeds;
}

+ (void)setEscapeLineFeeds:(BOOL)escape {
    LogFileTestsLoggerConfiguration_escapeLineFeeds = escape;
}

+ (BOOL)showFileNames {
    return LogFileTestsLoggerConfiguration_showFileNames;
}

+ (void)setShowFileNames:(BOOL)show {
    LogFileTestsLoggerConfiguration_showFileNames = show;
}

+ (BOOL)showLineNumbers {
    return LogFileTestsLoggerConfiguration_showLineNumbers;
}

+ (void)setShowLineNumbers:(BOOL)show {
    LogFileTestsLoggerConfiguration_showLineNumbers = show;
}

+ (BOOL)showFunctionNames {
    return LogFileTestsLoggerConfiguration_showFunctionNames;
}

+ (void)setShowFunctionNames:(BOOL)show {
    LogFileTestsLoggerConfiguration_showFunctionNames = show;
}

@end

