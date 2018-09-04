FROM opensuse/leap:42.3
MAINTAINER SUSE Containers Team <containers@suse.com>

# Install the entrypoint of this image.
COPY init /

# Install Portus and prepare the /certificates directory.
RUN chmod +x /init && \
    # Fetch the key from the obs://Virtualization:containers:Portus project.
    mkdir -m 0600 /tmp/build && \
    gpg --homedir /tmp/build --keyserver ha.pool.sks-keyservers.net --recv-keys 55A0B34D49501BB7CA474F5AA193FBB572174FC2 && \
    gpg --homedir /tmp/build --export --armor 55A0B34D49501BB7CA474F5AA193FBB572174FC2 > /tmp/build/repo.key && \
    rpm --import /tmp/build/repo.key && \
    rm -rf /tmp/build && \
    # Now add the repository and installa portus.
    zypper ar -f obs://Virtualization:containers:Portus/openSUSE_Leap_42.3 portus && \
    zypper ref && \
    zypper -n in --from portus ruby-common portus && \
    # Remove unneeded packages and clean stuff.
    zypper -n rm kbd-legacy && \
    zypper clean -a && \
    # Prepare the certificates directory.
    rm -rf /etc/pki/trust/anchors && \
    ln -sf /certificates /etc/pki/trust/anchors

EXPOSE 3000
ENTRYPOINT ["/init"]
