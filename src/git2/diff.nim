## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 

{.push dynlib: "libgit2".}
{.push callconv: cdecl.}
import
  common, types, oid, tree, refs, strarray, buffer

## *
##  @file git2/diff.h
##  @brief Git tree and file differencing routines.
## 
##  Overview
##  --------
## 
##  Calculating diffs is generally done in two phases: building a list of
##  diffs then traversing it.  This makes is easier to share logic across
##  the various types of diffs (tree vs tree, workdir vs index, etc.), and
##  also allows you to insert optional diff post-processing phases,
##  such as rename detection, in between the steps.  When you are done with
##  a diff object, it must be freed.
## 
##  Terminology
##  -----------
## 
##  To understand the diff APIs, you should know the following terms:
## 
##  - A `diff` represents the cumulative list of differences between two
##    snapshots of a repository (possibly filtered by a set of file name
##    patterns).  This is the `git_diff` object.
## 
##  - A `delta` is a file pair with an old and new revision.  The old version
##    may be absent if the file was just created and the new version may be
##    absent if the file was deleted.  A diff is mostly just a list of deltas.
## 
##  - A `binary` file / delta is a file (or pair) for which no text diffs
##    should be generated.  A diff can contain delta entries that are
##    binary, but no diff content will be output for those files.  There is
##    a base heuristic for binary detection and you can further tune the
##    behavior with git attributes or diff flags and option settings.
## 
##  - A `hunk` is a span of modified lines in a delta along with some stable
##    surrounding context.  You can configure the amount of context and other
##    properties of how hunks are generated.  Each hunk also comes with a
##    header that described where it starts and ends in both the old and new
##    versions in the delta.
## 
##  - A `line` is a range of characters inside a hunk.  It could be a context
##    line (i.e. in both old and new versions), an added line (i.e. only in
##    the new version), or a removed line (i.e. only in the old version).
##    Unfortunately, we don't know anything about the encoding of data in the
##    file being diffed, so we cannot tell you much about the line content.
##    Line data will not be NUL-byte terminated, however, because it will be
##    just a span of bytes inside the larger file.
## 
##  @ingroup Git
##  @{
## 
## *
##  Flags for diff options.  A combination of these flags can be passed
##  in via the `flags` value in the `git_diff_options`.
## 

type                          ## * Normal diff, the default
  git_diff_option_t* = enum
    GIT_DIFF_NORMAL = 0, ## 
                      ##  Options controlling which files will be in the diff
                      ## 
                      ## * Reverse the sides of the diff
    GIT_DIFF_REVERSE = (1 shl 0), ## * Include ignored files in the diff
    GIT_DIFF_INCLUDE_IGNORED = (1 shl 1), ## * Even with GIT_DIFF_INCLUDE_IGNORED, an entire ignored directory
                                     ##   will be marked with only a single entry in the diff; this flag
                                     ##   adds all files under the directory as IGNORED entries, too.
                                     ## 
    GIT_DIFF_RECURSE_IGNORED_DIRS = (1 shl 2), ## * Include untracked files in the diff
    GIT_DIFF_INCLUDE_UNTRACKED = (1 shl 3), ## * Even with GIT_DIFF_INCLUDE_UNTRACKED, an entire untracked
                                       ##   directory will be marked with only a single entry in the diff
                                       ##   (a la what core Git does in `git status`); this flag adds *all*
                                       ##   files under untracked directories as UNTRACKED entries, too.
                                       ## 
    GIT_DIFF_RECURSE_UNTRACKED_DIRS = (1 shl 4), ## * Include unmodified files in the diff
    GIT_DIFF_INCLUDE_UNMODIFIED = (1 shl 5), ## * Normally, a type change between files will be converted into a
                                        ##   DELETED record for the old and an ADDED record for the new; this
                                        ##   options enabled the generation of TYPECHANGE delta records.
                                        ## 
    GIT_DIFF_INCLUDE_TYPECHANGE = (1 shl 6), ## * Even with GIT_DIFF_INCLUDE_TYPECHANGE, blob->tree changes still
                                        ##   generally show as a DELETED blob.  This flag tries to correctly
                                        ##   label blob->tree transitions as TYPECHANGE records with new_file's
                                        ##   mode set to tree.  Note: the tree SHA will not be available.
                                        ## 
    GIT_DIFF_INCLUDE_TYPECHANGE_TREES = (1 shl 7), ## * Ignore file mode changes
    GIT_DIFF_IGNORE_FILEMODE = (1 shl 8), ## * Treat all submodules as unmodified
    GIT_DIFF_IGNORE_SUBMODULES = (1 shl 9), ## * Use case insensitive filename comparisons
    GIT_DIFF_IGNORE_CASE = (1 shl 10), ## * May be combined with `GIT_DIFF_IGNORE_CASE` to specify that a file
                                  ##   that has changed case will be returned as an add/delete pair.
                                  ## 
    GIT_DIFF_INCLUDE_CASECHANGE = (1 shl 11), ## * If the pathspec is set in the diff options, this flags indicates
                                         ##   that the paths will be treated as literal paths instead of
                                         ##   fnmatch patterns.  Each path in the list must either be a full
                                         ##   path to a file or a directory.  (A trailing slash indicates that
                                         ##   the path will _only_ match a directory).  If a directory is
                                         ##   specified, all children will be included.
                                         ## 
    GIT_DIFF_DISABLE_PATHSPEC_MATCH = (1 shl 12), ## * Disable updating of the `binary` flag in delta records.  This is
                                             ##   useful when iterating over a diff if you don't need hunk and data
                                             ##   callbacks and want to avoid having to load file completely.
                                             ## 
    GIT_DIFF_SKIP_BINARY_CHECK = (1 shl 13), ## * When diff finds an untracked directory, to match the behavior of
                                        ##   core Git, it scans the contents for IGNORED and UNTRACKED files.
                                        ##   If *all* contents are IGNORED, then the directory is IGNORED; if
                                        ##   any contents are not IGNORED, then the directory is UNTRACKED.
                                        ##   This is extra work that may not matter in many cases.  This flag
                                        ##   turns off that scan and immediately labels an untracked directory
                                        ##   as UNTRACKED (changing the behavior to not match core Git).
                                        ## 
    GIT_DIFF_ENABLE_FAST_UNTRACKED_DIRS = (1 shl 14), ## * When diff finds a file in the working directory with stat
                                                 ##  information different from the index, but the OID ends up being the
                                                 ##  same, write the correct stat information into the index.  Note:
                                                 ##  without this flag, diff will always leave the index untouched.
                                                 ## 
    GIT_DIFF_UPDATE_INDEX = (1 shl 15), ## * Include unreadable files in the diff
    GIT_DIFF_INCLUDE_UNREADABLE = (1 shl 16), ## * Include unreadable files in the diff
    GIT_DIFF_INCLUDE_UNREADABLE_AS_UNTRACKED = (1 shl 17), ## 
                                                      ##  Options controlling how output will be generated
                                                      ## 
                                                      ## * Treat all files as text, disabling binary attributes & detection
    GIT_DIFF_FORCE_TEXT = (1 shl 20), ## * Treat all files as binary, disabling text diffs
    GIT_DIFF_FORCE_BINARY = (1 shl 21), ## * Ignore all whitespace
    GIT_DIFF_IGNORE_WHITESPACE = (1 shl 22), ## * Ignore changes in amount of whitespace
    GIT_DIFF_IGNORE_WHITESPACE_CHANGE = (1 shl 23), ## * Ignore whitespace at end of line
    GIT_DIFF_IGNORE_WHITESPACE_EOL = (1 shl 24), ## * When generating patch text, include the content of untracked
                                            ##   files.  This automatically turns on GIT_DIFF_INCLUDE_UNTRACKED but
                                            ##   it does not turn on GIT_DIFF_RECURSE_UNTRACKED_DIRS.  Add that
                                            ##   flag if you want the content of every single UNTRACKED file.
                                            ## 
    GIT_DIFF_SHOW_UNTRACKED_CONTENT = (1 shl 25), ## * When generating output, include the names of unmodified files if
                                             ##   they are included in the git_diff.  Normally these are skipped in
                                             ##   the formats that list files (e.g. name-only, name-status, raw).
                                             ##   Even with this, these will not be included in patch format.
                                             ## 
    GIT_DIFF_SHOW_UNMODIFIED = (1 shl 26), ## * Use the "patience diff" algorithm
    GIT_DIFF_PATIENCE = (1 shl 28), ## * Take extra time to find minimal diff
    GIT_DIFF_MINIMAL = (1 shl 29), ## * Include the necessary deflate / delta information so that `git-apply`
                              ##   can apply given diff information to binary files.
                              ## 
    GIT_DIFF_SHOW_BINARY = (1 shl 30)


## *
##  The diff object that contains all individual file deltas.
## 
##  This is an opaque structure which will be allocated by one of the diff
##  generator functions below (such as `git_diff_tree_to_tree`).  You are
##  responsible for releasing the object memory when done, using the
##  `git_diff_free()` function.
## 


## *
##  Flags for the delta object and the file objects on each side.
## 
##  These flags are used for both the `flags` value of the `git_diff_delta`
##  and the flags for the `git_diff_file` objects representing the old and
##  new sides of the delta.  Values outside of this public range should be
##  considered reserved for internal or future use.
## 

type
  git_diff_flag_t* = enum
    GIT_DIFF_FLAG_BINARY = (1 shl 0), ## *< file(s) treated as binary data
    GIT_DIFF_FLAG_NOT_BINARY = (1 shl 1), ## *< file(s) treated as text data
    GIT_DIFF_FLAG_VALID_ID = (1 shl 2), ## *< `id` value is known correct
    GIT_DIFF_FLAG_EXISTS = (1 shl 3) ## *< file exists at this side of the delta


## *
##  What type of change is described by a git_diff_delta?
## 
##  `GIT_DELTA_RENAMED` and `GIT_DELTA_COPIED` will only show up if you run
##  `git_diff_find_similar()` on the diff object.
## 
##  `GIT_DELTA_TYPECHANGE` only shows up given `GIT_DIFF_INCLUDE_TYPECHANGE`
##  in the option flags (otherwise type changes will be split into ADDED /
##  DELETED pairs).
## 

type
  git_delta_t* = enum
    GIT_DELTA_UNMODIFIED = 0,   ## *< no changes
    GIT_DELTA_ADDED = 1,        ## *< entry does not exist in old version
    GIT_DELTA_DELETED = 2,      ## *< entry does not exist in new version
    GIT_DELTA_MODIFIED = 3,     ## *< entry content changed between old and new
    GIT_DELTA_RENAMED = 4,      ## *< entry was renamed between old and new
    GIT_DELTA_COPIED = 5,       ## *< entry was copied from another old entry
    GIT_DELTA_IGNORED = 6,      ## *< entry is ignored item in workdir
    GIT_DELTA_UNTRACKED = 7,    ## *< entry is untracked item in workdir
    GIT_DELTA_TYPECHANGE = 8,   ## *< type of entry changed between old and new
    GIT_DELTA_UNREADABLE = 9,   ## *< entry is unreadable
    GIT_DELTA_CONFLICTED = 10   ## *< entry in the index is conflicted


## *
##  Description of one side of a delta.
## 
##  Although this is called a "file", it could represent a file, a symbolic
##  link, a submodule commit id, or even a tree (although that only if you
##  are tracking type changes or ignored/untracked directories).
## 
##  The `id` is the `git_oid` of the item.  If the entry represents an
##  absent side of a diff (e.g. the `old_file` of a `GIT_DELTA_ADDED` delta),
##  then the oid will be zeroes.
## 
##  `path` is the NUL-terminated path to the entry relative to the working
##  directory of the repository.
## 
##  `size` is the size of the entry in bytes.
## 
##  `flags` is a combination of the `git_diff_flag_t` types
## 
##  `mode` is, roughly, the stat() `st_mode` value for the item.  This will
##  be restricted to one of the `git_filemode_t` values.
## 
##  The `id_abbrev` represents the known length of the `id` field, when
##  converted to a hex string.  It is generally `GIT_OID_HEXSZ`, unless this
##  delta was created from reading a patch file, in which case it may be
##  abbreviated to something reasonable, like 7 characters.
## 

type
  git_diff_file* {.bycopy.} = object
    id*: git_oid
    path*: cstring
    size*: git_off_t
    flags*: uint32
    mode*: uint16
    id_abbrev*: uint16


## *
##  Description of changes to one entry.
## 
##  When iterating over a diff, this will be passed to most callbacks and
##  you can use the contents to understand exactly what has changed.
## 
##  The `old_file` represents the "from" side of the diff and the `new_file`
##  represents to "to" side of the diff.  What those means depend on the
##  function that was used to generate the diff and will be documented below.
##  You can also use the `GIT_DIFF_REVERSE` flag to flip it around.
## 
##  Although the two sides of the delta are named "old_file" and "new_file",
##  they actually may correspond to entries that represent a file, a symbolic
##  link, a submodule commit id, or even a tree (if you are tracking type
##  changes or ignored/untracked directories).
## 
##  Under some circumstances, in the name of efficiency, not all fields will
##  be filled in, but we generally try to fill in as much as possible.  One
##  example is that the "flags" field may not have either the `BINARY` or the
##  `NOT_BINARY` flag set to avoid examining file contents if you do not pass
##  in hunk and/or line callbacks to the diff foreach iteration function.  It
##  will just use the git attributes for those files.
## 
##  The similarity score is zero unless you call `git_diff_find_similar()`
##  which does a similarity analysis of files in the diff.  Use that
##  function to do rename and copy detection, and to split heavily modified
##  files in add/delete pairs.  After that call, deltas with a status of
##  GIT_DELTA_RENAMED or GIT_DELTA_COPIED will have a similarity score
##  between 0 and 100 indicating how similar the old and new sides are.
## 
##  If you ask `git_diff_find_similar` to find heavily modified files to
##  break, but to not *actually* break the records, then GIT_DELTA_MODIFIED
##  records may have a non-zero similarity score if the self-similarity is
##  below the split threshold.  To display this value like core Git, invert
##  the score (a la `printf("M%03d", 100 - delta->similarity)`).
## 

type
  git_diff_delta* {.bycopy.} = object
    status*: git_delta_t
    flags*: uint32           ## *< git_diff_flag_t values
    similarity*: uint16      ## *< for RENAMED and COPIED, value 0-100
    nfiles*: uint16          ## *< number of files in this delta
    old_file*: git_diff_file
    new_file*: git_diff_file


## *
##  Diff notification callback function.
## 
##  The callback will be called for each file, just before the `git_delta_t`
##  gets inserted into the diff.
## 
##  When the callback:
##  - returns < 0, the diff process will be aborted.
##  - returns > 0, the delta will not be inserted into the diff, but the
## 		diff process continues.
##  - returns 0, the delta is inserted into the diff, and the diff process
## 		continues.
## 

type
  git_diff_notify_cb* = proc (diff_so_far: ptr git_diff; 
                           delta_to_add: ptr git_diff_delta;
                           matched_pathspec: cstring; payload: pointer): cint

## *
##  Diff progress callback.
## 
##  Called before each file comparison.
## 
##  @param diff_so_far The diff being generated.
##  @param old_path The path to the old file or NULL.
##  @param new_path The path to the new file or NULL.
##  @return Non-zero to abort the diff.
## 

type
  git_diff_progress_cb* = proc (diff_so_far: ptr git_diff; old_path: cstring; 
                             new_path: cstring; payload: pointer): cint

## *
##  Structure describing options about how the diff should be executed.
## 
##  Setting all values of the structure to zero will yield the default
##  values.  Similarly, passing NULL for the options structure will
##  give the defaults.  The default values are marked below.
## 
##  - `flags` is a combination of the `git_diff_option_t` values above
##  - `context_lines` is the number of unchanged lines that define the
##     boundary of a hunk (and to display before and after)
##  - `interhunk_lines` is the maximum number of unchanged lines between
##     hunk boundaries before the hunks will be merged into a one.
##  - `old_prefix` is the virtual "directory" to prefix to old file names
##    in hunk headers (default "a")
##  - `new_prefix` is the virtual "directory" to prefix to new file names
##    in hunk headers (default "b")
##  - `pathspec` is an array of paths / fnmatch patterns to constrain diff
##  - `max_size` is a file size (in bytes) above which a blob will be marked
##    as binary automatically; pass a negative value to disable.
##  - `notify_cb` is an optional callback function, notifying the consumer of
##    changes to the diff as new deltas are added.
##  - `progress_cb` is an optional callback function, notifying the consumer of
##    which files are being examined as the diff is generated.
##  - `payload` is the payload to pass to the callback functions.
##  - `ignore_submodules` overrides the submodule ignore setting for all
##    submodules in the diff.
## 

type
  git_diff_options* {.bycopy.} = object
    version*: cuint            ## *< version for the struct
    flags*: uint32           ## *< defaults to GIT_DIFF_NORMAL
                   ##  options controlling which files are in the diff
    ignore_submodules*: git_submodule_ignore_t ## *< submodule ignore rule
    pathspec*: git_strarray    ## *< defaults to include all paths
    notify_cb*: git_diff_notify_cb
    progress_cb*: git_diff_progress_cb
    payload*: pointer          ##  options controlling how to diff text is generated
    context_lines*: uint32   ## *< defaults to 3
    interhunk_lines*: uint32 ## *< defaults to 0
    id_abbrev*: uint16       ## *< default 'core.abbrev' or 7 if unset
    max_size*: git_off_t       ## *< defaults to 512MB
    old_prefix*: cstring       ## *< defaults to "a"
    new_prefix*: cstring       ## *< defaults to "b"
  

##  The current version of the diff options structure

const
  GIT_DIFF_OPTIONS_VERSION* = 1

##  Stack initializer for diff options.  Alternatively use
##  `git_diff_options_init` programmatic initialization.
## 

## *
##  Initializes a `git_diff_options` with default values. Equivalent to
##  creating an instance with GIT_DIFF_OPTIONS_INIT.
## 
##  @param opts The `git_diff_options` struct to initialize
##  @param version Version of struct; pass `GIT_DIFF_OPTIONS_VERSION`
##  @return Zero on success; -1 on failure.
## 

proc git_diff_init_options*(opts: ptr git_diff_options; version: cuint): cint  {.importc.}
## *
##  When iterating over a diff, callback that will be made per file.
## 
##  @param delta A pointer to the delta data for the file
##  @param progress Goes from 0 to 1 over the diff
##  @param payload User-specified pointer from foreach function
## 

type
  git_diff_file_cb* = proc (delta: ptr git_diff_delta; progress: cfloat; 
                         payload: pointer): cint

const
  GIT_DIFF_HUNK_HEADER_SIZE* = 128

## *
##  When producing a binary diff, the binary data returned will be
##  either the deflated full ("literal") contents of the file, or
##  the deflated binary delta between the two sides (whichever is
##  smaller).
## 

type                          ## * There is no binary delta.
  git_diff_binary_t* = enum
    GIT_DIFF_BINARY_NONE,     ## * The binary data is the literal contents of the file.
    GIT_DIFF_BINARY_LITERAL,  ## * The binary data is the delta from one side to the other.
    GIT_DIFF_BINARY_DELTA


## * The contents of one of the files in a binary diff.

type
  git_diff_binary_file* {.bycopy.} = object
    `type`*: git_diff_binary_t ## * The type of binary data for this file.
    ## * The binary data, deflated.
    data*: cstring             ## * The length of the binary data.
    datalen*: csize            ## * The length of the binary data after inflation.
    inflatedlen*: csize


## * Structure describing the binary contents of a diff.

type
  git_diff_binary* {.bycopy.} = object
    contains_data*: cuint ## *
                        ##  Whether there is data in this binary structure or not.  If this
                        ##  is `1`, then this was produced and included binary content.  If
                        ##  this is `0` then this was generated knowing only that a binary
                        ##  file changed but without providing the data, probably from a patch
                        ##  that said `Binary files a/file.txt and b/file.txt differ`.
                        ## 
    old_file*: git_diff_binary_file ## *< The contents of the old file.
    new_file*: git_diff_binary_file ## *< The contents of the new file.
  

## *
##  When iterating over a diff, callback that will be made for
##  binary content within the diff.
## 

type
  git_diff_binary_cb* = proc (delta: ptr git_diff_delta; binary: ptr git_diff_binary; 
                           payload: pointer): cint

## *
##  Structure describing a hunk of a diff.
## 

type
  git_diff_hunk* {.bycopy.} = object
    old_start*: cint           ## * Starting line number in old_file
    old_lines*: cint           ## * Number of lines in old_file
    new_start*: cint           ## * Starting line number in new_file
    new_lines*: cint           ## * Number of lines in new_file
    header_len*: csize         ## * Number of bytes in header text
    header*: array[GIT_DIFF_HUNK_HEADER_SIZE, char] ## * Header text, NUL-byte terminated
  

## *
##  When iterating over a diff, callback that will be made per hunk.
## 

type
  git_diff_hunk_cb* = proc (delta: ptr git_diff_delta; hunk: ptr git_diff_hunk; 
                         payload: pointer): cint

## *
##  Line origin constants.
## 
##  These values describe where a line came from and will be passed to
##  the git_diff_line_cb when iterating over a diff.  There are some
##  special origin constants at the end that are used for the text
##  output callbacks to demarcate lines that are actually part of
##  the file or hunk headers.
## 

type                          ##  These values will be sent to `git_diff_line_cb` along with the line
  git_diff_line_t* = int32
const
    GIT_DIFF_LINE_CONTEXT* = ' ' 
    GIT_DIFF_LINE_ADDITION* = '+'
    GIT_DIFF_LINE_DELETION* = '-'
    GIT_DIFF_LINE_CONTEXT_EOFNL* = '=' ## *< Both files have no LF at end
    GIT_DIFF_LINE_ADD_EOFNL* = '>' ## *< Old has no LF at end, new does
    GIT_DIFF_LINE_DEL_EOFNL* = '<' ## *< Old has LF at end, new does not
                                ##  The following values will only be sent to a `git_diff_line_cb` when
                                ##  the content of a diff is being formatted through `git_diff_print`.
                                ## 
    GIT_DIFF_LINE_FILE_HDR* = 'F'
    GIT_DIFF_LINE_HUNK_HDR* = 'H'
    GIT_DIFF_LINE_BINARY* = 'B'


## *
##  Structure describing a line (or data span) of a diff.
## 

type
  git_diff_line* {.bycopy.} = object
    origin*: char              ## *< A git_diff_line_t value
    old_lineno*: cint          ## *< Line number in old file or -1 for added line
    new_lineno*: cint          ## *< Line number in new file or -1 for deleted line
    num_lines*: cint           ## *< Number of newline characters in content
    content_len*: csize        ## *< Number of bytes of data
    content_offset*: git_off_t ## *< Offset in the original file to the content
    content*: cstring          ## *< Pointer to diff text, not NUL-byte terminated
  

## *
##  When iterating over a diff, callback that will be made per text diff
##  line. In this context, the provided range will be NULL.
## 
##  When printing a diff, callback that will be made to output each line
##  of text.  This uses some extra GIT_DIFF_LINE_... constants for output
##  of lines of file and hunk headers.
## 

type
  git_diff_line_cb* = proc (delta: ptr git_diff_delta; hunk: ptr git_diff_hunk; 
                         line: ptr git_diff_line; payload: pointer): cint ## *< delta that contains this data {.importc.}
                                                                    ## *< hunk containing this data
                                                                    ## *< line data

## *< user reference data
## *
##  Flags to control the behavior of diff rename/copy detection.
## 

type                          ## * Obey `diff.renames`. Overridden by any other GIT_DIFF_FIND_... flag.
  git_diff_find_t* = enum
    GIT_DIFF_FIND_BY_CONFIG = 0, ## * Look for renames? (`--find-renames`)
    GIT_DIFF_FIND_RENAMES = (1 shl 0), ## * Consider old side of MODIFIED for renames? (`--break-rewrites=N`)
    GIT_DIFF_FIND_RENAMES_FROM_REWRITES = (1 shl 1), ## * Look for copies? (a la `--find-copies`).
    GIT_DIFF_FIND_COPIES = (1 shl 2), ## * Consider UNMODIFIED as copy sources? (`--find-copies-harder`).
                                 ## 
                                 ##  For this to work correctly, use GIT_DIFF_INCLUDE_UNMODIFIED when
                                 ##  the initial `git_diff` is being generated.
                                 ## 
    GIT_DIFF_FIND_COPIES_FROM_UNMODIFIED = (1 shl 3), ## * Mark significant rewrites for split (`--break-rewrites=/M`)
    GIT_DIFF_FIND_REWRITES = (1 shl 4), ## * Actually split large rewrites into delete/add pairs
    GIT_DIFF_BREAK_REWRITES = (1 shl 5), ## * Mark rewrites for split and break into delete/add pairs
    GIT_DIFF_FIND_AND_BREAK_REWRITES = (ord(GIT_DIFF_FIND_REWRITES) or
        ord(GIT_DIFF_BREAK_REWRITES)), ## * Find renames/copies for UNTRACKED items in working directory.
                                 ## 
                                 ##  For this to work correctly, use GIT_DIFF_INCLUDE_UNTRACKED when the
                                 ##  initial `git_diff` is being generated (and obviously the diff must
                                 ##  be against the working directory for this to make sense).
                                 ## 
    GIT_DIFF_FIND_FOR_UNTRACKED = (1 shl 6), ## * Turn on all finding features.
    GIT_DIFF_FIND_ALL = (0x000000FF), ## * Measure similarity ignoring leading whitespace (default)
    GIT_DIFF_FIND_IGNORE_WHITESPACE = (1 shl 12), ## * Measure similarity including all data
    GIT_DIFF_FIND_DONT_IGNORE_WHITESPACE = (1 shl 13), ## * Measure similarity only by comparing SHAs (fast and cheap)
    GIT_DIFF_FIND_EXACT_MATCH_ONLY = (1 shl 14), ## * Do not break rewrites unless they contribute to a rename.
                                            ## 
                                            ##  Normally, GIT_DIFF_FIND_AND_BREAK_REWRITES will measure the self-
                                            ##  similarity of modified files and split the ones that have changed a
                                            ##  lot into a DELETE / ADD pair.  Then the sides of that pair will be
                                            ##  considered candidates for rename and copy detection.
                                            ## 
                                            ##  If you add this flag in and the split pair is *not* used for an
                                            ##  actual rename or copy, then the modified record will be restored to
                                            ##  a regular MODIFIED record instead of being split.
                                            ## 
    GIT_DIFF_BREAK_REWRITES_FOR_RENAMES_ONLY = (1 shl 15), ## * Remove any UNMODIFIED deltas after find_similar is done.
                                                      ## 
                                                      ##  Using 
                                                      ## GIT_DIFF_FIND_COPIES_FROM_UNMODIFIED to emulate the
                                                      ##  --find-copies-harder behavior requires building a diff with the
                                                      ##  
                                                      ## GIT_DIFF_INCLUDE_UNMODIFIED flag.  If you do not want UNMODIFIED
                                                      ##  records in the final result, pass this flag to have them removed.
                                                      ## 
    GIT_DIFF_FIND_REMOVE_UNMODIFIED = (1 shl 16)

const
  GIT_DIFF_FIND_IGNORE_LEADING_WHITESPACE* = GIT_DIFF_FIND_BY_CONFIG

## *
##  Pluggable similarity metric
## 

type
  git_diff_similarity_metric* {.bycopy.} = object
    file_signature*: proc (`out`: ptr pointer; file: ptr git_diff_file; 
                         fullpath: cstring; payload: pointer): cint
    buffer_signature*: proc (`out`: ptr pointer; file: ptr git_diff_file; buf: cstring; 
                           buflen: csize; payload: pointer): cint
    free_signature*: proc (sig: pointer; payload: pointer) 
    similarity*: proc (score: ptr cint; siga: pointer; sigb: pointer; payload: pointer): cint
    payload*: pointer


## *
##  Control behavior of rename and copy detection
## 
##  These options mostly mimic parameters that can be passed to git-diff.
## 
##  - `rename_threshold` is the same as the -M option with a value
##  - `copy_threshold` is the same as the -C option with a value
##  - `rename_from_rewrite_threshold` matches the top of the -B option
##  - `break_rewrite_threshold` matches the bottom of the -B option
##  - `rename_limit` is the maximum number of matches to consider for
##    a particular file.  This is a little different from the `-l` option
##    to regular Git because we will still process up to this many matches
##    before abandoning the search.
## 
##  The `metric` option allows you to plug in a custom similarity metric.
##  Set it to NULL for the default internal metric which is based on sampling
##  hashes of ranges of data in the file.  The default metric is a pretty
##  good similarity approximation that should work fairly well for both text
##  and binary data, and is pretty fast with fixed memory overhead.
## 

type
  git_diff_find_options* {.bycopy.} = object
    version*: cuint ## *
                  ##  Combination of git_diff_find_t values (default GIT_DIFF_FIND_BY_CONFIG).
                  ##  NOTE: if you don't explicitly set this, `diff.renames` could be set
                  ##  to false, resulting in `git_diff_find_similar` doing nothing.
                  ## 
    flags*: uint32           ## * Similarity to consider a file renamed (default 50)
    rename_threshold*: uint16 ## * Similarity of modified to be eligible rename source (default 50)
    rename_from_rewrite_threshold*: uint16 ## * Similarity to consider a file a copy (default 50)
    copy_threshold*: uint16  ## * Similarity to split modify into delete/add pair (default 60)
    break_rewrite_threshold*: uint16 ## * Maximum similarity sources to examine for a file (somewhat like
                                     ##   git-diff's `-l` option or `diff.renameLimit` config) (default 200)
                                     ## 
    rename_limit*: csize       ## * Pluggable similarity metric; pass NULL to use internal metric
    metric*: ptr git_diff_similarity_metric


const
  GIT_DIFF_FIND_OPTIONS_VERSION* = 1

## *
##  Initializes a `git_diff_find_options` with default values. Equivalent to
##  creating an instance with GIT_DIFF_FIND_OPTIONS_INIT.
## 
##  @param opts The `git_diff_find_options` struct to initialize
##  @param version Version of struct; pass `GIT_DIFF_FIND_OPTIONS_VERSION`
##  @return Zero on success; -1 on failure.
## 

proc git_diff_find_init_options*(opts: ptr git_diff_find_options; version: cuint): cint  {.importc.}
## * @name Diff Generator Functions
## 
##  These are the functions you would use to create (or destroy) a
##  git_diff from various objects in a repository.
## 
## *@{
## *
##  Deallocate a diff.
## 
##  @param diff The previously created diff; cannot be used after free.
## 

proc git_diff_free*(diff: ptr git_diff)  {.importc.}
## *
##  Create a diff with the difference between two tree objects.
## 
##  This is equivalent to `git diff <old-tree> <new-tree>`
## 
##  The first tree will be used for the "old_file" side of the delta and the
##  second tree will be used for the "new_file" side of the delta.  You can
##  pass NULL to indicate an empty tree, although it is an error to pass
##  NULL for both the `old_tree` and `new_tree`.
## 
##  @param diff Output pointer to a git_diff pointer to be allocated.
##  @param repo The repository containing the trees.
##  @param old_tree A git_tree object to diff from, or NULL for empty tree.
##  @param new_tree A git_tree object to diff to, or NULL for empty tree.
##  @param opts Structure with options to influence diff or NULL for defaults.
## 

proc git_diff_tree_to_tree*(diff: ptr ptr git_diff; repo: ptr git_repository; 
                           old_tree: ptr git_tree; new_tree: ptr git_tree;
                           opts: ptr git_diff_options): cint {.importc.}
## *< can be NULL for defaults
## *
##  Create a diff between a tree and repository index.
## 
##  This is equivalent to `git diff --cached <treeish>` or if you pass
##  the HEAD tree, then like `git diff --cached`.
## 
##  The tree you pass will be used for the "old_file" side of the delta, and
##  the index will be used for the "new_file" side of the delta.
## 
##  If you pass NULL for the index, then the existing index of the `repo`
##  will be used.  In this case, the index will be refreshed from disk
##  (if it has changed) before the diff is generated.
## 
##  @param diff Output pointer to a git_diff pointer to be allocated.
##  @param repo The repository containing the tree and index.
##  @param old_tree A git_tree object to diff from, or NULL for empty tree.
##  @param index The index to diff with; repo index used if NULL.
##  @param opts Structure with options to influence diff or NULL for defaults.
## 

proc git_diff_tree_to_index*(diff: ptr ptr git_diff; repo: ptr git_repository; 
                            old_tree: ptr git_tree; index: ptr git_index;
                            opts: ptr git_diff_options): cint {.importc.}
## *< can be NULL for defaults
## *
##  Create a diff between the repository index and the workdir directory.
## 
##  This matches the `git diff` command.  See the note below on
##  `git_diff_tree_to_workdir` for a discussion of the difference between
##  `git diff` and `git diff HEAD` and how to emulate a `git diff <treeish>`
##  using libgit2.
## 
##  The index will be used for the "old_file" side of the delta, and the
##  working directory will be used for the "new_file" side of the delta.
## 
##  If you pass NULL for the index, then the existing index of the `repo`
##  will be used.  In this case, the index will be refreshed from disk
##  (if it has changed) before the diff is generated.
## 
##  @param diff Output pointer to a git_diff pointer to be allocated.
##  @param repo The repository.
##  @param index The index to diff from; repo index used if NULL.
##  @param opts Structure with options to influence diff or NULL for defaults.
## 

proc git_diff_index_to_workdir*(diff: ptr ptr git_diff; repo: ptr git_repository; 
                               index: ptr git_index; opts: ptr git_diff_options): cint {.importc.}
## *< can be NULL for defaults
## *
##  Create a diff between a tree and the working directory.
## 
##  The tree you provide will be used for the "old_file" side of the delta,
##  and the working directory will be used for the "new_file" side.
## 
##  This is not the same as `git diff <treeish>` or `git diff-index
##  <treeish>`.  Those commands use information from the index, whereas this
##  function strictly returns the differences between the tree and the files
##  in the working directory, regardless of the state of the index.  Use
##  `git_diff_tree_to_workdir_with_index` to emulate those commands.
## 
##  To see difference between this and `git_diff_tree_to_workdir_with_index`,
##  consider the example of a staged file deletion where the file has then
##  been put back into the working dir and further modified.  The
##  tree-to-workdir diff for that file is 'modified', but `git diff` would
##  show status 'deleted' since there is a staged delete.
## 
##  @param diff A pointer to a git_diff pointer that will be allocated.
##  @param repo The repository containing the tree.
##  @param old_tree A git_tree object to diff from, or NULL for empty tree.
##  @param opts Structure with options to influence diff or NULL for defaults.
## 

proc git_diff_tree_to_workdir*(diff: ptr ptr git_diff; repo: ptr git_repository; 
                              old_tree: ptr git_tree; opts: ptr git_diff_options): cint {.importc.}
## *< can be NULL for defaults
## *
##  Create a diff between a tree and the working directory using index data
##  to account for staged deletes, tracked files, etc.
## 
##  This emulates `git diff <tree>` by diffing the tree to the index and
##  the index to the working directory and blending the results into a
##  single diff that includes staged deleted, etc.
## 
##  @param diff A pointer to a git_diff pointer that will be allocated.
##  @param repo The repository containing the tree.
##  @param old_tree A git_tree object to diff from, or NULL for empty tree.
##  @param opts Structure with options to influence diff or NULL for defaults.
## 

proc git_diff_tree_to_workdir_with_index*(diff: ptr ptr git_diff; 
    repo: ptr git_repository; old_tree: ptr git_tree; opts: ptr git_diff_options): cint {.importc.}
## *< can be NULL for defaults
## *
##  Create a diff with the difference between two index objects.
## 
##  The first index will be used for the "old_file" side of the delta and the
##  second index will be used for the "new_file" side of the delta.
## 
##  @param diff Output pointer to a git_diff pointer to be allocated.
##  @param repo The repository containing the indexes.
##  @param old_index A git_index object to diff from.
##  @param new_index A git_index object to diff to.
##  @param opts Structure with options to influence diff or NULL for defaults.
## 

proc git_diff_index_to_index*(diff: ptr ptr git_diff; repo: ptr git_repository; 
                             old_index: ptr git_index; new_index: ptr git_index;
                             opts: ptr git_diff_options): cint {.importc.}
## *< can be NULL for defaults
## *
##  Merge one diff into another.
## 
##  This merges items from the "from" list into the "onto" list.  The
##  resulting diff will have all items that appear in either list.
##  If an item appears in both lists, then it will be "merged" to appear
##  as if the old version was from the "onto" list and the new version
##  is from the "from" list (with the exception that if the item has a
##  pending DELETE in the middle, then it will show as deleted).
## 
##  @param onto Diff to merge into.
##  @param from Diff to merge.
## 

proc git_diff_merge*(onto: ptr git_diff; `from`: ptr git_diff): cint  {.importc.}
## *
##  Transform a diff marking file renames, copies, etc.
## 
##  This modifies a diff in place, replacing old entries that look
##  like renames or copies with new entries reflecting those changes.
##  This also will, if requested, break modified files into add/remove
##  pairs if the amount of change is above a threshold.
## 
##  @param diff diff to run detection algorithms on
##  @param options Control how detection should be run, NULL for defaults
##  @return 0 on success, -1 on failure
## 

proc git_diff_find_similar*(diff: ptr git_diff; options: ptr git_diff_find_options): cint  {.importc.}
## *@}
## * @name Diff Processor Functions
## 
##  These are the functions you apply to a diff to process it
##  or read it in some way.
## 
## *@{
## *
##  Query how many diff records are there in a diff.
## 
##  @param diff A git_diff generated by one of the above functions
##  @return Count of number of deltas in the list
## 

proc git_diff_num_deltas*(diff: ptr git_diff): csize  {.importc.}
## *
##  Query how many diff deltas are there in a diff filtered by type.
## 
##  This works just like `git_diff_entrycount()` with an extra parameter
##  that is a `git_delta_t` and returns just the count of how many deltas
##  match that particular type.
## 
##  @param diff A git_diff generated by one of the above functions
##  @param type A git_delta_t value to filter the count
##  @return Count of number of deltas matching delta_t type
## 

proc git_diff_num_deltas_of_type*(diff: ptr git_diff; `type`: git_delta_t): csize  {.importc.}
## *
##  Return the diff delta for an entry in the diff list.
## 
##  The `git_diff_delta` pointer points to internal data and you do not
##  have to release it when you are done with it.  It will go away when
##  the * `git_diff` (or any associated `git_patch`) goes away.
## 
##  Note that the flags on the delta related to whether it has binary
##  content or not may not be set if there are no attributes set for the
##  file and there has been no reason to load the file data at this point.
##  For now, if you need those flags to be up to date, your only option is
##  to either use `git_diff_foreach` or create a `git_patch`.
## 
##  @param diff Diff list object
##  @param idx Index into diff list
##  @return Pointer to git_diff_delta (or NULL if `idx` out of range)
## 

proc git_diff_get_delta*(diff: ptr git_diff; idx: csize): ptr git_diff_delta  {.importc.}
## *
##  Check if deltas are sorted case sensitively or insensitively.
## 
##  @param diff diff to check
##  @return 0 if case sensitive, 1 if case is ignored
## 

proc git_diff_is_sorted_icase*(diff: ptr git_diff): cint  {.importc.}
## *
##  Loop over all deltas in a diff issuing callbacks.
## 
##  This will iterate through all of the files described in a diff.  You
##  should provide a file callback to learn about each file.
## 
##  The "hunk" and "line" callbacks are optional, and the text diff of the
##  files will only be calculated if they are not NULL.  Of course, these
##  callbacks will not be invoked for binary files on the diff or for
##  files whose only changed is a file mode change.
## 
##  Returning a non-zero value from any of the callbacks will terminate
##  the iteration and return the value to the user.
## 
##  @param diff A git_diff generated by one of the above functions.
##  @param file_cb Callback function to make per file in the diff.
##  @param binary_cb Optional callback to make for binary files.
##  @param hunk_cb Optional callback to make per hunk of text diff.  This
##                 callback is called to describe a range of lines in the
##                 diff.  It will not be issued for binary files.
##  @param line_cb Optional callback to make per line of diff text.  This
##                 same callback will be made for context lines, added, and
##                 removed lines, and even for a deleted trailing newline.
##  @param payload Reference pointer that will be passed to your callbacks.
##  @return 0 on success, non-zero callback return value, or error code
## 

proc git_diff_foreach*(diff: ptr git_diff; file_cb: git_diff_file_cb; 
                      binary_cb: git_diff_binary_cb; hunk_cb: git_diff_hunk_cb;
                      line_cb: git_diff_line_cb; payload: pointer): cint {.importc.}
## *
##  Look up the single character abbreviation for a delta status code.
## 
##  When you run `git diff --name-status` it uses single letter codes in
##  the output such as 'A' for added, 'D' for deleted, 'M' for modified,
##  etc.  This function converts a git_delta_t value into these letters for
##  your own purposes.  GIT_DELTA_UNTRACKED will return a space (i.e. ' ').
## 
##  @param status The git_delta_t value to look up
##  @return The single character label for that code
## 

proc git_diff_status_char*(status: git_delta_t): char  {.importc.}
## *
##  Possible output formats for diff data
## 

type
  git_diff_format_t* = enum
    GIT_DIFF_FORMAT_PATCH = 1,  ## *< full git diff
    GIT_DIFF_FORMAT_PATCH_HEADER = 2, ## *< just the file headers of patch
    GIT_DIFF_FORMAT_RAW = 3,    ## *< like git diff --raw
    GIT_DIFF_FORMAT_NAME_ONLY = 4, ## *< like git diff --name-only
    GIT_DIFF_FORMAT_NAME_STATUS = 5 ## *< like git diff --name-status


## *
##  Iterate over a diff generating formatted text output.
## 
##  Returning a non-zero value from the callbacks will terminate the
##  iteration and return the non-zero value to the caller.
## 
##  @param diff A git_diff generated by one of the above functions.
##  @param format A git_diff_format_t value to pick the text format.
##  @param print_cb Callback to make per line of diff text.
##  @param payload Reference pointer that will be passed to your callback.
##  @return 0 on success, non-zero callback return value, or error code
## 

proc git_diff_print*(diff: ptr git_diff; format: git_diff_format_t; 
                    print_cb: git_diff_line_cb; payload: pointer): cint {.importc.}
## *
##  Produce the complete formatted text output from a diff into a
##  buffer.
## 
##  @param out A pointer to a user-allocated git_buf that will
##             contain the diff text
##  @param diff A git_diff generated by one of the above functions.
##  @param format A git_diff_format_t value to pick the text format.
##  @return 0 on success or error code
## 

proc git_diff_to_buf*(`out`: ptr git_buf; diff: ptr git_diff; format: git_diff_format_t): cint  {.importc.}
## *@}
## 
##  Misc
## 
## *
##  Directly run a diff on two blobs.
## 
##  Compared to a file, a blob lacks some contextual information. As such,
##  the `git_diff_file` given to the callback will have some fake data; i.e.
##  `mode` will be 0 and `path` will be NULL.
## 
##  NULL is allowed for either `old_blob` or `new_blob` and will be treated
##  as an empty blob, with the `oid` set to NULL in the `git_diff_file` data.
##  Passing NULL for both blobs is a noop; no callbacks will be made at all.
## 
##  We do run a binary content check on the blob content and if either blob
##  looks like binary data, the `git_diff_delta` binary attribute will be set
##  to 1 and no call to the hunk_cb nor line_cb will be made (unless you pass
##  `GIT_DIFF_FORCE_TEXT` of course).
## 
##  @param old_blob Blob for old side of diff, or NULL for empty blob
##  @param old_as_path Treat old blob as if it had this filename; can be NULL
##  @param new_blob Blob for new side of diff, or NULL for empty blob
##  @param new_as_path Treat new blob as if it had this filename; can be NULL
##  @param options Options for diff, or NULL for default options
##  @param file_cb Callback for "file"; made once if there is a diff; can be NULL
##  @param binary_cb Callback for binary files; can be NULL
##  @param hunk_cb Callback for each hunk in diff; can be NULL
##  @param line_cb Callback for each line in diff; can be NULL
##  @param payload Payload passed to each callback function
##  @return 0 on success, non-zero callback return value, or error code
## 

proc git_diff_blobs*(old_blob: ptr git_blob; old_as_path: cstring; 
                    new_blob: ptr git_blob; new_as_path: cstring;
                    options: ptr git_diff_options; file_cb: git_diff_file_cb;
                    binary_cb: git_diff_binary_cb; hunk_cb: git_diff_hunk_cb;
                    line_cb: git_diff_line_cb; payload: pointer): cint {.importc.}
## *
##  Directly run a diff between a blob and a buffer.
## 
##  As with `git_diff_blobs`, comparing a blob and buffer lacks some context,
##  so the `git_diff_file` parameters to the callbacks will be faked a la the
##  rules for `git_diff_blobs()`.
## 
##  Passing NULL for `old_blob` will be treated as an empty blob (i.e. the
##  `file_cb` will be invoked with GIT_DELTA_ADDED and the diff will be the
##  entire content of the buffer added).  Passing NULL to the buffer will do
##  the reverse, with GIT_DELTA_REMOVED and blob content removed.
## 
##  @param old_blob Blob for old side of diff, or NULL for empty blob
##  @param old_as_path Treat old blob as if it had this filename; can be NULL
##  @param buffer Raw data for new side of diff, or NULL for empty
##  @param buffer_len Length of raw data for new side of diff
##  @param buffer_as_path Treat buffer as if it had this filename; can be NULL
##  @param options Options for diff, or NULL for default options
##  @param file_cb Callback for "file"; made once if there is a diff; can be NULL
##  @param binary_cb Callback for binary files; can be NULL
##  @param hunk_cb Callback for each hunk in diff; can be NULL
##  @param line_cb Callback for each line in diff; can be NULL
##  @param payload Payload passed to each callback function
##  @return 0 on success, non-zero callback return value, or error code
## 

proc git_diff_blob_to_buffer*(old_blob: ptr git_blob; old_as_path: cstring; 
                             buffer: cstring; buffer_len: csize;
                             buffer_as_path: cstring;
                             options: ptr git_diff_options;
                             file_cb: git_diff_file_cb;
                             binary_cb: git_diff_binary_cb;
                             hunk_cb: git_diff_hunk_cb; line_cb: git_diff_line_cb;
                             payload: pointer): cint {.importc.}
## *
##  Directly run a diff between two buffers.
## 
##  Even more than with `git_diff_blobs`, comparing two buffer lacks
##  context, so the `git_diff_file` parameters to the callbacks will be
##  faked a la the rules for `git_diff_blobs()`.
## 
##  @param old_buffer Raw data for old side of diff, or NULL for empty
##  @param old_len Length of the raw data for old side of the diff
##  @param old_as_path Treat old buffer as if it had this filename; can be NULL
##  @param new_buffer Raw data for new side of diff, or NULL for empty
##  @param new_len Length of raw data for new side of diff
##  @param new_as_path Treat buffer as if it had this filename; can be NULL
##  @param options Options for diff, or NULL for default options
##  @param file_cb Callback for "file"; made once if there is a diff; can be NULL
##  @param binary_cb Callback for binary files; can be NULL
##  @param hunk_cb Callback for each hunk in diff; can be NULL
##  @param line_cb Callback for each line in diff; can be NULL
##  @param payload Payload passed to each callback function
##  @return 0 on success, non-zero callback return value, or error code
## 

proc git_diff_buffers*(old_buffer: pointer; old_len: csize; old_as_path: cstring; 
                      new_buffer: pointer; new_len: csize; new_as_path: cstring;
                      options: ptr git_diff_options; file_cb: git_diff_file_cb;
                      binary_cb: git_diff_binary_cb; hunk_cb: git_diff_hunk_cb;
                      line_cb: git_diff_line_cb; payload: pointer): cint {.importc.}
## *
##  Read the contents of a git patch file into a `git_diff` object.
## 
##  The diff object produced is similar to the one that would be
##  produced if you actually produced it computationally by comparing
##  two trees, however there may be subtle differences.  For example,
##  a patch file likely contains abbreviated object IDs, so the
##  object IDs in a `git_diff_delta` produced by this function will
##  also be abbreviated.
## 
##  This function will only read patch files created by a git
##  implementation, it will not read unified diffs produced by
##  the `diff` program, nor any other types of patch files.
## 
##  @param out A pointer to a git_diff pointer that will be allocated.
##  @param content The contents of a patch file
##  @param content_len The length of the patch file contents
##  @return 0 or an error code
## 

proc git_diff_from_buffer*(`out`: ptr ptr git_diff; content: cstring; 
                          content_len: csize): cint {.importc.}
## *
##  This is an opaque structure which is allocated by `git_diff_get_stats`.
##  You are responsible for releasing the object memory when done, using the
##  `git_diff_stats_free()` function.
## 


## *
##  Formatting options for diff stats
## 

type                          ## * No stats
  git_diff_stats_format_t* = enum
    GIT_DIFF_STATS_NONE = 0,    ## * Full statistics, equivalent of `--stat`
    GIT_DIFF_STATS_FULL = (1 shl 0), ## * Short statistics, equivalent of `--shortstat`
    GIT_DIFF_STATS_SHORT = (1 shl 1), ## * Number statistics, equivalent of `--numstat`
    GIT_DIFF_STATS_NUMBER = (1 shl 2), ## * Extended header information such as creations, renames and mode changes, equivalent of `--summary`
    GIT_DIFF_STATS_INCLUDE_SUMMARY = (1 shl 3)


## *
##  Accumulate diff statistics for all patches.
## 
##  @param out Structure containg the diff statistics.
##  @param diff A git_diff generated by one of the above functions.
##  @return 0 on success; non-zero on error
## 

proc git_diff_get_stats*(`out`: ptr ptr git_diff_stats; diff: ptr git_diff): cint  {.importc.}
## *
##  Get the total number of files changed in a diff
## 
##  @param stats A `git_diff_stats` generated by one of the above functions.
##  @return total number of files changed in the diff
## 

proc git_diff_stats_files_changed*(stats: ptr git_diff_stats): csize  {.importc.}
## *
##  Get the total number of insertions in a diff
## 
##  @param stats A `git_diff_stats` generated by one of the above functions.
##  @return total number of insertions in the diff
## 

proc git_diff_stats_insertions*(stats: ptr git_diff_stats): csize  {.importc.}
## *
##  Get the total number of deletions in a diff
## 
##  @param stats A `git_diff_stats` generated by one of the above functions.
##  @return total number of deletions in the diff
## 

proc git_diff_stats_deletions*(stats: ptr git_diff_stats): csize  {.importc.}
## *
##  Print diff statistics to a `git_buf`.
## 
##  @param out buffer to store the formatted diff statistics in.
##  @param stats A `git_diff_stats` generated by one of the above functions.
##  @param format Formatting option.
##  @param width Target width for output (only affects GIT_DIFF_STATS_FULL)
##  @return 0 on success; non-zero on error
## 

proc git_diff_stats_to_buf*(`out`: ptr git_buf; stats: ptr git_diff_stats; 
                           format: git_diff_stats_format_t; width: csize): cint {.importc.}
## *
##  Deallocate a `git_diff_stats`.
## 
##  @param stats The previously created statistics object;
##  cannot be used after free.
## 

proc git_diff_stats_free*(stats: ptr git_diff_stats)  {.importc.}
## *
##  Formatting options for diff e-mail generation
## 

type                          ## * Normal patch, the default
  git_diff_format_email_flags_t* = enum
    GIT_DIFF_FORMAT_EMAIL_NONE = 0, ## * Don't insert "[PATCH]" in the subject header
    GIT_DIFF_FORMAT_EMAIL_EXCLUDE_SUBJECT_PATCH_MARKER = (1 shl 0)


## *
##  Options for controlling the formatting of the generated e-mail.
## 

type
  git_diff_format_email_options* {.bycopy.} = object
    version*: cuint
    flags*: git_diff_format_email_flags_t ## * This patch number
    patch_no*: csize           ## * Total number of patches in this series
    total_patches*: csize      ## * id to use for the commit
    id*: ptr git_oid            ## * Summary of the change
    summary*: cstring          ## * Commit message's body
    body*: cstring             ## * Author of the change
    author*: ptr git_signature


const
  GIT_DIFF_FORMAT_EMAIL_OPTIONS_VERSION* = 1

## *
##  Create an e-mail ready patch from a diff.
## 
##  @param out buffer to store the e-mail patch in
##  @param diff containing the commit
##  @param opts structure with options to influence content and formatting.
##  @return 0 or an error code
## 

proc git_diff_format_email*(`out`: ptr git_buf; diff: ptr git_diff; 
                           opts: ptr git_diff_format_email_options): cint {.importc.}
## *
##  Create an e-mail ready patch for a commit.
## 
##  Does not support creating patches for merge commits (yet).
## 
##  @param out buffer to store the e-mail patch in
##  @param repo containing the commit
##  @param commit pointer to up commit
##  @param patch_no patch number of the commit
##  @param total_patches total number of patches in the patch set
##  @param flags determines the formatting of the e-mail
##  @param diff_opts structure with options to influence diff or NULL for defaults.
##  @return 0 or an error code
## 

proc git_diff_commit_as_email*(`out`: ptr git_buf; repo: ptr git_repository; 
                              commit: ptr git_commit; patch_no: csize;
                              total_patches: csize;
                              flags: git_diff_format_email_flags_t;
                              diff_opts: ptr git_diff_options): cint {.importc.}
## *
##  Initializes a `git_diff_format_email_options` with default values.
## 
##  Equivalent to creating an instance with GIT_DIFF_FORMAT_EMAIL_OPTIONS_INIT.
## 
##  @param opts The `git_diff_format_email_options` struct to initialize
##  @param version Version of struct; pass `GIT_DIFF_FORMAT_EMAIL_OPTIONS_VERSION`
##  @return Zero on success; -1 on failure.
## 

proc git_diff_format_email_init_options*(opts: ptr git_diff_format_email_options; 
                                        version: cuint): cint {.importc.}
## * @}
