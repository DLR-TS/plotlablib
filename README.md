
<!--
********************************************************************************
* Copyright (C) 2017-2022 German Aerospace Center (DLR). 
* Eclipse ADORe, Automated Driving Open Research https://eclipse.org/adore
*
* This program and the accompanying materials are made available under the 
* terms of the Eclipse Public License 2.0 which is available at
* http://www.eclipse.org/legal/epl-2.0.
*
* SPDX-License-Identifier: EPL-2.0 
*
* Contributors: 
*   Daniel Heß 
********************************************************************************
-->
# Plotlablib is an Interface to Plotlabserver
Plotlablib is a message-based interface, which allows a c++ application to connect to [Plotlabserver](https://github.com/dlr-ts/plotlabserver) in order to display graphs.

## Structure
On this level the repository is a docker and make wrapper for the actual content in the module subfolder.

## Getting Started
This module requires **make** and **docker** installed and configured for your user.

## Building
To build plotlablib run the following:
```bash
make build
```

## External Libraries
plotlablib depends on several external libraries that do not provide
distributions.  They are packaged and hosted for adore via docker.io.
All external libraries are located in `plotlablib/external`. There is a provided
make file to build and publish all external libraries. By default all external
libraries are disabled in the `.gitmodules` file. They have been previously 
published to docker.io. In order to build them you must first enable the one 
you would like to build in the `.gitmodules` file. 

> **ℹ️ INFO:**
> External library submodues are disabled and will not be pulled. Enable them
> by modifying the `.gitmodules` and invoking 'git submodue update --init'.

> **ℹ️ INFO:**
> By default external libraries are not built. They are sourced first from local
> cache in /var/tmp/docker and seconds as pre-compiled docker images from docker.io.
The external libraries cache is not deleted or cleaned automatically. In order
to clean the external libriary cache located in `/var/tmp/docker` invoke the 
provided target:
```bash
make clean_external_cache
```


