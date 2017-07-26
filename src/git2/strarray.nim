## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 

{.push dynlib: "libgit2".}
{.push callconv: cdecl.}
import
  common

## *
##  @file git2/strarray.h
##  @brief Git string array routines
##  @defgroup git_strarray Git string array routines
##  @ingroup Git
##  @{
## 
## * Array of strings

type
  git_strarray* {.bycopy.} = object
    strings*: cstringArray
    count*: csize


## *
##  Close a string array object
## 
##  This method should be called on `git_strarray` objects where the strings
##  array is allocated and contains allocated strings, such as what you
##  would get from `git_strarray_copy()`.  Not doing so, will result in a
##  memory leak.
## 
##  This does not free the `git_strarray` itself, since the library will
##  never allocate that object directly itself (it is more commonly embedded
##  inside another struct or created on the stack).
## 
##  @param array git_strarray from which to free string data
## 

proc git_strarray_free*(array: ptr git_strarray)  {.importc.}
## *
##  Copy a string array object from source to target.
## 
##  Note: target is overwritten and hence should be empty, otherwise its
##  contents are leaked.  Call git_strarray_free() if necessary.
## 
##  @param tgt target
##  @param src source
##  @return 0 on success, < 0 on allocation failure
## 

proc git_strarray_copy*(tgt: ptr git_strarray; src: ptr git_strarray): cint  {.importc.}
## * @}
