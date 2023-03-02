FROM prosyslab/classroom

RUN echo "1234" | sudo -S apt update
RUN echo "1234" | sudo -S apt install -y libssl-dev
RUN opam install -y cohttp-lwt-unix lwt_ssl
RUN git clone https://github.com/prosyslab/dude.git
WORKDIR dude
RUN eval $(opam env); dune build dup_scan.exe
