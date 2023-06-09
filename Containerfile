ARG FEDORA_MAJOR_VERSION=37

FROM ghcr.io/ublue-os/silverblue-main:${FEDORA_MAJOR_VERSION}

COPY etc /etc
COPY usr /usr

COPY ublue-firstboot /usr/bin
COPY recipe.yml /etc/ublue-recipe.yml

COPY --from=docker.io/mikefarah/yq /usr/bin/yq /usr/bin/yq

RUN rpm-ostree override remove firefox firefox-langpacks

RUN wget https://copr.fedorainfracloud.org/coprs/david35mm/pamixer/repo/fedora-"${FEDORA_MAJOR_VERSION}"/david35mm-pamixer-fedora-"${FEDORA_MAJOR_VERSION}".repo -O /etc/yum.repos.d/_copr_david35mm-pamixer.repo && \
wget https://copr.fedorainfracloud.org/coprs/nani8ot/waybar-git/repo/fedora-"${FEDORA_MAJOR_VERSION}"/nani8ot-waybar-git-fedora-"${FEDORA_MAJOR_VERSION}".repo -O /etc/yum.repos.d/_copr_nani8ot-waybar-git.repo && \
wget https://copr.fedorainfracloud.org/coprs/nani8ot/way-displays/repo/fedora-"${FEDORA_MAJOR_VERSION}"/nani8ot-way-displays-fedora-"${FEDORA_MAJOR_VERSION}".repo -O /etc/yum.repos.d/_copr_nani8ot-way-displays.repo

# install cliphist, change version accordingly
RUN wget https://github.com/sentriz/cliphist/releases/download/v0.4.0/v0.4.0-linux-amd64 -O /usr/bin/cliphist && \
	chmod +x /usr/bin/cliphist

# mask rfkill and power-profiles-daemon, to make tlp work (systemd preset in usr)
RUN systemctl mask systemd-rfkill.service systemd-rfkill.socket power-profiles-daemon.service

# set default terminal, since xdg-terminal-exec is not yet available https://gitlab.gnome.org/GNOME/glib/-/issues/338
RUN ln -s /usr/bin/foot /usr/bin/xterm

RUN echo "-- Installing RPMs defined in recipe.yml --" && \
    rpm_packages=$(yq '.rpms[]' < /etc/ublue-recipe.yml) && \
    echo "Installing: ${pkg}" && \
    rpm-ostree install $rpm_packages; \
    echo "---"

RUN rm -rf \
        /tmp/* \
        /var/* && \
	rm -f /etc/yum.repos.d/_copr_david35mm-pamixer.repo && \
	rm -f /etc/yum.repos.d/_copr_nani8ot-waybar-git.repo && \
	rm -f /etc/yum.repos.d/_copr_nani8ot-way-displays.repo && \
    ostree container commit
