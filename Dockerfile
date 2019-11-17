FROM alpine
LABEL author="wjl@icecavern.net"

# Install packages.
RUN \
	apk update && \
	apk upgrade && \
	apk add \
		awstats \
		lighttpd \
	&& \
	rm -r /var/cache/apk/*

# Install configuration.
COPY lighttpd.conf /etc/lighttpd/lighttpd.conf

# Sanity check lighttpd configuration.
RUN \
	lighttpd -D -t  -f /etc/lighttpd/lighttpd.conf && \
	lighttpd -D -tt -f /etc/lighttpd/lighttpd.conf

# Run as a lighttpd user.
USER lighttpd

# Use lighttpd-angel.
# * Automatically restarts as necessary.
# * Doesn't close its stdout, allowing logging to work.
ENTRYPOINT ["/usr/sbin/lighttpd-angel", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]

# Use SIGINT to allow lighttpd-angel to attempt a graceful shutdown.
STOPSIGNAL SIGINT

# Check every once in a while to see if the server is still responding.
HEALTHCHECK --interval=30m --timeout=10s \
  CMD wget --spider http://localhost:8080/cgi-bin/awstats.pl

# Awstats server.
EXPOSE 8080/tcp

# Awstats configuration (read-only).
VOLUME /etc/awstats

# Awstats database (read-write).
VOLUME /var/lib/awstats

# Logs for awstats to analyze (read-only).
VOLUME /var/log/awstats
