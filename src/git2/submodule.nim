## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 

{.push dynlib: "libgit2".}
{.push callconv: cdecl.}
import
  common, types, oid, remote, checkout, buffer

## *
##  @file git2/submodule.h
##  @brief Git submodule management utilities
## 
##  Submodule support in libgit2 builds a list of known submodules and keeps
##  it in the repository.  The list is built from the .gitmodules file, the
##  .git/config file, the index, and the HEAD tree.  Items in the working
##  directory that look like submodules (i.e. a git repo) but are not
##  mentioned in those places won't be tracked.
## 
##  @defgroup git_submodule Git submodule management routines
##  @ingroup Git
##  @{
## 
## *
##  Return codes for submodule status.
## 
##  A combination of these flags will be returned to describe the status of a
##  submodule.  Depending on the "ignore" property of the submodule, some of
##  the flags may never be returned because they indicate changes that are
##  supposed to be ignored.
## 
##  Submodule info is contained in 4 places: the HEAD tree, the index, config
##  files (both .git/config and .gitmodules), and the working directory.  Any
##  or all of those places might be missing information about the submodule
##  depending on what state the repo is in.  We consider all four places to
##  build the combination of status flags.
## 
##  There are four values that are not really status, but give basic info
##  about what sources of submodule data are available.  These will be
##  returned even if ignore is set to "ALL".
## 
##  * IN_HEAD   - superproject head contains submodule
##  * IN_INDEX  - superproject index contains submodule
##  * IN_CONFIG - superproject gitmodules has submodule
##  * IN_WD     - superproject workdir has submodule
## 
##  The following values will be returned so long as ignore is not "ALL".
## 
##  * INDEX_ADDED       - in index, not in head
##  * INDEX_DELETED     - in head, not in index
##  * INDEX_MODIFIED    - index and head don't match
##  * WD_UNINITIALIZED  - workdir contains empty directory
##  * WD_ADDED          - in workdir, not index
##  * WD_DELETED        - in index, not workdir
##  * WD_MODIFIED       - index and workdir head don't match
## 
##  The following can only be returned if ignore is "NONE" or "UNTRACKED".
## 
##  * WD_INDEX_MODIFIED - submodule workdir index is dirty
##  * WD_WD_MODIFIED    - submodule workdir has modified files
## 
##  Lastly, the following will only be returned for ignore "NONE".
## 
##  * WD_UNTRACKED      - wd contains untracked files
## 

type
  git_submodule_status_t* = enum
    GIT_SUBMODULE_STATUS_IN_HEAD = (1 shl 0),
    GIT_SUBMODULE_STATUS_IN_INDEX = (1 shl 1),
    GIT_SUBMODULE_STATUS_IN_CONFIG = (1 shl 2),
    GIT_SUBMODULE_STATUS_IN_WD = (1 shl 3),
    GIT_SUBMODULE_STATUS_INDEX_ADDED = (1 shl 4),
    GIT_SUBMODULE_STATUS_INDEX_DELETED = (1 shl 5),
    GIT_SUBMODULE_STATUS_INDEX_MODIFIED = (1 shl 6),
    GIT_SUBMODULE_STATUS_WD_UNINITIALIZED = (1 shl 7),
    GIT_SUBMODULE_STATUS_WD_ADDED = (1 shl 8),
    GIT_SUBMODULE_STATUS_WD_DELETED = (1 shl 9),
    GIT_SUBMODULE_STATUS_WD_MODIFIED = (1 shl 10),
    GIT_SUBMODULE_STATUS_WD_INDEX_MODIFIED = (1 shl 11),
    GIT_SUBMODULE_STATUS_WD_WD_MODIFIED = (1 shl 12),
    GIT_SUBMODULE_STATUS_WD_UNTRACKED = (1 shl 13)


const
  GIT_SUBMODULE_STATUS_IN_FLAGS* = 0x0000000F
  GIT_SUBMODULE_STATUS_INDEX_FLAGS* = 0x00000070
  GIT_SUBMODULE_STATUS_WD_FLAGS* = 0x00003F80

template GIT_SUBMODULE_STATUS_IS_UNMODIFIED*(S: untyped): untyped =
  (((S) and not GIT_SUBMODULE_STATUS_IN_FLAGS) == 0)

template GIT_SUBMODULE_STATUS_IS_INDEX_UNMODIFIED*(S: untyped): untyped =
  (((S) and GIT_SUBMODULE_STATUS_INDEX_FLAGS) == 0)

template GIT_SUBMODULE_STATUS_IS_WD_UNMODIFIED*(S: untyped): untyped =
  (((S) and
      (GIT_SUBMODULE_STATUS_WD_FLAGS and
      not GIT_SUBMODULE_STATUS_WD_UNINITIALIZED)) == 0)

template GIT_SUBMODULE_STATUS_IS_WD_DIRTY*(S: untyped): untyped =
  (((S) and
      (GIT_SUBMODULE_STATUS_WD_INDEX_MODIFIED or
      GIT_SUBMODULE_STATUS_WD_WD_MODIFIED or GIT_SUBMODULE_STATUS_WD_UNTRACKED)) !=
      0)

## *
##  Function pointer to receive each submodule
## 
##  @param sm git_submodule currently being visited
##  @param name name of the submodule
##  @param payload value you passed to the foreach function as payload
##  @return 0 on success or error code
## 

type
  git_submodule_cb* = proc (sm: ptr git_submodule; name: cstring; payload: pointer): cint  {.importc.}

## *
##  Submodule update options structure
## 
##  Use the GIT_SUBMODULE_UPDATE_OPTIONS_INIT to get the default settings,
##  like this:
## 
##  git_submodule_update_options opts = GIT_SUBMODULE_UPDATE_OPTIONS_INIT;
## 

type
  git_submodule_update_options* {.bycopy.} = object
    version*: cuint ## *
                  ##  These options are passed to the checkout step. To disable
                  ##  checkout, set the `checkout_strategy` to
                  ##  `GIT_CHECKOUT_NONE`. Generally you will want the use
                  ##  GIT_CHECKOUT_SAFE to update files in the working
                  ##  directory. 
                  ## 
    checkout_opts*: git_checkout_options ## *
                                       ##  Options which control the fetch, including callbacks.
                                       ## 
                                       ##  The callbacks to use for reporting fetch progress, and for acquiring
                                       ##  credentials in the event they are needed.
                                       ## 
    fetch_opts*: git_fetch_options ## *
                                 ##  Allow fetching from the submodule's default remote if the target
                                 ##  commit isn't found. Enabled by default.
                                 ## 
    allow_fetch*: cint


const
  GIT_SUBMODULE_UPDATE_OPTIONS_VERSION* = 1

## *
##  Initializes a `git_submodule_update_options` with default values.
##  Equivalent to creating an instance with GIT_SUBMODULE_UPDATE_OPTIONS_INIT.
## 
##  @param opts The `git_submodule_update_options` instance to initialize.
##  @param version Version of struct; pass `GIT_SUBMODULE_UPDATE_OPTIONS_VERSION`
##  @return Zero on success; -1 on failure.
## 

proc git_submodule_update_init_options*(opts: ptr git_submodule_update_options; 
                                       version: cuint): cint {.importc.}
## *
##  Update a submodule. This will clone a missing submodule and
##  checkout the subrepository to the commit specified in the index of
##  the containing repository. If the submodule repository doesn't contain
##  the target commit (e.g. because fetchRecurseSubmodules isn't set), then
##  the submodule is fetched using the fetch options supplied in options.
## 
##  @param submodule Submodule object
##  @param init If the submodule is not initialized, setting this flag to true
##         will initialize the submodule before updating. Otherwise, this will
##         return an error if attempting to update an uninitialzed repository.
##         but setting this to true forces them to be updated.
##  @param options configuration options for the update.  If NULL, the
##         function works as though GIT_SUBMODULE_UPDATE_OPTIONS_INIT was passed.
##  @return 0 on success, any non-zero return value from a callback
##          function, or a negative value to indicate an error (use
##          `giterr_last` for a detailed error message).
## 

proc git_submodule_update*(submodule: ptr git_submodule; init: cint; 
                          options: ptr git_submodule_update_options): cint {.importc.}
## *
##  Lookup submodule information by name or path.
## 
##  Given either the submodule name or path (they are usually the same), this
##  returns a structure describing the submodule.
## 
##  There are two expected error scenarios:
## 
##  - The submodule is not mentioned in the HEAD, the index, and the config,
##    but does "exist" in the working directory (i.e. there is a subdirectory
##    that appears to be a Git repository).  In this case, this function
##    returns GIT_EEXISTS to indicate a sub-repository exists but not in a
##    state where a git_submodule can be instantiated.
##  - The submodule is not mentioned in the HEAD, index, or config and the
##    working directory doesn't contain a value git repo at that path.
##    There may or may not be anything else at that path, but nothing that
##    looks like a submodule.  In this case, this returns GIT_ENOTFOUND.
## 
##  You must call `git_submodule_free` when done with the submodule.
## 
##  @param out Output ptr to submodule; pass NULL to just get return code
##  @param repo The parent repository
##  @param name The name of or path to the submodule; trailing slashes okay
##  @return 0 on success, GIT_ENOTFOUND if submodule does not exist,
##          GIT_EEXISTS if a repository is found in working directory only,
##          -1 on other errors.
## 

proc git_submodule_lookup*(`out`: ptr ptr git_submodule; repo: ptr git_repository; 
                          name: cstring): cint {.importc.}
## *
##  Release a submodule
## 
##  @param submodule Submodule object
## 

proc git_submodule_free*(submodule: ptr git_submodule)  {.importc.}
## *
##  Iterate over all tracked submodules of a repository.
## 
##  See the note on `git_submodule` above.  This iterates over the tracked
##  submodules as described therein.
## 
##  If you are concerned about items in the working directory that look like
##  submodules but are not tracked, the diff API will generate a diff record
##  for workdir items that look like submodules but are not tracked, showing
##  them as added in the workdir.  Also, the status API will treat the entire
##  subdirectory of a contained git repo as a single GIT_STATUS_WT_NEW item.
## 
##  @param repo The repository
##  @param callback Function to be called with the name of each submodule.
##         Return a non-zero value to terminate the iteration.
##  @param payload Extra data to pass to callback
##  @return 0 on success, -1 on error, or non-zero return value of callback
## 

proc git_submodule_foreach*(repo: ptr git_repository; callback: git_submodule_cb; 
                           payload: pointer): cint {.importc.}
## *
##  Set up a new git submodule for checkout.
## 
##  This does "git submodule add" up to the fetch and checkout of the
##  submodule contents.  It preps a new submodule, creates an entry in
##  .gitmodules and creates an empty initialized repository either at the
##  given path in the working directory or in .git/modules with a gitlink
##  from the working directory to the new repo.
## 
##  To fully emulate "git submodule add" call this function, then open the
##  submodule repo and perform the clone step as needed.  Lastly, call
##  `git_submodule_add_finalize()` to wrap up adding the new submodule and
##  .gitmodules to the index to be ready to commit.
## 
##  You must call `git_submodule_free` on the submodule object when done.
## 
##  @param out The newly created submodule ready to open for clone
##  @param repo The repository in which you want to create the submodule
##  @param url URL for the submodule's remote
##  @param path Path at which the submodule should be created
##  @param use_gitlink Should workdir contain a gitlink to the repo in
##         .git/modules vs. repo directly in workdir.
##  @return 0 on success, GIT_EEXISTS if submodule already exists,
##          -1 on other errors.
## 

proc git_submodule_add_setup*(`out`: ptr ptr git_submodule; repo: ptr git_repository; 
                             url: cstring; path: cstring; use_gitlink: cint): cint {.importc.}
## *
##  Resolve the setup of a new git submodule.
## 
##  This should be called on a submodule once you have called add setup
##  and done the clone of the submodule.  This adds the .gitmodules file
##  and the newly cloned submodule to the index to be ready to be committed
##  (but doesn't actually do the commit).
## 
##  @param submodule The submodule to finish adding.
## 

proc git_submodule_add_finalize*(submodule: ptr git_submodule): cint  {.importc.}
## *
##  Add current submodule HEAD commit to index of superproject.
## 
##  @param submodule The submodule to add to the index
##  @param write_index Boolean if this should immediately write the index
##             file.  If you pass this as false, you will have to get the
##             git_index and explicitly call `git_index_write()` on it to
##             save the change.
##  @return 0 on success, <0 on failure
## 

proc git_submodule_add_to_index*(submodule: ptr git_submodule; write_index: cint): cint  {.importc.}
## *
##  Get the containing repository for a submodule.
## 
##  This returns a pointer to the repository that contains the submodule.
##  This is a just a reference to the repository that was passed to the
##  original `git_submodule_lookup()` call, so if that repository has been
##  freed, then this may be a dangling reference.
## 
##  @param submodule Pointer to submodule object
##  @return Pointer to `git_repository`
## 

proc git_submodule_owner*(submodule: ptr git_submodule): ptr git_repository  {.importc.}
## *
##  Get the name of submodule.
## 
##  @param submodule Pointer to submodule object
##  @return Pointer to the submodule name
## 

proc git_submodule_name*(submodule: ptr git_submodule): cstring  {.importc.}
## *
##  Get the path to the submodule.
## 
##  The path is almost always the same as the submodule name, but the
##  two are actually not required to match.
## 
##  @param submodule Pointer to submodule object
##  @return Pointer to the submodule path
## 

proc git_submodule_path*(submodule: ptr git_submodule): cstring  {.importc.}
## *
##  Get the URL for the submodule.
## 
##  @param submodule Pointer to submodule object
##  @return Pointer to the submodule url
## 

proc git_submodule_url*(submodule: ptr git_submodule): cstring  {.importc.}
## *
##  Resolve a submodule url relative to the given repository.
## 
##  @param out buffer to store the absolute submodule url in
##  @param repo Pointer to repository object
##  @param url Relative url
##  @return 0 or an error code
## 

proc git_submodule_resolve_url*(`out`: ptr git_buf; repo: ptr git_repository; 
                               url: cstring): cint {.importc.}
## *
##  Get the branch for the submodule.
## 
##  @param submodule Pointer to submodule object
##  @return Pointer to the submodule branch
## 

proc git_submodule_branch*(submodule: ptr git_submodule): cstring  {.importc.}
## *
##  Set the branch for the submodule in the configuration
## 
##  After calling this, you may wish to call `git_submodule_sync()` to
##  write the changes to the checked out submodule repository.
## 
##  @param repo the repository to affect
##  @param name the name of the submodule to configure
##  @param branch Branch that should be used for the submodule
##  @return 0 on success, <0 on failure
## 

proc git_submodule_set_branch*(repo: ptr git_repository; name: cstring; 
                              branch: cstring): cint {.importc.}
## *
##  Set the URL for the submodule in the configuration
## 
## 
##  After calling this, you may wish to call `git_submodule_sync()` to
##  write the changes to the checked out submodule repository.
## 
##  @param repo the repository to affect
##  @param name the name of the submodule to configure
##  @param url URL that should be used for the submodule
##  @return 0 on success, <0 on failure
## 

proc git_submodule_set_url*(repo: ptr git_repository; name: cstring; url: cstring): cint  {.importc.}
## *
##  Get the OID for the submodule in the index.
## 
##  @param submodule Pointer to submodule object
##  @return Pointer to git_oid or NULL if submodule is not in index.
## 

proc git_submodule_index_id*(submodule: ptr git_submodule): ptr git_oid  {.importc.}
## *
##  Get the OID for the submodule in the current HEAD tree.
## 
##  @param submodule Pointer to submodule object
##  @return Pointer to git_oid or NULL if submodule is not in the HEAD.
## 

proc git_submodule_head_id*(submodule: ptr git_submodule): ptr git_oid  {.importc.}
## *
##  Get the OID for the submodule in the current working directory.
## 
##  This returns the OID that corresponds to looking up 'HEAD' in the checked
##  out submodule.  If there are pending changes in the index or anything
##  else, this won't notice that.  You should call `git_submodule_status()`
##  for a more complete picture about the state of the working directory.
## 
##  @param submodule Pointer to submodule object
##  @return Pointer to git_oid or NULL if submodule is not checked out.
## 

proc git_submodule_wd_id*(submodule: ptr git_submodule): ptr git_oid  {.importc.}
## *
##  Get the ignore rule that will be used for the submodule.
## 
##  These values control the behavior of `git_submodule_status()` for this
##  submodule.  There are four ignore values:
## 
##   - **GIT_SUBMODULE_IGNORE_NONE** will consider any change to the contents
##     of the submodule from a clean checkout to be dirty, including the
##     addition of untracked files.  This is the default if unspecified.
##   - **GIT_SUBMODULE_IGNORE_UNTRACKED** examines the contents of the
##     working tree (i.e. call `git_status_foreach()` on the submodule) but
##     UNTRACKED files will not count as making the submodule dirty.
##   - **GIT_SUBMODULE_IGNORE_DIRTY** means to only check if the HEAD of the
##     submodule has moved for status.  This is fast since it does not need to
##     scan the working tree of the submodule at all.
##   - **GIT_SUBMODULE_IGNORE_ALL** means not to open the submodule repo.
##     The working directory will be consider clean so long as there is a
##     checked out version present.
## 
##  @param submodule The submodule to check
##  @return The current git_submodule_ignore_t valyue what will be used for
##          this submodule.
## 

proc git_submodule_ignore*(submodule: ptr git_submodule): git_submodule_ignore_t  {.importc.}
## *
##  Set the ignore rule for the submodule in the configuration
## 
##  This does not affect any currently-loaded instances.
## 
##  @param repo the repository to affect
##  @param name the name of the submdule
##  @param ignore The new value for the ignore rule
##  @return 0 or an error code
## 

proc git_submodule_set_ignore*(repo: ptr git_repository; name: cstring; 
                              ignore: git_submodule_ignore_t): cint {.importc.}
## *
##  Get the update rule that will be used for the submodule.
## 
##  This value controls the behavior of the `git submodule update` command.
##  There are four useful values documented with `git_submodule_update_t`.
## 
##  @param submodule The submodule to check
##  @return The current git_submodule_update_t value that will be used
##          for this submodule.
## 

proc git_submodule_update_strategy*(submodule: ptr git_submodule): git_submodule_update_t  {.importc.}
## *
##  Set the update rule for the submodule in the configuration
## 
##  This setting won't affect any existing instances.
## 
##  @param repo the repository to affect
##  @param name the name of the submodule to configure
##  @param update The new value to use
##  @return 0 or an error code
## 

proc git_submodule_set_update*(repo: ptr git_repository; name: cstring; 
                              update: git_submodule_update_t): cint {.importc.}
## *
##  Read the fetchRecurseSubmodules rule for a submodule.
## 
##  This accesses the submodule.<name>.fetchRecurseSubmodules value for
##  the submodule that controls fetching behavior for the submodule.
## 
##  Note that at this time, libgit2 does not honor this setting and the
##  fetch functionality current ignores submodules.
## 
##  @return 0 if fetchRecurseSubmodules is false, 1 if true
## 

proc git_submodule_fetch_recurse_submodules*(submodule: ptr git_submodule): git_submodule_recurse_t  {.importc.}
## *
##  Set the fetchRecurseSubmodules rule for a submodule in the configuration
## 
##  This setting won't affect any existing instances.
## 
##  @param repo the repository to affect
##  @param name the submodule to configure
##  @param fetch_recurse_submodules Boolean value
##  @return old value for fetchRecurseSubmodules
## 

proc git_submodule_set_fetch_recurse_submodules*(repo: ptr git_repository; 
    name: cstring; fetch_recurse_submodules: git_submodule_recurse_t): cint {.importc.}
## *
##  Copy submodule info into ".git/config" file.
## 
##  Just like "git submodule init", this copies information about the
##  submodule into ".git/config".  You can use the accessor functions
##  above to alter the in-memory git_submodule object and control what
##  is written to the config, overriding what is in .gitmodules.
## 
##  @param submodule The submodule to write into the superproject config
##  @param overwrite By default, existing entries will not be overwritten,
##                   but setting this to true forces them to be updated.
##  @return 0 on success, <0 on failure.
## 

proc git_submodule_init*(submodule: ptr git_submodule; overwrite: cint): cint  {.importc.}
## *
##  Set up the subrepository for a submodule in preparation for clone.
## 
##  This function can be called to init and set up a submodule
##  repository from a submodule in preparation to clone it from
##  its remote.
## 
##  @param out Output pointer to the created git repository.
##  @param sm The submodule to create a new subrepository from.
##  @param use_gitlink Should the workdir contain a gitlink to
##         the repo in .git/modules vs. repo directly in workdir.
##  @return 0 on success, <0 on failure.
## 

proc git_submodule_repo_init*(`out`: ptr ptr git_repository; sm: ptr git_submodule; 
                             use_gitlink: cint): cint {.importc.}
## *
##  Copy submodule remote info into submodule repo.
## 
##  This copies the information about the submodules URL into the checked out
##  submodule config, acting like "git submodule sync".  This is useful if
##  you have altered the URL for the submodule (or it has been altered by a
##  fetch of upstream changes) and you need to update your local repo.
## 

proc git_submodule_sync*(submodule: ptr git_submodule): cint  {.importc.}
## *
##  Open the repository for a submodule.
## 
##  This is a newly opened repository object.  The caller is responsible for
##  calling `git_repository_free()` on it when done.  Multiple calls to this
##  function will return distinct `git_repository` objects.  This will only
##  work if the submodule is checked out into the working directory.
## 
##  @param repo Pointer to the submodule repo which was opened
##  @param submodule Submodule to be opened
##  @return 0 on success, <0 if submodule repo could not be opened.
## 

proc git_submodule_open*(repo: ptr ptr git_repository; submodule: ptr git_submodule): cint  {.importc.}
## *
##  Reread submodule info from config, index, and HEAD.
## 
##  Call this to reread cached submodule information for this submodule if
##  you have reason to believe that it has changed.
## 
##  @param submodule The submodule to reload
##  @param force Force reload even if the data doesn't seem out of date
##  @return 0 on success, <0 on error
## 

proc git_submodule_reload*(submodule: ptr git_submodule; force: cint): cint  {.importc.}
## *
##  Get the status for a submodule.
## 
##  This looks at a submodule and tries to determine the status.  It
##  will return a combination of the `GIT_SUBMODULE_STATUS` values above.
##  How deeply it examines the working directory to do this will depend
##  on the `git_submodule_ignore_t` value for the submodule.
## 
##  @param status Combination of `GIT_SUBMODULE_STATUS` flags
##  @param repo the repository in which to look
##  @param name name of the submodule
##  @param ignore the ignore rules to follow
##  @return 0 on success, <0 on error
## 

proc git_submodule_status*(status: ptr cuint; repo: ptr git_repository; name: cstring; 
                          ignore: git_submodule_ignore_t): cint {.importc.}
## *
##  Get the locations of submodule information.
## 
##  This is a bit like a very lightweight version of `git_submodule_status`.
##  It just returns a made of the first four submodule status values (i.e.
##  the ones like GIT_SUBMODULE_STATUS_IN_HEAD, etc) that tell you where the
##  submodule data comes from (i.e. the HEAD commit, gitmodules file, etc.).
##  This can be useful if you want to know if the submodule is present in the
##  working directory at this point in time, etc.
## 
##  @param location_status Combination of first four `GIT_SUBMODULE_STATUS` flags
##  @param submodule Submodule for which to get status
##  @return 0 on success, <0 on error
## 

proc git_submodule_location*(location_status: ptr cuint; 
                            submodule: ptr git_submodule): cint {.importc.}
## * @}
