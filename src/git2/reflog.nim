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
##  @file git2/reflog.h
##  @brief Git reflog management routines
##  @defgroup git_reflog Git reflog management routines
##  @ingroup Git
##  @{
## 
## *
##  Read the reflog for the given reference
## 
##  If there is no reflog file for the given
##  reference yet, an empty reflog object will
##  be returned.
## 
##  The reflog must be freed manually by using
##  git_reflog_free().
## 
##  @param out pointer to reflog
##  @param repo the repostiory
##  @param name reference to look up
##  @return 0 or an error code
## 

proc git_reflog_read*(`out`: ptr ptr git_reflog; repo: ptr git_repository; name: cstring): cint  {.importc.}
## *
##  Write an existing in-memory reflog object back to disk
##  using an atomic file lock.
## 
##  @param reflog an existing reflog object
##  @return 0 or an error code
## 

proc git_reflog_write*(reflog: ptr git_reflog): cint  {.importc.}
## *
##  Add a new entry to the in-memory reflog.
## 
##  `msg` is optional and can be NULL.
## 
##  @param reflog an existing reflog object
##  @param id the OID the reference is now pointing to
##  @param committer the signature of the committer
##  @param msg the reflog message
##  @return 0 or an error code
## 

proc git_reflog_append*(reflog: ptr git_reflog; id: ptr git_oid; 
                       committer: ptr git_signature; msg: cstring): cint {.importc.}
## *
##  Rename a reflog
## 
##  The reflog to be renamed is expected to already exist
## 
##  The new name will be checked for validity.
##  See `git_reference_create_symbolic()` for rules about valid names.
## 
##  @param repo the repository
##  @param old_name the old name of the reference
##  @param name the new name of the reference
##  @return 0 on success, GIT_EINVALIDSPEC or an error code
## 

proc git_reflog_rename*(repo: ptr git_repository; old_name: cstring; name: cstring): cint  {.importc.}
## *
##  Delete the reflog for the given reference
## 
##  @param repo the repository
##  @param name the reflog to delete
##  @return 0 or an error code
## 

proc git_reflog_delete*(repo: ptr git_repository; name: cstring): cint  {.importc.}
## *
##  Get the number of log entries in a reflog
## 
##  @param reflog the previously loaded reflog
##  @return the number of log entries
## 

proc git_reflog_entrycount*(reflog: ptr git_reflog): csize  {.importc.}
## *
##  Lookup an entry by its index
## 
##  Requesting the reflog entry with an index of 0 (zero) will
##  return the most recently created entry.
## 
##  @param reflog a previously loaded reflog
##  @param idx the position of the entry to lookup. Should be greater than or
##  equal to 0 (zero) and less than `git_reflog_entrycount()`.
##  @return the entry; NULL if not found
## 

proc git_reflog_entry_byindex*(reflog: ptr git_reflog; idx: csize): ptr git_reflog_entry  {.importc.}
## *
##  Remove an entry from the reflog by its index
## 
##  To ensure there's no gap in the log history, set `rewrite_previous_entry`
##  param value to 1. When deleting entry `n`, member old_oid of entry `n-1`
##  (if any) will be updated with the value of member new_oid of entry `n+1`.
## 
##  @param reflog a previously loaded reflog.
## 
##  @param idx the position of the entry to remove. Should be greater than or
##  equal to 0 (zero) and less than `git_reflog_entrycount()`.
## 
##  @param rewrite_previous_entry 1 to rewrite the history; 0 otherwise.
## 
##  @return 0 on success, GIT_ENOTFOUND if the entry doesn't exist
##  or an error code.
## 

proc git_reflog_drop*(reflog: ptr git_reflog; idx: csize; rewrite_previous_entry: cint): cint  {.importc.}
## *
##  Get the old oid
## 
##  @param entry a reflog entry
##  @return the old oid
## 

proc git_reflog_entry_id_old*(entry: ptr git_reflog_entry): ptr git_oid  {.importc.}
## *
##  Get the new oid
## 
##  @param entry a reflog entry
##  @return the new oid at this time
## 

proc git_reflog_entry_id_new*(entry: ptr git_reflog_entry): ptr git_oid  {.importc.}
## *
##  Get the committer of this entry
## 
##  @param entry a reflog entry
##  @return the committer
## 

proc git_reflog_entry_committer*(entry: ptr git_reflog_entry): ptr git_signature  {.importc.}
## *
##  Get the log message
## 
##  @param entry a reflog entry
##  @return the log msg
## 

proc git_reflog_entry_message*(entry: ptr git_reflog_entry): cstring  {.importc.}
## *
##  Free the reflog
## 
##  @param reflog reflog to free
## 

proc git_reflog_free*(reflog: ptr git_reflog)  {.importc.}
## * @}
