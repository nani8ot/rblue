ARG FEDORA_MAJOR_VERSION=37

FROM ghcr.io/ublue-os/silverblue-main:${FEDORA_MAJOR_VERSION}

COPY etc /etc
COPY usr /usr

COPY ublue-firstboot /usr/bin
COPY recipe.yml /etc/ublue-recipe.yml

COPY --from=docker.io/mikefarah/yq /usr/bin/yq /usr/bin/yq

RUN rpm-ostree override remove firefox firefox-langpacks

RUN wget https://copr.fedorainfracloud.org/coprs/david35mm/pamixer/repo/fedora-"${FEDORA_MAJOR_VERSION}"/david35mm-pamixer-fedora-"${FEDORA_MAJOR_VERSION}".repo -O /etc/yum.repos.d/_copr_david35mm-pamixer.repo && \
wget https://copr.fedorainfracloud.org/coprs/nani8ot/river-git/repo/fedora-"${FEDORA_MAJOR_VERSION}"/nani8ot-river-git-fedora-"${FEDORA_MAJOR_VERSION}".repo -O /etc/yum.repos.d/_copr_nani8ot-river-git.repo && \
wget https://copr.fedorainfracloud.org/coprs/nani8ot/waybar-git/repo/fedora-"${FEDORA_MAJOR_VERSION}"/nani8ot-waybar-git-fedora-"${FEDORA_MAJOR_VERSION}".repo -O /etc/yum.repos.d/_copr_nani8ot-waybar-git.repo && \
wget https://copr.fedorainfracloud.org/coprs/nani8ot/way-displays/repo/fedora-"${FEDORA_MAJOR_VERSION}"/nani8ot-way-displays-fedora-"${FEDORA_MAJOR_VERSION}".repo -O /etc/yum.repos.d/_copr_nani8ot-way-displays.repo

RUN wget https://github.com/hyprwm/Hyprland/releases/download/v0.20.1beta/v0.20.1beta.tar.gz && \
    tar -xvf v0.20.1beta.tar.gz Hyprland hyprctl libwlroots.so.12032 && \
    mv Hyprland hyprctl /usr/bin/ && \
    mv libwlroots.so.12032 /usr/lib/

# mask rfkill and power-profiles-daemon, to make tlp work (systemd preset in usr)
RUN systemctl mask systemd-rfkill.service systemd-rfkill.socket power-profiles-daemon.service

RUN echo "-- Installing RPMs defined in recipe.yml --" && \
    rpm_packages=$(yq '.rpms[]' < /etc/ublue-recipe.yml) && \
    echo "Installing: ${pkg}" && \
    rpm-ostree install $rpm_packages; \
    echo "---"

RUN rm -rf \
        /tmp/* \
        /var/* && \
	rm -f /etc/yum.repos.d/_copr_david35mm-pamixer.repo && \
	rm -f /etc/yum.repos.d/_copr_nani8ot-river-git.repo && \
	rm -f /etc/yum.repos.d/_copr_nani8ot-waybar-git.repo && \
	rm -f /etc/yum.repos.d/_copr_nani8ot-way-displays.repo && \
    ostree container commit
