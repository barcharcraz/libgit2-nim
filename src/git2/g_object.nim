## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 

{.push dynlib: "libgit2".}
{.push callconv: cdecl.}
import
  common, types, oid, buffer

## *
##  @file git2/object.h
##  @brief Git revision object management routines
##  @defgroup git_object Git revision object management routines
##  @ingroup Git
##  @{
## 
## *
##  Lookup a reference to one of the objects in a repository.
## 
##  The generated reference is owned by the repository and
##  should be closed with the `git_object_free` method
##  instead of free'd manually.
## 
##  The 'type' parameter must match the type of the object
##  in the odb; the method will fail otherwise.
##  The special value 'GIT_OBJ_ANY' may be passed to let
##  the method guess the object's type.
## 
##  @param object pointer to the looked-up object
##  @param repo the repository to look up the object
##  @param id the unique identifier for the object
##  @param type the type of the object
##  @return 0 or an error code
## 

proc git_object_lookup*(`object`: ptr ptr git_object; repo: ptr git_repository; 
                       id: ptr git_oid; `type`: git_otype): cint {.importc.}
## *
##  Lookup a reference to one of the objects in a repository,
##  given a prefix of its identifier (short id).
## 
##  The object obtained will be so that its identifier
##  matches the first 'len' hexadecimal characters
##  (packets of 4 bits) of the given 'id'.
##  'len' must be at least GIT_OID_MINPREFIXLEN, and
##  long enough to identify a unique object matching
##  the prefix; otherwise the method will fail.
## 
##  The generated reference is owned by the repository and
##  should be closed with the `git_object_free` method
##  instead of free'd manually.
## 
##  The 'type' parameter must match the type of the object
##  in the odb; the method will fail otherwise.
##  The special value 'GIT_OBJ_ANY' may be passed to let
##  the method guess the object's type.
## 
##  @param object_out pointer where to store the looked-up object
##  @param repo the repository to look up the object
##  @param id a short identifier for the object
##  @param len the length of the short identifier
##  @param type the type of the object
##  @return 0 or an error code
## 

proc git_object_lookup_prefix*(object_out: ptr ptr git_object; 
                              repo: ptr git_repository; id: ptr git_oid; len: csize;
                              `type`: git_otype): cint {.importc.}
## *
##  Lookup an object that represents a tree entry.
## 
##  @param out buffer that receives a pointer to the object (which must be freed
##             by the caller)
##  @param treeish root object that can be peeled to a tree
##  @param path relative path from the root object to the desired object
##  @param type type of object desired
##  @return 0 on success, or an error code
## 

proc git_object_lookup_bypath*(`out`: ptr ptr git_object; treeish: ptr git_object; 
                              path: cstring; `type`: git_otype): cint {.importc.}
## *
##  Get the id (SHA1) of a repository object
## 
##  @param obj the repository object
##  @return the SHA1 id
## 

proc git_object_id*(obj: ptr git_object): ptr git_oid  {.importc.}
## *
##  Get a short abbreviated OID string for the object
## 
##  This starts at the "core.abbrev" length (default 7 characters) and
##  iteratively extends to a longer string if that length is ambiguous.
##  The result will be unambiguous (at least until new objects are added to
##  the repository).
## 
##  @param out Buffer to write string into
##  @param obj The object to get an ID for
##  @return 0 on success, <0 for error
## 

proc git_object_short_id*(`out`: ptr git_buf; obj: ptr git_object): cint  {.importc.}
## *
##  Get the object type of an object
## 
##  @param obj the repository object
##  @return the object's type
## 

proc git_object_type*(obj: ptr git_object): git_otype  {.importc.}
## *
##  Get the repository that owns this object
## 
##  Freeing or calling `git_repository_close` on the
##  returned pointer will invalidate the actual object.
## 
##  Any other operation may be run on the repository without
##  affecting the object.
## 
##  @param obj the object
##  @return the repository who owns this object
## 

proc git_object_owner*(obj: ptr git_object): ptr git_repository  {.importc.}
## *
##  Close an open object
## 
##  This method instructs the library to close an existing
##  object; note that git_objects are owned and cached by the repository
##  so the object may or may not be freed after this library call,
##  depending on how aggressive is the caching mechanism used
##  by the repository.
## 
##  IMPORTANT:
##  It *is* necessary to call this method when you stop using
##  an object. Failure to do so will cause a memory leak.
## 
##  @param object the object to close
## 

proc git_object_free*(`object`: ptr git_object)  {.importc.}
## *
##  Convert an object type to its string representation.
## 
##  The result is a pointer to a string in static memory and
##  should not be free()'ed.
## 
##  @param type object type to convert.
##  @return the corresponding string representation.
## 

proc git_object_type2string*(`type`: git_otype): cstring  {.importc.}
## *
##  Convert a string object type representation to it's git_otype.
## 
##  @param str the string to convert.
##  @return the corresponding git_otype.
## 

proc git_object_string2type*(str: cstring): git_otype  {.importc.}
## *
##  Determine if the given git_otype is a valid loose object type.
## 
##  @param type object type to test.
##  @return true if the type represents a valid loose object type,
##  false otherwise.
## 

proc git_object_typeisloose*(`type`: git_otype): cint  {.importc.}
## *
##  Get the size in bytes for the structure which
##  acts as an in-memory representation of any given
##  object type.
## 
##  For all the core types, this would the equivalent
##  of calling `sizeof(git_commit)` if the core types
##  were not opaque on the external API.
## 
##  @param type object type to get its size
##  @return size in bytes of the object
## 

proc git_object_size*(`type`: git_otype): csize  {.importc.}
## *
##  Recursively peel an object until an object of the specified type is met.
## 
##  If the query cannot be satisfied due to the object model,
##  GIT_EINVALIDSPEC will be returned (e.g. trying to peel a blob to a
##  tree).
## 
##  If you pass `GIT_OBJ_ANY` as the target type, then the object will
##  be peeled until the type changes. A tag will be peeled until the
##  referenced object is no longer a tag, and a commit will be peeled
##  to a tree. Any other object type will return GIT_EINVALIDSPEC.
## 
##  If peeling a tag we discover an object which cannot be peeled to
##  the target type due to the object model, GIT_EPEEL will be
##  returned.
## 
##  You must free the returned object.
## 
##  @param peeled Pointer to the peeled git_object
##  @param object The object to be processed
##  @param target_type The type of the requested object (a GIT_OBJ_ value)
##  @return 0 on success, GIT_EINVALIDSPEC, GIT_EPEEL, or an error code
## 

proc git_object_peel*(peeled: ptr ptr git_object; `object`: ptr git_object; 
                     target_type: git_otype): cint {.importc.}
## *
##  Create an in-memory copy of a Git object. The copy must be
##  explicitly free'd or it will leak.
## 
##  @param dest Pointer to store the copy of the object
##  @param source Original object to copy
## 

proc git_object_dup*(dest: ptr ptr git_object; source: ptr git_object): cint  {.importc.}
## * @}
