## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 

## *
##  @file git2/sys/index.h
##  @brief Low-level Git index manipulation routines
##  @defgroup git_backend Git custom backend APIs
##  @ingroup Git
##  @{
## 
## * Representation of a rename conflict entry in the index.

type
  git_index_name_entry* {.bycopy.} = object
    ancestor*: cstring
    ours*: cstring
    theirs*: cstring


## * Representation of a resolve undo entry in the index.

type
  git_index_reuc_entry* {.bycopy.} = object
    mode*: array[3, uint32]
    oid*: array[3, git_oid]
    path*: cstring


## * @name Conflict Name entry functions
## 
##  These functions work on rename conflict entries.
## 
## *@{
## *
##  Get the count of filename conflict entries currently in the index.
## 
##  @param index an existing index object
##  @return integer of count of current filename conflict entries
## 

proc git_index_name_entrycount*(index: ptr git_index): csize
## *
##  Get a filename conflict entry from the index.
## 
##  The returned entry is read-only and should not be modified
##  or freed by the caller.
## 
##  @param index an existing index object
##  @param n the position of the entry
##  @return a pointer to the filename conflict entry; NULL if out of bounds
## 

proc git_index_name_get_byindex*(index: ptr git_index; n: csize): ptr git_index_name_entry
## *
##  Record the filenames involved in a rename conflict.
## 
##  @param index an existing index object
##  @param ancestor the path of the file as it existed in the ancestor
##  @param ours the path of the file as it existed in our tree
##  @param theirs the path of the file as it existed in their tree
## 

proc git_index_name_add*(index: ptr git_index; ancestor: cstring; ours: cstring;
                        theirs: cstring): cint
## *
##  Remove all filename conflict entries.
## 
##  @param index an existing index object
## 

proc git_index_name_clear*(index: ptr git_index)
## *@}
## * @name Resolve Undo (REUC) index entry manipulation.
## 
##  These functions work on the Resolve Undo index extension and contains
##  data about the original files that led to a merge conflict.
## 
## *@{
## *
##  Get the count of resolve undo entries currently in the index.
## 
##  @param index an existing index object
##  @return integer of count of current resolve undo entries
## 

proc git_index_reuc_entrycount*(index: ptr git_index): csize
## *
##  Finds the resolve undo entry that points to the given path in the Git
##  index.
## 
##  @param at_pos the address to which the position of the reuc entry is written (optional)
##  @param index an existing index object
##  @param path path to search
##  @return 0 if found, < 0 otherwise (GIT_ENOTFOUND)
## 

proc git_index_reuc_find*(at_pos: ptr csize; index: ptr git_index; path: cstring): cint
## *
##  Get a resolve undo entry from the index.
## 
##  The returned entry is read-only and should not be modified
##  or freed by the caller.
## 
##  @param index an existing index object
##  @param path path to search
##  @return the resolve undo entry; NULL if not found
## 

proc git_index_reuc_get_bypath*(index: ptr git_index; path: cstring): ptr git_index_reuc_entry
## *
##  Get a resolve undo entry from the index.
## 
##  The returned entry is read-only and should not be modified
##  or freed by the caller.
## 
##  @param index an existing index object
##  @param n the position of the entry
##  @return a pointer to the resolve undo entry; NULL if out of bounds
## 

proc git_index_reuc_get_byindex*(index: ptr git_index; n: csize): ptr git_index_reuc_entry
## *
##  Adds a resolve undo entry for a file based on the given parameters.
## 
##  The resolve undo entry contains the OIDs of files that were involved
##  in a merge conflict after the conflict has been resolved.  This allows
##  conflicts to be re-resolved later.
## 
##  If there exists a resolve undo entry for the given path in the index,
##  it will be removed.
## 
##  This method will fail in bare index instances.
## 
##  @param index an existing index object
##  @param path filename to add
##  @param ancestor_mode mode of the ancestor file
##  @param ancestor_id oid of the ancestor file
##  @param our_mode mode of our file
##  @param our_id oid of our file
##  @param their_mode mode of their file
##  @param their_id oid of their file
##  @return 0 or an error code
## 

proc git_index_reuc_add*(index: ptr git_index; path: cstring; ancestor_mode: cint;
                        ancestor_id: ptr git_oid; our_mode: cint;
                        our_id: ptr git_oid; their_mode: cint; their_id: ptr git_oid): cint
## *
##  Remove an resolve undo entry from the index
## 
##  @param index an existing index object
##  @param n position of the resolve undo entry to remove
##  @return 0 or an error code
## 

proc git_index_reuc_remove*(index: ptr git_index; n: csize): cint
## *
##  Remove all resolve undo entries from the index
## 
##  @param index an existing index object
## 

proc git_index_reuc_clear*(index: ptr git_index)
## *@}
## * @}
