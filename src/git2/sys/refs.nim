## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 

import
  git2/common, git2/types, git2/oid

## *
##  @file git2/sys/refs.h
##  @brief Low-level Git ref creation
##  @defgroup git_backend Git custom backend APIs
##  @ingroup Git
##  @{
## 
## *
##  Create a new direct reference from an OID.
## 
##  @param name the reference name
##  @param oid the object id for a direct reference
##  @param peel the first non-tag object's OID, or NULL
##  @return the created git_reference or NULL on error
## 

proc git_reference__alloc*(name: cstring; oid: ptr git_oid; peel: ptr git_oid): ptr git_reference
## *
##  Create a new symbolic reference.
## 
##  @param name the reference name
##  @param target the target for a symbolic reference
##  @return the created git_reference or NULL on error
## 

proc git_reference__alloc_symbolic*(name: cstring; target: cstring): ptr git_reference
## * @}
