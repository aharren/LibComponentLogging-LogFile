# LibComponentLogging-LogFile

[http://0xc0.de/LibComponentLogging](http://0xc0.de/LibComponentLogging)    
[http://github.com/aharren/LibComponentLogging-LogFile](http://github.com/aharren/LibComponentLogging-LogFile)

## Overview

LibComponentLogging-LogFile is a file logging class for Objective-C (Mac OS X
and iPhone OS) which writes log messages to an application-specific log file.

The application's log file is opened automatically when the first log message
needs to be written to the log file. If the log file reaches a configured
maximum size, it gets rotated and all previous messages will be moved to a
backup log file. The backup log file is kept until the next rotation.

The logging class can be used as a logging back-end for LibComponentLogging,
but it can also be used as a standalone logger without the Core files of
LibComponentLogging.

The LogFile logger uses the format

    <date> <time> <pid>:<tid> <level> <component>:<file>:<line>:<function> <message>

where the file name, the line number and the function name are optional.

Example:

    2009-02-01 12:38:32.796 4964:10b D component1:main.m:28:-[Class method] Message
    2009-02-01 12:38:32.798 4964:10b D component2:main.m:32:-[Class method] Message
    2009-02-01 12:38:32.799 4964:10b D component3:main.m:36:-[Class method] Message

## Repository Branches

The Git repository contains the following branches:

* *master*: The *master* branch contains stable builds of the main logging code
  which are tagged with version numbers.

* *devel*: The *devel* branch is the development branch for the logging code
  which contains an Xcode project with dependent code, e.g. the Core files of
  LibComponentLogging, and unit tests. The code in this branch is not stable.

## Related Repositories

The following Git repositories are related to this repository: 

* [http://github.com/aharren/LibComponentLogging-Core](http://github.com/aharren/LibComponentLogging-Core):
  Core files of LibComponentLogging.

* [http://github.com/aharren/LibComponentLogging-LogFile-Example](http://github.com/aharren/LibComponentLogging-LogFile-Example):
  An example Xcode project which uses the LibComponentLogging-LogFile logger.
