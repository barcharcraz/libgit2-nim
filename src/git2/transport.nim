## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 
{.push importc.}
{.push dynlib: "libgit2".}
import
  indexer, net, types

## *
##  @file git2/transport.h
##  @brief Git transport interfaces and functions
##  @defgroup git_transport interfaces and functions
##  @ingroup Git
##  @{
## 
## * Signature of a function which creates a transport

type
  git_transport_cb* = proc (`out`: ptr ptr git_transport; owner: ptr git_remote;
                         param: pointer): cint

## *
##  Type of SSH host fingerprint
## 

type                          ## * MD5 is available
  git_cert_ssh_t* = enum
    GIT_CERT_SSH_MD5 = (1 shl 0), ## * SHA-1 is available
    GIT_CERT_SSH_SHA1 = (1 shl 1)


## *
##  Hostkey information taken from libssh2
## 

type
  git_cert_hostkey* {.bycopy.} = object
    parent*: git_cert          ## *
                    ##  A hostkey type from libssh2, either
                    ##  `GIT_CERT_SSH_MD5` or `GIT_CERT_SSH_SHA1`
                    ## 
    `type`*: git_cert_ssh_t ## *
                          ##  Hostkey hash. If type has `GIT_CERT_SSH_MD5` set, this will
                          ##  have the MD5 hash of the hostkey.
                          ## 
    hash_md5*: array[16, cuchar] ## *
                              ##  Hostkey hash. If type has `GIT_CERT_SSH_SHA1` set, this will
                              ##  have the SHA-1 hash of the hostkey.
                              ## 
    hash_sha1*: array[20, cuchar]


## *
##  X.509 certificate information
## 

type
  git_cert_x509* {.bycopy.} = object
    parent*: git_cert          ## *
                    ##  Pointer to the X.509 certificate data
                    ## 
    data*: pointer             ## *
                 ##  Length of the memory block pointed to by `data`.
                 ## 
    len*: csize


## 
## ** Begin interface for credentials acquisition ***
## 
## * Authentication type requested

type                          ##  git_cred_userpass_plaintext
  git_credtype_t* = enum
    GIT_CREDTYPE_USERPASS_PLAINTEXT = (1 shl 0), ##  git_cred_ssh_key
    GIT_CREDTYPE_SSH_KEY = (1 shl 1), ##  git_cred_ssh_custom
    GIT_CREDTYPE_SSH_CUSTOM = (1 shl 2), ##  git_cred_default
    GIT_CREDTYPE_DEFAULT = (1 shl 3), ##  git_cred_ssh_interactive
    GIT_CREDTYPE_SSH_INTERACTIVE = (1 shl 4), ## *
                                         ##  Username-only information
                                         ## 
                                         ##  If the SSH transport does not know which username to use,
                                         ##  it will ask via this credential type.
                                         ## 
    GIT_CREDTYPE_USERNAME = (1 shl 5), ## *
                                  ##  Credentials read from memory.
                                  ## 
                                  ##  Only available for libssh2+OpenSSL for now.
                                  ## 
    GIT_CREDTYPE_SSH_MEMORY = (1 shl 6)


##  The base structure for all credential types

type
  git_cred* {.bycopy.} = object
    credtype*: git_credtype_t
    free*: proc (cred: ptr git_cred)


## * A plaintext username and password

type
  git_cred_userpass_plaintext* {.bycopy.} = object
    parent*: git_cred
    username*: cstring
    password*: cstring


## 
##  If the user hasn't included libssh2.h before git2.h, we need to
##  define a few types for the callback signatures.
## 

when not defined(LIBSSH2_VERSION):
  type
    LIBSSH2_SESSION* = _LIBSSH2_SESSION
    LIBSSH2_USERAUTH_KBDINT_PROMPT* = _LIBSSH2_USERAUTH_KBDINT_PROMPT
    LIBSSH2_USERAUTH_KBDINT_RESPONSE* = _LIBSSH2_USERAUTH_KBDINT_RESPONSE
type
  git_cred_sign_callback* = proc (session: ptr LIBSSH2_SESSION; sig: ptr ptr cuchar;
                               sig_len: ptr csize; data: ptr cuchar; data_len: csize;
                               abstract: ptr pointer): cint
  git_cred_ssh_interactive_callback* = proc (name: cstring; name_len: cint;
      instruction: cstring; instruction_len: cint; num_prompts: cint;
      prompts: ptr LIBSSH2_USERAUTH_KBDINT_PROMPT;
      responses: ptr LIBSSH2_USERAUTH_KBDINT_RESPONSE; abstract: ptr pointer)

## *
##  A ssh key from disk
## 

type
  git_cred_ssh_key* {.bycopy.} = object
    parent*: git_cred
    username*: cstring
    publickey*: cstring
    privatekey*: cstring
    passphrase*: cstring


## *
##  Keyboard-interactive based ssh authentication
## 

type
  git_cred_ssh_interactive* {.bycopy.} = object
    parent*: git_cred
    username*: cstring
    prompt_callback*: git_cred_ssh_interactive_callback
    payload*: pointer


## *
##  A key with a custom signature function
## 

type
  git_cred_ssh_custom* {.bycopy.} = object
    parent*: git_cred
    username*: cstring
    publickey*: cstring
    publickey_len*: csize
    sign_callback*: git_cred_sign_callback
    payload*: pointer


## * A key for NTLM/Kerberos "default" credentials

type
  git_cred_default* = git_cred

## * Username-only credential information

type
  git_cred_username* {.bycopy.} = object
    parent*: git_cred
    username*: array[1, char]


## *
##  Check whether a credential object contains username information.
## 
##  @param cred object to check
##  @return 1 if the credential object has non-NULL username, 0 otherwise
## 

proc git_cred_has_username*(cred: ptr git_cred): cint
## *
##  Create a new plain-text username and password credential object.
##  The supplied credential parameter will be internally duplicated.
## 
##  @param out The newly created credential object.
##  @param username The username of the credential.
##  @param password The password of the credential.
##  @return 0 for success or an error code for failure
## 

proc git_cred_userpass_plaintext_new*(`out`: ptr ptr git_cred; username: cstring;
                                     password: cstring): cint
## *
##  Create a new passphrase-protected ssh key credential object.
##  The supplied credential parameter will be internally duplicated.
## 
##  @param out The newly created credential object.
##  @param username username to use to authenticate
##  @param publickey The path to the public key of the credential.
##  @param privatekey The path to the private key of the credential.
##  @param passphrase The passphrase of the credential.
##  @return 0 for success or an error code for failure
## 

proc git_cred_ssh_key_new*(`out`: ptr ptr git_cred; username: cstring;
                          publickey: cstring; privatekey: cstring;
                          passphrase: cstring): cint
## *
##  Create a new ssh keyboard-interactive based credential object.
##  The supplied credential parameter will be internally duplicated.
## 
##  @param username Username to use to authenticate.
##  @param prompt_callback The callback method used for prompts.
##  @param payload Additional data to pass to the callback.
##  @return 0 for success or an error code for failure.
## 

proc git_cred_ssh_interactive_new*(`out`: ptr ptr git_cred; username: cstring;
    prompt_callback: git_cred_ssh_interactive_callback; payload: pointer): cint
## *
##  Create a new ssh key credential object used for querying an ssh-agent.
##  The supplied credential parameter will be internally duplicated.
## 
##  @param out The newly created credential object.
##  @param username username to use to authenticate
##  @return 0 for success or an error code for failure
## 

proc git_cred_ssh_key_from_agent*(`out`: ptr ptr git_cred; username: cstring): cint
## *
##  Create an ssh key credential with a custom signing function.
## 
##  This lets you use your own function to sign the challenge.
## 
##  This function and its credential type is provided for completeness
##  and wraps `libssh2_userauth_publickey()`, which is undocumented.
## 
##  The supplied credential parameter will be internally duplicated.
## 
##  @param out The newly created credential object.
##  @param username username to use to authenticate
##  @param publickey The bytes of the public key.
##  @param publickey_len The length of the public key in bytes.
##  @param sign_callback The callback method to sign the data during the challenge.
##  @param payload Additional data to pass to the callback.
##  @return 0 for success or an error code for failure
## 

proc git_cred_ssh_custom_new*(`out`: ptr ptr git_cred; username: cstring;
                             publickey: cstring; publickey_len: csize;
                             sign_callback: git_cred_sign_callback;
                             payload: pointer): cint
## *
##  Create a "default" credential usable for Negotiate mechanisms like NTLM
##  or Kerberos authentication.
## 
##  @return 0 for success or an error code for failure
## 

proc git_cred_default_new*(`out`: ptr ptr git_cred): cint
## *
##  Create a credential to specify a username.
## 
##  This is used with ssh authentication to query for the username if
##  none is specified in the url.
## 

proc git_cred_username_new*(cred: ptr ptr git_cred; username: cstring): cint
## *
##  Create a new ssh key credential object reading the keys from memory.
## 
##  @param out The newly created credential object.
##  @param username username to use to authenticate.
##  @param publickey The public key of the credential.
##  @param privatekey The private key of the credential.
##  @param passphrase The passphrase of the credential.
##  @return 0 for success or an error code for failure
## 

proc git_cred_ssh_key_memory_new*(`out`: ptr ptr git_cred; username: cstring;
                                 publickey: cstring; privatekey: cstring;
                                 passphrase: cstring): cint
## *
##  Free a credential.
## 
##  This is only necessary if you own the object; that is, if you are a
##  transport.
## 
##  @param cred the object to free
## 

proc git_cred_free*(cred: ptr git_cred)
## *
##  Signature of a function which acquires a credential object.
## 
##  @param cred The newly created credential object.
##  @param url The resource for which we are demanding a credential.
##  @param username_from_url The username that was embedded in a "user\@host"
##                           remote url, or NULL if not included.
##  @param allowed_types A bitmask stating which cred types are OK to return.
##  @param payload The payload provided when specifying this callback.
##  @return 0 for success, < 0 to indicate an error, > 0 to indicate
##        no credential was acquired
## 

type
  git_cred_acquire_cb* = proc (cred: ptr ptr git_cred; url: cstring;
                            username_from_url: cstring; allowed_types: cuint;
                            payload: pointer): cint

## * @}
