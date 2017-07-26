## 
##  Copyright (C) the libgit2 contributors. All rights reserved.
## 
##  This file is part of libgit2, distributed under the GNU GPL v2 with
##  a Linking Exception. For full terms see the included COPYING file.
## 
{.push importc.}
{.push dynlib: "libgit2".}
import
  common, transport

## *
##  The type of proxy to use.
## 

type ## *
    ##  Do not attempt to connect through a proxy
    ## 
    ##  If built against libcurl, it itself may attempt to connect
    ##  to a proxy if the environment variables specify it.
    ## 
  git_proxy_t* = enum
    GIT_PROXY_NONE, ## *
                   ##  Try to auto-detect the proxy from the git configuration.
                   ## 
    GIT_PROXY_AUTO,           ## *
                   ##  Connect via the URL given in the options
                   ## 
    GIT_PROXY_SPECIFIED


## *
##  Options for connecting through a proxy
## 
##  Note that not all types may be supported, depending on the platform
##  and compilation options.
## 

type
  git_proxy_options* {.bycopy.} = object
    version*: cuint            ## *
                  ##  The type of proxy to use, by URL, auto-detect.
                  ## 
    `type`*: git_proxy_t       ## *
                       ##  The URL of the proxy.
                       ## 
    url*: cstring ## *
                ##  This will be called if the remote host requires
                ##  authentication in order to connect to it.
                ## 
                ##  Returning GIT_PASSTHROUGH will make libgit2 behave as
                ##  though this field isn't set.
                ## 
    credentials*: git_cred_acquire_cb ## *
                                    ##  If cert verification fails, this will be called to let the
                                    ##  user make the final decision of whether to allow the
                                    ##  connection to proceed. Returns 1 to allow the connection, 0
                                    ##  to disallow it or a negative value to indicate an error.
                                    ## 
    certificate_check*: git_transport_certificate_check_cb ## *
                                                         ##  Payload to be provided to the credentials and certificate
                                                         ##  check callbacks.
                                                         ## 
    payload*: pointer


const
  GIT_PROXY_OPTIONS_VERSION* = 1

## *
##  Initialize a proxy options structure
## 
##  @param opts the options struct to initialize
##  @param version the version of the struct, use `GIT_PROXY_OPTIONS_VERSION`
## 

proc git_proxy_init_options*(opts: ptr git_proxy_options; version: cuint): cint