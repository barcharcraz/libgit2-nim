## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 

{.push dynlib: "libgit2".}
{.push callconv: cdecl.}
import
  common, types, oid, checkout

## *
##  @file git2/stash.h
##  @brief Git stash management routines
##  @ingroup Git
##  @{
## 
## *
##  Stash flags
## 

type                          ## *
    ##  No option, default
    ## 
  git_stash_flags* = enum
    GIT_STASH_DEFAULT = 0, ## *
                        ##  All changes already added to the index are left intact in
                        ##  the working directory
                        ## 
    GIT_STASH_KEEP_INDEX = (1 shl 0), ## *
                                 ##  All untracked files are also stashed and then cleaned up
                                 ##  from the working directory
                                 ## 
    GIT_STASH_INCLUDE_UNTRACKED = (1 shl 1), ## *
                                        ##  All ignored files are also stashed and then cleaned up from
                                        ##  the working directory
                                        ## 
    GIT_STASH_INCLUDE_IGNORED = (1 shl 2)


## *
##  Save the local modifications to a new stash.
## 
##  @param out Object id of the commit containing the stashed state.
##  This commit is also the target of the direct reference refs/stash.
## 
##  @param repo The owning repository.
## 
##  @param stasher The identity of the person performing the stashing.
## 
##  @param message Optional description along with the stashed state.
## 
##  @param flags Flags to control the stashing process. (see GIT_STASH_* above)
## 
##  @return 0 on success, GIT_ENOTFOUND where there's nothing to stash,
##  or error code.
## 

proc git_stash_save*(`out`: ptr git_oid; repo: ptr git_repository; 
                    stasher: ptr git_signature; message: cstring; flags: uint32): cint {.importc.}
## * Stash application flags.

type
  git_stash_apply_flags* = enum
    GIT_STASH_APPLY_DEFAULT = 0, ##  Try to reinstate not only the working tree's changes,
                              ##  but also the index's changes.
                              ## 
    GIT_STASH_APPLY_REINSTATE_INDEX = (1 shl 0)
  git_stash_apply_progress_t* = enum
    GIT_STASH_APPLY_PROGRESS_NONE = 0, ## * Loading the stashed data from the object database.
    GIT_STASH_APPLY_PROGRESS_LOADING_STASH, ## * The stored index is being analyzed.
    GIT_STASH_APPLY_PROGRESS_ANALYZE_INDEX, ## * The modified files are being analyzed.
    GIT_STASH_APPLY_PROGRESS_ANALYZE_MODIFIED, ## * The untracked and ignored files are being analyzed.
    GIT_STASH_APPLY_PROGRESS_ANALYZE_UNTRACKED, ## * The untracked files are being written to disk.
    GIT_STASH_APPLY_PROGRESS_CHECKOUT_UNTRACKED, ## * The modified files are being written to disk.
    GIT_STASH_APPLY_PROGRESS_CHECKOUT_MODIFIED, ## * The stash was applied successfully.
    GIT_STASH_APPLY_PROGRESS_DONE



## *
##  Stash application progress notification function.
##  Return 0 to continue processing, or a negative value to
##  abort the stash application.
## 

type
  git_stash_apply_progress_cb* = proc (progress: git_stash_apply_progress_t; 
                                    payload: pointer): cint {.importc.}

## * Stash application options structure.
## 
##  Initialize with the `GIT_STASH_APPLY_OPTIONS_INIT` macro to set
##  sensible defaults; for example:
## 
## 		git_stash_apply_options opts = GIT_STASH_APPLY_OPTIONS_INIT;
## 

type
  git_stash_apply_options* {.bycopy.} = object
    version*: cuint            ## * See `git_stash_apply_flags_t`, above.
    flags*: git_stash_apply_flags ## * Options to use when writing files to the working directory.
    checkout_options*: git_checkout_options ## * Optional callback to notify the consumer of application progress.
    progress_cb*: git_stash_apply_progress_cb
    progress_payload*: pointer


const
  GIT_STASH_APPLY_OPTIONS_VERSION* = 1

## *
##  Initializes a `git_stash_apply_options` with default values. Equivalent to
##  creating an instance with GIT_STASH_APPLY_OPTIONS_INIT.
## 
##  @param opts the `git_stash_apply_options` instance to initialize.
##  @param version the version of the struct; you should pass
##         `GIT_STASH_APPLY_OPTIONS_INIT` here.
##  @return Zero on success; -1 on failure.
## 

proc git_stash_apply_init_options*(opts: ptr git_stash_apply_options; version: cuint): cint  {.importc.}
## *
##  Apply a single stashed state from the stash list.
## 
##  If local changes in the working directory conflict with changes in the
##  stash then GIT_EMERGECONFLICT will be returned.  In this case, the index
##  will always remain unmodified and all files in the working directory will
##  remain unmodified.  However, if you are restoring untracked files or
##  ignored files and there is a conflict when applying the modified files,
##  then those files will remain in the working directory.
## 
##  If passing the GIT_STASH_APPLY_REINSTATE_INDEX flag and there would be
##  conflicts when reinstating the index, the function will return
##  GIT_EMERGECONFLICT and both the working directory and index will be left
##  unmodified.
## 
##  Note that a minimum checkout strategy of `GIT_CHECKOUT_SAFE` is implied.
## 
##  @param repo The owning repository.
##  @param index The position within the stash list. 0 points to the
##               most recent stashed state.
##  @param options Optional options to control how stashes are applied.
## 
##  @return 0 on success, GIT_ENOTFOUND if there's no stashed state for the
##          given index, GIT_EMERGECONFLICT if changes exist in the working
##          directory, or an error code
## 

proc git_stash_apply*(repo: ptr git_repository; index: csize; 
                     options: ptr git_stash_apply_options): cint {.importc.}
## *
##  This is a callback function you can provide to iterate over all the
##  stashed states that will be invoked per entry.
## 
##  @param index The position within the stash list. 0 points to the
##               most recent stashed state.
##  @param message The stash message.
##  @param stash_id The commit oid of the stashed state.
##  @param payload Extra parameter to callback function.
##  @return 0 to continue iterating or non-zero to stop.
## 

type
  git_stash_cb* = proc (index: csize; message: cstring; stash_id: ptr git_oid; 
                     payload: pointer): cint {.importc.}

## *
##  Loop over all the stashed states and issue a callback for each one.
## 
##  If the callback returns a non-zero value, this will stop looping.
## 
##  @param repo Repository where to find the stash.
## 
##  @param callback Callback to invoke per found stashed state. The most
##                  recent stash state will be enumerated first.
## 
##  @param payload Extra parameter to callback function.
## 
##  @return 0 on success, non-zero callback return value, or error code.
## 

proc git_stash_foreach*(repo: ptr git_repository; callback: git_stash_cb; 
                       payload: pointer): cint {.importc.}
## *
##  Remove a single stashed state from the stash list.
## 
##  @param repo The owning repository.
## 
##  @param index The position within the stash list. 0 points to the
##  most recent stashed state.
## 
##  @return 0 on success, GIT_ENOTFOUND if there's no stashed state for the given
##  index, or error code.
## 

proc git_stash_drop*(repo: ptr git_repository; index: csize): cint  {.importc.}
## *
##  Apply a single stashed state from the stash list and remove it from the list
##  if successful.
## 
##  @param repo The owning repository.
##  @param index The position within the stash list. 0 points to the
##               most recent stashed state.
##  @param options Optional options to control how stashes are applied.
## 
##  @return 0 on success, GIT_ENOTFOUND if there's no stashed state for the given
##  index, or error code. (see git_stash_apply() above for details)
## 

proc git_stash_pop*(repo: ptr git_repository; index: csize; 
                   options: ptr git_stash_apply_options): cint {.importc.}
## * @}
