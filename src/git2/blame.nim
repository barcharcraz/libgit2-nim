## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 

import
  common, oid, types

## *
##  @file git2/blame.h
##  @brief Git blame routines
##  @defgroup git_blame Git blame routines
##  @ingroup Git
##  @{
## 
## *
##  Flags for indicating option behavior for git_blame APIs.
## 

type                          ## * Normal blame, the default
  git_blame_flag_t* = enum
    GIT_BLAME_NORMAL = 0, ## * Track lines that have moved within a file (like `git blame -M`).
                       ##  NOT IMPLEMENTED.
    GIT_BLAME_TRACK_COPIES_SAME_FILE = (1 shl 0), ## * Track lines that have moved across files in the same commit (like `git blame -C`).
                                             ##  NOT IMPLEMENTED.
    GIT_BLAME_TRACK_COPIES_SAME_COMMIT_MOVES = (1 shl 1), ## * Track lines that have been copied from another file that exists in the
                                                     ##  same commit (like `git blame -CC`). Implies SAME_FILE.
                                                     ##  NOT IMPLEMENTED.
    GIT_BLAME_TRACK_COPIES_SAME_COMMIT_COPIES = (1 shl 2), ## * Track lines that have been copied from another file that exists in *any*
                                                      ##  commit (like `git blame -CCC`). Implies SAME_COMMIT_COPIES.
                                                      ##  NOT IMPLEMENTED.
    GIT_BLAME_TRACK_COPIES_ANY_COMMIT_COPIES = (1 shl 3), ## * Restrict the search of commits to those reachable following only the
                                                     ##  first parents.
    GIT_BLAME_FIRST_PARENT = (1 shl 4)


## *
##  Blame options structure
## 
##  Use zeros to indicate default settings.  It's easiest to use the
##  `GIT_BLAME_OPTIONS_INIT` macro:
##      git_blame_options opts = GIT_BLAME_OPTIONS_INIT;
## 
##  - `flags` is a combination of the `git_blame_flag_t` values above.
##  - `min_match_characters` is the lower bound on the number of alphanumeric
##    characters that must be detected as moving/copying within a file for it to
##    associate those lines with the parent commit. The default value is 20.
##    This value only takes effect if any of the `GIT_BLAME_TRACK_COPIES_*`
##    flags are specified.
##  - `newest_commit` is the id of the newest commit to consider.  The default
##                    is HEAD.
##  - `oldest_commit` is the id of the oldest commit to consider.  The default
##                    is the first commit encountered with a NULL parent.
## 	- `min_line` is the first line in the file to blame.  The default is 1 (line
## 	             numbers start with 1).
## 	- `max_line` is the last line in the file to blame.  The default is the last
## 	             line of the file.
## 

type
  git_blame_options* {.bycopy.} = object
    version*: cuint
    flags*: uint32
    min_match_characters*: uint16
    newest_commit*: git_oid
    oldest_commit*: git_oid
    min_line*: csize
    max_line*: csize


const
  GIT_BLAME_OPTIONS_VERSION* = 1

## *
##  Initializes a `git_blame_options` with default values. Equivalent to
##  creating an instance with GIT_BLAME_OPTIONS_INIT.
## 
##  @param opts The `git_blame_options` struct to initialize
##  @param version Version of struct; pass `GIT_BLAME_OPTIONS_VERSION`
##  @return Zero on success; -1 on failure.
## 

proc git_blame_init_options*(opts: ptr git_blame_options; version: cuint): cint  {.importc.}
## *
##  Structure that represents a blame hunk.
## 
##  - `lines_in_hunk` is the number of lines in this hunk
##  - `final_commit_id` is the OID of the commit where this line was last
##    changed.
##  - `final_start_line_number` is the 1-based line number where this hunk
##    begins, in the final version of the file
##  - `orig_commit_id` is the OID of the commit where this hunk was found.  This
##    will usually be the same as `final_commit_id`, except when
##    `GIT_BLAME_TRACK_COPIES_ANY_COMMIT_COPIES` has been specified.
##  - `orig_path` is the path to the file where this hunk originated, as of the
##    commit specified by `orig_commit_id`.
##  - `orig_start_line_number` is the 1-based line number where this hunk begins
##    in the file named by `orig_path` in the commit specified by
##    `orig_commit_id`.
##  - `boundary` is 1 iff the hunk has been tracked to a boundary commit (the
##    root, or the commit specified in git_blame_options.oldest_commit)
## 

type
  git_blame_hunk* {.bycopy.} = object
    lines_in_hunk*: csize
    final_commit_id*: git_oid
    final_start_line_number*: csize
    final_signature*: ptr git_signature
    orig_commit_id*: git_oid
    orig_path*: cstring
    orig_start_line_number*: csize
    orig_signature*: ptr git_signature
    boundary*: char


##  Opaque structure to hold blame results


## *
##  Gets the number of hunks that exist in the blame structure.
## 

proc git_blame_get_hunk_count*(blame: ptr git_blame): uint32  {.importc.}
## *
##  Gets the blame hunk at the given index.
## 
##  @param blame the blame structure to query
##  @param index index of the hunk to retrieve
##  @return the hunk at the given index, or NULL on error
## 

proc git_blame_get_hunk_byindex*(blame: ptr git_blame; index: uint32): ptr git_blame_hunk  {.importc.}
## *
##  Gets the hunk that relates to the given line number in the newest commit.
## 
##  @param blame the blame structure to query
##  @param lineno the (1-based) line number to find a hunk for
##  @return the hunk that contains the given line, or NULL on error
## 

proc git_blame_get_hunk_byline*(blame: ptr git_blame; lineno: csize): ptr git_blame_hunk  {.importc.}
## *
##  Get the blame for a single file.
## 
##  @param out pointer that will receive the blame object
##  @param repo repository whose history is to be walked
##  @param path path to file to consider
##  @param options options for the blame operation.  If NULL, this is treated as
##                 though GIT_BLAME_OPTIONS_INIT were passed.
##  @return 0 on success, or an error code. (use giterr_last for information
##          about the error.)
## 

proc git_blame_file*(`out`: ptr ptr git_blame; repo: ptr git_repository; path: cstring; 
                    options: ptr git_blame_options): cint {.importc.}
## *
##  Get blame data for a file that has been modified in memory. The `reference`
##  parameter is a pre-calculated blame for the in-odb history of the file. This
##  means that once a file blame is completed (which can be expensive), updating
##  the buffer blame is very fast.
## 
##  Lines that differ between the buffer and the committed version are marked as
##  having a zero OID for their final_commit_id.
## 
##  @param out pointer that will receive the resulting blame data
##  @param reference cached blame from the history of the file (usually the output
##                   from git_blame_file)
##  @param buffer the (possibly) modified contents of the file
##  @param buffer_len number of valid bytes in the buffer
##  @return 0 on success, or an error code. (use giterr_last for information
##          about the error)
## 

proc git_blame_buffer*(`out`: ptr ptr git_blame; reference: ptr git_blame; 
                      buffer: cstring; buffer_len: csize): cint {.importc.}
## *
##  Free memory allocated by git_blame_file or git_blame_buffer.
## 
##  @param blame the blame structure to free
## 

proc git_blame_free*(blame: ptr git_blame)  {.importc.}
## * @}
