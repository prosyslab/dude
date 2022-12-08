FROM prosyslab/dude:test
COPY entrypoint.sh /entrypoint.sh
COPY dune /dune
COPY dune-project /dune-project
COPY dup_scan.ml /dup_scan.ml
ENTRYPOINT ["/entrypoint.sh"]