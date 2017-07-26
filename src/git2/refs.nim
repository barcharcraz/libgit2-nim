## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 

{.push dynlib: "libgit2".}
{.push callconv: cdecl.}
import
  common, types, oid, strarray

## *
##  @file git2/refs.h
##  @brief Git reference management routines
##  @defgroup git_reference Git reference management routines
##  @ingroup Git
##  @{
## 
## *
##  Lookup a reference by name in a repository.
## 
##  The returned reference must be freed by the user.
## 
##  The name will be checked for validity.
##  See `git_reference_symbolic_create()` for rules about valid names.
## 
##  @param out pointer to the looked-up reference
##  @param repo the repository to look up the reference
##  @param name the long name for the reference (e.g. HEAD, refs/heads/master, refs/tags/v0.1.0, ...)
##  @return 0 on success, GIT_ENOTFOUND, GIT_EINVALIDSPEC or an error code.
## 

proc git_reference_lookup*(`out`: ptr ptr git_reference; repo: ptr git_repository; 
                          name: cstring): cint {.importc.}
## *
##  Lookup a reference by name and resolve immediately to OID.
## 
##  This function provides a quick way to resolve a reference name straight
##  through to the object id that it refers to.  This avoids having to
##  allocate or free any `git_reference` objects for simple situations.
## 
##  The name will be checked for validity.
##  See `git_reference_symbolic_create()` for rules about valid names.
## 
##  @param out Pointer to oid to be filled in
##  @param repo The repository in which to look up the reference
##  @param name The long name for the reference (e.g. HEAD, refs/heads/master, refs/tags/v0.1.0, ...)
##  @return 0 on success, GIT_ENOTFOUND, GIT_EINVALIDSPEC or an error code.
## 

proc git_reference_name_to_id*(`out`: ptr git_oid; repo: ptr git_repository; 
                              name: cstring): cint {.importc.}
## *
##  Lookup a reference by DWIMing its short name
## 
##  Apply the git precendence rules to the given shorthand to determine
##  which reference the user is referring to.
## 
##  @param out pointer in which to store the reference
##  @param repo the repository in which to look
##  @param shorthand the short name for the reference
##  @return 0 or an error code
## 

proc git_reference_dwim*(`out`: ptr ptr git_reference; repo: ptr git_repository; 
                        shorthand: cstring): cint {.importc.}
## *
##  Conditionally create a new symbolic reference.
## 
##  A symbolic reference is a reference name that refers to another
##  reference name.  If the other name moves, the symbolic name will move,
##  too.  As a simple example, the "HEAD" reference might refer to
##  "refs/heads/master" while on the "master" branch of a repository.
## 
##  The symbolic reference will be created in the repository and written to
##  the disk.  The generated reference object must be freed by the user.
## 
##  Valid reference names must follow one of two patterns:
## 
##  1. Top-level names must contain only capital letters and underscores,
##     and must begin and end with a letter. (e.g. "HEAD", "ORIG_HEAD").
##  2. Names prefixed with "refs/" can be almost anything.  You must avoid
##     the characters '~', '^', ':', '\\', '?', '[', and '*', and the
##     sequences ".." and "@{" which have special meaning to revparse.
## 
##  This function will return an error if a reference already exists with the
##  given name unless `force` is true, in which case it will be overwritten.
## 
##  The message for the reflog will be ignored if the reference does
##  not belong in the standard set (HEAD, branches and remote-tracking
##  branches) and it does not have a reflog.
## 
##  It will return GIT_EMODIFIED if the reference's value at the time
##  of updating does not match the one passed through `current_value`
##  (i.e. if the ref has changed since the user read it).
## 
##  @param out Pointer to the newly created reference
##  @param repo Repository where that reference will live
##  @param name The name of the reference
##  @param target The target of the reference
##  @param force Overwrite existing references
##  @param current_value The expected value of the reference when updating
##  @param log_message The one line long message to be appended to the reflog
##  @return 0 on success, GIT_EEXISTS, GIT_EINVALIDSPEC, GIT_EMODIFIED or an error code
## 

proc git_reference_symbolic_create_matching*(`out`: ptr ptr git_reference; 
    repo: ptr git_repository; name: cstring; target: cstring; force: cint;
    current_value: cstring; log_message: cstring): cint {.importc.}
## *
##  Create a new symbolic reference.
## 
##  A symbolic reference is a reference name that refers to another
##  reference name.  If the other name moves, the symbolic name will move,
##  too.  As a simple example, the "HEAD" reference might refer to
##  "refs/heads/master" while on the "master" branch of a repository.
## 
##  The symbolic reference will be created in the repository and written to
##  the disk.  The generated reference object must be freed by the user.
## 
##  Valid reference names must follow one of two patterns:
## 
##  1. Top-level names must contain only capital letters and underscores,
##     and must begin and end with a letter. (e.g. "HEAD", "ORIG_HEAD").
##  2. Names prefixed with "refs/" can be almost anything.  You must avoid
##     the characters '~', '^', ':', '\\', '?', '[', and '*', and the
##     sequences ".." and "@{" which have special meaning to revparse.
## 
##  This function will return an error if a reference already exists with the
##  given name unless `force` is true, in which case it will be overwritten.
## 
##  The message for the reflog will be ignored if the reference does
##  not belong in the standard set (HEAD, branches and remote-tracking
##  branches) and it does not have a reflog.
## 
##  @param out Pointer to the newly created reference
##  @param repo Repository where that reference will live
##  @param name The name of the reference
##  @param target The target of the reference
##  @param force Overwrite existing references
##  @param log_message The one line long message to be appended to the reflog
##  @return 0 on success, GIT_EEXISTS, GIT_EINVALIDSPEC or an error code
## 

proc git_reference_symbolic_create*(`out`: ptr ptr git_reference; 
                                   repo: ptr git_repository; name: cstring;
                                   target: cstring; force: cint;
                                   log_message: cstring): cint {.importc.}
## *
##  Create a new direct reference.
## 
##  A direct reference (also called an object id reference) refers directly
##  to a specific object id (a.k.a. OID or SHA) in the repository.  The id
##  permanently refers to the object (although the reference itself can be
##  moved).  For example, in libgit2 the direct ref "refs/tags/v0.17.0"
##  refers to OID 5b9fac39d8a76b9139667c26a63e6b3f204b3977.
## 
##  The direct reference will be created in the repository and written to
##  the disk.  The generated reference object must be freed by the user.
## 
##  Valid reference names must follow one of two patterns:
## 
##  1. Top-level names must contain only capital letters and underscores,
##     and must begin and end with a letter. (e.g. "HEAD", "ORIG_HEAD").
##  2. Names prefixed with "refs/" can be almost anything.  You must avoid
##     the characters '~', '^', ':', '\\', '?', '[', and '*', and the
##     sequences ".." and "@{" which have special meaning to revparse.
## 
##  This function will return an error if a reference already exists with the
##  given name unless `force` is true, in which case it will be overwritten.
## 
##  The message for the reflog will be ignored if the reference does
##  not belong in the standard set (HEAD, branches and remote-tracking
##  branches) and and it does not have a reflog.
## 
##  @param out Pointer to the newly created reference
##  @param repo Repository where that reference will live
##  @param name The name of the reference
##  @param id The object id pointed to by the reference.
##  @param force Overwrite existing references
##  @param log_message The one line long message to be appended to the reflog
##  @return 0 on success, GIT_EEXISTS, GIT_EINVALIDSPEC or an error code
## 

proc git_reference_create*(`out`: ptr ptr git_reference; repo: ptr git_repository; 
                          name: cstring; id: ptr git_oid; force: cint;
                          log_message: cstring): cint {.importc.}
## *
##  Conditionally create new direct reference
## 
##  A direct reference (also called an object id reference) refers directly
##  to a specific object id (a.k.a. OID or SHA) in the repository.  The id
##  permanently refers to the object (although the reference itself can be
##  moved).  For example, in libgit2 the direct ref "refs/tags/v0.17.0"
##  refers to OID 5b9fac39d8a76b9139667c26a63e6b3f204b3977.
## 
##  The direct reference will be created in the repository and written to
##  the disk.  The generated reference object must be freed by the user.
## 
##  Valid reference names must follow one of two patterns:
## 
##  1. Top-level names must contain only capital letters and underscores,
##     and must begin and end with a letter. (e.g. "HEAD", "ORIG_HEAD").
##  2. Names prefixed with "refs/" can be almost anything.  You must avoid
##     the characters '~', '^', ':', '\\', '?', '[', and '*', and the
##     sequences ".." and "@{" which have special meaning to revparse.
## 
##  This function will return an error if a reference already exists with the
##  given name unless `force` is true, in which case it will be overwritten.
## 
##  The message for the reflog will be ignored if the reference does
##  not belong in the standard set (HEAD, branches and remote-tracking
##  branches) and and it does not have a reflog.
## 
##  It will return GIT_EMODIFIED if the reference's value at the time
##  of updating does not match the one passed through `current_id`
##  (i.e. if the ref has changed since the user read it).
## 
##  @param out Pointer to the newly created reference
##  @param repo Repository where that reference will live
##  @param name The name of the reference
##  @param id The object id pointed to by the reference.
##  @param force Overwrite existing references
##  @param current_id The expected value of the reference at the time of update
##  @param log_message The one line long message to be appended to the reflog
##  @return 0 on success, GIT_EMODIFIED if the value of the reference
##  has changed, GIT_EEXISTS, GIT_EINVALIDSPEC or an error code
## 

proc git_reference_create_matching*(`out`: ptr ptr git_reference; 
                                   repo: ptr git_repository; name: cstring;
                                   id: ptr git_oid; force: cint;
                                   current_id: ptr git_oid; log_message: cstring): cint {.importc.}
## *
##  Get the OID pointed to by a direct reference.
## 
##  Only available if the reference is direct (i.e. an object id reference,
##  not a symbolic one).
## 
##  To find the OID of a symbolic ref, call `git_reference_resolve()` and
##  then this function (or maybe use `git_reference_name_to_id()` to
##  directly resolve a reference name all the way through to an OID).
## 
##  @param ref The reference
##  @return a pointer to the oid if available, NULL otherwise
## 

proc git_reference_target*(`ref`: ptr git_reference): ptr git_oid  {.importc.}
## *
##  Return the peeled OID target of this reference.
## 
##  This peeled OID only applies to direct references that point to
##  a hard Tag object: it is the result of peeling such Tag.
## 
##  @param ref The reference
##  @return a pointer to the oid if available, NULL otherwise
## 

proc git_reference_target_peel*(`ref`: ptr git_reference): ptr git_oid  {.importc.}
## *
##  Get full name to the reference pointed to by a symbolic reference.
## 
##  Only available if the reference is symbolic.
## 
##  @param ref The reference
##  @return a pointer to the name if available, NULL otherwise
## 

proc git_reference_symbolic_target*(`ref`: ptr git_reference): cstring  {.importc.}
## *
##  Get the type of a reference.
## 
##  Either direct (GIT_REF_OID) or symbolic (GIT_REF_SYMBOLIC)
## 
##  @param ref The reference
##  @return the type
## 

proc git_reference_type*(`ref`: ptr git_reference): git_ref_t  {.importc.}
## *
##  Get the full name of a reference.
## 
##  See `git_reference_symbolic_create()` for rules about valid names.
## 
##  @param ref The reference
##  @return the full name for the ref
## 

proc git_reference_name*(`ref`: ptr git_reference): cstring  {.importc.}
## *
##  Resolve a symbolic reference to a direct reference.
## 
##  This method iteratively peels a symbolic reference until it resolves to
##  a direct reference to an OID.
## 
##  The peeled reference is returned in the `resolved_ref` argument, and
##  must be freed manually once it's no longer needed.
## 
##  If a direct reference is passed as an argument, a copy of that
##  reference is returned. This copy must be manually freed too.
## 
##  @param out Pointer to the peeled reference
##  @param ref The reference
##  @return 0 or an error code
## 

proc git_reference_resolve*(`out`: ptr ptr git_reference; `ref`: ptr git_reference): cint  {.importc.}
## *
##  Get the repository where a reference resides.
## 
##  @param ref The reference
##  @return a pointer to the repo
## 

proc git_reference_owner*(`ref`: ptr git_reference): ptr git_repository  {.importc.}
## *
##  Create a new reference with the same name as the given reference but a
##  different symbolic target. The reference must be a symbolic reference,
##  otherwise this will fail.
## 
##  The new reference will be written to disk, overwriting the given reference.
## 
##  The target name will be checked for validity.
##  See `git_reference_symbolic_create()` for rules about valid names.
## 
##  The message for the reflog will be ignored if the reference does
##  not belong in the standard set (HEAD, branches and remote-tracking
##  branches) and and it does not have a reflog.
## 
##  @param out Pointer to the newly created reference
##  @param ref The reference
##  @param target The new target for the reference
##  @param log_message The one line long message to be appended to the reflog
##  @return 0 on success, GIT_EINVALIDSPEC or an error code
## 

proc git_reference_symbolic_set_target*(`out`: ptr ptr git_reference; 
                                       `ref`: ptr git_reference; target: cstring;
                                       log_message: cstring): cint {.importc.}
## *
##  Conditionally create a new reference with the same name as the given reference but a
##  different OID target. The reference must be a direct reference, otherwise
##  this will fail.
## 
##  The new reference will be written to disk, overwriting the given reference.
## 
##  @param out Pointer to the newly created reference
##  @param ref The reference
##  @param id The new target OID for the reference
##  @param log_message The one line long message to be appended to the reflog
##  @return 0 on success, GIT_EMODIFIED if the value of the reference
##  has changed since it was read, or an error code
## 

proc git_reference_set_target*(`out`: ptr ptr git_reference; 
                              `ref`: ptr git_reference; id: ptr git_oid;
                              log_message: cstring): cint {.importc.}
## *
##  Rename an existing reference.
## 
##  This method works for both direct and symbolic references.
## 
##  The new name will be checked for validity.
##  See `git_reference_symbolic_create()` for rules about valid names.
## 
##  If the `force` flag is not enabled, and there's already
##  a reference with the given name, the renaming will fail.
## 
##  IMPORTANT:
##  The user needs to write a proper reflog entry if the
##  reflog is enabled for the repository. We only rename
##  the reflog if it exists.
## 
##  @param ref The reference to rename
##  @param new_name The new name for the reference
##  @param force Overwrite an existing reference
##  @param log_message The one line long message to be appended to the reflog
##  @return 0 on success, GIT_EINVALIDSPEC, GIT_EEXISTS or an error code
## 
## 

proc git_reference_rename*(new_ref: ptr ptr git_reference; `ref`: ptr git_reference; 
                          new_name: cstring; force: cint; log_message: cstring): cint {.importc.}
## *
##  Delete an existing reference.
## 
##  This method works for both direct and symbolic references.  The reference
##  will be immediately removed on disk but the memory will not be freed.
##  Callers must call `git_reference_free`.
## 
##  This function will return an error if the reference has changed
##  from the time it was looked up.
## 
##  @param ref The reference to remove
##  @return 0, GIT_EMODIFIED or an error code
## 

proc git_reference_delete*(`ref`: ptr git_reference): cint  {.importc.}
## *
##  Delete an existing reference by name
## 
##  This method removes the named reference from the repository without
##  looking at its old value.
## 
##  @param name The reference to remove
##  @return 0 or an error code
## 

proc git_reference_remove*(repo: ptr git_repository; name: cstring): cint  {.importc.}
## *
##  Fill a list with all the references that can be found in a repository.
## 
##  The string array will be filled with the names of all references; these
##  values are owned by the user and should be free'd manually when no
##  longer needed, using `git_strarray_free()`.
## 
##  @param array Pointer to a git_strarray structure where
## 		the reference names will be stored
##  @param repo Repository where to find the refs
##  @return 0 or an error code
## 

proc git_reference_list*(array: ptr git_strarray; repo: ptr git_repository): cint {.importc.}
type
  git_reference_foreach_cb* = proc (reference: ptr git_reference; payload: pointer): cint
  git_reference_foreach_name_cb* = proc (name: cstring; payload: pointer): cint

## *
##  Perform a callback on each reference in the repository.
## 
##  The `callback` function will be called for each reference in the
##  repository, receiving the reference object and the `payload` value
##  passed to this method.  Returning a non-zero value from the callback
##  will terminate the iteration.
## 
##  @param repo Repository where to find the refs
##  @param callback Function which will be called for every listed ref
##  @param payload Additional data to pass to the callback
##  @return 0 on success, non-zero callback return value, or error code
## 

proc git_reference_foreach*(repo: ptr git_repository; 
                           callback: git_reference_foreach_cb; payload: pointer): cint {.importc.}
## *
##  Perform a callback on the fully-qualified name of each reference.
## 
##  The `callback` function will be called for each reference in the
##  repository, receiving the name of the reference and the `payload` value
##  passed to this method.  Returning a non-zero value from the callback
##  will terminate the iteration.
## 
##  @param repo Repository where to find the refs
##  @param callback Function which will be called for every listed ref name
##  @param payload Additional data to pass to the callback
##  @return 0 on success, non-zero callback return value, or error code
## 

proc git_reference_foreach_name*(repo: ptr git_repository; 
                                callback: git_reference_foreach_name_cb;
                                payload: pointer): cint {.importc.}
## *
##  Create a copy of an existing reference.
## 
##  Call `git_reference_free` to free the data.
## 
##  @param dest pointer where to store the copy
##  @param source object to copy
##  @return 0 or an error code
## 

proc git_reference_dup*(dest: ptr ptr git_reference; source: ptr git_reference): cint  {.importc.}
## *
##  Free the given reference.
## 
##  @param ref git_reference
## 

proc git_reference_free*(`ref`: ptr git_reference)  {.importc.}
## *
##  Compare two references.
## 
##  @param ref1 The first git_reference
##  @param ref2 The second git_reference
##  @return 0 if the same, else a stable but meaningless ordering.
## 

proc git_reference_cmp*(ref1: ptr git_reference; ref2: ptr git_reference): cint  {.importc.}
## *
##  Create an iterator for the repo's references
## 
##  @param out pointer in which to store the iterator
##  @param repo the repository
##  @return 0 or an error code
## 

proc git_reference_iterator_new*(`out`: ptr ptr git_reference_iterator; 
                                repo: ptr git_repository): cint {.importc.}
## *
##  Create an iterator for the repo's references that match the
##  specified glob
## 
##  @param out pointer in which to store the iterator
##  @param repo the repository
##  @param glob the glob to match against the reference names
##  @return 0 or an error code
## 

proc git_reference_iterator_glob_new*(`out`: ptr ptr git_reference_iterator; 
                                     repo: ptr git_repository; glob: cstring): cint {.importc.}
## *
##  Get the next reference
## 
##  @param out pointer in which to store the reference
##  @param iter the iterator
##  @return 0, GIT_ITEROVER if there are no more; or an error code
## 

proc git_reference_next*(`out`: ptr ptr git_reference; 
                        iter: ptr git_reference_iterator): cint {.importc.}
## *
##  Get the next reference's name
## 
##  This function is provided for convenience in case only the names
##  are interesting as it avoids the allocation of the `git_reference`
##  object which `git_reference_next()` needs.
## 
##  @param out pointer in which to store the string
##  @param iter the iterator
##  @return 0, GIT_ITEROVER if there are no more; or an error code
## 

proc git_reference_next_name*(`out`: cstringArray; iter: ptr git_reference_iterator): cint  {.importc.}
## *
##  Free the iterator and its associated resources
## 
##  @param iter the iterator to free
## 

proc git_reference_iterator_free*(iter: ptr git_reference_iterator)  {.importc.}
## *
##  Perform a callback on each reference in the repository whose name
##  matches the given pattern.
## 
##  This function acts like `git_reference_foreach()` with an additional
##  pattern match being applied to the reference name before issuing the
##  callback function.  See that function for more information.
## 
##  The pattern is matched using fnmatch or "glob" style where a '*' matches
##  any sequence of letters, a '?' matches any letter, and square brackets
##  can be used to define character ranges (such as "[0-9]" for digits).
## 
##  @param repo Repository where to find the refs
##  @param glob Pattern to match (fnmatch-style) against reference name.
##  @param callback Function which will be called for every listed ref
##  @param payload Additional data to pass to the callback
##  @return 0 on success, GIT_EUSER on non-zero callback, or error code
## 

proc git_reference_foreach_glob*(repo: ptr git_repository; glob: cstring; 
                                callback: git_reference_foreach_name_cb;
                                payload: pointer): cint {.importc.}
## *
##  Check if a reflog exists for the specified reference.
## 
##  @param repo the repository
##  @param refname the reference's name
##  @return 0 when no reflog can be found, 1 when it exists;
##  otherwise an error code.
## 

proc git_reference_has_log*(repo: ptr git_repository; refname: cstring): cint  {.importc.}
## *
##  Ensure there is a reflog for a particular reference.
## 
##  Make sure that successive updates to the reference will append to
##  its log.
## 
##  @param repo the repository
##  @param refname the reference's name
##  @return 0 or an error code.
## 

proc git_reference_ensure_log*(repo: ptr git_repository; refname: cstring): cint  {.importc.}
## *
##  Check if a reference is a local branch.
## 
##  @param ref A git reference
## 
##  @return 1 when the reference lives in the refs/heads
##  namespace; 0 otherwise.
## 

proc git_reference_is_branch*(`ref`: ptr git_reference): cint  {.importc.}
## *
##  Check if a reference is a remote tracking branch
## 
##  @param ref A git reference
## 
##  @return 1 when the reference lives in the refs/remotes
##  namespace; 0 otherwise.
## 

proc git_reference_is_remote*(`ref`: ptr git_reference): cint  {.importc.}
## *
##  Check if a reference is a tag
## 
##  @param ref A git reference
## 
##  @return 1 when the reference lives in the refs/tags
##  namespace; 0 otherwise.
## 

proc git_reference_is_tag*(`ref`: ptr git_reference): cint  {.importc.}
## *
##  Check if a reference is a note
## 
##  @param ref A git reference
## 
##  @return 1 when the reference lives in the refs/notes
##  namespace; 0 otherwise.
## 

proc git_reference_is_note*(`ref`: ptr git_reference): cint  {.importc.}
## *
##  Normalization options for reference lookup
## 

type                          ## *
    ##  No particular normalization.
    ## 
  git_reference_normalize_t* = enum
    GIT_REF_FORMAT_NORMAL = 0, ## *
                            ##  Control whether one-level refnames are accepted
                            ##  (i.e., refnames that do not contain multiple /-separated
                            ##  components). Those are expected to be written only using
                            ##  uppercase letters and underscore (FETCH_HEAD, ...)
                            ## 
    GIT_REF_FORMAT_ALLOW_ONELEVEL = (1 shl 0), ## *
                                          ##  Interpret the provided name as a reference pattern for a
                                          ##  refspec (as used with remote repositories). If this option
                                          ##  is enabled, the name is allowed to contain a single * (<star>)
                                          ##  in place of a one full pathname component
                                          ##  (e.g., foo/<star>/bar but not foo/bar<star>).
                                          ## 
    GIT_REF_FORMAT_REFSPEC_PATTERN = (1 shl 1), ## *
                                           ##  Interpret the name as part of a refspec in shorthand form
                                           ##  so the `ONELEVEL` naming rules aren't enforced and 'master'
                                           ##  becomes a valid name.
                                           ## 
    GIT_REF_FORMAT_REFSPEC_SHORTHAND = (1 shl 2)


## *
##  Normalize reference name and check validity.
## 
##  This will normalize the reference name by removing any leading slash
##  '/' characters and collapsing runs of adjacent slashes between name
##  components into a single slash.
## 
##  Once normalized, if the reference name is valid, it will be returned in
##  the user allocated buffer.
## 
##  See `git_reference_symbolic_create()` for rules about valid names.
## 
##  @param buffer_out User allocated buffer to store normalized name
##  @param buffer_size Size of buffer_out
##  @param name Reference name to be checked.
##  @param flags Flags to constrain name validation rules - see the
##               GIT_REF_FORMAT constants above.
##  @return 0 on success, GIT_EBUFS if buffer is too small, GIT_EINVALIDSPEC
##  or an error code.
## 

proc git_reference_normalize_name*(buffer_out: cstring; buffer_size: csize; 
                                  name: cstring; flags: cuint): cint {.importc.}
## *
##  Recursively peel reference until object of the specified type is found.
## 
##  The retrieved `peeled` object is owned by the repository
##  and should be closed with the `git_object_free` method.
## 
##  If you pass `GIT_OBJ_ANY` as the target type, then the object
##  will be peeled until a non-tag object is met.
## 
##  @param out Pointer to the peeled git_object
##  @param ref The reference to be processed
##  @param type The type of the requested object (GIT_OBJ_COMMIT,
##  GIT_OBJ_TAG, GIT_OBJ_TREE, GIT_OBJ_BLOB or GIT_OBJ_ANY).
##  @return 0 on success, GIT_EAMBIGUOUS, GIT_ENOTFOUND or an error code
## 

proc git_reference_peel*(`out`: ptr ptr git_object; `ref`: ptr git_reference; 
                        `type`: git_otype): cint {.importc.}
## *
##  Ensure the reference name is well-formed.
## 
##  Valid reference names must follow one of two patterns:
## 
##  1. Top-level names must contain only capital letters and underscores,
##     and must begin and end with a letter. (e.g. "HEAD", "ORIG_HEAD").
##  2. Names prefixed with "refs/" can be almost anything.  You must avoid
##     the characters '~', '^', ':', '\\', '?', '[', and '*', and the
##     sequences ".." and "@{" which have special meaning to revparse.
## 
##  @param refname name to be checked.
##  @return 1 if the reference name is acceptable; 0 if it isn't
## 

proc git_reference_is_valid_name*(refname: cstring): cint  {.importc.}
## *
##  Get the reference's short name
## 
##  This will transform the reference name into a name "human-readable"
##  version. If no shortname is appropriate, it will return the full
##  name.
## 
##  The memory is owned by the reference and must not be freed.
## 
##  @param ref a reference
##  @return the human-readable version of the name
## 

proc git_reference_shorthand*(`ref`: ptr git_reference): cstring  {.importc.}
## * @}
