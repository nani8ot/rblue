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
wget https://copr.fedorainfracloud.org/coprs/nani8ot/waybar-git/repo/fedora-"${FEDORA_MAJOR_VERSION}"/nani8ot-waybar-git-fedora-"${FEDORA_MAJOR_VERSION}".repo -O /etc/yum.repos.d/_copr_nani8ot-waybar-git.repo

RUN echo "-- Installing RPMs defined in recipe.yml --" && \
    rpm_packages=$(yq '.rpms[]' < /etc/ublue-recipe.yml) && \
    for pkg in $rpm_packages; do \
        echo "Installing: ${pkg}" && \
        rpm-ostree install $pkg; \
    done && \ 
    echo "---"

RUN rm -rf \
        /tmp/* \
        /var/* && \
	rm -f /etc/yum.repos.d/_copr_david35mm-pamixer.repo && \
	rm -f /etc/yum.repos.d/_copr_nani8ot-river-git.repo && \
	rm -f /etc/yum.repos.d/_copr_nani8ot-waybar-git.repo && \
    ostree container commit
