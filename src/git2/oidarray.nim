## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 

{.push dynlib: "libgit2".}
{.push callconv: cdecl.}
import
  common, oid

## * Array of object ids

type
  git_oidarray* {.bycopy.} = object
    ids*: ptr git_oid
    count*: csize


## *
##  Free the OID array
## 
##  This method must (and must only) be called on `git_oidarray`
##  objects where the array is allocated by the library. Not doing so,
##  will result in a memory leak.
## 
##  This does not free the `git_oidarray` itself, since the library will
##  never allocate that object directly itself (it is more commonly embedded
##  inside another struct or created on the stack).
## 
##  @param array git_oidarray from which to free oid data
## 

proc git_oidarray_free*(array: ptr git_oidarray)  {.importc.}
## * @}
