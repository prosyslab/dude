FROM prosyslab/dude
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]