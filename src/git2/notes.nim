## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 

{.push dynlib: "libgit2".}
{.push callconv: cdecl.}
import
  oid, types, buffer

## *
##  @file git2/notes.h
##  @brief Git notes management routines
##  @defgroup git_note Git notes management routines
##  @ingroup Git
##  @{
## 
## *
##  Callback for git_note_foreach.
## 
##  Receives:
##  - blob_id: Oid of the blob containing the message
##  - annotated_object_id: Oid of the git object being annotated
##  - payload: Payload data passed to `git_note_foreach`
## 

type
  git_note_foreach_cb* = proc (blob_id: ptr git_oid; annotated_object_id: ptr git_oid; 
                            payload: pointer): cint

## *
##  note iterator
## 

type
  git_note_iterator* = git_iterator

## *
##  Creates a new iterator for notes
## 
##  The iterator must be freed manually by the user.
## 
##  @param out pointer to the iterator
##  @param repo repository where to look up the note
##  @param notes_ref canonical name of the reference to use (optional); defaults to
##                   "refs/notes/commits"
## 
##  @return 0 or an error code
## 

proc git_note_iterator_new*(`out`: ptr ptr git_note_iterator; 
                           repo: ptr git_repository; notes_ref: cstring): cint {.importc.}
## *
##  Frees an git_note_iterator
## 
##  @param it pointer to the iterator
## 

proc git_note_iterator_free*(it: ptr git_note_iterator)  {.importc.}
## *
##  Return the current item (note_id and annotated_id) and advance the iterator
##  internally to the next value
## 
##  @param note_id id of blob containing the message
##  @param annotated_id id of the git object being annotated
##  @param it pointer to the iterator
## 
##  @return 0 (no error), GIT_ITEROVER (iteration is done) or an error code
##          (negative value)
## 

proc git_note_next*(note_id: ptr git_oid; annotated_id: ptr git_oid; 
                   it: ptr git_note_iterator): cint {.importc.}
## *
##  Read the note for an object
## 
##  The note must be freed manually by the user.
## 
##  @param out pointer to the read note; NULL in case of error
##  @param repo repository where to look up the note
##  @param notes_ref canonical name of the reference to use (optional); defaults to
##                   "refs/notes/commits"
##  @param oid OID of the git object to read the note from
## 
##  @return 0 or an error code
## 

proc git_note_read*(`out`: ptr ptr git_note; repo: ptr git_repository; 
                   notes_ref: cstring; oid: ptr git_oid): cint {.importc.}
## *
##  Get the note author
## 
##  @param note the note
##  @return the author
## 

proc git_note_author*(note: ptr git_note): ptr git_signature  {.importc.}
## *
##  Get the note committer
## 
##  @param note the note
##  @return the committer
## 

proc git_note_committer*(note: ptr git_note): ptr git_signature  {.importc.}
## *
##  Get the note message
## 
##  @param note the note
##  @return the note message
## 

proc git_note_message*(note: ptr git_note): cstring  {.importc.}
## *
##  Get the note object's id
## 
##  @param note the note
##  @return the note object's id
## 

proc git_note_id*(note: ptr git_note): ptr git_oid  {.importc.}
## *
##  Add a note for an object
## 
##  @param out pointer to store the OID (optional); NULL in case of error
##  @param repo repository where to store the note
##  @param notes_ref canonical name of the reference to use (optional);
## 					defaults to "refs/notes/commits"
##  @param author signature of the notes commit author
##  @param committer signature of the notes commit committer
##  @param oid OID of the git object to decorate
##  @param note Content of the note to add for object oid
##  @param force Overwrite existing note
## 
##  @return 0 or an error code
## 

proc git_note_create*(`out`: ptr git_oid; repo: ptr git_repository; notes_ref: cstring; 
                     author: ptr git_signature; committer: ptr git_signature;
                     oid: ptr git_oid; note: cstring; force: cint): cint {.importc.}
## *
##  Remove the note for an object
## 
##  @param repo repository where the note lives
##  @param notes_ref canonical name of the reference to use (optional);
## 					defaults to "refs/notes/commits"
##  @param author signature of the notes commit author
##  @param committer signature of the notes commit committer
##  @param oid OID of the git object to remove the note from
## 
##  @return 0 or an error code
## 

proc git_note_remove*(repo: ptr git_repository; notes_ref: cstring; 
                     author: ptr git_signature; committer: ptr git_signature;
                     oid: ptr git_oid): cint {.importc.}
## *
##  Free a git_note object
## 
##  @param note git_note object
## 

proc git_note_free*(note: ptr git_note)  {.importc.}
## *
##  Get the default notes reference for a repository
## 
##  @param out buffer in which to store the name of the default notes reference
##  @param repo The Git repository
## 
##  @return 0 or an error code
## 

proc git_note_default_ref*(`out`: ptr git_buf; repo: ptr git_repository): cint  {.importc.}
## *
##  Loop over all the notes within a specified namespace
##  and issue a callback for each one.
## 
##  @param repo Repository where to find the notes.
## 
##  @param notes_ref Reference to read from (optional); defaults to
##         "refs/notes/commits".
## 
##  @param note_cb Callback to invoke per found annotation.  Return non-zero
##         to stop looping.
## 
##  @param payload Extra parameter to callback function.
## 
##  @return 0 on success, non-zero callback return value, or error code
## 

proc git_note_foreach*(repo: ptr git_repository; notes_ref: cstring; 
                      note_cb: git_note_foreach_cb; payload: pointer): cint {.importc.}
## * @}
