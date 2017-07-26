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
##  @file git2/revparse.h
##  @brief Git revision parsing routines
##  @defgroup git_revparse Git revision parsing routines
##  @ingroup Git
##  @{
## 
## *
##  Find a single object, as specified by a revision string.
## 
##  See `man gitrevisions`, or
##  http://git-scm.com/docs/git-rev-parse.html#_specifying_revisions for
##  information on the syntax accepted.
## 
##  The returned object should be released with `git_object_free` when no
##  longer needed.
## 
##  @param out pointer to output object
##  @param repo the repository to search in
##  @param spec the textual specification for an object
##  @return 0 on success, GIT_ENOTFOUND, GIT_EAMBIGUOUS, GIT_EINVALIDSPEC or an error code
## 

proc git_revparse_single*(`out`: ptr ptr git_object; repo: ptr git_repository; 
                         spec: cstring): cint {.importc.}
## *
##  Find a single object and intermediate reference by a revision string.
## 
##  See `man gitrevisions`, or
##  http://git-scm.com/docs/git-rev-parse.html#_specifying_revisions for
##  information on the syntax accepted.
## 
##  In some cases (`@{<-n>}` or `<branchname>@{upstream}`), the expression may
##  point to an intermediate reference. When such expressions are being passed
##  in, `reference_out` will be valued as well.
## 
##  The returned object should be released with `git_object_free` and the
##  returned reference with `git_reference_free` when no longer needed.
## 
##  @param object_out pointer to output object
##  @param reference_out pointer to output reference or NULL
##  @param repo the repository to search in
##  @param spec the textual specification for an object
##  @return 0 on success, GIT_ENOTFOUND, GIT_EAMBIGUOUS, GIT_EINVALIDSPEC
##  or an error code
## 

proc git_revparse_ext*(object_out: ptr ptr git_object; 
                      reference_out: ptr ptr git_reference;
                      repo: ptr git_repository; spec: cstring): cint {.importc.}
## *
##  Revparse flags.  These indicate the intended behavior of the spec passed to
##  git_revparse.
## 

type                          ## * The spec targeted a single object.
  git_revparse_mode_t* = enum
    GIT_REVPARSE_SINGLE = 1 shl 0, ## * The spec targeted a range of commits.
    GIT_REVPARSE_RANGE = 1 shl 1, ## * The spec used the '...' operator, which invokes special semantics.
    GIT_REVPARSE_MERGE_BASE = 1 shl 2


## *
##  Git Revision Spec: output of a `git_revparse` operation
## 

type
  git_revspec* {.bycopy.} = object
    `from`*: ptr git_object     ## * The left element of the revspec; must be freed by the user
    ## * The right element of the revspec; must be freed by the user
    to*: ptr git_object         ## * The intent of the revspec (i.e. `git_revparse_mode_t` flags)
    flags*: cuint


## *
##  Parse a revision string for `from`, `to`, and intent.
## 
##  See `man gitrevisions` or
##  http://git-scm.com/docs/git-rev-parse.html#_specifying_revisions for
##  information on the syntax accepted.
## 
##  @param revspec Pointer to an user-allocated git_revspec struct where
## 	              the result of the rev-parse will be stored
##  @param repo the repository to search in
##  @param spec the rev-parse spec to parse
##  @return 0 on success, GIT_INVALIDSPEC, GIT_ENOTFOUND, GIT_EAMBIGUOUS or an error code
## 

proc git_revparse*(revspec: ptr git_revspec; repo: ptr git_repository; spec: cstring): cint  {.importc.}
## * @}
