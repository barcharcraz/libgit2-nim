## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 
{.push importc.}
{.push dynlib: "libgit2".}
import
  common, repository, refspec, net, indexer, strarray, transport, pack, proxy

## *
##  @file git2/remote.h
##  @brief Git remote management functions
##  @defgroup git_remote remote management functions
##  @ingroup Git
##  @{
## 
## *
##  Add a remote with the default fetch refspec to the repository's configuration.
## 
##  @param out the resulting remote
##  @param repo the repository in which to create the remote
##  @param name the remote's name
##  @param url the remote's url
##  @return 0, GIT_EINVALIDSPEC, GIT_EEXISTS or an error code
## 

proc git_remote_create*(`out`: ptr ptr git_remote; repo: ptr git_repository;
                       name: cstring; url: cstring): cint
## *
##  Add a remote with the provided fetch refspec (or default if NULL) to the repository's
##  configuration.
## 
##  @param out the resulting remote
##  @param repo the repository in which to create the remote
##  @param name the remote's name
##  @param url the remote's url
##  @param fetch the remote fetch value
##  @return 0, GIT_EINVALIDSPEC, GIT_EEXISTS or an error code
## 

proc git_remote_create_with_fetchspec*(`out`: ptr ptr git_remote;
                                      repo: ptr git_repository; name: cstring;
                                      url: cstring; fetch: cstring): cint
## *
##  Create an anonymous remote
## 
##  Create a remote with the given url in-memory. You can use this when
##  you have a URL instead of a remote's name.
## 
##  @param out pointer to the new remote objects
##  @param repo the associated repository
##  @param url the remote repository's URL
##  @return 0 or an error code
## 

proc git_remote_create_anonymous*(`out`: ptr ptr git_remote;
                                 repo: ptr git_repository; url: cstring): cint
## *
##  Get the information for a particular remote
## 
##  The name will be checked for validity.
##  See `git_tag_create()` for rules about valid names.
## 
##  @param out pointer to the new remote object
##  @param repo the associated repository
##  @param name the remote's name
##  @return 0, GIT_ENOTFOUND, GIT_EINVALIDSPEC or an error code
## 

proc git_remote_lookup*(`out`: ptr ptr git_remote; repo: ptr git_repository;
                       name: cstring): cint
## *
##  Create a copy of an existing remote.  All internal strings are also
##  duplicated. Callbacks are not duplicated.
## 
##  Call `git_remote_free` to free the data.
## 
##  @param dest pointer where to store the copy
##  @param source object to copy
##  @return 0 or an error code
## 

proc git_remote_dup*(dest: ptr ptr git_remote; source: ptr git_remote): cint
## *
##  Get the remote's repository
## 
##  @param remote the remote
##  @return a pointer to the repository
## 

proc git_remote_owner*(remote: ptr git_remote): ptr git_repository
## *
##  Get the remote's name
## 
##  @param remote the remote
##  @return a pointer to the name or NULL for in-memory remotes
## 

proc git_remote_name*(remote: ptr git_remote): cstring
## *
##  Get the remote's url
## 
##  If url.*.insteadOf has been configured for this URL, it will
##  return the modified URL.
## 
##  @param remote the remote
##  @return a pointer to the url
## 

proc git_remote_url*(remote: ptr git_remote): cstring
## *
##  Get the remote's url for pushing
## 
##  If url.*.pushInsteadOf has been configured for this URL, it
##  will return the modified URL.
## 
##  @param remote the remote
##  @return a pointer to the url or NULL if no special url for pushing is set
## 

proc git_remote_pushurl*(remote: ptr git_remote): cstring
## *
##  Set the remote's url in the configuration
## 
##  Remote objects already in memory will not be affected. This assumes
##  the common case of a single-url remote and will otherwise return an error.
## 
##  @param repo the repository in which to perform the change
##  @param remote the remote's name
##  @param url the url to set
##  @return 0 or an error value
## 

proc git_remote_set_url*(repo: ptr git_repository; remote: cstring; url: cstring): cint
## *
##  Set the remote's url for pushing in the configuration.
## 
##  Remote objects already in memory will not be affected. This assumes
##  the common case of a single-url remote and will otherwise return an error.
## 
## 
##  @param repo the repository in which to perform the change
##  @param remote the remote's name
##  @param url the url to set
## 

proc git_remote_set_pushurl*(repo: ptr git_repository; remote: cstring; url: cstring): cint
## *
##  Add a fetch refspec to the remote's configuration
## 
##  Add the given refspec to the fetch list in the configuration. No
##  loaded remote instances will be affected.
## 
##  @param repo the repository in which to change the configuration
##  @param remote the name of the remote to change
##  @param refspec the new fetch refspec
##  @return 0, GIT_EINVALIDSPEC if refspec is invalid or an error value
## 

proc git_remote_add_fetch*(repo: ptr git_repository; remote: cstring; refspec: cstring): cint
## *
##  Get the remote's list of fetch refspecs
## 
##  The memory is owned by the user and should be freed with
##  `git_strarray_free`.
## 
##  @param array pointer to the array in which to store the strings
##  @param remote the remote to query
## 

proc git_remote_get_fetch_refspecs*(array: ptr git_strarray; remote: ptr git_remote): cint
## *
##  Add a push refspec to the remote's configuration
## 
##  Add the given refspec to the push list in the configuration. No
##  loaded remote instances will be affected.
## 
##  @param repo the repository in which to change the configuration
##  @param remote the name of the remote to change
##  @param refspec the new push refspec
##  @return 0, GIT_EINVALIDSPEC if refspec is invalid or an error value
## 

proc git_remote_add_push*(repo: ptr git_repository; remote: cstring; refspec: cstring): cint
## *
##  Get the remote's list of push refspecs
## 
##  The memory is owned by the user and should be freed with
##  `git_strarray_free`.
## 
##  @param array pointer to the array in which to store the strings
##  @param remote the remote to query
## 

proc git_remote_get_push_refspecs*(array: ptr git_strarray; remote: ptr git_remote): cint
## *
##  Get the number of refspecs for a remote
## 
##  @param remote the remote
##  @return the amount of refspecs configured in this remote
## 

proc git_remote_refspec_count*(remote: ptr git_remote): csize
## *
##  Get a refspec from the remote
## 
##  @param remote the remote to query
##  @param n the refspec to get
##  @return the nth refspec
## 

proc git_remote_get_refspec*(remote: ptr git_remote; n: csize): ptr git_refspec
## *
##  Open a connection to a remote
## 
##  The transport is selected based on the URL. The direction argument
##  is due to a limitation of the git protocol (over TCP or SSH) which
##  starts up a specific binary which can only do the one or the other.
## 
##  @param remote the remote to connect to
##  @param direction GIT_DIRECTION_FETCH if you want to fetch or
##  GIT_DIRECTION_PUSH if you want to push
##  @param callbacks the callbacks to use for this connection
##  @param proxy_opts proxy settings
##  @param custom_headers extra HTTP headers to use in this connection
##  @return 0 or an error code
## 

proc git_remote_connect*(remote: ptr git_remote; direction: git_direction;
                        callbacks: ptr git_remote_callbacks;
                        proxy_opts: ptr git_proxy_options;
                        custom_headers: ptr git_strarray): cint
## *
##  Get the remote repository's reference advertisement list
## 
##  Get the list of references with which the server responds to a new
##  connection.
## 
##  The remote (or more exactly its transport) must have connected to
##  the remote repository. This list is available as soon as the
##  connection to the remote is initiated and it remains available
##  after disconnecting.
## 
##  The memory belongs to the remote. The pointer will be valid as long
##  as a new connection is not initiated, but it is recommended that
##  you make a copy in order to make use of the data.
## 
##  @param out pointer to the array
##  @param size the number of remote heads
##  @param remote the remote
##  @return 0 on success, or an error code
## 

proc git_remote_ls*(`out`: ptr ptr ptr git_remote_head; size: ptr csize;
                   remote: ptr git_remote): cint
## *
##  Check whether the remote is connected
## 
##  Check whether the remote's underlying transport is connected to the
##  remote host.
## 
##  @param remote the remote
##  @return 1 if it's connected, 0 otherwise.
## 

proc git_remote_connected*(remote: ptr git_remote): cint
## *
##  Cancel the operation
## 
##  At certain points in its operation, the network code checks whether
##  the operation has been cancelled and if so stops the operation.
## 
##  @param remote the remote
## 

proc git_remote_stop*(remote: ptr git_remote)
## *
##  Disconnect from the remote
## 
##  Close the connection to the remote.
## 
##  @param remote the remote to disconnect from
## 

proc git_remote_disconnect*(remote: ptr git_remote)
## *
##  Free the memory associated with a remote
## 
##  This also disconnects from the remote, if the connection
##  has not been closed yet (using git_remote_disconnect).
## 
##  @param remote the remote to free
## 

proc git_remote_free*(remote: ptr git_remote)
## *
##  Get a list of the configured remotes for a repo
## 
##  The string array must be freed by the user.
## 
##  @param out a string array which receives the names of the remotes
##  @param repo the repository to query
##  @return 0 or an error code
## 

proc git_remote_list*(`out`: ptr git_strarray; repo: ptr git_repository): cint
## *
##  Argument to the completion callback which tells it which operation
##  finished.
## 

type
  git_remote_completion_type* = enum
    GIT_REMOTE_COMPLETION_DOWNLOAD, GIT_REMOTE_COMPLETION_INDEXING,
    GIT_REMOTE_COMPLETION_ERROR


## * Push network progress notification function

type
  git_push_transfer_progress* = proc (current: cuint; total: cuint; bytes: csize;
                                   payload: pointer): cint

## *
##  Represents an update which will be performed on the remote during push
## 

type
  git_push_update* {.bycopy.} = object
    src_refname*: cstring      ## *
                        ##  The source name of the reference
                        ## 
    ## *
    ##  The name of the reference to update on the server
    ## 
    dst_refname*: cstring      ## *
                        ##  The current target of the reference
                        ## 
    src*: git_oid              ## *
                ##  The new target for the reference
                ## 
    dst*: git_oid


## *
##  Callback used to inform of upcoming updates.
## 
##  @param updates an array containing the updates which will be sent
##  as commands to the destination.
##  @param len number of elements in `updates`
##  @param payload Payload provided by the caller
## 

type
  git_push_negotiation* = proc (updates: ptr ptr git_push_update; len: csize;
                             payload: pointer): cint

## *
##  The callback settings structure
## 
##  Set the callbacks to be called by the remote when informing the user
##  about the progress of the network operations.
## 

type
  git_remote_callbacks* {.bycopy.} = object
    version*: cuint ## *
                  ##  Textual progress from the remote. Text send over the
                  ##  progress side-band will be passed to this function (this is
                  ##  the 'counting objects' output).
                  ## 
    sideband_progress*: git_transport_message_cb ## *
                                               ##  Completion is called when different parts of the download
                                               ##  process are done (currently unused).
                                               ## 
    completion*: proc (`type`: git_remote_completion_type; data: pointer): cint ## *
                                                                         ##  This will be called if the remote host requires
                                                                         ##  authentication in order to connect to it.
                                                                         ## 
                                                                         ##  Returning GIT_PASSTHROUGH will make libgit2 behave as
                                                                         ##  though this field isn't set.
                                                                         ## 
    credentials*: git_cred_acquire_cb ## *
                                    ##  If cert verification fails, this will be called to let the
                                    ##  user make the final decision of whether to allow the
                                    ##  connection to proceed. Returns 1 to allow the connection, 0
                                    ##  to disallow it or a negative value to indicate an error.
                                    ## 
    certificate_check*: git_transport_certificate_check_cb ## *
                                                         ##  During the download of new data, this will be regularly
                                                         ##  called with the current count of progress done by the
                                                         ##  indexer.
                                                         ## 
    transfer_progress*: git_transfer_progress_cb ## *
                                               ##  Each time a reference is updated locally, this function
                                               ##  will be called with information about it.
                                               ## 
    update_tips*: proc (refname: cstring; a: ptr git_oid; b: ptr git_oid; data: pointer): cint ## *
                                                                                  ##  Function to call with progress information during pack
                                                                                  ##  building. Be aware that this is called inline with pack
                                                                                  ##  building operations, so performance may be affected.
                                                                                  ## 
    pack_progress*: git_packbuilder_progress ## *
                                           ##  Function to call with progress information during the
                                           ##  upload portion of a push. Be aware that this is called
                                           ##  inline with pack building operations, so performance may be
                                           ##  affected.
                                           ## 
    push_transfer_progress*: git_push_transfer_progress ## *
                                                      ##  Called for each updated reference on push. If `status` is
                                                      ##  not `NULL`, the update was rejected by the remote server
                                                      ##  and `status` contains the reason given.
                                                      ## 
    push_update_reference*: proc (refname: cstring; status: cstring; data: pointer): cint ## *
                                                                                 ##  Called once between the negotiation step and the upload. It
                                                                                 ##  provides information about what updates will be performed.
                                                                                 ## 
    push_negotiation*: git_push_negotiation ## *
                                          ##  Create the transport to use for this operation. Leave NULL
                                          ##  to auto-detect.
                                          ## 
    transport*: git_transport_cb ## *
                               ##  This will be passed to each of the callbacks in this struct
                               ##  as the last parameter.
                               ## 
    payload*: pointer


const
  GIT_REMOTE_CALLBACKS_VERSION* = 1

## *
##  Initializes a `git_remote_callbacks` with default values. Equivalent to
##  creating an instance with GIT_REMOTE_CALLBACKS_INIT.
## 
##  @param opts the `git_remote_callbacks` struct to initialize
##  @param version Version of struct; pass `GIT_REMOTE_CALLBACKS_VERSION`
##  @return Zero on success; -1 on failure.
## 

proc git_remote_init_callbacks*(opts: ptr git_remote_callbacks; version: cuint): cint
type                          ## *
    ##  Use the setting from the configuration
    ## 
  git_fetch_prune_t* = enum
    GIT_FETCH_PRUNE_UNSPECIFIED, ## *
                                ##  Force pruning on
                                ## 
    GIT_FETCH_PRUNE,          ## *
                    ##  Force pruning off
                    ## 
    GIT_FETCH_NO_PRUNE


## *
##  Automatic tag following option
## 
##  Lets us select the --tags option to use.
## 

type                          ## *
    ##  Use the setting from the configuration.
    ## 
  git_remote_autotag_option_t* = enum
    GIT_REMOTE_DOWNLOAD_TAGS_UNSPECIFIED = 0, ## *
                                           ##  Ask the server for tags pointing to objects we're already
                                           ##  downloading.
                                           ## 
    GIT_REMOTE_DOWNLOAD_TAGS_AUTO, ## *
                                  ##  Don't ask for any tags beyond the refspecs.
                                  ## 
    GIT_REMOTE_DOWNLOAD_TAGS_NONE, ## *
                                  ##  Ask for the all the tags.
                                  ## 
    GIT_REMOTE_DOWNLOAD_TAGS_ALL


## *
##  Fetch options structure.
## 
##  Zero out for defaults.  Initialize with `GIT_FETCH_OPTIONS_INIT` macro to
##  correctly set the `version` field.  E.g.
## 
## 		git_fetch_options opts = GIT_FETCH_OPTIONS_INIT;
## 

type
  git_fetch_options* {.bycopy.} = object
    version*: cint             ## *
                 ##  Callbacks to use for this fetch operation
                 ## 
    callbacks*: git_remote_callbacks ## *
                                   ##  Whether to perform a prune after the fetch
                                   ## 
    prune*: git_fetch_prune_t ## *
                            ##  Whether to write the results to FETCH_HEAD. Defaults to
                            ##  on. Leave this default in order to behave like git.
                            ## 
    update_fetchhead*: cint ## *
                          ##  Determines how to behave regarding tags on the remote, such
                          ##  as auto-downloading tags for objects we're downloading or
                          ##  downloading all of them.
                          ## 
                          ##  The default is to auto-follow tags.
                          ## 
    download_tags*: git_remote_autotag_option_t ## *
                                              ##  Proxy options to use, by default no proxy is used.
                                              ## 
    proxy_opts*: git_proxy_options ## *
                                 ##  Extra headers for this fetch operation
                                 ## 
    custom_headers*: git_strarray


const
  GIT_FETCH_OPTIONS_VERSION* = 1

## *
##  Initializes a `git_fetch_options` with default values. Equivalent to
##  creating an instance with GIT_FETCH_OPTIONS_INIT.
## 
##  @param opts the `git_fetch_options` instance to initialize.
##  @param version the version of the struct; you should pass
##         `GIT_FETCH_OPTIONS_VERSION` here.
##  @return Zero on success; -1 on failure.
## 

proc git_fetch_init_options*(opts: ptr git_fetch_options; version: cuint): cint
## *
##  Controls the behavior of a git_push object.
## 

type
  git_push_options* {.bycopy.} = object
    version*: cuint ## *
                  ##  If the transport being used to push to the remote requires the creation
                  ##  of a pack file, this controls the number of worker threads used by
                  ##  the packbuilder when creating that pack file to be sent to the remote.
                  ## 
                  ##  If set to 0, the packbuilder will auto-detect the number of threads
                  ##  to create. The default value is 1.
                  ## 
    pb_parallelism*: cuint     ## *
                         ##  Callbacks to use for this push operation
                         ## 
    callbacks*: git_remote_callbacks ## *
                                   ##  Proxy options to use, by default no proxy is used.
                                   ## 
    proxy_opts*: git_proxy_options ## *
                                 ##  Extra headers for this push operation
                                 ## 
    custom_headers*: git_strarray


const
  GIT_PUSH_OPTIONS_VERSION* = 1

## *
##  Initializes a `git_push_options` with default values. Equivalent to
##  creating an instance with GIT_PUSH_OPTIONS_INIT.
## 
##  @param opts the `git_push_options` instance to initialize.
##  @param version the version of the struct; you should pass
##         `GIT_PUSH_OPTIONS_VERSION` here.
##  @return Zero on success; -1 on failure.
## 

proc git_push_init_options*(opts: ptr git_push_options; version: cuint): cint
## *
##  Download and index the packfile
## 
##  Connect to the remote if it hasn't been done yet, negotiate with
##  the remote git which objects are missing, download and index the
##  packfile.
## 
##  The .idx file will be created and both it and the packfile with be
##  renamed to their final name.
## 
##  @param remote the remote
##  @param refspecs the refspecs to use for this negotiation and
##  download. Use NULL or an empty array to use the base refspecs
##  @param opts the options to use for this fetch
##  @return 0 or an error code
## 

proc git_remote_download*(remote: ptr git_remote; refspecs: ptr git_strarray;
                         opts: ptr git_fetch_options): cint
## *
##  Create a packfile and send it to the server
## 
##  Connect to the remote if it hasn't been done yet, negotiate with
##  the remote git which objects are missing, create a packfile with the missing objects and send it.
## 
##  @param remote the remote
##  @param refspecs the refspecs to use for this negotiation and
##  upload. Use NULL or an empty array to use the base refspecs
##  @param opts the options to use for this push
##  @return 0 or an error code
## 

proc git_remote_upload*(remote: ptr git_remote; refspecs: ptr git_strarray;
                       opts: ptr git_push_options): cint
## *
##  Update the tips to the new state
## 
##  @param remote the remote to update
##  @param reflog_message The message to insert into the reflogs. If
##  NULL and fetching, the default is "fetch <name>", where <name> is
##  the name of the remote (or its url, for in-memory remotes). This
##  parameter is ignored when pushing.
##  @param callbacks  pointer to the callback structure to use
##  @param update_fetchhead whether to write to FETCH_HEAD. Pass 1 to behave like git.
##  @param download_tags what the behaviour for downloading tags is for this fetch. This is
##  ignored for push. This must be the same value passed to `git_remote_download()`.
##  @return 0 or an error code
## 

proc git_remote_update_tips*(remote: ptr git_remote;
                            callbacks: ptr git_remote_callbacks;
                            update_fetchhead: cint;
                            download_tags: git_remote_autotag_option_t;
                            reflog_message: cstring): cint
## *
##  Download new data and update tips
## 
##  Convenience function to connect to a remote, download the data,
##  disconnect and update the remote-tracking branches.
## 
##  @param remote the remote to fetch from
##  @param refspecs the refspecs to use for this fetch. Pass NULL or an
##                  empty array to use the base refspecs.
##  @param opts options to use for this fetch
##  @param reflog_message The message to insert into the reflogs. If NULL, the
## 								 default is "fetch"
##  @return 0 or an error code
## 

proc git_remote_fetch*(remote: ptr git_remote; refspecs: ptr git_strarray;
                      opts: ptr git_fetch_options; reflog_message: cstring): cint
## *
##  Prune tracking refs that are no longer present on remote
## 
##  @param remote the remote to prune
##  @param callbacks callbacks to use for this prune
##  @return 0 or an error code
## 

proc git_remote_prune*(remote: ptr git_remote; callbacks: ptr git_remote_callbacks): cint
## *
##  Perform a push
## 
##  Peform all the steps from a push.
## 
##  @param remote the remote to push to
##  @param refspecs the refspecs to use for pushing. If NULL or an empty
##                  array, the configured refspecs will be used
##  @param opts options to use for this push
## 

proc git_remote_push*(remote: ptr git_remote; refspecs: ptr git_strarray;
                     opts: ptr git_push_options): cint
## *
##  Get the statistics structure that is filled in by the fetch operation.
## 

proc git_remote_stats*(remote: ptr git_remote): ptr git_transfer_progress
## *
##  Retrieve the tag auto-follow setting
## 
##  @param remote the remote to query
##  @return the auto-follow setting
## 

proc git_remote_autotag*(remote: ptr git_remote): git_remote_autotag_option_t
## *
##  Set the remote's tag following setting.
## 
##  The change will be made in the configuration. No loaded remotes
##  will be affected.
## 
##  @param repo the repository in which to make the change
##  @param remote the name of the remote
##  @param value the new value to take.
## 

proc git_remote_set_autotag*(repo: ptr git_repository; remote: cstring;
                            value: git_remote_autotag_option_t): cint
## *
##  Retrieve the ref-prune setting
## 
##  @param remote the remote to query
##  @return the ref-prune setting
## 

proc git_remote_prune_refs*(remote: ptr git_remote): cint
## *
##  Give the remote a new name
## 
##  All remote-tracking branches and configuration settings
##  for the remote are updated.
## 
##  The new name will be checked for validity.
##  See `git_tag_create()` for rules about valid names.
## 
##  No loaded instances of a the remote with the old name will change
##  their name or their list of refspecs.
## 
##  @param problems non-default refspecs cannot be renamed and will be
##  stored here for further processing by the caller. Always free this
##  strarray on successful return.
##  @param repo the repository in which to rename
##  @param name the current name of the remote
##  @param new_name the new name the remote should bear
##  @return 0, GIT_EINVALIDSPEC, GIT_EEXISTS or an error code
## 

proc git_remote_rename*(problems: ptr git_strarray; repo: ptr git_repository;
                       name: cstring; new_name: cstring): cint
## *
##  Ensure the remote name is well-formed.
## 
##  @param remote_name name to be checked.
##  @return 1 if the reference name is acceptable; 0 if it isn't
## 

proc git_remote_is_valid_name*(remote_name: cstring): cint
## *
##  Delete an existing persisted remote.
## 
##  All remote-tracking branches and configuration settings
##  for the remote will be removed.
## 
##  @param repo the repository in which to act
##  @param name the name of the remote to delete
##  @return 0 on success, or an error code.
## 

proc git_remote_delete*(repo: ptr git_repository; name: cstring): cint
## *
##  Retrieve the name of the remote's default branch
## 
##  The default branch of a repository is the branch which HEAD points
##  to. If the remote does not support reporting this information
##  directly, it performs the guess as git does; that is, if there are
##  multiple branches which point to the same commit, the first one is
##  chosen. If the master branch is a candidate, it wins.
## 
##  This function must only be called after connecting.
## 
##  @param out the buffern in which to store the reference name
##  @param remote the remote
##  @return 0, GIT_ENOTFOUND if the remote does not have any references
##  or none of them point to HEAD's commit, or an error message.
## 

proc git_remote_default_branch*(`out`: ptr git_buf; remote: ptr git_remote): cint
## * @}
