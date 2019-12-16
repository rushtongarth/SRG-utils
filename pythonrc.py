#!/usr/bin/env python

import os
import sys

if sys.version_info < (3, 0):
    import rlcompleter
    import readline
    readline.parse_and_bind("tab: complete")

def myprint(arg1,arg2):
    tmp = arg1 % arg2
    if (sys.version_info > (3, 0)):
        sys.displayhook(tmp)
    else:
        sys.displayhook(tmp)

def clear(funcname=None):
    if funcname:
        if funcname in globals().keys():
            _ = globals().pop(funcname)
            myprint("Function <%s> removed from namespace",funcname)
        else:
            myprint("Function <%s> not found in the namespace",funcname)
    else:
        _ = os.system('clear')
