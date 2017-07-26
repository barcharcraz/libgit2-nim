## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 

{.push dynlib: "libgit2".}
{.push callconv: cdecl.}
import
  common, types, buffer

## *
##  @file git2/describe.h
##  @brief Git describing routines
##  @defgroup git_describe Git describing routines
##  @ingroup Git
##  @{
## 
## *
##  Reference lookup strategy
## 
##  These behave like the --tags and --all optios to git-describe,
##  namely they say to look for any reference in either refs/tags/ or
##  refs/ respectively.
## 

type
  git_describe_strategy_t* = enum
    GIT_DESCRIBE_DEFAULT, GIT_DESCRIBE_TAGS, GIT_DESCRIBE_ALL


## *
##  Describe options structure
## 
##  Initialize with `GIT_DESCRIBE_OPTIONS_INIT` macro to correctly set
##  the `version` field.  E.g.
## 
## 		git_describe_options opts = GIT_DESCRIBE_OPTIONS_INIT;
## 

type
  git_describe_options* {.bycopy.} = object
    version*: cuint
    max_candidates_tags*: cuint ## *< default: 10
    describe_strategy*: cuint  ## *< default: GIT_DESCRIBE_DEFAULT
    pattern*: cstring ## *
                    ##  When calculating the distance from the matching tag or
                    ##  reference, only walk down the first-parent ancestry.
                    ## 
    only_follow_first_parent*: cint ## *
                                  ##  If no matching tag or reference is found, the describe
                                  ##  operation would normally fail. If this option is set, it
                                  ##  will instead fall back to showing the full id of the
                                  ##  commit.
                                  ## 
    show_commit_oid_as_fallback*: cint


const
  GIT_DESCRIBE_DEFAULT_MAX_CANDIDATES_TAGS* = 10
  GIT_DESCRIBE_DEFAULT_ABBREVIATED_SIZE* = 7
  GIT_DESCRIBE_OPTIONS_VERSION* = 1

proc git_describe_init_options*(opts: ptr git_describe_options; version: cuint): cint  {.importc.}
## *
##  Options for formatting the describe string
## 

type
  git_describe_format_options* {.bycopy.} = object
    version*: cuint ## *
                  ##  Size of the abbreviated commit id to use. This value is the
                  ##  lower bound for the length of the abbreviated string. The
                  ##  default is 7.
                  ## 
    abbreviated_size*: cuint ## *
                           ##  Set to use the long format even when a shorter name could be used.
                           ## 
    always_use_long_format*: cint ## *
                                ##  If the workdir is dirty and this is set, this string will
                                ##  be appended to the description string.
                                ## 
    dirty_suffix*: cstring


const
  GIT_DESCRIBE_FORMAT_OPTIONS_VERSION* = 1

proc git_describe_init_format_options*(opts: ptr git_describe_format_options; 
                                      version: cuint): cint {.importc.}
## *
##  A struct that stores the result of a describe operation.
## 


## *
##  Describe a commit
## 
##  Perform the describe operation on the given committish object.
## 
##  @param result pointer to store the result. You must free this once
##  you're done with it.
##  @param committish a committish to describe
##  @param opts the lookup options
## 

proc git_describe_commit*(result: ptr ptr git_describe_result; 
                         committish: ptr git_object; opts: ptr git_describe_options): cint {.importc.}
## *
##  Describe a commit
## 
##  Perform the describe operation on the current commit and the
##  worktree. After peforming describe on HEAD, a status is run and the
##  description is considered to be dirty if there are.
## 
##  @param out pointer to store the result. You must free this once
##  you're done with it.
##  @param repo the repository in which to perform the describe
##  @param opts the lookup options
## 

proc git_describe_workdir*(`out`: ptr ptr git_describe_result; 
                          repo: ptr git_repository; opts: ptr git_describe_options): cint {.importc.}
## *
##  Print the describe result to a buffer
## 
##  @param out The buffer to store the result
##  @param result the result from `git_describe_commit()` or
##  `git_describe_workdir()`.
##  @param opts the formatting options
## 

proc git_describe_format*(`out`: ptr git_buf; result: ptr git_describe_result; 
                         opts: ptr git_describe_format_options): cint {.importc.}
## *
##  Free the describe result.
## 

proc git_describe_result_free*(result: ptr git_describe_result)  {.importc.}
## * @}
