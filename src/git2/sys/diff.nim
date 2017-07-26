## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 

import
  git2/common, git2/types, git2/oid, git2/diff, git2/status

## *
##  @file git2/sys/diff.h
##  @brief Low-level Git diff utilities
##  @ingroup Git
##  @{
## 
## *
##  Diff print callback that writes to a git_buf.
## 
##  This function is provided not for you to call it directly, but instead
##  so you can use it as a function pointer to the `git_diff_print` or
##  `git_patch_print` APIs.  When using those APIs, you specify a callback
##  to actually handle the diff and/or patch data.
## 
##  Use this callback to easily write that data to a `git_buf` buffer.  You
##  must pass a `git_buf *` value as the payload to the `git_diff_print`
##  and/or `git_patch_print` function.  The data will be appended to the
##  buffer (after any existing content).
## 

proc git_diff_print_callback__to_buf*(delta: ptr git_diff_delta; 
                                     hunk: ptr git_diff_hunk;
                                     line: ptr git_diff_line; payload: pointer): cint {.importc.}
## *< payload must be a `git_buf *`
## *
##  Diff print callback that writes to stdio FILE handle.
## 
##  This function is provided not for you to call it directly, but instead
##  so you can use it as a function pointer to the `git_diff_print` or
##  `git_patch_print` APIs.  When using those APIs, you specify a callback
##  to actually handle the diff and/or patch data.
## 
##  Use this callback to easily write that data to a stdio FILE handle.  You
##  must pass a `FILE *` value (such as `stdout` or `stderr` or the return
##  value from `fopen()`) as the payload to the `git_diff_print`
##  and/or `git_patch_print` function.  If you pass NULL, this will write
##  data to `stdout`.
## 

proc git_diff_print_callback__to_file_handle*(delta: ptr git_diff_delta; 
    hunk: ptr git_diff_hunk; line: ptr git_diff_line; payload: pointer): cint {.importc.}
## *< payload must be a `FILE *`
## *
##  Performance data from diffing
## 

type
  git_diff_perfdata* {.bycopy.} = object
    version*: cuint
    stat_calls*: csize         ## *< Number of stat() calls performed
    oid_calculations*: csize   ## *< Number of ID calculations
  

const
  GIT_DIFF_PERFDATA_VERSION* = 1

## *
##  Get performance data for a diff object.
## 
##  @param out Structure to be filled with diff performance data
##  @param diff Diff to read performance data from
##  @return 0 for success, <0 for error
## 

proc git_diff_get_perfdata*(`out`: ptr git_diff_perfdata; diff: ptr git_diff): cint  {.importc.}
## *
##  Get performance data for diffs from a git_status_list
## 

proc git_status_list_get_perfdata*(`out`: ptr git_diff_perfdata; 
                                  status: ptr git_status_list): cint {.importc.}
## * @}
