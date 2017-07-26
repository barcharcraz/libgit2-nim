## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 

import
  git2/common, git2/types, git2/oid, git2/odb

## *
##  @file git2/sys/backend.h
##  @brief Git custom backend implementors functions
##  @defgroup git_backend Git custom backend APIs
##  @ingroup Git
##  @{
## 
## *
##  An instance for a custom backend
## 

type
  git_odb_backend* {.bycopy.} = object
    version*: cuint
    odb*: ptr git_odb ##  read and read_prefix each return to libgit2 a buffer which
                   ##  will be freed later. The buffer should be allocated using
                   ##  the function git_odb_backend_malloc to ensure that it can
                   ##  be safely freed later.
    read*: proc (a2: ptr pointer; a3: ptr csize; a4: ptr git_otype; 
               a5: ptr git_odb_backend; a6: ptr git_oid): cint ##  To find a unique object given a prefix of its oid.  The oid given {.importc.}
                                                        ##  must be so that the remaining (GIT_OID_HEXSZ - len)*4 bits are 0s.
                                                        ## 
    read_prefix*: proc (a2: ptr git_oid; a3: ptr pointer; a4: ptr csize; a5: ptr git_otype; 
                      a6: ptr git_odb_backend; a7: ptr git_oid; a8: csize): cint {.importc.}
    read_header*: proc (a2: ptr csize; a3: ptr git_otype; a4: ptr git_odb_backend; 
                      a5: ptr git_oid): cint ## * {.importc.}
                                         ##  Write an object into the backend. The id of the object has
                                         ##  already been calculated and is passed in.
                                         ## 
    write*: proc (a2: ptr git_odb_backend; a3: ptr git_oid; a4: pointer; a5: csize; 
                a6: git_otype): cint {.importc.}
    writestream*: proc (a2: ptr ptr git_odb_stream; a3: ptr git_odb_backend; 
                      a4: git_off_t; a5: git_otype): cint {.importc.}
    readstream*: proc (a2: ptr ptr git_odb_stream; a3: ptr git_odb_backend; 
                     a4: ptr git_oid): cint
    exists*: proc (a2: ptr git_odb_backend; a3: ptr git_oid): cint  {.importc.}
    exists_prefix*: proc (a2: ptr git_oid; a3: ptr git_odb_backend; a4: ptr git_oid; 
                        a5: csize): cint ## * {.importc.}
                                      ##  If the backend implements a refreshing mechanism, it should be exposed
                                      ##  through this endpoint. Each call to `git_odb_refresh()` will invoke it.
                                      ## 
                                      ##  However, the backend implementation should try to stay up-to-date as much
                                      ##  as possible by itself as libgit2 will not automatically invoke
                                      ##  `git_odb_refresh()`. For instance, a potential strategy for the backend
                                      ##  implementation to achieve this could be to internally invoke this
                                      ##  endpoint on failed lookups (ie. `exists()`, `read()`, `read_header()`).
                                      ## 
    refresh*: proc (a2: ptr git_odb_backend): cint 
    foreach*: proc (a2: ptr git_odb_backend; cb: git_odb_foreach_cb; payload: pointer): cint  {.importc.}
    writepack*: proc (a2: ptr ptr git_odb_writepack; a3: ptr git_odb_backend; 
                    odb: ptr git_odb; progress_cb: git_transfer_progress_cb;
                    progress_payload: pointer): cint ## * {.importc.}
                                                  ##  "Freshens" an already existing object, updating its last-used
                                                  ##  time.  This occurs when `git_odb_write` was called, but the
                                                  ##  object already existed (and will not be re-written).  The
                                                  ##  underlying implementation may want to update last-used timestamps.
                                                  ## 
                                                  ##  If callers implement this, they should return `0` if the object
                                                  ##  exists and was freshened, and non-zero otherwise.
                                                  ## 
    freshen*: proc (a2: ptr git_odb_backend; a3: ptr git_oid): cint ## *  {.importc.}
                                                           ##  Frees any resources held by the odb (including the `git_odb_backend`
                                                           ##  itself). An odb backend implementation must provide this function.
                                                           ## 
    free*: proc (a2: ptr git_odb_backend) 


const
  GIT_ODB_BACKEND_VERSION* = 1

## *
##  Initializes a `git_odb_backend` with default values. Equivalent to
##  creating an instance with GIT_ODB_BACKEND_INIT.
## 
##  @param backend the `git_odb_backend` struct to initialize.
##  @param version Version the struct; pass `GIT_ODB_BACKEND_VERSION`
##  @return Zero on success; -1 on failure.
## 

proc git_odb_init_backend*(backend: ptr git_odb_backend; version: cuint): cint 
proc git_odb_backend_malloc*(backend: ptr git_odb_backend; len: csize): pointer  {.importc.}