## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 

import
  git2/common, git2/types, git2/oid

## *
##  @file git2/refdb_backend.h
##  @brief Git custom refs backend functions
##  @defgroup git_refdb_backend Git custom refs backend API
##  @ingroup Git
##  @{
## 
## *
##  Every backend's iterator must have a pointer to itself as the first
##  element, so the API can talk to it. You'd define your iterator as
## 
##      struct my_iterator {
##              git_reference_iterator parent;
##              ...
##      }
## 
##  and assign `iter->parent.backend` to your `git_refdb_backend`.
## 

type
  git_reference_iterator* {.bycopy.} = object
    db*: ptr git_refdb ## *
                    ##  Return the current reference and advance the iterator.
                    ## 
    next*: proc (`ref`: ptr ptr git_reference; iter: ptr git_reference_iterator): cint ## *
                                                                             ##  Return the name of the current reference and advance the iterator
                                                                             ## 
    next_name*: proc (ref_name: cstringArray; iter: ptr git_reference_iterator): cint ## *
                                                                              ##  Free the iterator
                                                                              ## 
    free*: proc (iter: ptr git_reference_iterator)


## * An instance for a custom backend

type
  git_refdb_backend* {.bycopy.} = object
    version*: cuint ## *
                  ##  Queries the refdb backend to determine if the given ref_name
                  ##  exists.  A refdb implementation must provide this function.
                  ## 
    exists*: proc (exists: ptr cint; backend: ptr git_refdb_backend; ref_name: cstring): cint ## *
                                                                                   ##  Queries the refdb backend for a given reference.  A refdb
                                                                                   ##  implementation must provide this function.
                                                                                   ## 
    lookup*: proc (`out`: ptr ptr git_reference; backend: ptr git_refdb_backend;
                 ref_name: cstring): cint ## *
                                       ##  Allocate an iterator object for the backend.
                                       ## 
                                       ##  A refdb implementation must provide this function.
                                       ## 
    `iterator`*: proc (iter: ptr ptr git_reference_iterator;
                     backend: ptr git_refdb_backend; glob: cstring): cint ## 
                                                                    ##  Writes the given reference to the refdb.  A refdb implementation
                                                                    ##  must provide this function.
                                                                    ## 
    write*: proc (backend: ptr git_refdb_backend; `ref`: ptr git_reference; force: cint;
                who: ptr git_signature; message: cstring; old: ptr git_oid;
                old_target: cstring): cint
    rename*: proc (`out`: ptr ptr git_reference; backend: ptr git_refdb_backend;
                 old_name: cstring; new_name: cstring; force: cint;
                 who: ptr git_signature; message: cstring): cint ## *
                                                           ##  Deletes the given reference (and if necessary its reflog)
                                                           ##  from the refdb.  A refdb implementation must provide this
                                                           ##  function.
                                                           ## 
    del*: proc (backend: ptr git_refdb_backend; ref_name: cstring; old_id: ptr git_oid;
              old_target: cstring): cint ## *
                                      ##  Suggests that the given refdb compress or optimize its references.
                                      ##  This mechanism is implementation specific.  (For on-disk reference
                                      ##  databases, this may pack all loose references.)    A refdb
                                      ##  implementation may provide this function; if it is not provided,
                                      ##  nothing will be done.
                                      ## 
    compress*: proc (backend: ptr git_refdb_backend): cint ## *
                                                     ##  Query whether a particular reference has a log (may be empty)
                                                     ## 
    has_log*: proc (backend: ptr git_refdb_backend; refname: cstring): cint ## *
                                                                    ##  Make sure a particular reference will have a reflog which
                                                                    ##  will be appended to on writes.
                                                                    ## 
    ensure_log*: proc (backend: ptr git_refdb_backend; refname: cstring): cint ## *
                                                                       ##  Frees any resources held by the refdb (including the `git_refdb_backend`
                                                                       ##  itself). A refdb backend implementation must provide this function.
                                                                       ## 
    free*: proc (backend: ptr git_refdb_backend) ## *
                                            ##  Read the reflog for the given reference name.
                                            ## 
    reflog_read*: proc (`out`: ptr ptr git_reflog; backend: ptr git_refdb_backend;
                      name: cstring): cint ## *
                                        ##  Write a reflog to disk.
                                        ## 
    reflog_write*: proc (backend: ptr git_refdb_backend; reflog: ptr git_reflog): cint ## *
                                                                              ##  Rename a reflog
                                                                              ## 
    reflog_rename*: proc (_backend: ptr git_refdb_backend; old_name: cstring;
                        new_name: cstring): cint ## *
                                              ##  Remove a reflog.
                                              ## 
    reflog_delete*: proc (backend: ptr git_refdb_backend; name: cstring): cint ## *
                                                                       ##  Lock a reference. The opaque parameter will be passed to the unlock function
                                                                       ## 
    lock*: proc (payload_out: ptr pointer; backend: ptr git_refdb_backend;
               refname: cstring): cint ## *
                                    ##  Unlock a reference. Only one of target or symbolic_target
                                    ##  will be set. success indicates whether to update the
                                    ##  reference or discard the lock (if it's false)
                                    ## 
    unlock*: proc (backend: ptr git_refdb_backend; payload: pointer; success: cint;
                 update_reflog: cint; `ref`: ptr git_reference;
                 sig: ptr git_signature; message: cstring): cint


const
  GIT_REFDB_BACKEND_VERSION* = 1

## *
##  Initializes a `git_refdb_backend` with default values. Equivalent to
##  creating an instance with GIT_REFDB_BACKEND_INIT.
## 
##  @param backend the `git_refdb_backend` struct to initialize
##  @param version Version of struct; pass `GIT_REFDB_BACKEND_VERSION`
##  @return Zero on success; -1 on failure.
## 

proc git_refdb_init_backend*(backend: ptr git_refdb_backend; version: cuint): cint
## *
##  Constructors for default filesystem-based refdb backend
## 
##  Under normal usage, this is called for you when the repository is
##  opened / created, but you can use this to explicitly construct a
##  filesystem refdb backend for a repository.
## 
##  @param backend_out Output pointer to the git_refdb_backend object
##  @param repo Git repository to access
##  @return 0 on success, <0 error code on failure
## 

proc git_refdb_backend_fs*(backend_out: ptr ptr git_refdb_backend;
                          repo: ptr git_repository): cint
## *
##  Sets the custom backend to an existing reference DB
## 
##  The `git_refdb` will take ownership of the `git_refdb_backend` so you
##  should NOT free it after calling this function.
## 
##  @param refdb database to add the backend to
##  @param backend pointer to a git_refdb_backend instance
##  @return 0 on success; error code otherwise
## 

proc git_refdb_set_backend*(refdb: ptr git_refdb; backend: ptr git_refdb_backend): cint