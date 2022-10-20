#!/bin/bash

# opam init --yes --disable-sandboxing
# eval $(opam env)
# opam install dune

dune build ocaml_test.exe

dune exec ./ocaml_test.exe $1 $2 