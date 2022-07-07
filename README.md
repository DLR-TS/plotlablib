
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

## Setup
This repository may be used on a system, which fulfills a set of requirements [adore_setup](https://github.com/dlr-ts/adore_setup).
After checkout, enter make in the top level of the repository in order to build.
