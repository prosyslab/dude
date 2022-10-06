FROM prosyslab/classroom
COPY entrypoint.sh /entrypoint.sh
USER 0
ENTRYPOINT ["/entrypoint.sh"]