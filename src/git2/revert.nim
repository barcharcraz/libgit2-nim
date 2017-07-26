## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 

{.push dynlib: "libgit2".}
{.push callconv: cdecl.}
import
  common, types, merge, checkout

## *
##  @file git2/revert.h
##  @brief Git revert routines
##  @defgroup git_revert Git revert routines
##  @ingroup Git
##  @{
## 
## *
##  Options for revert
## 

type
  git_revert_options* {.bycopy.} = object
    version*: cuint            ## * For merge commits, the "mainline" is treated as the parent.
    mainline*: cuint
    merge_opts*: git_merge_options ## *< Options for the merging
    checkout_opts*: git_checkout_options ## *< Options for the checkout
  

const
  GIT_REVERT_OPTIONS_VERSION* = 1

## *
##  Initializes a `git_revert_options` with default values. Equivalent to
##  creating an instance with GIT_REVERT_OPTIONS_INIT.
## 
##  @param opts the `git_revert_options` struct to initialize
##  @param version Version of struct; pass `GIT_REVERT_OPTIONS_VERSION`
##  @return Zero on success; -1 on failure.
## 

proc git_revert_init_options*(opts: ptr git_revert_options; version: cuint): cint  {.importc.}
## *
##  Reverts the given commit against the given "our" commit, producing an
##  index that reflects the result of the revert.
## 
##  The returned index must be freed explicitly with `git_index_free`.
## 
##  @param out pointer to store the index result in
##  @param repo the repository that contains the given commits
##  @param revert_commit the commit to revert
##  @param our_commit the commit to revert against (eg, HEAD)
##  @param mainline the parent of the revert commit, if it is a merge
##  @param merge_options the merge options (or null for defaults)
##  @return zero on success, -1 on failure.
## 

proc git_revert_commit*(`out`: ptr ptr git_index; repo: ptr git_repository; 
                       revert_commit: ptr git_commit; our_commit: ptr git_commit;
                       mainline: cuint; merge_options: ptr git_merge_options): cint {.importc.}
## *
##  Reverts the given commit, producing changes in the index and working directory.
## 
##  @param repo the repository to revert
##  @param commit the commit to revert
##  @param given_opts the revert options (or null for defaults)
##  @return zero on success, -1 on failure.
## 

proc git_revert*(repo: ptr git_repository; commit: ptr git_commit; 
                given_opts: ptr git_revert_options): cint {.importc.}
## * @}
