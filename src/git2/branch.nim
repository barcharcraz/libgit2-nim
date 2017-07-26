## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 
{.push importc.}
{.push dynlib: "libgit2".}
import
  common, oid, types, buffer

## *
##  @file git2/branch.h
##  @brief Git branch parsing routines
##  @defgroup git_branch Git branch management
##  @ingroup Git
##  @{
## 
## *
##  Create a new branch pointing at a target commit
## 
##  A new direct reference will be created pointing to
##  this target commit. If `force` is true and a reference
##  already exists with the given name, it'll be replaced.
## 
##  The returned reference must be freed by the user.
## 
##  The branch name will be checked for validity.
##  See `git_tag_create()` for rules about valid names.
## 
##  @param out Pointer where to store the underlying reference.
## 
##  @param branch_name Name for the branch; this name is
##  validated for consistency. It should also not conflict with
##  an already existing branch name.
## 
##  @param target Commit to which this branch should point. This object
##  must belong to the given `repo`.
## 
##  @param force Overwrite existing branch.
## 
##  @return 0, GIT_EINVALIDSPEC or an error code.
##  A proper reference is written in the refs/heads namespace
##  pointing to the provided target commit.
## 

proc git_branch_create*(`out`: ptr ptr git_reference; repo: ptr git_repository;
                       branch_name: cstring; target: ptr git_commit; force: cint): cint
## *
##  Create a new branch pointing at a target commit
## 
##  This behaves like `git_branch_create()` but takes an annotated
##  commit, which lets you specify which extended sha syntax string was
##  specified by a user, allowing for more exact reflog messages.
## 
##  See the documentation for `git_branch_create()`.
## 
##  @see git_branch_create
## 

proc git_branch_create_from_annotated*(ref_out: ptr ptr git_reference;
                                      repository: ptr git_repository;
                                      branch_name: cstring;
                                      commit: ptr git_annotated_commit; force: cint): cint
## *
##  Delete an existing branch reference.
## 
##  If the branch is successfully deleted, the passed reference
##  object will be invalidated. The reference must be freed manually
##  by the user.
## 
##  @param branch A valid reference representing a branch
##  @return 0 on success, or an error code.
## 

proc git_branch_delete*(branch: ptr git_reference): cint
## * Iterator type for branches


## *
##  Create an iterator which loops over the requested branches.
## 
##  @param out the iterator
##  @param repo Repository where to find the branches.
##  @param list_flags Filtering flags for the branch
##  listing. Valid values are GIT_BRANCH_LOCAL, GIT_BRANCH_REMOTE
##  or GIT_BRANCH_ALL.
## 
##  @return 0 on success  or an error code
## 

proc git_branch_iterator_new*(`out`: ptr ptr git_branch_iterator;
                             repo: ptr git_repository; list_flags: git_branch_t): cint
## *
##  Retrieve the next branch from the iterator
## 
##  @param out the reference
##  @param out_type the type of branch (local or remote-tracking)
##  @param iter the branch iterator
##  @return 0 on success, GIT_ITEROVER if there are no more branches or an error code.
## 

proc git_branch_next*(`out`: ptr ptr git_reference; out_type: ptr git_branch_t;
                     iter: ptr git_branch_iterator): cint
## *
##  Free a branch iterator
## 
##  @param iter the iterator to free
## 

proc git_branch_iterator_free*(iter: ptr git_branch_iterator)
## *
##  Move/rename an existing local branch reference.
## 
##  The new branch name will be checked for validity.
##  See `git_tag_create()` for rules about valid names.
## 
##  @param branch Current underlying reference of the branch.
## 
##  @param new_branch_name Target name of the branch once the move
##  is performed; this name is validated for consistency.
## 
##  @param force Overwrite existing branch.
## 
##  @return 0 on success, GIT_EINVALIDSPEC or an error code.
## 

proc git_branch_move*(`out`: ptr ptr git_reference; branch: ptr git_reference;
                     new_branch_name: cstring; force: cint): cint
## *
##  Lookup a branch by its name in a repository.
## 
##  The generated reference must be freed by the user.
## 
##  The branch name will be checked for validity.
##  See `git_tag_create()` for rules about valid names.
## 
##  @param out pointer to the looked-up branch reference
## 
##  @param repo the repository to look up the branch
## 
##  @param branch_name Name of the branch to be looked-up;
##  this name is validated for consistency.
## 
##  @param branch_type Type of the considered branch. This should
##  be valued with either GIT_BRANCH_LOCAL or GIT_BRANCH_REMOTE.
## 
##  @return 0 on success; GIT_ENOTFOUND when no matching branch
##  exists, GIT_EINVALIDSPEC, otherwise an error code.
## 

proc git_branch_lookup*(`out`: ptr ptr git_reference; repo: ptr git_repository;
                       branch_name: cstring; branch_type: git_branch_t): cint
## *
##  Return the name of the given local or remote branch.
## 
##  The name of the branch matches the definition of the name
##  for git_branch_lookup. That is, if the returned name is given
##  to git_branch_lookup() then the reference is returned that
##  was given to this function.
## 
##  @param out where the pointer of branch name is stored;
##  this is valid as long as the ref is not freed.
##  @param ref the reference ideally pointing to a branch
## 
##  @return 0 on success; otherwise an error code (e.g., if the
##   ref is no local or remote branch).
## 

proc git_branch_name*(`out`: cstringArray; `ref`: ptr git_reference): cint
## *
##  Return the reference supporting the remote tracking branch,
##  given a local branch reference.
## 
##  @param out Pointer where to store the retrieved
##  reference.
## 
##  @param branch Current underlying reference of the branch.
## 
##  @return 0 on success; GIT_ENOTFOUND when no remote tracking
##  reference exists, otherwise an error code.
## 

proc git_branch_upstream*(`out`: ptr ptr git_reference; branch: ptr git_reference): cint
## *
##  Set the upstream configuration for a given local branch
## 
##  @param branch the branch to configure
## 
##  @param upstream_name remote-tracking or local branch to set as
##  upstream. Pass NULL to unset.
## 
##  @return 0 or an error code
## 

proc git_branch_set_upstream*(branch: ptr git_reference; upstream_name: cstring): cint
## *
##  Return the name of the reference supporting the remote tracking branch,
##  given the name of a local branch reference.
## 
##  @param out Pointer to the user-allocated git_buf which will be
##  filled with the name of the reference.
## 
##  @param repo the repository where the branches live
## 
##  @param refname reference name of the local branch.
## 
##  @return 0, GIT_ENOTFOUND when no remote tracking reference exists,
##      otherwise an error code.
## 

proc git_branch_upstream_name*(`out`: ptr git_buf; repo: ptr git_repository;
                              refname: cstring): cint
## *
##  Determine if the current local branch is pointed at by HEAD.
## 
##  @param branch Current underlying reference of the branch.
## 
##  @return 1 if HEAD points at the branch, 0 if it isn't,
##  error code otherwise.
## 

proc git_branch_is_head*(branch: ptr git_reference): cint
## *
##  Determine if the current branch is checked out in any linked
##  repository.
## 
##  @param branch Reference to the branch.
## 
##  @return 1 if branch is checked out, 0 if it isn't,
##  error code otherwise.
## 

proc git_branch_is_checked_out*(branch: ptr git_reference): cint
## *
##  Return the name of remote that the remote tracking branch belongs to.
## 
##  @param out Pointer to the user-allocated git_buf which will be filled with the name of the remote.
## 
##  @param repo The repository where the branch lives.
## 
##  @param canonical_branch_name name of the remote tracking branch.
## 
##  @return 0, GIT_ENOTFOUND
##      when no remote matching remote was found,
##      GIT_EAMBIGUOUS when the branch maps to several remotes,
##      otherwise an error code.
## 

proc git_branch_remote_name*(`out`: ptr git_buf; repo: ptr git_repository;
                            canonical_branch_name: cstring): cint
## *
##  Retrieve the name fo the upstream remote of a local branch
## 
##  @param buf the buffer into which to write the name
##  @param repo the repository in which to look
##  @param refname the full name of the branch
##  @return 0 or an error code
## 

proc git_branch_upstream_remote*(buf: ptr git_buf; repo: ptr git_repository;
                                refname: cstring): cint
## * @}
