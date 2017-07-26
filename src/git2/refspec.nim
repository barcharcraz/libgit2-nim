## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 

{.push dynlib: "libgit2".}
{.push callconv: cdecl.}
import
  common, types, net, buffer

## *
##  @file git2/refspec.h
##  @brief Git refspec attributes
##  @defgroup git_refspec Git refspec attributes
##  @ingroup Git
##  @{
## 
## *
##  Get the source specifier
## 
##  @param refspec the refspec
##  @return the refspec's source specifier
## 

proc git_refspec_src*(refspec: ptr git_refspec): cstring  {.importc.}
## *
##  Get the destination specifier
## 
##  @param refspec the refspec
##  @return the refspec's destination specifier
## 

proc git_refspec_dst*(refspec: ptr git_refspec): cstring  {.importc.}
## *
##  Get the refspec's string
## 
##  @param refspec the refspec
##  @returns the refspec's original string
## 

proc git_refspec_string*(refspec: ptr git_refspec): cstring  {.importc.}
## *
##  Get the force update setting
## 
##  @param refspec the refspec
##  @return 1 if force update has been set, 0 otherwise
## 

proc git_refspec_force*(refspec: ptr git_refspec): cint  {.importc.}
## *
##  Get the refspec's direction.
## 
##  @param spec refspec
##  @return GIT_DIRECTION_FETCH or GIT_DIRECTION_PUSH
## 

proc git_refspec_direction*(spec: ptr git_refspec): git_direction  {.importc.}
## *
##  Check if a refspec's source descriptor matches a reference 
## 
##  @param refspec the refspec
##  @param refname the name of the reference to check
##  @return 1 if the refspec matches, 0 otherwise
## 

proc git_refspec_src_matches*(refspec: ptr git_refspec; refname: cstring): cint  {.importc.}
## *
##  Check if a refspec's destination descriptor matches a reference
## 
##  @param refspec the refspec
##  @param refname the name of the reference to check
##  @return 1 if the refspec matches, 0 otherwise
## 

proc git_refspec_dst_matches*(refspec: ptr git_refspec; refname: cstring): cint  {.importc.}
## *
##  Transform a reference to its target following the refspec's rules
## 
##  @param out where to store the target name
##  @param spec the refspec
##  @param name the name of the reference to transform
##  @return 0, GIT_EBUFS or another error
## 

proc git_refspec_transform*(`out`: ptr git_buf; spec: ptr git_refspec; name: cstring): cint  {.importc.}
## *
##  Transform a target reference to its source reference following the refspec's rules
## 
##  @param out where to store the source reference name
##  @param spec the refspec
##  @param name the name of the reference to transform
##  @return 0, GIT_EBUFS or another error
## 

proc git_refspec_rtransform*(`out`: ptr git_buf; spec: ptr git_refspec; name: cstring): cint  {.importc.}