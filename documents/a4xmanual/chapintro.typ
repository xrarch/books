#import "@preview/tablex:0.0.6": tablex, cellx, colspanx, rowspanx

= Overview

The A4X firmware forms the contents of the boot ROM of XR/computer platforms.#footnote([See the _XR/computer Systems Handbook_ for more information.]) This is the first code that executes in the system after processor reset, and is responsible for initializing the integral devices and enabling the user to select a boot device.

It is designed to be very simple. It executes entirely out of ROM, using a small region in low memory for volatile data. Virtual addressing is disabled and polling is used for all I/O.

This document describes the user interface of the A4X firmware, and the fundamentals of its boot protocol, including an overview of the A3X partition table (APT) format.

Implementation details of the firmware are not described here; they are best defined by the source code of the firmware itself.