## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 

{.push dynlib: "libgit2".}
{.push callconv: cdecl.}
import
  common, types, oid, g_object, buffer

## *
##  @file git2/commit.h
##  @brief Git commit parsing, formatting routines
##  @defgroup git_commit Git commit parsing, formatting routines
##  @ingroup Git
##  @{
## 
## *
##  Lookup a commit object from a repository.
## 
##  The returned object should be released with `git_commit_free` when no
##  longer needed.
## 
##  @param commit pointer to the looked up commit
##  @param repo the repo to use when locating the commit.
##  @param id identity of the commit to locate. If the object is
## 		an annotated tag it will be peeled back to the commit.
##  @return 0 or an error code
## 

proc git_commit_lookup*(commit: ptr ptr git_commit; repo: ptr git_repository; 
                       id: ptr git_oid): cint {.importc.}
## *
##  Lookup a commit object from a repository, given a prefix of its
##  identifier (short id).
## 
##  The returned object should be released with `git_commit_free` when no
##  longer needed.
## 
##  @see git_object_lookup_prefix
## 
##  @param commit pointer to the looked up commit
##  @param repo the repo to use when locating the commit.
##  @param id identity of the commit to locate. If the object is
## 		an annotated tag it will be peeled back to the commit.
##  @param len the length of the short identifier
##  @return 0 or an error code
## 

proc git_commit_lookup_prefix*(commit: ptr ptr git_commit; repo: ptr git_repository; 
                              id: ptr git_oid; len: csize): cint {.importc.}
## *
##  Close an open commit
## 
##  This is a wrapper around git_object_free()
## 
##  IMPORTANT:
##  It *is* necessary to call this method when you stop
##  using a commit. Failure to do so will cause a memory leak.
## 
##  @param commit the commit to close
## 

proc git_commit_free*(commit: ptr git_commit)  {.importc.}
## *
##  Get the id of a commit.
## 
##  @param commit a previously loaded commit.
##  @return object identity for the commit.
## 

proc git_commit_id*(commit: ptr git_commit): ptr git_oid  {.importc.}
## *
##  Get the repository that contains the commit.
## 
##  @param commit A previously loaded commit.
##  @return Repository that contains this commit.
## 

proc git_commit_owner*(commit: ptr git_commit): ptr git_repository  {.importc.}
## *
##  Get the encoding for the message of a commit,
##  as a string representing a standard encoding name.
## 
##  The encoding may be NULL if the `encoding` header
##  in the commit is missing; in that case UTF-8 is assumed.
## 
##  @param commit a previously loaded commit.
##  @return NULL, or the encoding
## 

proc git_commit_message_encoding*(commit: ptr git_commit): cstring  {.importc.}
## *
##  Get the full message of a commit.
## 
##  The returned message will be slightly prettified by removing any
##  potential leading newlines.
## 
##  @param commit a previously loaded commit.
##  @return the message of a commit
## 

proc git_commit_message*(commit: ptr git_commit): cstring  {.importc.}
## *
##  Get the full raw message of a commit.
## 
##  @param commit a previously loaded commit.
##  @return the raw message of a commit
## 

proc git_commit_message_raw*(commit: ptr git_commit): cstring  {.importc.}
## *
##  Get the short "summary" of the git commit message.
## 
##  The returned message is the summary of the commit, comprising the
##  first paragraph of the message with whitespace trimmed and squashed.
## 
##  @param commit a previously loaded commit.
##  @return the summary of a commit or NULL on error
## 

proc git_commit_summary*(commit: ptr git_commit): cstring  {.importc.}
## *
##  Get the long "body" of the git commit message.
## 
##  The returned message is the body of the commit, comprising
##  everything but the first paragraph of the message. Leading and
##  trailing whitespaces are trimmed.
## 
##  @param commit a previously loaded commit.
##  @return the body of a commit or NULL when no the message only
##    consists of a summary
## 

proc git_commit_body*(commit: ptr git_commit): cstring  {.importc.}
## *
##  Get the commit time (i.e. committer time) of a commit.
## 
##  @param commit a previously loaded commit.
##  @return the time of a commit
## 

proc git_commit_time*(commit: ptr git_commit): git_time_t  {.importc.}
## *
##  Get the commit timezone offset (i.e. committer's preferred timezone) of a commit.
## 
##  @param commit a previously loaded commit.
##  @return positive or negative timezone offset, in minutes from UTC
## 

proc git_commit_time_offset*(commit: ptr git_commit): cint  {.importc.}
## *
##  Get the committer of a commit.
## 
##  @param commit a previously loaded commit.
##  @return the committer of a commit
## 

proc git_commit_committer*(commit: ptr git_commit): ptr git_signature  {.importc.}
## *
##  Get the author of a commit.
## 
##  @param commit a previously loaded commit.
##  @return the author of a commit
## 

proc git_commit_author*(commit: ptr git_commit): ptr git_signature  {.importc.}
## *
##  Get the full raw text of the commit header.
## 
##  @param commit a previously loaded commit
##  @return the header text of the commit
## 

proc git_commit_raw_header*(commit: ptr git_commit): cstring  {.importc.}
## *
##  Get the tree pointed to by a commit.
## 
##  @param tree_out pointer where to store the tree object
##  @param commit a previously loaded commit.
##  @return 0 or an error code
## 

proc git_commit_tree*(tree_out: ptr ptr git_tree; commit: ptr git_commit): cint  {.importc.}
## *
##  Get the id of the tree pointed to by a commit. This differs from
##  `git_commit_tree` in that no attempts are made to fetch an object
##  from the ODB.
## 
##  @param commit a previously loaded commit.
##  @return the id of tree pointed to by commit.
## 

proc git_commit_tree_id*(commit: ptr git_commit): ptr git_oid  {.importc.}
## *
##  Get the number of parents of this commit
## 
##  @param commit a previously loaded commit.
##  @return integer of count of parents
## 

proc git_commit_parentcount*(commit: ptr git_commit): cuint  {.importc.}
## *
##  Get the specified parent of the commit.
## 
##  @param out Pointer where to store the parent commit
##  @param commit a previously loaded commit.
##  @param n the position of the parent (from 0 to `parentcount`)
##  @return 0 or an error code
## 

proc git_commit_parent*(`out`: ptr ptr git_commit; commit: ptr git_commit; n: cuint): cint  {.importc.}
## *
##  Get the oid of a specified parent for a commit. This is different from
##  `git_commit_parent`, which will attempt to load the parent commit from
##  the ODB.
## 
##  @param commit a previously loaded commit.
##  @param n the position of the parent (from 0 to `parentcount`)
##  @return the id of the parent, NULL on error.
## 

proc git_commit_parent_id*(commit: ptr git_commit; n: cuint): ptr git_oid  {.importc.}
## *
##  Get the commit object that is the <n>th generation ancestor
##  of the named commit object, following only the first parents.
##  The returned commit has to be freed by the caller.
## 
##  Passing `0` as the generation number returns another instance of the
##  base commit itself.
## 
##  @param ancestor Pointer where to store the ancestor commit
##  @param commit a previously loaded commit.
##  @param n the requested generation
##  @return 0 on success; GIT_ENOTFOUND if no matching ancestor exists
##  or an error code
## 

proc git_commit_nth_gen_ancestor*(ancestor: ptr ptr git_commit; 
                                 commit: ptr git_commit; n: cuint): cint {.importc.}
## *
##  Get an arbitrary header field
## 
##  @param out the buffer to fill; existing content will be
##  overwritten
##  @param commit the commit to look in
##  @param field the header field to return
##  @return 0 on succeess, GIT_ENOTFOUND if the field does not exist,
##  or an error code
## 

proc git_commit_header_field*(`out`: ptr git_buf; commit: ptr git_commit; 
                             field: cstring): cint {.importc.}
## *
##  Extract the signature from a commit
## 
##  If the id is not for a commit, the error class will be
##  `GITERR_INVALID`. If the commit does not have a signature, the
##  error class will be `GITERR_OBJECT`.
## 
##  @param signature the signature block; existing content will be
##  overwritten
##  @param signed_data signed data; this is the commit contents minus the signature block;
##  existing content will be overwritten
##  @param repo the repository in which the commit exists
##  @param commit_id the commit from which to extract the data
##  @param field the name of the header field containing the signature
##  block; pass `NULL` to extract the default 'gpgsig'
##  @return 0 on success, GIT_ENOTFOUND if the id is not for a commit
##  or the commit does not have a signature.
## 

proc git_commit_extract_signature*(signature: ptr git_buf; signed_data: ptr git_buf; 
                                  repo: ptr git_repository; commit_id: ptr git_oid;
                                  field: cstring): cint {.importc.}
## *
##  Create new commit in the repository from a list of `git_object` pointers
## 
##  The message will **not** be cleaned up automatically. You can do that
##  with the `git_message_prettify()` function.
## 
##  @param id Pointer in which to store the OID of the newly created commit
## 
##  @param repo Repository where to store the commit
## 
##  @param update_ref If not NULL, name of the reference that
## 	will be updated to point to this commit. If the reference
## 	is not direct, it will be resolved to a direct reference.
## 	Use "HEAD" to update the HEAD of the current branch and
## 	make it point to this commit. If the reference doesn't
## 	exist yet, it will be created. If it does exist, the first
## 	parent must be the tip of this branch.
## 
##  @param author Signature with author and author time of commit
## 
##  @param committer Signature with committer and * commit time of commit
## 
##  @param message_encoding The encoding for the message in the
##   commit, represented with a standard encoding name.
##   E.g. "UTF-8". If NULL, no encoding header is written and
##   UTF-8 is assumed.
## 
##  @param message Full message for this commit
## 
##  @param tree An instance of a `git_tree` object that will
##   be used as the tree for the commit. This tree object must
##   also be owned by the given `repo`.
## 
##  @param parent_count Number of parents for this commit
## 
##  @param parents Array of `parent_count` pointers to `git_commit`
##   objects that will be used as the parents for this commit. This
##   array may be NULL if `parent_count` is 0 (root commit). All the
##   given commits must be owned by the `repo`.
## 
##  @return 0 or an error code
## 	The created commit will be written to the Object Database and
## 	the given reference will be updated to point to it
## 

proc git_commit_create*(id: ptr git_oid; repo: ptr git_repository; update_ref: cstring; 
                       author: ptr git_signature; committer: ptr git_signature;
                       message_encoding: cstring; message: cstring;
                       tree: ptr git_tree; parent_count: csize;
                       parents: ptr ptr git_commit): cint {.importc.}
## *
##  Create new commit in the repository using a variable argument list.
## 
##  The message will **not** be cleaned up automatically. You can do that
##  with the `git_message_prettify()` function.
## 
##  The parents for the commit are specified as a variable list of pointers
##  to `const git_commit *`. Note that this is a convenience method which may
##  not be safe to export for certain languages or compilers
## 
##  All other parameters remain the same as `git_commit_create()`.
## 
##  @see git_commit_create
## 

proc git_commit_create_v*(id: ptr git_oid; repo: ptr git_repository; 
                         update_ref: cstring; author: ptr git_signature;
                         committer: ptr git_signature; message_encoding: cstring;
                         message: cstring; tree: ptr git_tree; parent_count: csize): cint {.
    varargs, importc.}
## *
##  Amend an existing commit by replacing only non-NULL values.
## 
##  This creates a new commit that is exactly the same as the old commit,
##  except that any non-NULL values will be updated.  The new commit has
##  the same parents as the old commit.
## 
##  The `update_ref` value works as in the regular `git_commit_create()`,
##  updating the ref to point to the newly rewritten commit.  If you want
##  to amend a commit that is not currently the tip of the branch and then
##  rewrite the following commits to reach a ref, pass this as NULL and
##  update the rest of the commit chain and ref separately.
## 
##  Unlike `git_commit_create()`, the `author`, `committer`, `message`,
##  `message_encoding`, and `tree` parameters can be NULL in which case this
##  will use the values from the original `commit_to_amend`.
## 
##  All parameters have the same meanings as in `git_commit_create()`.
## 
##  @see git_commit_create
## 

proc git_commit_amend*(id: ptr git_oid; commit_to_amend: ptr git_commit; 
                      update_ref: cstring; author: ptr git_signature;
                      committer: ptr git_signature; message_encoding: cstring;
                      message: cstring; tree: ptr git_tree): cint {.importc.}
## *
##  Create a commit and write it into a buffer
## 
##  Create a commit as with `git_commit_create()` but instead of
##  writing it to the objectdb, write the contents of the object into a
##  buffer.
## 
##  @param out the buffer into which to write the commit object content
## 
##  @param repo Repository where the referenced tree and parents live
## 
##  @param author Signature with author and author time of commit
## 
##  @param committer Signature with committer and * commit time of commit
## 
##  @param message_encoding The encoding for the message in the
##   commit, represented with a standard encoding name.
##   E.g. "UTF-8". If NULL, no encoding header is written and
##   UTF-8 is assumed.
## 
##  @param message Full message for this commit
## 
##  @param tree An instance of a `git_tree` object that will
##   be used as the tree for the commit. This tree object must
##   also be owned by the given `repo`.
## 
##  @param parent_count Number of parents for this commit
## 
##  @param parents Array of `parent_count` pointers to `git_commit`
##   objects that will be used as the parents for this commit. This
##   array may be NULL if `parent_count` is 0 (root commit). All the
##   given commits must be owned by the `repo`.
## 
##  @return 0 or an error code
## 

proc git_commit_create_buffer*(`out`: ptr git_buf; repo: ptr git_repository; 
                              author: ptr git_signature;
                              committer: ptr git_signature;
                              message_encoding: cstring; message: cstring;
                              tree: ptr git_tree; parent_count: csize;
                              parents: ptr ptr git_commit): cint {.importc.}
## *
##  Create a commit object from the given buffer and signature
## 
##  Given the unsigned commit object's contents, its signature and the
##  header field in which to store the signature, attach the signature
##  to the commit and write it into the given repository.
## 
##  @param out the resulting commit id
##  @param commit_content the content of the unsigned commit object
##  @param signature the signature to add to the commit
##  @param signature_field which header field should contain this
##  signature. Leave `NULL` for the default of "gpgsig"
##  @return 0 or an error code
## 

proc git_commit_create_with_signature*(`out`: ptr git_oid; repo: ptr git_repository; 
                                      commit_content: cstring; signature: cstring;
                                      signature_field: cstring): cint {.importc.}
## *
##  Create an in-memory copy of a commit. The copy must be explicitly
##  free'd or it will leak.
## 
##  @param out Pointer to store the copy of the commit
##  @param source Original commit to copy
## 

proc git_commit_dup*(`out`: ptr ptr git_commit; source: ptr git_commit): cint  {.importc.}
## * @}
