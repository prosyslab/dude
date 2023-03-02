FROM prosyslab/classroom

RUN opam install -y cohttp-lwt-unix
RUN git clone https://github.com/prosyslab/dude.git
WORKDIR dude
RUN eval $(opam env); dune build dup_scan.exe
