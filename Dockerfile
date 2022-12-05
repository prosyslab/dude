FROM prosyslab/dude:test
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]