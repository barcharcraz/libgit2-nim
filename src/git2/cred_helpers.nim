## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 
{.push importc.}
{.push dynlib: "libgit2".}
import
  transport

## *
##  @file git2/cred_helpers.h
##  @brief Utility functions for credential management
##  @defgroup git_cred_helpers credential management helpers
##  @ingroup Git
##  @{
## 
## *
##  Payload for git_cred_stock_userpass_plaintext.
## 

type
  git_cred_userpass_payload* {.bycopy.} = object
    username*: cstring
    password*: cstring


## *
##  Stock callback usable as a git_cred_acquire_cb.  This calls
##  git_cred_userpass_plaintext_new unless the protocol has not specified
##  `GIT_CREDTYPE_USERPASS_PLAINTEXT` as an allowed type.
## 
##  @param cred The newly created credential object.
##  @param url The resource for which we are demanding a credential.
##  @param user_from_url The username that was embedded in a "user\@host"
##                           remote url, or NULL if not included.
##  @param allowed_types A bitmask stating which cred types are OK to return.
##  @param payload The payload provided when specifying this callback.  (This is
##         interpreted as a `git_cred_userpass_payload*`.)
## 

proc git_cred_userpass*(cred: ptr ptr git_cred; url: cstring; user_from_url: cstring;
                       allowed_types: cuint; payload: pointer): cint
## * @}
