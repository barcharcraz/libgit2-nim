## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 
{.push importc.}
{.push dynlib: "libgit2".}
import
  common

## *
##  @file git2/errors.h
##  @brief Git error handling routines and variables
##  @ingroup Git
##  @{
## 
## * Generic return codes

type
  git_error_code* = enum
    GIT_EMISMATCH = - 33,        ## *< Hashsum mismatch in object
    GIT_RETRY = - 32,            ## *< Internal only
    GIT_ITEROVER = - 31,         ## *< Signals end of iteration with iterator
    GIT_PASSTHROUGH = - 30,      ## *< Internal only
    GIT_EMERGECONFLICT = - 24,   ## *< A merge conflict exists and cannot continue
    GIT_EDIRECTORY = - 23,       ## *< The operation is not valid for a directory
    GIT_EUNCOMMITTED = - 22,     ## *< Uncommitted changes in index prevented operation
    GIT_EINVALID = - 21,         ## *< Invalid operation or input
    GIT_EEOF = - 20,             ## *< Unexpected EOF
    GIT_EPEEL = - 19,            ## *< The requested peel operation is not possible
    GIT_EAPPLIED = - 18,         ## *< Patch/merge has already been applied
    GIT_ECERTIFICATE = - 17,     ## *< Server certificate is invalid
    GIT_EAUTH = - 16,            ## *< Authentication error
    GIT_EMODIFIED = - 15,        ## *< Reference value does not match expected
    GIT_ELOCKED = - 14,          ## *< Lock file prevented operation
    GIT_ECONFLICT = - 13,        ## *< Checkout conflicts prevented operation
    GIT_EINVALIDSPEC = - 12,     ## *< Name/ref spec was not in a valid format
    GIT_ENONFASTFORWARD = - 11,  ## *< Reference was not fast-forwardable
    GIT_EUNMERGED = - 10,        ## *< Merge in progress prevented operation
    GIT_EUNBORNBRANCH = - 9,     ## *< HEAD refers to branch with no commits
    GIT_EBAREREPO = - 8,         ## *< Operation not allowed on bare repository
    GIT_EUSER = - 7, GIT_EBUFS = - 6, ## *< Output buffer too short to hold data
                              ##  GIT_EUSER is a special error that is never generated by libgit2
                              ##  code.  You can return it from a callback (e.g to stop an iteration)
                              ##  to know that it was generated by the callback and not by libgit2.
                              ## 
    GIT_EAMBIGUOUS = - 5,        ## *< More than one object matches
    GIT_EEXISTS = - 4,           ## *< Object exists preventing operation
    GIT_ENOTFOUND = - 3,         ## *< Requested object could not be found
    GIT_ERROR = - 1,             ## *< Generic error
    GIT_OK = 0                  ## *< No error


## *
##  Structure to store extra details of the last error that occurred.
## 
##  This is kept on a per-thread basis if GIT_THREADS was defined when the
##  library was build, otherwise one is kept globally for the library
## 

type
  git_error* {.bycopy.} = object
    message*: cstring
    klass*: cint


## * Error classes

type
  git_error_t* = enum
    GITERR_NONE = 0, GITERR_NOMEMORY, GITERR_OS, GITERR_INVALID, GITERR_REFERENCE,
    GITERR_ZLIB, GITERR_REPOSITORY, GITERR_CONFIG, GITERR_REGEX, GITERR_ODB,
    GITERR_INDEX, GITERR_OBJECT, GITERR_NET, GITERR_TAG, GITERR_TREE, GITERR_INDEXER,
    GITERR_SSL, GITERR_SUBMODULE, GITERR_THREAD, GITERR_STASH, GITERR_CHECKOUT,
    GITERR_FETCHHEAD, GITERR_MERGE, GITERR_SSH, GITERR_FILTER, GITERR_REVERT,
    GITERR_CALLBACK, GITERR_CHERRYPICK, GITERR_DESCRIBE, GITERR_REBASE,
    GITERR_FILESYSTEM, GITERR_PATCH, GITERR_WORKTREE, GITERR_SHA1


## *
##  Return the last `git_error` object that was generated for the
##  current thread or NULL if no error has occurred.
## 
##  @return A git_error object.
## 

proc giterr_last*(): ptr git_error
## *
##  Clear the last library error that occurred for this thread.
## 

proc giterr_clear*()
## *
##  Set the error message string for this thread.
## 
##  This function is public so that custom ODB backends and the like can
##  relay an error message through libgit2.  Most regular users of libgit2
##  will never need to call this function -- actually, calling it in most
##  circumstances (for example, calling from within a callback function)
##  will just end up having the value overwritten by libgit2 internals.
## 
##  This error message is stored in thread-local storage and only applies
##  to the particular thread that this libgit2 call is made from.
## 
##  @param error_class One of the `git_error_t` enum above describing the
##                     general subsystem that is responsible for the error.
##  @param string The formatted error message to keep
## 

proc giterr_set_str*(error_class: cint; string: cstring)
## *
##  Set the error message to a special value for memory allocation failure.
## 
##  The normal `giterr_set_str()` function attempts to `strdup()` the string
##  that is passed in.  This is not a good idea when the error in question
##  is a memory allocation failure.  That circumstance has a special setter
##  function that sets the error string to a known and statically allocated
##  internal value.
## 

proc giterr_set_oom*()
## * @}
