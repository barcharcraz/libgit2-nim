## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 

import
  git2/common, git2/types, git2/config

## *
##  @file git2/sys/config.h
##  @brief Git config backend routines
##  @defgroup git_backend Git custom backend APIs
##  @ingroup Git
##  @{
## 
## *
##  Every iterator must have this struct as its first element, so the
##  API can talk to it. You'd define your iterator as
## 
##      struct my_iterator {
##              git_config_iterator parent;
##              ...
##      }
## 
##  and assign `iter->parent.backend` to your `git_config_backend`.
## 

type
  git_config_iterator* {.bycopy.} = object
    backend*: ptr git_config_backend
    flags*: cuint ## *
                ##  Return the current entry and advance the iterator. The
                ##  memory belongs to the library.
                ## 
    next*: proc (entry: ptr ptr git_config_entry; iter: ptr git_config_iterator): cint ## *  {.importc.}
                                                                             ##  Free the iterator
                                                                             ## 
    free*: proc (iter: ptr git_config_iterator) 


## *
##  Generic backend that implements the interface to
##  access a configuration file
## 

type
  git_config_backend* {.bycopy.} = object
    version*: cuint            ## * True if this backend is for a snapshot
    readonly*: cint
    cfg*: ptr git_config        ##  Open means open the file/database and parse if necessary
    open*: proc (a2: ptr git_config_backend; level: git_config_level_t): cint 
    get*: proc (a2: ptr git_config_backend; key: cstring; 
              entry: ptr ptr git_config_entry): cint {.importc.}
    set*: proc (a2: ptr git_config_backend; key: cstring; value: cstring): cint 
    set_multivar*: proc (cfg: ptr git_config_backend; name: cstring; regexp: cstring; 
                       value: cstring): cint {.importc.}
    del*: proc (a2: ptr git_config_backend; key: cstring): cint 
    del_multivar*: proc (a2: ptr git_config_backend; key: cstring; regexp: cstring): cint 
    `iterator`*: proc (a2: ptr ptr git_config_iterator; a3: ptr git_config_backend): cint ##   {.importc.}
                                                                                ## * 
                                                                                ## Produce 
                                                                                ## a 
                                                                                ## read-only 
                                                                                ## version 
                                                                                ## of 
                                                                                ## this 
                                                                                ## backend
    snapshot*: proc (a2: ptr ptr git_config_backend; a3: ptr git_config_backend): cint ## *  {.importc.}
                                                                             ##  Lock this backend.
                                                                             ## 
                                                                             ##  Prevent any writes to the data store backing this
                                                                             ##  backend. Any updates must not be visible to any other
                                                                             ##  readers.
                                                                             ## 
    lock*: proc (a2: ptr git_config_backend): cint ## *  {.importc.}
                                             ##  Unlock the data store backing this backend. If success is
                                             ##  true, the changes should be committed, otherwise rolled
                                             ##  back.
                                             ## 
    unlock*: proc (a2: ptr git_config_backend; success: cint): cint  {.importc.}
    free*: proc (a2: ptr git_config_backend) 


const
  GIT_CONFIG_BACKEND_VERSION* = 1

## *
##  Initializes a `git_config_backend` with default values. Equivalent to
##  creating an instance with GIT_CONFIG_BACKEND_INIT.
## 
##  @param backend the `git_config_backend` struct to initialize.
##  @param version Version of struct; pass `GIT_CONFIG_BACKEND_VERSION`
##  @return Zero on success; -1 on failure.
## 

proc git_config_init_backend*(backend: ptr git_config_backend; version: cuint): cint  {.importc.}
## *
##  Add a generic config file instance to an existing config
## 
##  Note that the configuration object will free the file
##  automatically.
## 
##  Further queries on this config object will access each
##  of the config file instances in order (instances with
##  a higher priority level will be accessed first).
## 
##  @param cfg the configuration to add the file to
##  @param file the configuration file (backend) to add
##  @param level the priority level of the backend
##  @param force if a config file already exists for the given
##   priority level, replace it
##  @return 0 on success, GIT_EEXISTS when adding more than one file
##   for a given priority level (and force_replace set to 0), or error code
## 

proc git_config_add_backend*(cfg: ptr git_config; file: ptr git_config_backend; 
                            level: git_config_level_t; force: cint): cint {.importc.}
## * @}
