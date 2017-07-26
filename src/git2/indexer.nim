## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 
{.push importc.}
{.push dynlib: "libgit2".}
import
  common, types, oid


## *
##  Create a new indexer instance
## 
##  @param out where to store the indexer instance
##  @param path to the directory where the packfile should be stored
##  @param mode permissions to use creating packfile or 0 for defaults
##  @param odb object database from which to read base objects when
##  fixing thin packs. Pass NULL if no thin pack is expected (an error
##  will be returned if there are bases missing)
##  @param progress_cb function to call with progress information
##  @param progress_cb_payload payload for the progress callback
## 

proc git_indexer_new*(`out`: ptr ptr git_indexer; path: cstring; mode: cuint;
                     odb: ptr git_odb; progress_cb: git_transfer_progress_cb;
                     progress_cb_payload: pointer): cint
## *
##  Add data to the indexer
## 
##  @param idx the indexer
##  @param data the data to add
##  @param size the size of the data in bytes
##  @param stats stat storage
## 

proc git_indexer_append*(idx: ptr git_indexer; data: pointer; size: csize;
                        stats: ptr git_transfer_progress): cint
## *
##  Finalize the pack and index
## 
##  Resolve any pending deltas and write out the index file
## 
##  @param idx the indexer
## 

proc git_indexer_commit*(idx: ptr git_indexer; stats: ptr git_transfer_progress): cint
## *
##  Get the packfile's hash
## 
##  A packfile's name is derived from the sorted hashing of all object
##  names. This is only correct after the index has been finalized.
## 
##  @param idx the indexer instance
## 

proc git_indexer_hash*(idx: ptr git_indexer): ptr git_oid
## *
##  Free the indexer and its resources
## 
##  @param idx the indexer to free
## 

proc git_indexer_free*(idx: ptr git_indexer)