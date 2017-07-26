## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 
{.push importc.}
{.push dynlib: "libgit2".}
import
  common, types, oid, annotated_commit

## *
##  @file git2/rebase.h
##  @brief Git rebase routines
##  @defgroup git_rebase Git merge routines
##  @ingroup Git
##  @{
## 
## *
##  Rebase options
## 
##  Use to tell the rebase machinery how to operate.
## 

type
  git_rebase_options* {.bycopy.} = object
    version*: cuint ## *
                  ##  Used by `git_rebase_init`, this will instruct other clients working
                  ##  on this rebase that you want a quiet rebase experience, which they
                  ##  may choose to provide in an application-specific manner.  This has no
                  ##  effect upon libgit2 directly, but is provided for interoperability
                  ##  between Git tools.
                  ## 
    quiet*: cint ## *
               ##  Used by `git_rebase_init`, this will begin an in-memory rebase,
               ##  which will allow callers to step through the rebase operations and
               ##  commit the rebased changes, but will not rewind HEAD or update the
               ##  repository to be in a rebasing state.  This will not interfere with
               ##  the working directory (if there is one).
               ## 
    inmemory*: cint ## *
                  ##  Used by `git_rebase_finish`, this is the name of the notes reference
                  ##  used to rewrite notes for rebased commits when finishing the rebase;
                  ##  if NULL, the contents of the configuration option `notes.rewriteRef`
                  ##  is examined, unless the configuration option `notes.rewrite.rebase`
                  ##  is set to false.  If `notes.rewriteRef` is also NULL, notes will
                  ##  not be rewritten.
                  ## 
    rewrite_notes_ref*: cstring ## *
                              ##  Options to control how trees are merged during `git_rebase_next`.
                              ## 
    merge_options*: git_merge_options ## *
                                    ##  Options to control how files are written during `git_rebase_init`,
                                    ##  `git_rebase_next` and `git_rebase_abort`.  Note that a minimum
                                    ##  strategy of `GIT_CHECKOUT_SAFE` is defaulted in `init` and `next`,
                                    ##  and a minimum strategy of `GIT_CHECKOUT_FORCE` is defaulted in
                                    ##  `abort` to match git semantics.
                                    ## 
    checkout_options*: git_checkout_options


## *
##  Type of rebase operation in-progress after calling `git_rebase_next`.
## 

type ## *
    ##  The given commit is to be cherry-picked.  The client should commit
    ##  the changes and continue if there are no conflicts.
    ## 
  git_rebase_operation_t* = enum
    GIT_REBASE_OPERATION_PICK = 0, ## *
                                ##  The given commit is to be cherry-picked, but the client should prompt
                                ##  the user to provide an updated commit message.
                                ## 
    GIT_REBASE_OPERATION_REWORD, ## *
                                ##  The given commit is to be cherry-picked, but the client should stop
                                ##  to allow the user to edit the changes before committing them.
                                ## 
    GIT_REBASE_OPERATION_EDIT, ## *
                              ##  The given commit is to be squashed into the previous commit.  The
                              ##  commit message will be merged with the previous message.
                              ## 
    GIT_REBASE_OPERATION_SQUASH, ## *
                                ##  The given commit is to be squashed into the previous commit.  The
                                ##  commit message from this commit will be discarded.
                                ## 
    GIT_REBASE_OPERATION_FIXUP, ## *
                               ##  No commit will be cherry-picked.  The client should run the given
                               ##  command and (if successful) continue.
                               ## 
    GIT_REBASE_OPERATION_EXEC


const
  GIT_REBASE_OPTIONS_VERSION* = 1

## * Indicates that a rebase operation is not (yet) in progress.

const
  GIT_REBASE_NO_OPERATION* = SIZE_MAX

## *
##  A rebase operation
## 
##  Describes a single instruction/operation to be performed during the
##  rebase.
## 

type
  git_rebase_operation* {.bycopy.} = object
    `type`*: git_rebase_operation_t ## * The type of rebase operation.
    ## *
    ##  The commit ID being cherry-picked.  This will be populated for
    ##  all operations except those of type `GIT_REBASE_OPERATION_EXEC`.
    ## 
    id*: git_oid ## *
               ##  The executable the user has requested be run.  This will only
               ##  be populated for operations of type `GIT_REBASE_OPERATION_EXEC`.
               ## 
    exec*: cstring


## *
##  Initializes a `git_rebase_options` with default values. Equivalent to
##  creating an instance with GIT_REBASE_OPTIONS_INIT.
## 
##  @param opts the `git_rebase_options` instance to initialize.
##  @param version the version of the struct; you should pass
##         `GIT_REBASE_OPTIONS_VERSION` here.
##  @return Zero on success; -1 on failure.
## 

proc git_rebase_init_options*(opts: ptr git_rebase_options; version: cuint): cint
## *
##  Initializes a rebase operation to rebase the changes in `branch`
##  relative to `upstream` onto another branch.  To begin the rebase
##  process, call `git_rebase_next`.  When you have finished with this
##  object, call `git_rebase_free`.
## 
##  @param out Pointer to store the rebase object
##  @param repo The repository to perform the rebase
##  @param branch The terminal commit to rebase, or NULL to rebase the
##                current branch
##  @param upstream The commit to begin rebasing from, or NULL to rebase all
##                  reachable commits
##  @param onto The branch to rebase onto, or NULL to rebase onto the given
##              upstream
##  @param opts Options to specify how rebase is performed, or NULL
##  @return Zero on success; -1 on failure.
## 

proc git_rebase_init*(`out`: ptr ptr git_rebase; repo: ptr git_repository;
                     branch: ptr git_annotated_commit;
                     upstream: ptr git_annotated_commit;
                     onto: ptr git_annotated_commit; opts: ptr git_rebase_options): cint
## *
##  Opens an existing rebase that was previously started by either an
##  invocation of `git_rebase_init` or by another client.
## 
##  @param out Pointer to store the rebase object
##  @param repo The repository that has a rebase in-progress
##  @param opts Options to specify how rebase is performed
##  @return Zero on success; -1 on failure.
## 

proc git_rebase_open*(`out`: ptr ptr git_rebase; repo: ptr git_repository;
                     opts: ptr git_rebase_options): cint
## *
##  Gets the count of rebase operations that are to be applied.
## 
##  @param rebase The in-progress rebase
##  @return The number of rebase operations in total
## 

proc git_rebase_operation_entrycount*(rebase: ptr git_rebase): csize
## *
##  Gets the index of the rebase operation that is currently being applied.
##  If the first operation has not yet been applied (because you have
##  called `init` but not yet `next`) then this returns
##  `GIT_REBASE_NO_OPERATION`.
## 
##  @param rebase The in-progress rebase
##  @return The index of the rebase operation currently being applied.
## 

proc git_rebase_operation_current*(rebase: ptr git_rebase): csize
## *
##  Gets the rebase operation specified by the given index.
## 
##  @param rebase The in-progress rebase
##  @param idx The index of the rebase operation to retrieve
##  @return The rebase operation or NULL if `idx` was out of bounds
## 

proc git_rebase_operation_byindex*(rebase: ptr git_rebase; idx: csize): ptr git_rebase_operation
## *
##  Performs the next rebase operation and returns the information about it.
##  If the operation is one that applies a patch (which is any operation except
##  GIT_REBASE_OPERATION_EXEC) then the patch will be applied and the index and
##  working directory will be updated with the changes.  If there are conflicts,
##  you will need to address those before committing the changes.
## 
##  @param operation Pointer to store the rebase operation that is to be performed next
##  @param rebase The rebase in progress
##  @return Zero on success; -1 on failure.
## 

proc git_rebase_next*(operation: ptr ptr git_rebase_operation; rebase: ptr git_rebase): cint
## *
##  Gets the index produced by the last operation, which is the result
##  of `git_rebase_next` and which will be committed by the next
##  invocation of `git_rebase_commit`.  This is useful for resolving
##  conflicts in an in-memory rebase before committing them.  You must
##  call `git_index_free` when you are finished with this.
## 
##  This is only applicable for in-memory rebases; for rebases within
##  a working directory, the changes were applied to the repository's
##  index.
## 

proc git_rebase_inmemory_index*(index: ptr ptr git_index; rebase: ptr git_rebase): cint
## *
##  Commits the current patch.  You must have resolved any conflicts that
##  were introduced during the patch application from the `git_rebase_next`
##  invocation.
## 
##  @param id Pointer in which to store the OID of the newly created commit
##  @param rebase The rebase that is in-progress
##  @param author The author of the updated commit, or NULL to keep the
##         author from the original commit
##  @param committer The committer of the rebase
##  @param message_encoding The encoding for the message in the commit,
##         represented with a standard encoding name.  If message is NULL,
##         this should also be NULL, and the encoding from the original
##         commit will be maintained.  If message is specified, this may be
##         NULL to indicate that "UTF-8" is to be used.
##  @param message The message for this commit, or NULL to use the message
##         from the original commit.
##  @return Zero on success, GIT_EUNMERGED if there are unmerged changes in
##         the index, GIT_EAPPLIED if the current commit has already
##         been applied to the upstream and there is nothing to commit,
##         -1 on failure.
## 

proc git_rebase_commit*(id: ptr git_oid; rebase: ptr git_rebase;
                       author: ptr git_signature; committer: ptr git_signature;
                       message_encoding: cstring; message: cstring): cint
## *
##  Aborts a rebase that is currently in progress, resetting the repository
##  and working directory to their state before rebase began.
## 
##  @param rebase The rebase that is in-progress
##  @return Zero on success; GIT_ENOTFOUND if a rebase is not in progress,
##          -1 on other errors.
## 

proc git_rebase_abort*(rebase: ptr git_rebase): cint
## *
##  Finishes a rebase that is currently in progress once all patches have
##  been applied.
## 
##  @param rebase The rebase that is in-progress
##  @param signature The identity that is finishing the rebase (optional)
##  @return Zero on success; -1 on error
## 

proc git_rebase_finish*(rebase: ptr git_rebase; signature: ptr git_signature): cint
## *
##  Frees the `git_rebase` object.
## 
##  @param rebase The rebase object
## 

proc git_rebase_free*(rebase: ptr git_rebase)
## * @}
