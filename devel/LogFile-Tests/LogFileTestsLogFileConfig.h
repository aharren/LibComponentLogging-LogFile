//
//
// LogFileTestsLogFileConfig.h
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


// Rename the LCLLogFile class by adding your application/framework's unique
// prefix in order to avoid duplicate symbols in the global class namespace.
#define LCLLogFile                                                             \
    LogFileTestsLCLLogFile

// Tell LCLLogFile the path of the log file as an NSString.
#define _LCLLogFile_LogFilePath /* (NSString *) */                             \
    [LogFileTestsLoggerConfiguration logFilePath]

// Tell LCLLogFile whether it should append to an existing log file on startup,
// instead of creating a new log file.
#define _LCLLogFile_AppendToExistingLogFile /* (BOOL) */                       \
    [LogFileTestsLoggerConfiguration appendToExistingLogFile]

// Tell LCLLogFile the maximum size of a log file in bytes.
#define _LCLLogFile_MaxLogFileSizeInBytes /* (size_t) */                       \
    [LogFileTestsLoggerConfiguration maxLogFileSizeInBytes]

// Tell LCLLogFile whether it should mirror the log messages to stderr.
#define _LCLLogFile_MirrorMessagesToStdErr /* (BOOL) */                        \
    [LogFileTestsLoggerConfiguration mirrorMessagesToStdErr]

// Tell LCLLogFile whether it should escape special characters.
#define _LCLLogFile_EscapeSpecialCharacters /* BOOL */                         \
    [LogFileTestsLoggerConfiguration escapeSpecialCharacters]

// Tell LCLLogFile the maximum size of a log message in characters.
#define _LCLLogFile_MaxMessageSizeInCharacters /* NSUInteger */                \
    [LogFileTestsLoggerConfiguration maxMessageSize]

// Tell LCLLogFile whether it should show file names.
#define _LCLLogFile_ShowFileNames /* (BOOL) */                                 \
    [LogFileTestsLoggerConfiguration showFileNames]

// Tell LCLLogFile whether it should show line numbers.
#define _LCLLogFile_ShowLineNumbers /* (BOOL) */                               \
    [LogFileTestsLoggerConfiguration showLineNumbers]

// Tell LCLLogFile whether it should show function names.
#define _LCLLogFile_ShowFunctionNames /* (BOOL) */                             \
    [LogFileTestsLoggerConfiguration showFunctionNames]


// LogFileTestsLoggerConfiguration holds the configuration data.
#import "LogFileTestsLoggerConfiguration.h"


// Override some global symbols for testing.
#import "LogFileTestsInjections.h"

