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

# Run as a lighttpd user.
USER lighttpd

# Use lighttpd-angel.
# * Automatically restarts as necessary.
# * Doesn't close its stdout, allowing logging to work.
ENTRYPOINT ["/usr/sbin/lighttpd-angel", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]

# Use SIGINT to allow lighttpd-angel to attempt a graceful shutdown.
STOPSIGNAL SIGINT

# Check every few minutes to see if the server is still responding.
HEALTHCHECK --interval=5m --timeout=10s \
  CMD wget --spider http://localhost:8080

# Awstats server.
# http://localhost:8080/awstats/awstats.pl
EXPOSE 8080/tcp

# Awstats configuration.
VOLUME /etc/awstats

# Awstats database.
VOLUME /var/lib/awstats

# Logs for awstats to analyze (read-only).
VOLUME /var/log/awstats
