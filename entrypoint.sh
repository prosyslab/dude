#!/bin/bash -l

# opam init --yes
# eval $(opam env)
# opam install dune --yes
# opam install cohttp-lwt-unix --yes --confirm-level=unsafe-yes
# opam install lwt_ssl --yes --confirm-level=unsafe-yes
# opam install yojson --yes --confirm-level=unsafe-yes

# eval $(opam env) # 제대로 못 잡아주는중.....

env CAML_LD_LIBRARY_PATH=/root/.opam/default/lib/stublibs:/root/.opam/default/lib/ocaml/stublibs:/root/.opam/default/lib/ocaml > /dev/null
env OCAML_TOPLEVEL_PATH=/root/.opam/default/lib/toplevel > /dev/null
env PKG_CONFIG_PATH=/root/.opam/default/lib/pkgconfig > /dev/null
env HOSTNAME=32638fc6e417 > /dev/null
env PWD=/ > /dev/null
env MANPATH=:/root/.opam/default/man > /dev/null
env OPAM_SWITCH_PREFIX=/root/.opam/default > /dev/null
env HOME=/root > /dev/null
env LESSCLOSE=/usr/bin/lesspipe %s %s > /dev/null
env TERM=xterm > /dev/null
env LESSOPEN=| /usr/bin/lesspipe %s > /dev/null
env OLDPWD=/roote > /dev/null
PATH=/root/.opam/default/bin:$PATH > /dev/null

dune exec ./dup_scan.exe $1 "contents:$2" $3 $4 "$5" "$6" # $1: issue_num, $2: issue_contents, $3: repository_path_name, $4: rapid_key, $5: repo_key, $6: threshold