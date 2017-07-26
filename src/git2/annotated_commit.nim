## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 

{.push dynlib: "libgit2".}
{.push callconv: cdecl.}
import
  common, repository, types, oid

## *
##  @file git2/annotated_commit.h
##  @brief Git annotated commit routines
##  @defgroup git_annotated_commit Git annotated commit routines
##  @ingroup Git
##  @{
## 
## *
##  Creates a `git_annotated_commit` from the given reference.
##  The resulting git_annotated_commit must be freed with
##  `git_annotated_commit_free`.
## 
##  @param out pointer to store the git_annotated_commit result in
##  @param repo repository that contains the given reference
##  @param ref reference to use to lookup the git_annotated_commit
##  @return 0 on success or error code
## 

proc git_annotated_commit_from_ref*(`out`: ptr ptr git_annotated_commit;
                                   repo: ptr git_repository;
                                   `ref`: ptr git_reference): cint {.importc.}
## *
##  Creates a `git_annotated_commit` from the given fetch head data.
##  The resulting git_annotated_commit must be freed with
##  `git_annotated_commit_free`.
## 
##  @param out pointer to store the git_annotated_commit result in
##  @param repo repository that contains the given commit
##  @param branch_name name of the (remote) branch
##  @param remote_url url of the remote
##  @param id the commit object id of the remote branch
##  @return 0 on success or error code
## 

proc git_annotated_commit_from_fetchhead*(`out`: ptr ptr git_annotated_commit; 
    repo: ptr git_repository; branch_name: cstring; remote_url: cstring;
    id: ptr git_oid): cint {.importc.}
## *
##  Creates a `git_annotated_commit` from the given commit id.
##  The resulting git_annotated_commit must be freed with
##  `git_annotated_commit_free`.
## 
##  An annotated commit contains information about how it was
##  looked up, which may be useful for functions like merge or
##  rebase to provide context to the operation.  For example,
##  conflict files will include the name of the source or target
##  branches being merged.  It is therefore preferable to use the
##  most specific function (eg `git_annotated_commit_from_ref`)
##  instead of this one when that data is known.
## 
##  @param out pointer to store the git_annotated_commit result in
##  @param repo repository that contains the given commit
##  @param id the commit object id to lookup
##  @return 0 on success or error code
## 

proc git_annotated_commit_lookup*(`out`: ptr ptr git_annotated_commit; 
                                 repo: ptr git_repository; id: ptr git_oid): cint {.importc.}
## *
##  Creates a `git_annotated_comit` from a revision string.
## 
##  See `man gitrevisions`, or
##  http://git-scm.com/docs/git-rev-parse.html#_specifying_revisions for
##  information on the syntax accepted.
## 
##  @param out pointer to store the git_annotated_commit result in
##  @param repo repository that contains the given commit
##  @param revspec the extended sha syntax string to use to lookup the commit
##  @return 0 on success or error code
## 

proc git_annotated_commit_from_revspec*(`out`: ptr ptr git_annotated_commit; 
                                       repo: ptr git_repository; revspec: cstring): cint {.importc.}
## *
##  Gets the commit ID that the given `git_annotated_commit` refers to.
## 
##  @param commit the given annotated commit
##  @return commit id
## 

proc git_annotated_commit_id*(commit: ptr git_annotated_commit): ptr git_oid  {.importc.}
## *
##  Frees a `git_annotated_commit`.
## 
##  @param commit annotated commit to free
## 

proc git_annotated_commit_free*(commit: ptr git_annotated_commit) {.importc.}
## * @}
