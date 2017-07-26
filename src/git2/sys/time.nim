## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 

import
  git2/common

## *
##  Return a monotonic time value, useful for measuring running time
##  and setting up timeouts.
## 
##  The returned value is an arbitrary point in time -- it can only be
##  used when comparing it to another `git_time_monotonic` call.
## 
##  The time is returned in seconds, with a decimal fraction that differs
##  on accuracy based on the underlying system, but should be least
##  accurate to Nanoseconds.
## 
##  This function cannot fail.
## 

proc git_time_monotonic*(): cdouble