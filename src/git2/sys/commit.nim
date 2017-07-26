## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 

import
  git2/common, git2/types, git2/oid

## *
##  @file git2/sys/commit.h
##  @brief Low-level Git commit creation
##  @defgroup git_backend Git custom backend APIs
##  @ingroup Git
##  @{
## 
## *
##  Create new commit in the repository from a list of `git_oid` values.
## 
##  See documentation for `git_commit_create()` for information about the
##  parameters, as the meaning is identical excepting that `tree` and
##  `parents` now take `git_oid`.  This is a dangerous API in that nor
##  the `tree`, neither the `parents` list of `git_oid`s are checked for
##  validity.
## 
##  @see git_commit_create
## 

proc git_commit_create_from_ids*(id: ptr git_oid; repo: ptr git_repository;
                                update_ref: cstring; author: ptr git_signature;
                                committer: ptr git_signature;
                                message_encoding: cstring; message: cstring;
                                tree: ptr git_oid; parent_count: csize;
                                parents: ptr ptr git_oid): cint
## *
##  Callback function to return parents for commit.
## 
##  This is invoked with the count of the number of parents processed so far
##  along with the user supplied payload.  This should return a git_oid of
##  the next parent or NULL if all parents have been provided.
## 

type
  git_commit_parent_callback* = proc (idx: csize; payload: pointer): ptr git_oid

## *
##  Create a new commit in the repository with an callback to supply parents.
## 
##  See documentation for `git_commit_create()` for information about the
##  parameters, as the meaning is identical excepting that `tree` takes a
##  `git_oid` and doesn't check for validity, and `parent_cb` is invoked
##  with `parent_payload` and should return `git_oid` values or NULL to
##  indicate that all parents are accounted for.
## 
##  @see git_commit_create
## 

proc git_commit_create_from_callback*(id: ptr git_oid; repo: ptr git_repository;
                                     update_ref: cstring;
                                     author: ptr git_signature;
                                     committer: ptr git_signature;
                                     message_encoding: cstring; message: cstring;
                                     tree: ptr git_oid;
                                     parent_cb: git_commit_parent_callback;
                                     parent_payload: pointer): cint
## * @}
