## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 
{.push importc.}
{.push dynlib: "libgit2".}
import
  common, types, oid, g_object, buffer

## *
##  @file git2/blob.h
##  @brief Git blob load and write routines
##  @defgroup git_blob Git blob load and write routines
##  @ingroup Git
##  @{
## 
## *
##  Lookup a blob object from a repository.
## 
##  @param blob pointer to the looked up blob
##  @param repo the repo to use when locating the blob.
##  @param id identity of the blob to locate.
##  @return 0 or an error code
## 

proc git_blob_lookup*(blob: ptr ptr git_blob; repo: ptr git_repository; id: ptr git_oid): cint
## *
##  Lookup a blob object from a repository,
##  given a prefix of its identifier (short id).
## 
##  @see git_object_lookup_prefix
## 
##  @param blob pointer to the looked up blob
##  @param repo the repo to use when locating the blob.
##  @param id identity of the blob to locate.
##  @param len the length of the short identifier
##  @return 0 or an error code
## 

proc git_blob_lookup_prefix*(blob: ptr ptr git_blob; repo: ptr git_repository;
                            id: ptr git_oid; len: csize): cint
## *
##  Close an open blob
## 
##  This is a wrapper around git_object_free()
## 
##  IMPORTANT:
##  It *is* necessary to call this method when you stop
##  using a blob. Failure to do so will cause a memory leak.
## 
##  @param blob the blob to close
## 

proc git_blob_free*(blob: ptr git_blob)
## *
##  Get the id of a blob.
## 
##  @param blob a previously loaded blob.
##  @return SHA1 hash for this blob.
## 

proc git_blob_id*(blob: ptr git_blob): ptr git_oid
## *
##  Get the repository that contains the blob.
## 
##  @param blob A previously loaded blob.
##  @return Repository that contains this blob.
## 

proc git_blob_owner*(blob: ptr git_blob): ptr git_repository
## *
##  Get a read-only buffer with the raw content of a blob.
## 
##  A pointer to the raw content of a blob is returned;
##  this pointer is owned internally by the object and shall
##  not be free'd. The pointer may be invalidated at a later
##  time.
## 
##  @param blob pointer to the blob
##  @return the pointer
## 

proc git_blob_rawcontent*(blob: ptr git_blob): pointer
## *
##  Get the size in bytes of the contents of a blob
## 
##  @param blob pointer to the blob
##  @return size on bytes
## 

proc git_blob_rawsize*(blob: ptr git_blob): git_off_t
## *
##  Get a buffer with the filtered content of a blob.
## 
##  This applies filters as if the blob was being checked out to the
##  working directory under the specified filename.  This may apply
##  CRLF filtering or other types of changes depending on the file
##  attributes set for the blob and the content detected in it.
## 
##  The output is written into a `git_buf` which the caller must free
##  when done (via `git_buf_free`).
## 
##  If no filters need to be applied, then the `out` buffer will just
##  be populated with a pointer to the raw content of the blob.  In
##  that case, be careful to *not* free the blob until done with the
##  buffer or copy it into memory you own.
## 
##  @param out The git_buf to be filled in
##  @param blob Pointer to the blob
##  @param as_path Path used for file attribute lookups, etc.
##  @param check_for_binary_data Should this test if blob content contains
##         NUL bytes / looks like binary data before applying filters?
##  @return 0 on success or an error code
## 

proc git_blob_filtered_content*(`out`: ptr git_buf; blob: ptr git_blob;
                               as_path: cstring; check_for_binary_data: cint): cint
## *
##  Read a file from the working folder of a repository
##  and write it to the Object Database as a loose blob
## 
##  @param id return the id of the written blob
##  @param repo repository where the blob will be written.
## 	this repository cannot be bare
##  @param relative_path file from which the blob will be created,
## 	relative to the repository's working dir
##  @return 0 or an error code
## 

proc git_blob_create_fromworkdir*(id: ptr git_oid; repo: ptr git_repository;
                                 relative_path: cstring): cint
## *
##  Read a file from the filesystem and write its content
##  to the Object Database as a loose blob
## 
##  @param id return the id of the written blob
##  @param repo repository where the blob will be written.
## 	this repository can be bare or not
##  @param path file from which the blob will be created
##  @return 0 or an error code
## 

proc git_blob_create_fromdisk*(id: ptr git_oid; repo: ptr git_repository; path: cstring): cint
## *
##  Create a stream to write a new blob into the object db
## 
##  This function may need to buffer the data on disk and will in
##  general not be the right choice if you know the size of the data
##  to write. If you have data in memory, use
##  `git_blob_create_frombuffer()`. If you do not, but know the size of
##  the contents (and don't want/need to perform filtering), use
##  `git_odb_open_wstream()`.
## 
##  Don't close this stream yourself but pass it to
##  `git_blob_create_fromstream_commit()` to commit the write to the
##  object db and get the object id.
## 
##  If the `hintpath` parameter is filled, it will be used to determine
##  what git filters should be applied to the object before it is written
##  to the object database.
## 
##  @param out the stream into which to write
##  @param repo Repository where the blob will be written.
##         This repository can be bare or not.
##  @param hintpath If not NULL, will be used to select data filters
##         to apply onto the content of the blob to be created.
##  @return 0 or error code
## 

proc git_blob_create_fromstream*(`out`: ptr ptr git_writestream;
                                repo: ptr git_repository; hintpath: cstring): cint
## *
##  Close the stream and write the blob to the object db
## 
##  The stream will be closed and freed.
## 
##  @param out the id of the new blob
##  @param stream the stream to close
##  @return 0 or an error code
## 

proc git_blob_create_fromstream_commit*(`out`: ptr git_oid;
                                       stream: ptr git_writestream): cint
## *
##  Write an in-memory buffer to the ODB as a blob
## 
##  @param id return the id of the written blob
##  @param repo repository where to blob will be written
##  @param buffer data to be written into the blob
##  @param len length of the data
##  @return 0 or an error code
## 

proc git_blob_create_frombuffer*(id: ptr git_oid; repo: ptr git_repository;
                                buffer: pointer; len: csize): cint
## *
##  Determine if the blob content is most certainly binary or not.
## 
##  The heuristic used to guess if a file is binary is taken from core git:
##  Searching for NUL bytes and looking for a reasonable ratio of printable
##  to non-printable characters among the first 8000 bytes.
## 
##  @param blob The blob which content should be analyzed
##  @return 1 if the content of the blob is detected
##  as binary; 0 otherwise.
## 

proc git_blob_is_binary*(blob: ptr git_blob): cint
## *
##  Create an in-memory copy of a blob. The copy must be explicitly
##  free'd or it will leak.
## 
##  @param out Pointer to store the copy of the object
##  @param source Original object to copy
## 

proc git_blob_dup*(`out`: ptr ptr git_blob; source: ptr git_blob): cint
## * @}
