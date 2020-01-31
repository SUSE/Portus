FROM opensuse/leap:15.1
MAINTAINER SUSE Containers Team <containers@suse.com>

# Install the entrypoint of this image.
COPY init /

# Install Portus and prepare the /certificates directory.
RUN chmod +x /init && \
    # add repositories
    zypper ar -f obs://devel:languages:ruby/openSUSE_Leap_15.1 ruby && \
    zypper ar -f obs://Virtualization:containers:Portus/openSUSE_Leap_15.1 portus && \
    # refresh repositories and automatically trust their signing keys
    zypper --gpg-auto-import-keys ref && \
    # install portus
    zypper -n in --from portus ruby-common portus && \
    zypper clean -a && \
    # Prepare the certificates directory.
    rm -rf /etc/pki/trust/anchors && \
    ln -sf /certificates /etc/pki/trust/anchors

EXPOSE 3000
ENTRYPOINT ["/init"]
