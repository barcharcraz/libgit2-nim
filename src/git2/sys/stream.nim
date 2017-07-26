## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 

import
  git2/common, git2/types, git2/proxy

const
  GIT_STREAM_VERSION* = 1

## *
##  Every stream must have this struct as its first element, so the
##  API can talk to it. You'd define your stream as
## 
##      struct my_stream {
##              git_stream parent;
##              ...
##      }
## 
##  and fill the functions
## 

type
  git_stream* {.bycopy.} = object
    version*: cint
    encrypted*: cint
    proxy_support*: cint
    connect*: proc (a2: ptr git_stream): cint 
    certificate*: proc (a2: ptr ptr git_cert; a3: ptr git_stream): cint 
    set_proxy*: proc (a2: ptr git_stream; proxy_opts: ptr git_proxy_options): cint  {.importc.}
    read*: proc (a2: ptr git_stream; a3: pointer; a4: csize): ssize_t 
    write*: proc (a2: ptr git_stream; a3: cstring; a4: csize; a5: cint): ssize_t 
    close*: proc (a2: ptr git_stream): cint  {.importc.}
    free*: proc (a2: ptr git_stream) 

  git_stream_cb* = proc (`out`: ptr ptr git_stream; host: cstring; port: cstring): cint  {.importc.}

## *
##  Register a TLS stream constructor for the library to use
## 
##  If a constructor is already set, it will be overwritten. Pass
##  `NULL` in order to deregister the current constructor.
## 
##  @param ctor the constructor to use
##  @return 0 or an error code
## 

proc git_stream_register_tls*(ctor: git_stream_cb): cint  {.importc.}