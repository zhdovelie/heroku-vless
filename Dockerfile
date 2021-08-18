FROM windows:20H2-KB5005033-amd64
ADD configure.sh /configure.sh
RUN chmod +x /configure.sh
CMD /configure.sh
