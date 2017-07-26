## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 
{.push importc.}
{.push dynlib: "libgit2".}
import
  common, types, oid, `object`

## *
##  @file git2/tree.h
##  @brief Git tree parsing, loading routines
##  @defgroup git_tree Git tree parsing, loading routines
##  @ingroup Git
##  @{
## 
## *
##  Lookup a tree object from the repository.
## 
##  @param out Pointer to the looked up tree
##  @param repo The repo to use when locating the tree.
##  @param id Identity of the tree to locate.
##  @return 0 or an error code
## 

proc git_tree_lookup*(`out`: ptr ptr git_tree; repo: ptr git_repository; id: ptr git_oid): cint
## *
##  Lookup a tree object from the repository,
##  given a prefix of its identifier (short id).
## 
##  @see git_object_lookup_prefix
## 
##  @param out pointer to the looked up tree
##  @param repo the repo to use when locating the tree.
##  @param id identity of the tree to locate.
##  @param len the length of the short identifier
##  @return 0 or an error code
## 

proc git_tree_lookup_prefix*(`out`: ptr ptr git_tree; repo: ptr git_repository;
                            id: ptr git_oid; len: csize): cint
## *
##  Close an open tree
## 
##  You can no longer use the git_tree pointer after this call.
## 
##  IMPORTANT: You MUST call this method when you stop using a tree to
##  release memory. Failure to do so will cause a memory leak.
## 
##  @param tree The tree to close
## 

proc git_tree_free*(tree: ptr git_tree)
## *
##  Get the id of a tree.
## 
##  @param tree a previously loaded tree.
##  @return object identity for the tree.
## 

proc git_tree_id*(tree: ptr git_tree): ptr git_oid
## *
##  Get the repository that contains the tree.
## 
##  @param tree A previously loaded tree.
##  @return Repository that contains this tree.
## 

proc git_tree_owner*(tree: ptr git_tree): ptr git_repository
## *
##  Get the number of entries listed in a tree
## 
##  @param tree a previously loaded tree.
##  @return the number of entries in the tree
## 

proc git_tree_entrycount*(tree: ptr git_tree): csize
## *
##  Lookup a tree entry by its filename
## 
##  This returns a git_tree_entry that is owned by the git_tree.  You don't
##  have to free it, but you must not use it after the git_tree is released.
## 
##  @param tree a previously loaded tree.
##  @param filename the filename of the desired entry
##  @return the tree entry; NULL if not found
## 

proc git_tree_entry_byname*(tree: ptr git_tree; filename: cstring): ptr git_tree_entry
## *
##  Lookup a tree entry by its position in the tree
## 
##  This returns a git_tree_entry that is owned by the git_tree.  You don't
##  have to free it, but you must not use it after the git_tree is released.
## 
##  @param tree a previously loaded tree.
##  @param idx the position in the entry list
##  @return the tree entry; NULL if not found
## 

proc git_tree_entry_byindex*(tree: ptr git_tree; idx: csize): ptr git_tree_entry
## *
##  Lookup a tree entry by SHA value.
## 
##  This returns a git_tree_entry that is owned by the git_tree.  You don't
##  have to free it, but you must not use it after the git_tree is released.
## 
##  Warning: this must examine every entry in the tree, so it is not fast.
## 
##  @param tree a previously loaded tree.
##  @param id the sha being looked for
##  @return the tree entry; NULL if not found
## 

proc git_tree_entry_byid*(tree: ptr git_tree; id: ptr git_oid): ptr git_tree_entry
## *
##  Retrieve a tree entry contained in a tree or in any of its subtrees,
##  given its relative path.
## 
##  Unlike the other lookup functions, the returned tree entry is owned by
##  the user and must be freed explicitly with `git_tree_entry_free()`.
## 
##  @param out Pointer where to store the tree entry
##  @param root Previously loaded tree which is the root of the relative path
##  @param path Path to the contained entry
##  @return 0 on success; GIT_ENOTFOUND if the path does not exist
## 

proc git_tree_entry_bypath*(`out`: ptr ptr git_tree_entry; root: ptr git_tree;
                           path: cstring): cint
## *
##  Duplicate a tree entry
## 
##  Create a copy of a tree entry. The returned copy is owned by the user,
##  and must be freed explicitly with `git_tree_entry_free()`.
## 
##  @param dest pointer where to store the copy
##  @param source tree entry to duplicate
##  @return 0 or an error code
## 

proc git_tree_entry_dup*(dest: ptr ptr git_tree_entry; source: ptr git_tree_entry): cint
## *
##  Free a user-owned tree entry
## 
##  IMPORTANT: This function is only needed for tree entries owned by the
##  user, such as the ones returned by `git_tree_entry_dup()` or
##  `git_tree_entry_bypath()`.
## 
##  @param entry The entry to free
## 

proc git_tree_entry_free*(entry: ptr git_tree_entry)
## *
##  Get the filename of a tree entry
## 
##  @param entry a tree entry
##  @return the name of the file
## 

proc git_tree_entry_name*(entry: ptr git_tree_entry): cstring
## *
##  Get the id of the object pointed by the entry
## 
##  @param entry a tree entry
##  @return the oid of the object
## 

proc git_tree_entry_id*(entry: ptr git_tree_entry): ptr git_oid
## *
##  Get the type of the object pointed by the entry
## 
##  @param entry a tree entry
##  @return the type of the pointed object
## 

proc git_tree_entry_type*(entry: ptr git_tree_entry): git_otype
## *
##  Get the UNIX file attributes of a tree entry
## 
##  @param entry a tree entry
##  @return filemode as an integer
## 

proc git_tree_entry_filemode*(entry: ptr git_tree_entry): git_filemode_t
## *
##  Get the raw UNIX file attributes of a tree entry
## 
##  This function does not perform any normalization and is only useful
##  if you need to be able to recreate the original tree object.
## 
##  @param entry a tree entry
##  @return filemode as an integer
## 

proc git_tree_entry_filemode_raw*(entry: ptr git_tree_entry): git_filemode_t
## *
##  Compare two tree entries
## 
##  @param e1 first tree entry
##  @param e2 second tree entry
##  @return <0 if e1 is before e2, 0 if e1 == e2, >0 if e1 is after e2
## 

proc git_tree_entry_cmp*(e1: ptr git_tree_entry; e2: ptr git_tree_entry): cint
## *
##  Convert a tree entry to the git_object it points to.
## 
##  You must call `git_object_free()` on the object when you are done with it.
## 
##  @param object_out pointer to the converted object
##  @param repo repository where to lookup the pointed object
##  @param entry a tree entry
##  @return 0 or an error code
## 

proc git_tree_entry_to_object*(object_out: ptr ptr git_object;
                              repo: ptr git_repository; entry: ptr git_tree_entry): cint
## *
##  Create a new tree builder.
## 
##  The tree builder can be used to create or modify trees in memory and
##  write them as tree objects to the database.
## 
##  If the `source` parameter is not NULL, the tree builder will be
##  initialized with the entries of the given tree.
## 
##  If the `source` parameter is NULL, the tree builder will start with no
##  entries and will have to be filled manually.
## 
##  @param out Pointer where to store the tree builder
##  @param repo Repository in which to store the object
##  @param source Source tree to initialize the builder (optional)
##  @return 0 on success; error code otherwise
## 

proc git_treebuilder_new*(`out`: ptr ptr git_treebuilder; repo: ptr git_repository;
                         source: ptr git_tree): cint
## *
##  Clear all the entires in the builder
## 
##  @param bld Builder to clear
## 

proc git_treebuilder_clear*(bld: ptr git_treebuilder)
## *
##  Get the number of entries listed in a treebuilder
## 
##  @param bld a previously loaded treebuilder.
##  @return the number of entries in the treebuilder
## 

proc git_treebuilder_entrycount*(bld: ptr git_treebuilder): cuint
## *
##  Free a tree builder
## 
##  This will clear all the entries and free to builder.
##  Failing to free the builder after you're done using it
##  will result in a memory leak
## 
##  @param bld Builder to free
## 

proc git_treebuilder_free*(bld: ptr git_treebuilder)
## *
##  Get an entry from the builder from its filename
## 
##  The returned entry is owned by the builder and should
##  not be freed manually.
## 
##  @param bld Tree builder
##  @param filename Name of the entry
##  @return pointer to the entry; NULL if not found
## 

proc git_treebuilder_get*(bld: ptr git_treebuilder; filename: cstring): ptr git_tree_entry
## *
##  Add or update an entry to the builder
## 
##  Insert a new entry for `filename` in the builder with the
##  given attributes.
## 
##  If an entry named `filename` already exists, its attributes
##  will be updated with the given ones.
## 
##  The optional pointer `out` can be used to retrieve a pointer to the
##  newly created/updated entry.  Pass NULL if you do not need it. The
##  pointer may not be valid past the next operation in this
##  builder. Duplicate the entry if you want to keep it.
## 
##  No attempt is being made to ensure that the provided oid points
##  to an existing git object in the object database, nor that the
##  attributes make sense regarding the type of the pointed at object.
## 
##  @param out Pointer to store the entry (optional)
##  @param bld Tree builder
##  @param filename Filename of the entry
##  @param id SHA1 oid of the entry
##  @param filemode Folder attributes of the entry. This parameter must
## 			be valued with one of the following entries: 0040000, 0100644,
## 			0100755, 0120000 or 0160000.
##  @return 0 or an error code
## 

proc git_treebuilder_insert*(`out`: ptr ptr git_tree_entry; bld: ptr git_treebuilder;
                            filename: cstring; id: ptr git_oid;
                            filemode: git_filemode_t): cint
## *
##  Remove an entry from the builder by its filename
## 
##  @param bld Tree builder
##  @param filename Filename of the entry to remove
## 

proc git_treebuilder_remove*(bld: ptr git_treebuilder; filename: cstring): cint
## *
##  Callback for git_treebuilder_filter
## 
##  The return value is treated as a boolean, with zero indicating that the
##  entry should be left alone and any non-zero value meaning that the
##  entry should be removed from the treebuilder list (i.e. filtered out).
## 

type
  git_treebuilder_filter_cb* = proc (entry: ptr git_tree_entry; payload: pointer): cint

## *
##  Selectively remove entries in the tree
## 
##  The `filter` callback will be called for each entry in the tree with a
##  pointer to the entry and the provided `payload`; if the callback returns
##  non-zero, the entry will be filtered (removed from the builder).
## 
##  @param bld Tree builder
##  @param filter Callback to filter entries
##  @param payload Extra data to pass to filter callback
## 

proc git_treebuilder_filter*(bld: ptr git_treebuilder;
                            filter: git_treebuilder_filter_cb; payload: pointer)
## *
##  Write the contents of the tree builder as a tree object
## 
##  The tree builder will be written to the given `repo`, and its
##  identifying SHA1 hash will be stored in the `id` pointer.
## 
##  @param id Pointer to store the OID of the newly written tree
##  @param bld Tree builder to write
##  @return 0 or an error code
## 

proc git_treebuilder_write*(id: ptr git_oid; bld: ptr git_treebuilder): cint
## *
##  Write the contents of the tree builder as a tree object
##  using a shared git_buf.
## 
##  @see git_treebuilder_write
## 
##  @param oid Pointer to store the OID of the newly written tree
##  @param bld Tree builder to write
##  @param tree Shared buffer for writing the tree. Will be grown as necessary.
##  @return 0 or an error code
## 

proc git_treebuilder_write_with_buffer*(oid: ptr git_oid; bld: ptr git_treebuilder;
                                       tree: ptr git_buf): cint
## * Callback for the tree traversal method

type
  git_treewalk_cb* = proc (root: cstring; entry: ptr git_tree_entry; payload: pointer): cint

## * Tree traversal modes

type
  git_treewalk_mode* = enum
    GIT_TREEWALK_PRE = 0,       ##  Pre-order
    GIT_TREEWALK_POST = 1       ##  Post-order


## *
##  Traverse the entries in a tree and its subtrees in post or pre order.
## 
##  The entries will be traversed in the specified order, children subtrees
##  will be automatically loaded as required, and the `callback` will be
##  called once per entry with the current (relative) root for the entry and
##  the entry data itself.
## 
##  If the callback returns a positive value, the passed entry will be
##  skipped on the traversal (in pre mode). A negative value stops the walk.
## 
##  @param tree The tree to walk
##  @param mode Traversal mode (pre or post-order)
##  @param callback Function to call on each tree entry
##  @param payload Opaque pointer to be passed on each callback
##  @return 0 or an error code
## 

proc git_tree_walk*(tree: ptr git_tree; mode: git_treewalk_mode;
                   callback: git_treewalk_cb; payload: pointer): cint
## *
##  Create an in-memory copy of a tree. The copy must be explicitly
##  free'd or it will leak.
## 
##  @param out Pointer to store the copy of the tree
##  @param source Original tree to copy
## 

proc git_tree_dup*(`out`: ptr ptr git_tree; source: ptr git_tree): cint
## *
##  The kind of update to perform
## 

type                          ## * Update or insert an entry at the specified path
  git_tree_update_t* = enum
    GIT_TREE_UPDATE_UPSERT,   ## * Remove an entry from the specified path
    GIT_TREE_UPDATE_REMOVE


## *
##  An action to perform during the update of a tree
## 

type
  git_tree_update* {.bycopy.} = object
    action*: git_tree_update_t ## * Update action. If it's an removal, only the path is looked at
    ## * The entry's id
    id*: git_oid               ## * The filemode/kind of object
    filemode*: git_filemode_t  ## * The full path from the root tree
    path*: cstring


## *
##  Create a tree based on another one with the specified modifications
## 
##  Given the `baseline` perform the changes described in the list of
##  `updates` and create a new tree.
## 
##  This function is optimized for common file/directory addition, removal and
##  replacement in trees. It is much more efficient than reading the tree into a
##  `git_index` and modifying that, but in exchange it is not as flexible.
## 
##  Deleting and adding the same entry is undefined behaviour, changing
##  a tree to a blob or viceversa is not supported.
## 
##  @param out id of the new tree
##  @param repo the repository in which to create the tree, must be the
##  same as for `baseline`
##  @param baseline the tree to base these changes on
##  @param nupdates the number of elements in the update list
##  @param updates the list of updates to perform
## 

proc git_tree_create_updated*(`out`: ptr git_oid; repo: ptr git_repository;
                             baseline: ptr git_tree; nupdates: csize;
                             updates: ptr git_tree_update): cint
## * @}
