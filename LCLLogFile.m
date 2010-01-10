//
//
// LCLLogFile.m
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

#ifndef _LCLLogFile_LogFilePath
#error  '_LCLLogFile_LogFilePath' must be defined in 'lcl_config_logger.h'
#endif

#ifndef _LCLLogFile_AppendToExistingLogFile
#error  '_LCLLogFile_AppendToExistingLogFile' must be defined in 'lcl_config_logger.h'
#endif

#ifndef _LCLLogFile_MaxLogFileSizeInBytes
#error  '_LCLLogFile_MaxLogFileSizeInBytes' must be defined in 'lcl_config_logger.h'
#endif

#ifndef _LCLLogFile_MirrorMessagesToStdErr
#error  '_LCLLogFile_MirrorMessagesToStdErr' must be defined in 'lcl_config_logger.h'
#endif

#ifndef _LCLLogFile_ShowFileNames
#error  '_LCLLogFile_ShowFileNames' must be defined in 'lcl_config_logger.h'
#endif

#ifndef _LCLLogFile_ShowLineNumbers
#error  '_LCLLogFile_ShowLineNumbers' must be defined in 'lcl_config_logger.h'
#endif

#ifndef _LCLLogFile_ShowFunctionNames
#error  '_LCLLogFile_ShowFunctionNames' must be defined in 'lcl_config_logger.h'
#endif

#include <unistd.h>
#include <mach/mach_init.h>
#include <sys/time.h>
#include <sys/stat.h>


@interface LCLLogFile (Internals)

// Initializes the class.
+ (void)initialize;

@end


// A lock which is held when the log file is used, opened, etc.
static NSRecursiveLock *_LCLLogFile_lock = nil;

// A handle to the current log file, if opened.
static volatile FILE *_LCLLogFile_fileHandle = NULL;

// YES, if logging is active.
static volatile BOOL _LCLLogFile_isActive = NO;

// YES, if log messages should be appended to an existing log file.
static BOOL _LCLLogFile_appendToExistingLogFile = NO;

// YES, if log messages should be mirrored to stderr.
static BOOL _LCLLogFile_mirrorToStdErr = NO;

// YES, if the file name should be shown.
static BOOL _LCLLogFile_showFileName = NO;

// YES, if the line number should be shown.
static BOOL _LCLLogFile_showLineNumber = NO;

// YES, if the function name should be shown.
static BOOL _LCLLogFile_showFunctionName = NO;

// Max size of log file.
static size_t _LCLLogFile_fileSizeMax = 0;

// Current size of log file.
static size_t _LCLLogFile_fileSize = 0;

// Paths of log files.
static NSString *_LCLLogFile_filePath = nil;
static const char *_LCLLogFile_filePath_c = NULL;
static NSString *_LCLLogFile_filePath0 = nil;
static const char *_LCLLogFile_filePath0_c = NULL;

// The process id.
static pid_t _LCLLogFile_processId = 0;


@implementation LCLLogFile

// No instances, please.
+(id)alloc {
    [LCLLogFile doesNotRecognizeSelector:_cmd];
    return nil;
}

// Initializes the class.
+ (void)initialize {
    // perform initialization only once
    if (self != [LCLLogFile class])
        return;
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // create the lock
    _LCLLogFile_lock = [[NSRecursiveLock alloc] init];
    
    // get the process id
    _LCLLogFile_processId = getpid();
    
    // get the max file size, at least 4k
    _LCLLogFile_fileSizeMax = (_LCLLogFile_MaxLogFileSizeInBytes);
    if (_LCLLogFile_fileSizeMax < 4 * 1024) {
        _LCLLogFile_fileSizeMax = 4 * 1024;
    }
    
    // get whether we should append to an existing log file
    _LCLLogFile_appendToExistingLogFile = (_LCLLogFile_AppendToExistingLogFile);
    
    // get whether we should mirror log messages to stderr
    _LCLLogFile_mirrorToStdErr = (_LCLLogFile_MirrorMessagesToStdErr);

    // get whether we should show file names
    _LCLLogFile_showFileName = (_LCLLogFile_ShowFileNames);

    // get whether we should show line numbers
    _LCLLogFile_showLineNumber = (_LCLLogFile_ShowLineNumbers);
    
    // get whether we should show function names
    _LCLLogFile_showFunctionName = (_LCLLogFile_ShowFunctionNames);

    // get the full path of the log file
    NSString *path = (_LCLLogFile_LogFilePath);
    path = [path stringByStandardizingPath];
    
    // create parent paths for the log file
    NSString *parentpath = [path stringByDeletingLastPathComponent];
    [[NSFileManager defaultManager] createDirectoryAtPath:parentpath
                              withIntermediateDirectories:YES 
                                               attributes:nil
                                                    error:NULL];
    
    // create local copies of the log file paths
    _LCLLogFile_filePath = [path copy];
    _LCLLogFile_filePath_c = strdup([_LCLLogFile_filePath fileSystemRepresentation]);
    _LCLLogFile_filePath0 = [[path stringByAppendingString:@".0"] copy];
    _LCLLogFile_filePath0_c = strdup([_LCLLogFile_filePath0 fileSystemRepresentation]);
    
    // log file size is zero
    _LCLLogFile_fileSize = 0;
    
    [pool release];
}

// Returns the path of the log file.
+ (NSString *)path {
    return _LCLLogFile_filePath;
}

// Returns the path of the backup log file.
+ (NSString *)path0 {
    return _LCLLogFile_filePath0;
}

// Opens the log file.
+ (void)open {
    [_LCLLogFile_lock lock];
    {
        if (_LCLLogFile_fileHandle == NULL) {
            // size of log file is 0
            _LCLLogFile_fileSize = 0;
            
            if (_LCLLogFile_isActive || !_LCLLogFile_appendToExistingLogFile) {
                // create a new log file
                _LCLLogFile_fileHandle = fopen(_LCLLogFile_filePath_c, "w");
            } else {
                // append to existing log file, get size from file
                _LCLLogFile_fileHandle = fopen(_LCLLogFile_filePath_c, "a");
                
                // try to get size of existing log file
                struct stat stat_c;
                if (stat(_LCLLogFile_filePath_c, &stat_c) == 0) {
                    _LCLLogFile_fileSize = (size_t)stat_c.st_size;
                }
            }
            
            // logging is active
            _LCLLogFile_isActive = YES;
        }
    }
    [_LCLLogFile_lock unlock];
}

// Closes the log file.
+ (void)close {
    [_LCLLogFile_lock lock];
    {
        // close the log file
        FILE *filehandle = (FILE *)_LCLLogFile_fileHandle;
        if (filehandle != NULL) {
            fclose(filehandle);
            _LCLLogFile_fileHandle = NULL;
        }
        
        // log file size is zero
        _LCLLogFile_fileSize = 0;
    }
    [_LCLLogFile_lock unlock];
}

// Resets the log file.
+ (void)reset {
    [_LCLLogFile_lock lock];
    {
        // close the log file
        [LCLLogFile close];
        
        // unlink existing log files
        unlink(_LCLLogFile_filePath_c);
        unlink(_LCLLogFile_filePath0_c);
        
        // logging is not active
        _LCLLogFile_isActive = NO;
        
    }
    [_LCLLogFile_lock unlock];
}

// Rotates the log file.
+ (void)rotate {
    [_LCLLogFile_lock lock];
    {
        // close the log file
        [LCLLogFile close];
        
        // keep a copy of the current log file
        rename(_LCLLogFile_filePath_c, _LCLLogFile_filePath0_c);
    }
    [_LCLLogFile_lock unlock];
}

// Returns the current size of the log file.
+ (size_t)size {
    size_t sz = 0;
    [_LCLLogFile_lock lock];
    {
        // get the size
        sz = _LCLLogFile_fileSize;
    }
    [_LCLLogFile_lock unlock];
    return sz;
}

// Returns the maximum size of the log file.
+ (size_t)maxSize {
    return _LCLLogFile_fileSizeMax;
}

// Returns whether log messages get appended to an existing log file on startup.
+ (BOOL)appendsToExistingLogFile {
    return _LCLLogFile_appendToExistingLogFile;
}

// Returns whether log messages are mirrored to stderr.
+ (BOOL)mirrorsToStdErr {
    return _LCLLogFile_mirrorToStdErr;
}

// Returns whether file names are shown.
+ (BOOL)showsFileNames {
    return _LCLLogFile_showFileName;
}

// Returns whether line numbers are shown.
+ (BOOL)showsLineNumbers {
    return _LCLLogFile_showLineNumber;
}

// Returns whether function names are shown.
+ (BOOL)showsFunctionNames {
    return _LCLLogFile_showFunctionName;
}

// Returns the version of LCLLogFile.
+ (NSString *)version {
#define __lcl_version_to_string( _text) __lcl_version_to_string0(_text)
#define __lcl_version_to_string0(_text) #_text
    return @__lcl_version_to_string(_LCLLOGFILE_VERSION_MAJOR) 
        "." __lcl_version_to_string(_LCLLOGFILE_VERSION_MINOR)
        "." __lcl_version_to_string(_LCLLOGFILE_VERSION_BUILD);
}

// Writes the given log message to the log file (checked).
+ (void)logWithComponent:(_lcl_component_t)component level:(_lcl_level_t)level
                    path:(const char *)path line:(uint32_t)line
                function:(const char *)function
                  format:(NSString *)format, ... {
    // open the log file
    if (!_LCLLogFile_isActive) {
        [LCLLogFile open];
    }
    
    // write log message if the log file is opened
    if (_LCLLogFile_fileHandle) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        // variables for current time
        struct timeval now;
        struct tm now_tm;
        char time_c[24];        
        
        // get file from path
        const char *file_c = "";
        if (_LCLLogFile_showFileName) {
            file_c = path != NULL ? strrchr(path, '/') : NULL;
            file_c = (file_c != NULL) ? (file_c + 1) : (path);
        }
        
        // get line
        char line_c[11];
        if (_LCLLogFile_showLineNumber) {
            snprintf(line_c, sizeof(line_c), "%u", line);
            line_c[sizeof(line_c) - 1] = '\0';
        } else {
            line_c[0] = '\0';
        }
        
        // create prefix
        NSString *prefix = [NSString stringWithFormat:@" %u:%x %s %s%s%s%s%s%s%s ",
                            _LCLLogFile_processId,
                            mach_thread_self(),
                            _lcl_level_header_1[level],
                            _lcl_component_header[component],
                            _LCLLogFile_showFileName ? ":" : "",
                            file_c,
                            _LCLLogFile_showLineNumber ? ":" : "",
                            line_c,
                            _LCLLogFile_showFunctionName ? ":" : "",
                            _LCLLogFile_showFunctionName ? function : ""];
        
        // create log message
        va_list args;
        va_start(args, format);
        NSString *message = [[[NSString alloc] initWithFormat:format arguments:args] autorelease];
        va_end(args);
        
        // create C strings
        const char *message_c = [message UTF8String];
        const char *prefix_c = [prefix UTF8String];
        
        // get size of log entry
        const int backslash_n_len = 1;
        size_t entry_len = sizeof(time_c) + strlen(prefix_c) + strlen(message_c) + backslash_n_len;
        
        // under lock protection ...
        [_LCLLogFile_lock lock];
        {
            FILE *filehandle = (FILE *)_LCLLogFile_fileHandle;
            
            // rotate the log file if required
            if (filehandle) {
                if (_LCLLogFile_fileSize + entry_len > _LCLLogFile_fileSizeMax) {
                    [LCLLogFile rotate];
                    [LCLLogFile open];
                    filehandle = (FILE *)_LCLLogFile_fileHandle;
                }
            }
            
            // write the log message 
            if (filehandle) {
                // increase file size
                _LCLLogFile_fileSize += entry_len;
                
                // get current time
                gettimeofday(&now, NULL);
                localtime_r(&now.tv_sec, &now_tm);
                snprintf(time_c, sizeof(time_c), "%04d-%02d-%02d %02d:%02d:%02d.%03d", 
                         now_tm.tm_year + 1900,
                         now_tm.tm_mon + 1,
                         now_tm.tm_mday,
                         now_tm.tm_hour,
                         now_tm.tm_min,
                         now_tm.tm_sec,
                         now.tv_usec / 1000);
                
                // write current time and log message
                fprintf(filehandle, "%s%s%s\n", time_c, prefix_c, message_c);
                
                // flush the file
                fflush(filehandle);
            }
            
            // mirror to stderr?
            if (_LCLLogFile_mirrorToStdErr) {
                fprintf(stderr, "%s%s%s\n", time_c, prefix_c, message_c);
            }
        }
        // ... done
        [_LCLLogFile_lock unlock];
        
        [pool release];
    }
}

@end
