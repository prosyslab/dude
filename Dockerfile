FROM prosyslab/dude:contain-test
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]