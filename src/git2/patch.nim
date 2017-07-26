## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 
{.push importc.}
{.push dynlib: "libgit2".}
import
  common, types, oid, diff

## *
##  @file git2/patch.h
##  @brief Patch handling routines.
##  @ingroup Git
##  @{
## 
## *
##  The diff patch is used to store all the text diffs for a delta.
## 
##  You can easily loop over the content of patches and get information about
##  them.
## 


## *
##  Return a patch for an entry in the diff list.
## 
##  The `git_patch` is a newly created object contains the text diffs
##  for the delta.  You have to call `git_patch_free()` when you are
##  done with it.  You can use the patch object to loop over all the hunks
##  and lines in the diff of the one delta.
## 
##  For an unchanged file or a binary file, no `git_patch` will be
##  created, the output will be set to NULL, and the `binary` flag will be
##  set true in the `git_diff_delta` structure.
## 
##  It is okay to pass NULL for either of the output parameters; if you pass
##  NULL for the `git_patch`, then the text diff will not be calculated.
## 
##  @param out Output parameter for the delta patch object
##  @param diff Diff list object
##  @param idx Index into diff list
##  @return 0 on success, other value < 0 on error
## 

proc git_patch_from_diff*(`out`: ptr ptr git_patch; diff: ptr git_diff; idx: csize): cint
## *
##  Directly generate a patch from the difference between two blobs.
## 
##  This is just like `git_diff_blobs()` except it generates a patch object
##  for the difference instead of directly making callbacks.  You can use the
##  standard `git_patch` accessor functions to read the patch data, and
##  you must call `git_patch_free()` on the patch when done.
## 
##  @param out The generated patch; NULL on error
##  @param old_blob Blob for old side of diff, or NULL for empty blob
##  @param old_as_path Treat old blob as if it had this filename; can be NULL
##  @param new_blob Blob for new side of diff, or NULL for empty blob
##  @param new_as_path Treat new blob as if it had this filename; can be NULL
##  @param opts Options for diff, or NULL for default options
##  @return 0 on success or error code < 0
## 

proc git_patch_from_blobs*(`out`: ptr ptr git_patch; old_blob: ptr git_blob;
                          old_as_path: cstring; new_blob: ptr git_blob;
                          new_as_path: cstring; opts: ptr git_diff_options): cint
## *
##  Directly generate a patch from the difference between a blob and a buffer.
## 
##  This is just like `git_diff_blob_to_buffer()` except it generates a patch
##  object for the difference instead of directly making callbacks.  You can
##  use the standard `git_patch` accessor functions to read the patch
##  data, and you must call `git_patch_free()` on the patch when done.
## 
##  @param out The generated patch; NULL on error
##  @param old_blob Blob for old side of diff, or NULL for empty blob
##  @param old_as_path Treat old blob as if it had this filename; can be NULL
##  @param buffer Raw data for new side of diff, or NULL for empty
##  @param buffer_len Length of raw data for new side of diff
##  @param buffer_as_path Treat buffer as if it had this filename; can be NULL
##  @param opts Options for diff, or NULL for default options
##  @return 0 on success or error code < 0
## 

proc git_patch_from_blob_and_buffer*(`out`: ptr ptr git_patch;
                                    old_blob: ptr git_blob; old_as_path: cstring;
                                    buffer: cstring; buffer_len: csize;
                                    buffer_as_path: cstring;
                                    opts: ptr git_diff_options): cint
## *
##  Directly generate a patch from the difference between two buffers.
## 
##  This is just like `git_diff_buffers()` except it generates a patch
##  object for the difference instead of directly making callbacks.  You can
##  use the standard `git_patch` accessor functions to read the patch
##  data, and you must call `git_patch_free()` on the patch when done.
## 
##  @param out The generated patch; NULL on error
##  @param old_buffer Raw data for old side of diff, or NULL for empty
##  @param old_len Length of the raw data for old side of the diff
##  @param old_as_path Treat old buffer as if it had this filename; can be NULL
##  @param new_buffer Raw data for new side of diff, or NULL for empty
##  @param new_len Length of raw data for new side of diff
##  @param new_as_path Treat buffer as if it had this filename; can be NULL
##  @param opts Options for diff, or NULL for default options
##  @return 0 on success or error code < 0
## 

proc git_patch_from_buffers*(`out`: ptr ptr git_patch; old_buffer: pointer;
                            old_len: csize; old_as_path: cstring;
                            new_buffer: cstring; new_len: csize;
                            new_as_path: cstring; opts: ptr git_diff_options): cint
## *
##  Free a git_patch object.
## 

proc git_patch_free*(patch: ptr git_patch)
## *
##  Get the delta associated with a patch.  This delta points to internal
##  data and you do not have to release it when you are done with it.
## 

proc git_patch_get_delta*(patch: ptr git_patch): ptr git_diff_delta
## *
##  Get the number of hunks in a patch
## 

proc git_patch_num_hunks*(patch: ptr git_patch): csize
## *
##  Get line counts of each type in a patch.
## 
##  This helps imitate a diff --numstat type of output.  For that purpose,
##  you only need the `total_additions` and `total_deletions` values, but we
##  include the `total_context` line count in case you want the total number
##  of lines of diff output that will be generated.
## 
##  All outputs are optional. Pass NULL if you don't need a particular count.
## 
##  @param total_context Count of context lines in output, can be NULL.
##  @param total_additions Count of addition lines in output, can be NULL.
##  @param total_deletions Count of deletion lines in output, can be NULL.
##  @param patch The git_patch object
##  @return 0 on success, <0 on error
## 

proc git_patch_line_stats*(total_context: ptr csize; total_additions: ptr csize;
                          total_deletions: ptr csize; patch: ptr git_patch): cint
## *
##  Get the information about a hunk in a patch
## 
##  Given a patch and a hunk index into the patch, this returns detailed
##  information about that hunk.  Any of the output pointers can be passed
##  as NULL if you don't care about that particular piece of information.
## 
##  @param out Output pointer to git_diff_hunk of hunk
##  @param lines_in_hunk Output count of total lines in this hunk
##  @param patch Input pointer to patch object
##  @param hunk_idx Input index of hunk to get information about
##  @return 0 on success, GIT_ENOTFOUND if hunk_idx out of range, <0 on error
## 

proc git_patch_get_hunk*(`out`: ptr ptr git_diff_hunk; lines_in_hunk: ptr csize;
                        patch: ptr git_patch; hunk_idx: csize): cint
## *
##  Get the number of lines in a hunk.
## 
##  @param patch The git_patch object
##  @param hunk_idx Index of the hunk
##  @return Number of lines in hunk or GIT_ENOTFOUND if invalid hunk index
## 

proc git_patch_num_lines_in_hunk*(patch: ptr git_patch; hunk_idx: csize): cint
## *
##  Get data about a line in a hunk of a patch.
## 
##  Given a patch, a hunk index, and a line index in the hunk, this
##  will return a lot of details about that line.  If you pass a hunk
##  index larger than the number of hunks or a line index larger than
##  the number of lines in the hunk, this will return -1.
## 
##  @param out The git_diff_line data for this line
##  @param patch The patch to look in
##  @param hunk_idx The index of the hunk
##  @param line_of_hunk The index of the line in the hunk
##  @return 0 on success, <0 on failure
## 

proc git_patch_get_line_in_hunk*(`out`: ptr ptr git_diff_line; patch: ptr git_patch;
                                hunk_idx: csize; line_of_hunk: csize): cint
## *
##  Look up size of patch diff data in bytes
## 
##  This returns the raw size of the patch data.  This only includes the
##  actual data from the lines of the diff, not the file or hunk headers.
## 
##  If you pass `include_context` as true (non-zero), this will be the size
##  of all of the diff output; if you pass it as false (zero), this will
##  only include the actual changed lines (as if `context_lines` was 0).
## 
##  @param patch A git_patch representing changes to one file
##  @param include_context Include context lines in size if non-zero
##  @param include_hunk_headers Include hunk header lines if non-zero
##  @param include_file_headers Include file header lines if non-zero
##  @return The number of bytes of data
## 

proc git_patch_size*(patch: ptr git_patch; include_context: cint;
                    include_hunk_headers: cint; include_file_headers: cint): csize
## *
##  Serialize the patch to text via callback.
## 
##  Returning a non-zero value from the callback will terminate the iteration
##  and return that value to the caller.
## 
##  @param patch A git_patch representing changes to one file
##  @param print_cb Callback function to output lines of the patch.  Will be
##                  called for file headers, hunk headers, and diff lines.
##  @param payload Reference pointer that will be passed to your callbacks.
##  @return 0 on success, non-zero callback return value, or error code
## 

proc git_patch_print*(patch: ptr git_patch; print_cb: git_diff_line_cb;
                     payload: pointer): cint
## *
##  Get the content of a patch as a single diff text.
## 
##  @param out The git_buf to be filled in
##  @param patch A git_patch representing changes to one file
##  @return 0 on success, <0 on failure.
## 

proc git_patch_to_buf*(`out`: ptr git_buf; patch: ptr git_patch): cint
## *@}
