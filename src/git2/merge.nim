## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 

{.push dynlib: "libgit2".}
{.push callconv: cdecl.}
import
  common, types, oid, oidarray, checkout, index, annotated_commit

## *
##  @file git2/merge.h
##  @brief Git merge routines
##  @defgroup git_merge Git merge routines
##  @ingroup Git
##  @{
## 
## *
##  The file inputs to `git_merge_file`.  Callers should populate the
##  `git_merge_file_input` structure with descriptions of the files in
##  each side of the conflict for use in producing the merge file.
## 

type
  git_merge_file_input* {.bycopy.} = object
    version*: cuint            ## * Pointer to the contents of the file.
    `ptr`*: cstring            ## * Size of the contents pointed to in `ptr`.
    size*: csize               ## * File name of the conflicted file, or `NULL` to not merge the path.
    path*: cstring             ## * File mode of the conflicted file, or `0` to not merge the mode.
    mode*: cuint


const
  GIT_MERGE_FILE_INPUT_VERSION* = 1

## *
##  Initializes a `git_merge_file_input` with default values. Equivalent to
##  creating an instance with GIT_MERGE_FILE_INPUT_INIT.
## 
##  @param opts the `git_merge_file_input` instance to initialize.
##  @param version the version of the struct; you should pass
##         `GIT_MERGE_FILE_INPUT_VERSION` here.
##  @return Zero on success; -1 on failure.
## 

proc git_merge_file_init_input*(opts: ptr git_merge_file_input; version: cuint): cint  {.importc.}
## *
##  Flags for `git_merge` options.  A combination of these flags can be
##  passed in via the `flags` value in the `git_merge_options`.
## 

type ## *
    ##  Detect renames that occur between the common ancestor and the "ours"
    ##  side or the common ancestor and the "theirs" side.  This will enable
    ##  the ability to merge between a modified and renamed file.
    ## 
  git_merge_flag_t* = enum
    GIT_MERGE_FIND_RENAMES = (1 shl 0), ## *
                                   ##  If a conflict occurs, exit immediately instead of attempting to
                                   ##  continue resolving conflicts.  The merge operation will fail with
                                   ##  GIT_EMERGECONFLICT and no index will be returned.
                                   ## 
    GIT_MERGE_FAIL_ON_CONFLICT = (1 shl 1), ## *
                                       ##  Do not write the REUC extension on the generated index
                                       ## 
    GIT_MERGE_SKIP_REUC = (1 shl 2), ## *
                                ##  If the commits being merged have multiple merge bases, do not build
                                ##  a recursive merge base (by merging the multiple merge bases),
                                ##  instead simply use the first base.  This flag provides a similar
                                ##  merge base to `git-merge-resolve`.
                                ## 
    GIT_MERGE_NO_RECURSIVE = (1 shl 3)


## *
##  Merge file favor options for `git_merge_options` instruct the file-level
##  merging functionality how to deal with conflicting regions of the files.
## 

type ## *
    ##  When a region of a file is changed in both branches, a conflict
    ##  will be recorded in the index so that `git_checkout` can produce
    ##  a merge file with conflict markers in the working directory.
    ##  This is the default.
    ## 
  git_merge_file_favor_t* = enum
    GIT_MERGE_FILE_FAVOR_NORMAL = 0, ## *
                                  ##  When a region of a file is changed in both branches, the file
                                  ##  created in the index will contain the "ours" side of any conflicting
                                  ##  region.  The index will not record a conflict.
                                  ## 
    GIT_MERGE_FILE_FAVOR_OURS = 1, ## *
                                ##  When a region of a file is changed in both branches, the file
                                ##  created in the index will contain the "theirs" side of any conflicting
                                ##  region.  The index will not record a conflict.
                                ## 
    GIT_MERGE_FILE_FAVOR_THEIRS = 2, ## *
                                  ##  When a region of a file is changed in both branches, the file
                                  ##  created in the index will contain each unique line from each side,
                                  ##  which has the result of combining both files.  The index will not
                                  ##  record a conflict.
                                  ## 
    GIT_MERGE_FILE_FAVOR_UNION = 3


## *
##  File merging flags
## 

type                          ## * Defaults
  git_merge_file_flag_t* = enum
    GIT_MERGE_FILE_DEFAULT = 0, ## * Create standard conflicted merge files
    GIT_MERGE_FILE_STYLE_MERGE = (1 shl 0), ## * Create diff3-style files
    GIT_MERGE_FILE_STYLE_DIFF3 = (1 shl 1), ## * Condense non-alphanumeric regions for simplified diff file
    GIT_MERGE_FILE_SIMPLIFY_ALNUM = (1 shl 2), ## * Ignore all whitespace
    GIT_MERGE_FILE_IGNORE_WHITESPACE = (1 shl 3), ## * Ignore changes in amount of whitespace
    GIT_MERGE_FILE_IGNORE_WHITESPACE_CHANGE = (1 shl 4), ## * Ignore whitespace at end of line
    GIT_MERGE_FILE_IGNORE_WHITESPACE_EOL = (1 shl 5), ## * Use the "patience diff" algorithm
    GIT_MERGE_FILE_DIFF_PATIENCE = (1 shl 6), ## * Take extra time to find minimal diff
    GIT_MERGE_FILE_DIFF_MINIMAL = (1 shl 7)


## *
##  Options for merging a file
## 

type
  git_merge_file_options* {.bycopy.} = object
    version*: cuint ## *
                  ##  Label for the ancestor file side of the conflict which will be prepended
                  ##  to labels in diff3-format merge files.
                  ## 
    ancestor_label*: cstring ## *
                           ##  Label for our file side of the conflict which will be prepended
                           ##  to labels in merge files.
                           ## 
    our_label*: cstring ## *
                      ##  Label for their file side of the conflict which will be prepended
                      ##  to labels in merge files.
                      ## 
    their_label*: cstring      ## * The file to favor in region conflicts.
    favor*: git_merge_file_favor_t ## * see `git_merge_file_flag_t` above
    flags*: git_merge_file_flag_t


const
  GIT_MERGE_FILE_OPTIONS_VERSION* = 1

## *
##  Initializes a `git_merge_file_options` with default values. Equivalent to
##  creating an instance with GIT_MERGE_FILE_OPTIONS_INIT.
## 
##  @param opts the `git_merge_file_options` instance to initialize.
##  @param version the version of the struct; you should pass
##         `GIT_MERGE_FILE_OPTIONS_VERSION` here.
##  @return Zero on success; -1 on failure.
## 

proc git_merge_file_init_options*(opts: ptr git_merge_file_options; version: cuint): cint  {.importc.}
## *
##  Information about file-level merging
## 

type
  git_merge_file_result* {.bycopy.} = object
    automergeable*: cuint ## *
                        ##  True if the output was automerged, false if the output contains
                        ##  conflict markers.
                        ## 
    ## *
    ##  The path that the resultant merge file should use, or NULL if a
    ##  filename conflict would occur.
    ## 
    path*: cstring             ## * The mode that the resultant merge file should use.
    mode*: cuint               ## * The contents of the merge.
    `ptr`*: cstring            ## * The length of the merge contents.
    len*: csize


## *
##  Merging options
## 

type
  git_merge_options* {.bycopy.} = object
    version*: cuint            ## * See `git_merge_flag_t` above
    flags*: git_merge_flag_t ## *
                           ##  Similarity to consider a file renamed (default 50).  If
                           ##  `GIT_MERGE_FIND_RENAMES` is enabled, added files will be compared
                           ##  with deleted files to determine their similarity.  Files that are
                           ##  more similar than the rename threshold (percentage-wise) will be
                           ##  treated as a rename.
                           ## 
    rename_threshold*: cuint ## *
                           ##  Maximum similarity sources to examine for renames (default 200).
                           ##  If the number of rename candidates (add / delete pairs) is greater
                           ##  than this value, inexact rename detection is aborted.
                           ## 
                           ##  This setting overrides the `merge.renameLimit` configuration value.
                           ## 
    target_limit*: cuint       ## * Pluggable similarity metric; pass NULL to use internal metric
    metric*: ptr git_diff_similarity_metric ## *
                                         ##  Maximum number of times to merge common ancestors to build a
                                         ##  virtual merge base when faced with criss-cross merges.  When this
                                         ##  limit is reached, the next ancestor will simply be used instead of
                                         ##  attempting to merge it.  The default is unlimited.
                                         ## 
    recursion_limit*: cuint ## *
                          ##  Default merge driver to be used when both sides of a merge have
                          ##  changed.  The default is the `text` driver.
                          ## 
    default_driver*: cstring ## *
                           ##  Flags for handling conflicting content, to be used with the standard
                           ##  (`text`) merge driver.
                           ## 
    file_favor*: git_merge_file_favor_t ## * see `git_merge_file_flag_t` above
    file_flags*: git_merge_file_flag_t


const
  GIT_MERGE_OPTIONS_VERSION* = 1

## *
##  Initializes a `git_merge_options` with default values. Equivalent to
##  creating an instance with GIT_MERGE_OPTIONS_INIT.
## 
##  @param opts the `git_merge_options` instance to initialize.
##  @param version the version of the struct; you should pass
##         `GIT_MERGE_OPTIONS_VERSION` here.
##  @return Zero on success; -1 on failure.
## 

proc git_merge_init_options*(opts: ptr git_merge_options; version: cuint): cint  {.importc.}
## *
##  The results of `git_merge_analysis` indicate the merge opportunities.
## 

type                          ## * No merge is possible.  (Unused.)
  git_merge_analysis_t* = enum
    GIT_MERGE_ANALYSIS_NONE = 0, ## *
                              ##  A "normal" merge; both HEAD and the given merge input have diverged
                              ##  from their common ancestor.  The divergent commits must be merged.
                              ## 
    GIT_MERGE_ANALYSIS_NORMAL = (1 shl 0), ## *
                                      ##  All given merge inputs are reachable from HEAD, meaning the
                                      ##  repository is up-to-date and no merge needs to be performed.
                                      ## 
    GIT_MERGE_ANALYSIS_UP_TO_DATE = (1 shl 1), ## *
                                          ##  The given merge input is a fast-forward from HEAD and no merge
                                          ##  needs to be performed.  Instead, the client can check out the
                                          ##  given merge input.
                                          ## 
    GIT_MERGE_ANALYSIS_FASTFORWARD = (1 shl 2), ## *
                                           ##  The HEAD of the current repository is "unborn" and does not point to
                                           ##  a valid commit.  No merge can be performed, but the caller may wish
                                           ##  to simply set HEAD to the target commit(s).
                                           ## 
    GIT_MERGE_ANALYSIS_UNBORN = (1 shl 3)


## *
##  The user's stated preference for merges.
## 

type ## *
    ##  No configuration was found that suggests a preferred behavior for
    ##  merge.
    ## 
  git_merge_preference_t* = enum
    GIT_MERGE_PREFERENCE_NONE = 0, ## *
                                ##  There is a `merge.ff=false` configuration setting, suggesting that
                                ##  the user does not want to allow a fast-forward merge.
                                ## 
    GIT_MERGE_PREFERENCE_NO_FASTFORWARD = (1 shl 0), ## *
                                                ##  There is a `merge.ff=only` configuration setting, suggesting that
                                                ##  the user only wants fast-forward merges.
                                                ## 
    GIT_MERGE_PREFERENCE_FASTFORWARD_ONLY = (1 shl 1)


## *
##  Analyzes the given branch(es) and determines the opportunities for
##  merging them into the HEAD of the repository.
## 
##  @param analysis_out analysis enumeration that the result is written into
##  @param repo the repository to merge
##  @param their_heads the heads to merge into
##  @param their_heads_len the number of heads to merge
##  @return 0 on success or error code
## 

proc git_merge_analysis*(analysis_out: ptr git_merge_analysis_t; 
                        preference_out: ptr git_merge_preference_t;
                        repo: ptr git_repository;
                        their_heads: ptr ptr git_annotated_commit;
                        their_heads_len: csize): cint
## *
##  Find a merge base between two commits
## 
##  @param out the OID of a merge base between 'one' and 'two'
##  @param repo the repository where the commits exist
##  @param one one of the commits
##  @param two the other commit
##  @return 0 on success, GIT_ENOTFOUND if not found or error code
## 

proc git_merge_base*(`out`: ptr git_oid; repo: ptr git_repository; one: ptr git_oid; 
                    two: ptr git_oid): cint {.importc.}
## *
##  Find merge bases between two commits
## 
##  @param out array in which to store the resulting ids
##  @param repo the repository where the commits exist
##  @param one one of the commits
##  @param two the other commit
##  @return 0 on success, GIT_ENOTFOUND if not found or error code
## 

proc git_merge_bases*(`out`: ptr git_oidarray; repo: ptr git_repository; 
                     one: ptr git_oid; two: ptr git_oid): cint {.importc.}
## *
##  Find a merge base given a list of commits
## 
##  @param out the OID of a merge base considering all the commits
##  @param repo the repository where the commits exist
##  @param length The number of commits in the provided `input_array`
##  @param input_array oids of the commits
##  @return Zero on success; GIT_ENOTFOUND or -1 on failure.
## 

proc git_merge_base_many*(`out`: ptr git_oid; repo: ptr git_repository; length: csize; 
                         input_array: ptr git_oid): cint {.importc.}
## *
##  Find all merge bases given a list of commits
## 
##  @param out array in which to store the resulting ids
##  @param repo the repository where the commits exist
##  @param length The number of commits in the provided `input_array`
##  @param input_array oids of the commits
##  @return Zero on success; GIT_ENOTFOUND or -1 on failure.
## 

proc git_merge_bases_many*(`out`: ptr git_oidarray; repo: ptr git_repository; 
                          length: csize; input_array: ptr git_oid): cint {.importc.}
## *
##  Find a merge base in preparation for an octopus merge
## 
##  @param out the OID of a merge base considering all the commits
##  @param repo the repository where the commits exist
##  @param length The number of commits in the provided `input_array`
##  @param input_array oids of the commits
##  @return Zero on success; GIT_ENOTFOUND or -1 on failure.
## 

proc git_merge_base_octopus*(`out`: ptr git_oid; repo: ptr git_repository; 
                            length: csize; input_array: ptr git_oid): cint {.importc.}
## *
##  Merge two files as they exist in the in-memory data structures, using
##  the given common ancestor as the baseline, producing a
##  `git_merge_file_result` that reflects the merge result.  The
##  `git_merge_file_result` must be freed with `git_merge_file_result_free`.
## 
##  Note that this function does not reference a repository and any
##  configuration must be passed as `git_merge_file_options`.
## 
##  @param out The git_merge_file_result to be filled in
##  @param ancestor The contents of the ancestor file
##  @param ours The contents of the file in "our" side
##  @param theirs The contents of the file in "their" side
##  @param opts The merge file options or `NULL` for defaults
##  @return 0 on success or error code
## 

proc git_merge_file*(`out`: ptr git_merge_file_result; 
                    ancestor: ptr git_merge_file_input;
                    ours: ptr git_merge_file_input;
                    theirs: ptr git_merge_file_input;
                    opts: ptr git_merge_file_options): cint {.importc.}
## *
##  Merge two files as they exist in the index, using the given common
##  ancestor as the baseline, producing a `git_merge_file_result` that
##  reflects the merge result.  The `git_merge_file_result` must be freed with
##  `git_merge_file_result_free`.
## 
##  @param out The git_merge_file_result to be filled in
##  @param repo The repository
##  @param ancestor The index entry for the ancestor file (stage level 1)
##  @param ours The index entry for our file (stage level 2)
##  @param theirs The index entry for their file (stage level 3)
##  @param opts The merge file options or NULL
##  @return 0 on success or error code
## 

proc git_merge_file_from_index*(`out`: ptr git_merge_file_result; 
                               repo: ptr git_repository;
                               ancestor: ptr git_index_entry;
                               ours: ptr git_index_entry;
                               theirs: ptr git_index_entry;
                               opts: ptr git_merge_file_options): cint
## *
##  Frees a `git_merge_file_result`.
## 
##  @param result The result to free or `NULL`
## 

proc git_merge_file_result_free*(result: ptr git_merge_file_result)  {.importc.}
## *
##  Merge two trees, producing a `git_index` that reflects the result of
##  the merge.  The index may be written as-is to the working directory
##  or checked out.  If the index is to be converted to a tree, the caller
##  should resolve any conflicts that arose as part of the merge.
## 
##  The returned index must be freed explicitly with `git_index_free`.
## 
##  @param out pointer to store the index result in
##  @param repo repository that contains the given trees
##  @param ancestor_tree the common ancestor between the trees (or null if none)
##  @param our_tree the tree that reflects the destination tree
##  @param their_tree the tree to merge in to `our_tree`
##  @param opts the merge tree options (or null for defaults)
##  @return 0 on success or error code
## 

proc git_merge_trees*(`out`: ptr ptr git_index; repo: ptr git_repository; 
                     ancestor_tree: ptr git_tree; our_tree: ptr git_tree;
                     their_tree: ptr git_tree; opts: ptr git_merge_options): cint {.importc.}
## *
##  Merge two commits, producing a `git_index` that reflects the result of
##  the merge.  The index may be written as-is to the working directory
##  or checked out.  If the index is to be converted to a tree, the caller
##  should resolve any conflicts that arose as part of the merge.
## 
##  The returned index must be freed explicitly with `git_index_free`.
## 
##  @param out pointer to store the index result in
##  @param repo repository that contains the given trees
##  @param our_commit the commit that reflects the destination tree
##  @param their_commit the commit to merge in to `our_commit`
##  @param opts the merge tree options (or null for defaults)
##  @return 0 on success or error code
## 

proc git_merge_commits*(`out`: ptr ptr git_index; repo: ptr git_repository; 
                       our_commit: ptr git_commit; their_commit: ptr git_commit;
                       opts: ptr git_merge_options): cint {.importc.}
## *
##  Merges the given commit(s) into HEAD, writing the results into the working
##  directory.  Any changes are staged for commit and any conflicts are written
##  to the index.  Callers should inspect the repository's index after this
##  completes, resolve any conflicts and prepare a commit.
## 
##  For compatibility with git, the repository is put into a merging
##  state. Once the commit is done (or if the uses wishes to abort),
##  you should clear this state by calling
##  `git_repository_state_cleanup()`.
## 
##  @param repo the repository to merge
##  @param their_heads the heads to merge into
##  @param their_heads_len the number of heads to merge
##  @param merge_opts merge options
##  @param checkout_opts checkout options
##  @return 0 on success or error code
## 

proc git_merge*(repo: ptr git_repository; their_heads: ptr ptr git_annotated_commit; 
               their_heads_len: csize; merge_opts: ptr git_merge_options;
               checkout_opts: ptr git_checkout_options): cint {.importc.}
## * @}
