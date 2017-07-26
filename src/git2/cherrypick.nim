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
##  @file git2/cherrypick.h
##  @brief Git cherry-pick routines
##  @defgroup git_cherrypick Git cherry-pick routines
##  @ingroup Git
##  @{
## 
## *
##  Cherry-pick options
## 

type
  git_cherrypick_options* {.bycopy.} = object
    version*: cuint            ## * For merge commits, the "mainline" is treated as the parent.
    mainline*: cuint
    merge_opts*: git_merge_options ## *< Options for the merging
    checkout_opts*: git_checkout_options ## *< Options for the checkout
  

const
  GIT_CHERRYPICK_OPTIONS_VERSION* = 1

## *
##  Initializes a `git_cherrypick_options` with default values. Equivalent to
##  creating an instance with GIT_CHERRYPICK_OPTIONS_INIT.
## 
##  @param opts the `git_cherrypick_options` struct to initialize
##  @param version Version of struct; pass `GIT_CHERRYPICK_OPTIONS_VERSION`
##  @return Zero on success; -1 on failure.
## 

proc git_cherrypick_init_options*(opts: ptr git_cherrypick_options; version: cuint): cint  {.importc.}
## *
##  Cherry-picks the given commit against the given "our" commit, producing an
##  index that reflects the result of the cherry-pick.
## 
##  The returned index must be freed explicitly with `git_index_free`.
## 
##  @param out pointer to store the index result in
##  @param repo the repository that contains the given commits
##  @param cherrypick_commit the commit to cherry-pick
##  @param our_commit the commit to revert against (eg, HEAD)
##  @param mainline the parent of the revert commit, if it is a merge
##  @param merge_options the merge options (or null for defaults)
##  @return zero on success, -1 on failure.
## 

proc git_cherrypick_commit*(`out`: ptr ptr git_index; repo: ptr git_repository; 
                           cherrypick_commit: ptr git_commit;
                           our_commit: ptr git_commit; mainline: cuint;
                           merge_options: ptr git_merge_options): cint
## *
##  Cherry-pick the given commit, producing changes in the index and working directory.
## 
##  @param repo the repository to cherry-pick
##  @param commit the commit to cherry-pick
##  @param cherrypick_options the cherry-pick options (or null for defaults)
##  @return zero on success, -1 on failure.
## 

proc git_cherrypick*(repo: ptr git_repository; commit: ptr git_commit; 
                    cherrypick_options: ptr git_cherrypick_options): cint {.importc.}
## * @}
