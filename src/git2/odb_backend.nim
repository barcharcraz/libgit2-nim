## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 

{.push dynlib: "libgit2".}
{.push callconv: cdecl.}
import
  common, types, oid

## *
##  @file git2/backend.h
##  @brief Git custom backend functions
##  @defgroup git_odb Git object database routines
##  @ingroup Git
##  @{
## 
## 
##  Constructors for in-box ODB backends.
## 
## *
##  Create a backend for the packfiles.
## 
##  @param out location to store the odb backend pointer
##  @param objects_dir the Git repository's objects directory
## 
##  @return 0 or an error code
## 

proc git_odb_backend_pack*(`out`: ptr ptr git_odb_backend; objects_dir: cstring): cint  {.importc.}
## *
##  Create a backend for loose objects
## 
##  @param out location to store the odb backend pointer
##  @param objects_dir the Git repository's objects directory
##  @param compression_level zlib compression level to use
##  @param do_fsync whether to do an fsync() after writing
##  @param dir_mode permissions to use creating a directory or 0 for defaults
##  @param file_mode permissions to use creating a file or 0 for defaults
## 
##  @return 0 or an error code
## 

proc git_odb_backend_loose*(`out`: ptr ptr git_odb_backend; objects_dir: cstring; 
                           compression_level: cint; do_fsync: cint; dir_mode: cuint;
                           file_mode: cuint): cint {.importc.}
## *
##  Create a backend out of a single packfile
## 
##  This can be useful for inspecting the contents of a single
##  packfile.
## 
##  @param out location to store the odb backend pointer
##  @param index_file path to the packfile's .idx file
## 
##  @return 0 or an error code
## 

proc git_odb_backend_one_pack*(`out`: ptr ptr git_odb_backend; index_file: cstring): cint  {.importc.}
## * Streaming mode

type
  git_odb_stream_t* = enum
    GIT_STREAM_RDONLY = (1 shl 1), GIT_STREAM_WRONLY = (1 shl 2),
    GIT_STREAM_RW = (ord(GIT_STREAM_RDONLY) or ord(GIT_STREAM_WRONLY))


## *
##  A stream to read/write from a backend.
## 
##  This represents a stream of data being written to or read from a
##  backend. When writing, the frontend functions take care of
##  calculating the object's id and all `finalize_write` needs to do is
##  store the object with the id it is passed.
## 

type
  git_odb_stream* {.bycopy.} = object
    backend*: ptr git_odb_backend
    mode*: cuint
    hash_ctx*: pointer
    declared_size*: git_off_t
    received_bytes*: git_off_t ## *
                             ##  Write at most `len` bytes into `buffer` and advance the stream.
                             ## 
    read*: proc (stream: ptr git_odb_stream; buffer: cstring; len: csize): cint ## *  {.importc.}
                                                                      ##  Write `len` bytes from `buffer` into the stream.
                                                                      ## 
    write*: proc (stream: ptr git_odb_stream; buffer: cstring; len: csize): cint ## *  {.importc.}
                                                                       ##  Store the contents of the stream as an object with the id
                                                                       ##  specified in `oid`.
                                                                       ## 
                                                                       ##  This method might not be invoked if:
                                                                       ##  - an error occurs earlier with the `write` callback,
                                                                       ##  - the object referred to by `oid` already exists in any backend, or
                                                                       ##  - the final number of received bytes differs from the size declared
                                                                       ##    with `git_odb_open_wstream()`
                                                                       ## 
    finalize_write*: proc (stream: ptr git_odb_stream; oid: ptr git_oid): cint ## *  {.importc.}
                                                                      ##  Free the stream's memory.
                                                                      ## 
                                                                      ##  This method might be called without a call to `finalize_write` if
                                                                      ##  an error occurs or if the object is already present in the ODB.
                                                                      ## 
    free*: proc (stream: ptr git_odb_stream) 


## * A stream to write a pack file to the ODB

type
  git_odb_writepack* {.bycopy.} = object
    backend*: ptr git_odb_backend
    append*: proc (writepack: ptr git_odb_writepack; data: pointer; size: csize; 
                 stats: ptr git_transfer_progress): cint
    commit*: proc (writepack: ptr git_odb_writepack; stats: ptr git_transfer_progress): cint
    free*: proc (writepack: ptr git_odb_writepack) 

