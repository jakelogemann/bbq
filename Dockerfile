FROM cuelang/cue:0.4.3
COPY cue.mod *.cue ./
ENTRYPOINT [ "/usr/bin/cue"]
CMD ["cmd", "generate"]
