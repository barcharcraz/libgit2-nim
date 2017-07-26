## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 

{.push dynlib: "libgit2".}
{.push callconv: cdecl.}
import
  common, types, oid, refs

## *
##  @file git2/refdb.h
##  @brief Git custom refs backend functions
##  @defgroup git_refdb Git custom refs backend API
##  @ingroup Git
##  @{
## 
## *
##  Create a new reference database with no backends.
## 
##  Before the Ref DB can be used for read/writing, a custom database
##  backend must be manually set using `git_refdb_set_backend()`
## 
##  @param out location to store the database pointer, if opened.
## 			Set to NULL if the open failed.
##  @param repo the repository
##  @return 0 or an error code
## 

proc git_refdb_new*(`out`: ptr ptr git_refdb; repo: ptr git_repository): cint  {.importc.}
## *
##  Create a new reference database and automatically add
##  the default backends:
## 
##   - git_refdb_dir: read and write loose and packed refs
##       from disk, assuming the repository dir as the folder
## 
##  @param out location to store the database pointer, if opened.
## 			Set to NULL if the open failed.
##  @param repo the repository
##  @return 0 or an error code
## 

proc git_refdb_open*(`out`: ptr ptr git_refdb; repo: ptr git_repository): cint  {.importc.}
## *
##  Suggests that the given refdb compress or optimize its references.
##  This mechanism is implementation specific.  For on-disk reference
##  databases, for example, this may pack all loose references.
## 

proc git_refdb_compress*(refdb: ptr git_refdb): cint  {.importc.}
## *
##  Close an open reference database.
## 
##  @param refdb reference database pointer or NULL
## 

proc git_refdb_free*(refdb: ptr git_refdb)  {.importc.}
## * @}
