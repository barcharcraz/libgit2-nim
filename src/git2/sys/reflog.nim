## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 

import
  git2/common, git2/types, git2/oid

proc git_reflog_entry__alloc*(): ptr git_reflog_entry  {.importc.}
proc git_reflog_entry__free*(entry: ptr git_reflog_entry)  {.importc.}