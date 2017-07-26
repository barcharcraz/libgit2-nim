## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 

import
  git2/net, git2/types, git2/strarray, git2/proxy

## *
##  @file git2/sys/transport.h
##  @brief Git custom transport registration interfaces and functions
##  @defgroup git_transport Git custom transport registration
##  @ingroup Git
##  @{
## 
## *
##  Flags to pass to transport
## 
##  Currently unused.
## 

type
  git_transport_flags_t* = enum
    GIT_TRANSPORTFLAGS_NONE = 0


type
  git_transport* {.bycopy.} = object
    version*: cuint            ##  Set progress and error callbacks
    set_callbacks*: proc (transport: ptr git_transport; 
                        progress_cb: git_transport_message_cb;
                        error_cb: git_transport_message_cb; certificate_check_cb: git_transport_certificate_check_cb;
                        payload: pointer): cint ##  Set custom headers for HTTP requests
    set_custom_headers*: proc (transport: ptr git_transport; 
                             custom_headers: ptr git_strarray): cint ##  Connect the transport to the remote repository, using the given {.importc.}
                                                                 ##  direction.
    connect*: proc (transport: ptr git_transport; url: cstring; 
                  cred_acquire_cb: git_cred_acquire_cb;
                  cred_acquire_payload: pointer;
                  proxy_opts: ptr git_proxy_options; direction: cint; flags: cint): cint ##  This function may be called after a successful call to
                                                                                 ##  connect(). The array returned is owned by the transport and
                                                                                 ##  is guaranteed until the next call of a transport function.
    ls*: proc (`out`: ptr ptr ptr git_remote_head; size: ptr csize; 
             transport: ptr git_transport): cint ##  Executes the push whose context is in the git_push object. {.importc.}
    push*: proc (transport: ptr git_transport; push: ptr git_push; 
               callbacks: ptr git_remote_callbacks): cint ##  This function may be called after a successful call to connect(), when {.importc.}
                                                      ##  the direction is FETCH. The function performs a negotiation to calculate
                                                      ##  the wants list for the fetch.
    negotiate_fetch*: proc (transport: ptr git_transport; repo: ptr git_repository; 
                          refs: ptr ptr git_remote_head; count: csize): cint ##  This function may be called after a successful call to negotiate_fetch(), {.importc.}
                                                                      ##  when the direction is FETCH. This function retrieves the pack file for
                                                                      ##  the fetch from the remote end.
    download_pack*: proc (transport: ptr git_transport; repo: ptr git_repository; 
                        stats: ptr git_transfer_progress;
                        progress_cb: git_transfer_progress_cb;
                        progress_payload: pointer): cint ##  Checks to see if the transport is connected
    is_connected*: proc (transport: ptr git_transport): cint ##  Reads the flags value previously passed into connect() 
    read_flags*: proc (transport: ptr git_transport; flags: ptr cint): cint ##  Cancels any outstanding transport operation  {.importc.}
    cancel*: proc (transport: ptr git_transport) ##  This function is the reverse of connect() -- it terminates the 
                                            ##  connection to the remote end.
    close*: proc (transport: ptr git_transport): cint ##  Frees/destructs the git_transport object.  {.importc.}
    free*: proc (transport: ptr git_transport) 


const
  GIT_TRANSPORT_VERSION* = 1

## *
##  Initializes a `git_transport` with default values. Equivalent to
##  creating an instance with GIT_TRANSPORT_INIT.
## 
##  @param opts the `git_transport` struct to initialize
##  @param version Version of struct; pass `GIT_TRANSPORT_VERSION`
##  @return Zero on success; -1 on failure.
## 

proc git_transport_init*(opts: ptr git_transport; version: cuint): cint  {.importc.}
## *
##  Function to use to create a transport from a URL. The transport database
##  is scanned to find a transport that implements the scheme of the URI (i.e.
##  git:// or http://) and a transport object is returned to the caller.
## 
##  @param out The newly created transport (out)
##  @param owner The git_remote which will own this transport
##  @param url The URL to connect to
##  @return 0 or an error code
## 

proc git_transport_new*(`out`: ptr ptr git_transport; owner: ptr git_remote; 
                       url: cstring): cint {.importc.}
## *
##  Create an ssh transport with custom git command paths
## 
##  This is a factory function suitable for setting as the transport
##  callback in a remote (or for a clone in the options).
## 
##  The payload argument must be a strarray pointer with the paths for
##  the `git-upload-pack` and `git-receive-pack` at index 0 and 1.
## 
##  @param out the resulting transport
##  @param owner the owning remote
##  @param payload a strarray with the paths
##  @return 0 or an error code
## 

proc git_transport_ssh_with_paths*(`out`: ptr ptr git_transport; 
                                  owner: ptr git_remote; payload: pointer): cint {.importc.}
## *
##  Add a custom transport definition, to be used in addition to the built-in
##  set of transports that come with libgit2.
## 
##  The caller is responsible for synchronizing calls to git_transport_register
##  and git_transport_unregister with other calls to the library that
##  instantiate transports.
## 
##  @param prefix The scheme (ending in "://") to match, i.e. "git://"
##  @param cb The callback used to create an instance of the transport
##  @param param A fixed parameter to pass to cb at creation time
##  @return 0 or an error code
## 

proc git_transport_register*(prefix: cstring; cb: git_transport_cb; param: pointer): cint  {.importc.}
## *
## 
##  Unregister a custom transport definition which was previously registered
##  with git_transport_register.
## 
##  @param prefix From the previous call to git_transport_register
##  @return 0 or an error code
## 

proc git_transport_unregister*(prefix: cstring): cint  {.importc.}
##  Transports which come with libgit2 (match git_transport_cb). The expected
##  value for "param" is listed in-line below.
## *
##  Create an instance of the dummy transport.
## 
##  @param out The newly created transport (out)
##  @param owner The git_remote which will own this transport
##  @param payload You must pass NULL for this parameter.
##  @return 0 or an error code
## 

proc git_transport_dummy*(`out`: ptr ptr git_transport; owner: ptr git_remote; 
                         payload: pointer): cint {.importc.}
  ##  NULL
## *
##  Create an instance of the local transport.
## 
##  @param out The newly created transport (out)
##  @param owner The git_remote which will own this transport
##  @param payload You must pass NULL for this parameter.
##  @return 0 or an error code
## 

proc git_transport_local*(`out`: ptr ptr git_transport; owner: ptr git_remote; 
                         payload: pointer): cint {.importc.}
  ##  NULL
## *
##  Create an instance of the smart transport.
## 
##  @param out The newly created transport (out)
##  @param owner The git_remote which will own this transport
##  @param payload A pointer to a git_smart_subtransport_definition
##  @return 0 or an error code
## 

proc git_transport_smart*(`out`: ptr ptr git_transport; owner: ptr git_remote; 
                         payload: pointer): cint {.importc.}
  ##  (git_smart_subtransport_definition *)
## *
##  Call the certificate check for this transport.
## 
##  @param transport a smart transport
##  @param cert the certificate to pass to the caller
##  @param valid whether we believe the certificate is valid
##  @param hostname the hostname we connected to
##  @return the return value of the callback
## 

proc git_transport_smart_certificate_check*(transport: ptr git_transport; 
    cert: ptr git_cert; valid: cint; hostname: cstring): cint {.importc.}
## *
##  Call the credentials callback for this transport
## 
##  @param out the pointer where the creds are to be stored
##  @param transport a smart transport
##  @param user the user we saw on the url (if any)
##  @param methods available methods for authentication
##  @return the return value of the callback
## 

proc git_transport_smart_credentials*(`out`: ptr ptr git_cred; 
                                     transport: ptr git_transport; user: cstring;
                                     methods: cint): cint {.importc.}
## *
##  Get a copy of the proxy options
## 
##  The url is copied and must be freed by the caller.
## 
##  @param out options struct to fill
##  @param transport the transport to extract the data from.
## 

proc git_transport_smart_proxy_options*(`out`: ptr git_proxy_options; 
                                       transport: ptr git_transport): cint {.importc.}
## 
## ** End of base transport interface ***
## ** Begin interface for subtransports for the smart transport ***
## 
##  The smart transport knows how to speak the git protocol, but it has no
##  knowledge of how to establish a connection between it and another endpoint,
##  or how to move data back and forth. For this, a subtransport interface is
##  declared, and the smart transport delegates this work to the subtransports.
##  Three subtransports are implemented: git, http, and winhttp. (The http and
##  winhttp transports each implement both http and https.)
##  Subtransports can either be RPC = 0 (persistent connection) or RPC = 1
##  (request/response). The smart transport handles the differences in its own
##  logic. The git subtransport is RPC = 0, while http and winhttp are both
##  RPC = 1.
##  Actions that the smart transport can ask
##  a subtransport to perform

type
  git_smart_service_t* = enum
    GIT_SERVICE_UPLOADPACK_LS = 1, GIT_SERVICE_UPLOADPACK = 2,
    GIT_SERVICE_RECEIVEPACK_LS = 3, GIT_SERVICE_RECEIVEPACK = 4


##  A stream used by the smart transport to read and write data
##  from a subtransport

type
  git_smart_subtransport_stream* {.bycopy.} = object
    subtransport*: ptr git_smart_subtransport ##  The owning subtransport
    read*: proc (stream: ptr git_smart_subtransport_stream; buffer: cstring; 
               buf_size: csize; bytes_read: ptr csize): cint {.importc.}
    write*: proc (stream: ptr git_smart_subtransport_stream; buffer: cstring; 
                len: csize): cint {.importc.}
    free*: proc (stream: ptr git_smart_subtransport_stream) 


##  An implementation of a subtransport which carries data for the
##  smart transport

type
  git_smart_subtransport* {.bycopy.} = object
    action*: proc (`out`: ptr ptr git_smart_subtransport_stream; 
                 transport: ptr git_smart_subtransport; url: cstring;
                 action: git_smart_service_t): cint ##  Subtransports are guaranteed a call to close() between {.importc.}
                                                 ##  calls to action(), except for the following two "natural" progressions
                                                 ##  of actions against a constant URL.
                                                 ## 
                                                 ##  1. UPLOADPACK_LS -> UPLOADPACK
                                                 ##  2. RECEIVEPACK_LS -> RECEIVEPACK
    close*: proc (transport: ptr git_smart_subtransport): cint  {.importc.}
    free*: proc (transport: ptr git_smart_subtransport) 


##  A function which creates a new subtransport for the smart transport

type
  git_smart_subtransport_cb* = proc (`out`: ptr ptr git_smart_subtransport; 
                                  owner: ptr git_transport; param: pointer): cint {.importc.}

## *
##  Definition for a "subtransport"
## 
##  This is used to let the smart protocol code know about the protocol
##  which you are implementing.
## 

type
  git_smart_subtransport_definition* {.bycopy.} = object
    callback*: git_smart_subtransport_cb ## * The function to use to create the git_smart_subtransport
    ## *
    ##  True if the protocol is stateless; false otherwise. For example,
    ##  http:// is stateless, but git:// is not.
    ## 
    rpc*: cuint                ## * Param of the callback
              ## 
    param*: pointer


##  Smart transport subtransports that come with libgit2
## *
##  Create an instance of the http subtransport. This subtransport
##  also supports https. On Win32, this subtransport may be implemented
##  using the WinHTTP library.
## 
##  @param out The newly created subtransport
##  @param owner The smart transport to own this subtransport
##  @return 0 or an error code
## 

proc git_smart_subtransport_http*(`out`: ptr ptr git_smart_subtransport; 
                                 owner: ptr git_transport; param: pointer): cint {.importc.}
## *
##  Create an instance of the git subtransport.
## 
##  @param out The newly created subtransport
##  @param owner The smart transport to own this subtransport
##  @return 0 or an error code
## 

proc git_smart_subtransport_git*(`out`: ptr ptr git_smart_subtransport; 
                                owner: ptr git_transport; param: pointer): cint {.importc.}
## *
##  Create an instance of the ssh subtransport.
## 
##  @param out The newly created subtransport
##  @param owner The smart transport to own this subtransport
##  @return 0 or an error code
## 

proc git_smart_subtransport_ssh*(`out`: ptr ptr git_smart_subtransport; 
                                owner: ptr git_transport; param: pointer): cint {.importc.}
## * @}
