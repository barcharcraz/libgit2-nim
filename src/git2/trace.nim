## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 

{.push dynlib: "libgit2".}
{.push callconv: cdecl.}
import
  common, types

## *
##  @file git2/trace.h
##  @brief Git tracing configuration routines
##  @defgroup git_trace Git tracing configuration routines
##  @ingroup Git
##  @{
## 
## *
##  Available tracing levels.  When tracing is set to a particular level,
##  callers will be provided tracing at the given level and all lower levels.
## 

type                          ## * No tracing will be performed.
  git_trace_level_t* = enum
    GIT_TRACE_NONE = 0,         ## * Severe errors that may impact the program's execution
    GIT_TRACE_FATAL = 1,        ## * Errors that do not impact the program's execution
    GIT_TRACE_ERROR = 2,        ## * Warnings that suggest abnormal data
    GIT_TRACE_WARN = 3,         ## * Informational messages about program execution
    GIT_TRACE_INFO = 4,         ## * Detailed data that allows for debugging
    GIT_TRACE_DEBUG = 5,        ## * Exceptionally detailed debugging data
    GIT_TRACE_TRACE = 6


## *
##  An instance for a tracing function
## 

type
  git_trace_callback* = proc (level: git_trace_level_t; msg: cstring) 

## *
##  Sets the system tracing configuration to the specified level with the
##  specified callback.  When system events occur at a level equal to, or
##  lower than, the given level they will be reported to the given callback.
## 
##  @param level Level to set tracing to
##  @param cb Function to call with trace data
##  @return 0 or an error code
## 

proc git_trace_set*(level: git_trace_level_t; cb: git_trace_callback): cint  {.importc.}
## * @}
