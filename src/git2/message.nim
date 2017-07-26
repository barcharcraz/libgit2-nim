## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 

{.push dynlib: "libgit2".}
{.push callconv: cdecl.}
import
  common, buffer

## *
##  @file git2/message.h
##  @brief Git message management routines
##  @ingroup Git
##  @{
## 
## *
##  Clean up message from excess whitespace and make sure that the last line
##  ends with a '\n'.
## 
##  Optionally, can remove lines starting with a "#".
## 
##  @param out The user-allocated git_buf which will be filled with the
##      cleaned up message.
## 
##  @param message The message to be prettified.
## 
##  @param strip_comments Non-zero to remove comment lines, 0 to leave them in.
## 
##  @param comment_char Comment character. Lines starting with this character
##  are considered to be comments and removed if `strip_comments` is non-zero.
## 
##  @return 0 or an error code.
## 

proc git_message_prettify*(`out`: ptr git_buf; message: cstring; strip_comments: cint; 
                          comment_char: char): cint {.importc.}
## * @}
