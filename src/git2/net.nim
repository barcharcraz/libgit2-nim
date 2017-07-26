## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 

{.push dynlib: "libgit2".}
{.push callconv: cdecl.}
import
  common, oid, types

## *
##  @file git2/net.h
##  @brief Git networking declarations
##  @ingroup Git
##  @{
## 

const
  GIT_DEFAULT_PORT* = "9418"

## *
##  Direction of the connection.
## 
##  We need this because we need to know whether we should call
##  git-upload-pack or git-receive-pack on the remote end when get_refs
##  gets called.
## 

type
  git_direction* = enum
    GIT_DIRECTION_FETCH = 0, GIT_DIRECTION_PUSH = 1


## *
##  Description of a reference advertised by a remote server, given out
##  on `ls` calls.
## 

type
  git_remote_head* {.bycopy.} = object
    local*: cint               ##  available locally
    oid*: git_oid
    loid*: git_oid
    name*: cstring ## *
                 ##  If the server send a symref mapping for this ref, this will
                 ##  point to the target.
                 ## 
    symref_target*: cstring


## *
##  Callback for listing the remote heads
## 

type
  git_headlist_cb* = proc (rhead: ptr git_remote_head; payload: pointer): cint

## * @}
