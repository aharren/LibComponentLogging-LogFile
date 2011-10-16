//
//
// LogFileTestsInjections.m
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

#import "LogFileTestsInjections.h"


// ARC defines for non-ARC builds
#if !__has_feature(objc_arc)
#ifndef __bridge
#define __bridge
#endif
#endif


#undef CFStringGetFileSystemRepresentation

Boolean LogFileTestsInjections_CFStringGetFileSystemRepresentation(CFStringRef string, char *buffer, CFIndex maxBufLen) {
    if ([(__bridge NSString *)string isEqualToString:@"bad-file-path"]) {
        return false;
    }
    
    return CFStringGetFileSystemRepresentation(string, buffer, maxBufLen);
}


#undef mainBundle

static NSBundle *NSBundle_LogFileTestsInjections_mainBundle = nil;

@implementation NSBundle (LogFileTestsInjections)

+ (NSBundle *)LogFileTestsInjections_mainBundle {
    if (NSBundle_LogFileTestsInjections_mainBundle != nil) {
#       if !__has_feature(objc_arc)
        [[NSBundle_LogFileTestsInjections_mainBundle retain] autorelease];
#       endif
        return NSBundle_LogFileTestsInjections_mainBundle;
    }
    
    return [NSBundle mainBundle];
}

+ (void)setMainBundle:(NSBundle *)bundle {
#   if !__has_feature(objc_arc)
    [NSBundle_LogFileTestsInjections_mainBundle release];
    [bundle retain];
#   endif
    NSBundle_LogFileTestsInjections_mainBundle = bundle;
}

@end


#undef __LCLLogFile_stderr

FILE * LogFileTestsInjections_stderr = NULL;

__attribute__((constructor))
static void LogFileTestsInjections_stderr_initializer() {
    LogFileTestsInjections_stderr = stderr;
}

