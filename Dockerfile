# ------------------- builder stage
FROM gentoo/stage3-amd64:latest as builder

# ------------------- portage tree
COPY --from=gentoo/portage:latest /var/db/repos/gentoo /var/db/repos/gentoo

# ------------------- emerge
RUN emerge -C sandbox
COPY portage/package.unmask /etc/portage/package.unmask
COPY portage/awscli.use /etc/portage/package.use/awscli
COPY portage/awscli.accept_keywords /etc/portage/package.accept_keywords/awscli
RUN ROOT=/awscli FEATURES='-usersandbox' emerge app-admin/awscli

# ------------------- shrink
RUN ROOT=/awscli emerge --quiet -C \
      app-admin/*\
      sys-apps/* \
      sys-kernel/* \
      virtual/* \
      sys-libs/ncurses

# ------------------- detox
RUN rm -rf \
        /awscli/var/db/pkg \
        /awscli/usr/share/doc \
        /awscli/usr/share/eselect \
        /awscli/usr/share/info \
        /awscli/usr/share/man \
        /awscli/var/lib/gentoo \
        /awscli/var/lib/portage \
        /awscli/var/cache/edb

# ------------------- empty image
FROM scratch
COPY --from=builder /awscli /
