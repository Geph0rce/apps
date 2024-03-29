#!/usr/bin/python

import sys

from capabilities import Capabilities

CAPABILITIES = set([
    # Add capabilities here to mark them as supported.
    Capabilities.CAPABILITIES_HEADER,
])

TEMPLATE = """
// Copyright 2004-present Facebook. All Rights Reserved.

/*
 * This file is autogenerated by a build script. Do not modify it manually.
 * See capabilities.py for more info.
 */

#define kIGCapabilitiesString @"%s"
""".strip()

if __name__ == "__main__":
    print TEMPLATE % Capabilities.build_header(CAPABILITIES)
