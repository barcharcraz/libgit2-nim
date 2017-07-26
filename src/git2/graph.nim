## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 
{.push importc.}
{.push dynlib: "libgit2".}
import
  common, types, oid

## *
##  @file git2/graph.h
##  @brief Git graph traversal routines
##  @defgroup git_revwalk Git graph traversal routines
##  @ingroup Git
##  @{
## 
## *
##  Count the number of unique commits between two commit objects
## 
##  There is no need for branches containing the commits to have any
##  upstream relationship, but it helps to think of one as a branch and
##  the other as its upstream, the `ahead` and `behind` values will be
##  what git would report for the branches.
## 
##  @param ahead number of unique from commits in `upstream`
##  @param behind number of unique from commits in `local`
##  @param repo the repository where the commits exist
##  @param local the commit for local
##  @param upstream the commit for upstream
## 

proc git_graph_ahead_behind*(ahead: ptr csize; behind: ptr csize;
                            repo: ptr git_repository; local: ptr git_oid;
                            upstream: ptr git_oid): cint
## *
##  Determine if a commit is the descendant of another commit.
## 
##  @param commit a previously loaded commit.
##  @param ancestor a potential ancestor commit.
##  @return 1 if the given commit is a descendant of the potential ancestor,
##  0 if not, error code otherwise.
## 

proc git_graph_descendant_of*(repo: ptr git_repository; commit: ptr git_oid;
                             ancestor: ptr git_oid): cint
## * @}
