# vim: ft=dockerfile
FROM alpine:3.1
MAINTAINER Johan Stenqvist <johan@stenqvist.net>
LABEL Description="Bastion with google authenticator"

RUN apk --update add \
		build-base automake autoconf libtool curl tar \
		linux-pam linux-pam-dev \
		libssl1.0 openssl-dev \
	&& mkdir -p /src/ga \
		&& curl -L https://github.com/google/google-authenticator/tarball/f2db05c52884e4d6c3894f5fd2cf10f0f686aec2 \
		| tar -xzvf - -C /src/ga --strip-components 1 \
		&& (cd /src/ga/libpam \
			&& ./bootstrap.sh \
			&& ./configure \
				--prefix=/ \
			&& make \
			&& make install) \
	&& mkdir -p /src/sshd \
		&& curl -L https://github.com/openssh/openssh-portable/tarball/V_7_1_P1 \
		| tar -xzvf - -C /src/sshd --strip-components 1 \
		&& (cd /src/sshd \
			&& autoreconf \
			&& ./configure \
				--prefix=/usr \
				--sysconfdir=/etc/ssh \
				--with-pam \
			&& make \
			&& make install) \
		&& rm -rf /etc/ssh/ssh_host_*_key* \
		&& rm -f /usr/bin/ssh-agent \
		&& rm -f /usr/bin/ssh-keyscan \
	&& rm -rf /src \
	&& apk del build-base automake autoconf libtool curl tar \
		linux-pam-dev \
		openssl-dev \
	&& rm -rf /var/cache/apk/*

COPY ./sshd_config /etc/ssh/
COPY ./sshd.pam /etc/pam.d/sshd
RUN rm -f /etc/motd

RUN adduser -D -G users -s /bin/sh -h /bastion bastion \
	&& passwd -u bastion
RUN echo '[[ -e .google_authenticator ]] || google-authenticator' >> /etc/profile

EXPOSE 22
VOLUME /etc/ssh /bastion
CMD ssh-keygen -A && /usr/sbin/sshd -De
