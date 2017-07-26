## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 
{.push importc.}
{.push dynlib: "libgit2".}
import
  common
type git_repository* = object
type git_worktree* = object
type git_odb* = object
type git_reference* = object
type git_config* = object
type git_refdb* = object
type git_index* = object
type git_annotated_commit* = object
type git_object* = object
type git_blob* = object
type git_blame* = object
type git_commit* = object
type git_branch_iterator* = object  

## *
##  @file git2/types.h
##  @brief libgit2 base & compatibility types
##  @ingroup Git
##  @{
## 
## *
##  Cross-platform compatibility types for off_t / time_t
## 
##  NOTE: This needs to be in a public header so that both the library
##  implementation and client applications both agree on the same types.
##  Otherwise we get undefined behavior.
## 
##  Use the "best" types that each platform provides. Currently we truncate
##  these intermediate representations for compatibility with the git ABI, but
##  if and when it changes to support 64 bit types, our code will naturally
##  adapt.
##  NOTE: These types should match those that are returned by our internal
##  stat() functions, for all platforms.
## 


## 
##  Note: Can't use off_t since if a client program includes <sys/types.h>
##  before us (directly or indirectly), they'll get 32 bit off_t in their client
##  app, even though /we/ define _FILE_OFFSET_BITS=64.
## 
type
  git_off_t* = int64
  git_time_t* = int64
## * Basic type (loose or packed) of any Git object.

type
  git_otype* = enum
    GIT_OBJ_ANY = - 2,           ## *< Object can be any of the following
    GIT_OBJ_BAD = - 1,           ## *< Object is invalid.
    GIT_OBJ_EXT1 = 0,          ## *< Reserved for future use.
    GIT_OBJ_COMMIT = 1,         ## *< A commit object.
    GIT_OBJ_TREE = 2,           ## *< A tree (directory listing) object.
    GIT_OBJ_BLOB = 3,           ## *< A file revision object.
    GIT_OBJ_TAG = 4,            ## *< An annotated tag object.
    GIT_OBJ_EXT2 = 5,          ## *< Reserved for future use.
    GIT_OBJ_OFS_DELTA = 6,      ## *< A delta, base is given by an offset.
    GIT_OBJ_REF_DELTA = 7       ## *< A delta, base is given by object id.


## * An open object database handle.


## * A custom backend in an ODB


## * An object read from the ODB


## * A stream to read/write from the ODB


## * A stream to write a packfile to the ODB


## * An open refs database handle.


## * A custom backend for refs


## *
##  Representation of an existing git repository,
##  including all its object contents
## 


## * Representation of a working tree


## * Representation of a generic object in a repository


## * Representation of an in-progress walk through the commits in a repo


## * Parsed representation of a tag object.


## * In-memory representation of a blob object.


## * Parsed representation of a commit object.


## * Representation of each one of the entries in a tree object.


## * Representation of a tree object.


## * Constructor for in-memory trees


## * Memory representation of an index file.


## * An iterator for conflicts in the index.


## * Memory representation of a set of config files


## * Interface to access a configuration file


## * Representation of a reference log entry


## * Representation of a reference log


## * Representation of a git note


## * Representation of a git packbuilder


## * Time in a signature

type
  git_time* {.bycopy.} = object
    time*: git_time_t          ## *< time in seconds from epoch
    offset*: cint              ## *< timezone offset, in minutes
  

## * An action signature (e.g. for committers, taggers, etc)

type
  git_signature* {.bycopy.} = object
    name*: cstring             ## *< full name of the author
    email*: cstring            ## *< email of the author
    `when`*: git_time          ## *< time when the action happened
  

## * In-memory representation of a reference.


## * Iterator for references


## * Transactional interface to references


## * Annotated commits, the input to merge and rebase.


## * Merge result


## * Representation of a status collection


## * Representation of a rebase


## * Basic type of any Git reference.

type
  git_ref_t* = enum
    GIT_REF_INVALID = 0,        ## *< Invalid reference
    GIT_REF_OID = 1,            ## *< A reference which points at an object id
    GIT_REF_SYMBOLIC = 2,       ## *< A reference which points at another reference
    GIT_REF_LISTALL = ord(GIT_REF_OID) or ord(GIT_REF_SYMBOLIC)


## * Basic type of any Git branch.

type
  git_branch_t* = enum
    GIT_BRANCH_LOCAL = 1, GIT_BRANCH_REMOTE = 2,
    GIT_BRANCH_ALL = ord(GIT_BRANCH_LOCAL) or ord(GIT_BRANCH_REMOTE)


## * Valid modes for index and tree entries.

type
  git_filemode_t* = enum
    GIT_FILEMODE_UNREADABLE = 0, GIT_FILEMODE_BLOB = 0o000000100644,
    GIT_FILEMODE_BLOB_EXECUTABLE = 0o000000100755, GIT_FILEMODE_TREE = 40000,
    GIT_FILEMODE_LINK = 0o000000120000, GIT_FILEMODE_COMMIT = 0o000000160000


## 
##  A refspec specifies the mapping between remote and local reference
##  names when fetch or pushing.
## 


## *
##  Git's idea of a remote repository. A remote can be anonymous (in
##  which case it does not have backing configuration entires).
## 


## *
##  Interface which represents a transport to communicate with a
##  remote.
## 


## *
##  Preparation for a push operation. Can be used to configure what to
##  push and the level of parallelism of the packfile builder.
## 


##  documentation in the definition


## *
##  This is passed as the first argument to the callback to allow the
##  user to see the progress.
## 
##  - total_objects: number of objects in the packfile being downloaded
##  - indexed_objects: received objects that have been hashed
##  - received_objects: objects which have been downloaded
##  - local_objects: locally-available objects that have been injected
##     in order to fix a thin pack.
##  - received-bytes: size of the packfile received up to now
## 

type
  git_transfer_progress* {.bycopy.} = object
    total_objects*: cuint
    indexed_objects*: cuint
    received_objects*: cuint
    local_objects*: cuint
    total_deltas*: cuint
    indexed_deltas*: cuint
    received_bytes*: csize


## *
##  Type for progress callbacks during indexing.  Return a value less than zero
##  to cancel the transfer.
## 
##  @param stats Structure containing information about the state of the transfer
##  @param payload Payload provided by caller
## 

type
  git_transfer_progress_cb* = proc (stats: ptr git_transfer_progress; payload: pointer): cint

## *
##  Type for messages delivered by the transport.  Return a negative value
##  to cancel the network operation.
## 
##  @param str The message from the transport
##  @param len The length of the message
##  @param payload Payload provided by the caller
## 

type
  git_transport_message_cb* = proc (str: cstring; len: cint; payload: pointer): cint

## *
##  Type of host certificate structure that is passed to the check callback
## 

type ## *
    ##  No information about the certificate is available. This may
    ##  happen when using curl.
    ## 
  git_cert_t* = enum
    GIT_CERT_NONE, ## *
                  ##  The `data` argument to the callback will be a pointer to
                  ##  the DER-encoded data.
                  ## 
    GIT_CERT_X509, ## *
                  ##  The `data` argument to the callback will be a pointer to a
                  ##  `git_cert_hostkey` structure.
                  ## 
    GIT_CERT_HOSTKEY_LIBSSH2, ## *
                             ##  The `data` argument to the callback will be a pointer to a
                             ##  `git_strarray` with `name:content` strings containing
                             ##  information about the certificate. This is used when using
                             ##  curl.
                             ## 
    GIT_CERT_STRARRAY


## *
##  Parent type for `git_cert_hostkey` and `git_cert_x509`.
## 

type
  git_cert* {.bycopy.} = object
    cert_type*: git_cert_t     ## *
                         ##  Type of certificate. A `GIT_CERT_` value.
                         ## 
  

## *
##  Callback for the user's custom certificate checks.
## 
##  @param cert The host certificate
##  @param valid Whether the libgit2 checks (OpenSSL or WinHTTP) think
##  this certificate is valid
##  @param host Hostname of the host libgit2 connected to
##  @param payload Payload provided by the caller
## 

type
  git_transport_certificate_check_cb* = proc (cert: ptr git_cert; valid: cint;
      host: cstring; payload: pointer): cint

## *
##  Opaque structure representing a submodule.
## 


## *
##  Submodule update values
## 
##  These values represent settings for the `submodule.$name.update`
##  configuration value which says how to handle `git submodule update` for
##  this submodule.  The value is usually set in the ".gitmodules" file and
##  copied to ".git/config" when the submodule is initialized.
## 
##  You can override this setting on a per-submodule basis with
##  `git_submodule_set_update()` and write the changed value to disk using
##  `git_submodule_save()`.  If you have overwritten the value, you can
##  revert it by passing `GIT_SUBMODULE_UPDATE_RESET` to the set function.
## 
##  The values are:
## 
##  - GIT_SUBMODULE_UPDATE_CHECKOUT: the default; when a submodule is
##    updated, checkout the new detached HEAD to the submodule directory.
##  - GIT_SUBMODULE_UPDATE_REBASE: update by rebasing the current checked
##    out branch onto the commit from the superproject.
##  - GIT_SUBMODULE_UPDATE_MERGE: update by merging the commit in the
##    superproject into the current checkout out branch of the submodule.
##  - GIT_SUBMODULE_UPDATE_NONE: do not update this submodule even when
##    the commit in the superproject is updated.
##  - GIT_SUBMODULE_UPDATE_DEFAULT: not used except as static initializer
##    when we don't want any particular update rule to be specified.
## 

type
  git_submodule_update_t* = enum
    GIT_SUBMODULE_UPDATE_DEFAULT = 0, GIT_SUBMODULE_UPDATE_CHECKOUT = 1,
    GIT_SUBMODULE_UPDATE_REBASE = 2, GIT_SUBMODULE_UPDATE_MERGE = 3,
    GIT_SUBMODULE_UPDATE_NONE = 4


## *
##  Submodule ignore values
## 
##  These values represent settings for the `submodule.$name.ignore`
##  configuration value which says how deeply to look at the working
##  directory when getting submodule status.
## 
##  You can override this value in memory on a per-submodule basis with
##  `git_submodule_set_ignore()` and can write the changed value to disk
##  with `git_submodule_save()`.  If you have overwritten the value, you
##  can revert to the on disk value by using `GIT_SUBMODULE_IGNORE_RESET`.
## 
##  The values are:
## 
##  - GIT_SUBMODULE_IGNORE_UNSPECIFIED: use the submodule's configuration
##  - GIT_SUBMODULE_IGNORE_NONE: don't ignore any change - i.e. even an
##    untracked file, will mark the submodule as dirty.  Ignored files are
##    still ignored, of course.
##  - GIT_SUBMODULE_IGNORE_UNTRACKED: ignore untracked files; only changes
##    to tracked files, or the index or the HEAD commit will matter.
##  - GIT_SUBMODULE_IGNORE_DIRTY: ignore changes in the working directory,
##    only considering changes if the HEAD of submodule has moved from the
##    value in the superproject.
##  - GIT_SUBMODULE_IGNORE_ALL: never check if the submodule is dirty
##  - GIT_SUBMODULE_IGNORE_DEFAULT: not used except as static initializer
##    when we don't want any particular ignore rule to be specified.
## 

type
  git_submodule_ignore_t* = enum
    GIT_SUBMODULE_IGNORE_UNSPECIFIED = - 1, ## *< use the submodule's configuration
    GIT_SUBMODULE_IGNORE_NONE = 1, ## *< any change or untracked == dirty
    GIT_SUBMODULE_IGNORE_UNTRACKED = 2, ## *< dirty if tracked files change
    GIT_SUBMODULE_IGNORE_DIRTY = 3, ## *< only dirty if HEAD moved
    GIT_SUBMODULE_IGNORE_ALL = 4 ## *< never dirty


## *
##  Options for submodule recurse.
## 
##  Represent the value of `submodule.$name.fetchRecurseSubmodules`
## 
##  * GIT_SUBMODULE_RECURSE_NO    - do no recurse into submodules
##  * GIT_SUBMODULE_RECURSE_YES   - recurse into submodules
##  * GIT_SUBMODULE_RECURSE_ONDEMAND - recurse into submodules only when
##                                     commit not already in local clone
## 

type
  git_submodule_recurse_t* = enum
    GIT_SUBMODULE_RECURSE_NO = 0, GIT_SUBMODULE_RECURSE_YES = 1,
    GIT_SUBMODULE_RECURSE_ONDEMAND = 2


## * A type to write in a streaming fashion, for example, for filters.

type
  git_writestream* {.bycopy.} = object
    write*: proc (stream: ptr git_writestream; buffer: cstring; len: csize): cint
    close*: proc (stream: ptr git_writestream): cint
    free*: proc (stream: ptr git_writestream)


## * @}
