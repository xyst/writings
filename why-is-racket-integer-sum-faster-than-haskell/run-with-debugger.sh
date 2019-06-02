#!/bin/bash                                                                     
set -euo pipefail                                                               
gdb racket <<EOF                                                                
handle SIGSEGV nostop noprint
break scheme_gmpn_add_n
command 1
  print 123
  continue
end
run sum.rkt
EOF
