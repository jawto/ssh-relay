FROM alpine:edge

RUN apk --update add \
		openssh-client openssh-server-pam linux-pam \
		build-base automake autoconf libtool libusb-dev curl-dev curl tar help2man linux-pam-dev \
	&& mkdir -p /src/yk-cl \
	        && curl -L https://developers.yubico.com/yubico-c-client/Releases/ykclient-2.15.tar.gz \
		| tar -xzvf - -C /src/yk-cl --strip-components 1 \
		&& (cd /src/yk-cl \
			&& ./configure \
			&& make install \
			&& ldconfig /usr/local/lib) \
	&& mkdir -p /src/yk-c \
	         && curl -L https://developers.yubico.com/yubico-c/Releases/libyubikey-1.13.tar.gz \
		 | tar -xzvf - -C /src/yk-c --strip-components 1 \
		 && (cd /src/yk-c \
			&& ./configure \
			&& make check install \
			&& ldconfig /usr/local/lib) \
	&& mkdir -p /src/yk-pers \
	        && curl -L https://developers.yubico.com/yubikey-personalization/Releases/ykpers-1.19.3.tar.gz \
		| tar -xzvf - -C /src/yk-pers --strip-components 1 \
		&& (cd /src/yk-pers \
			&& ./configure \
			&& make install) \
	&& mkdir -p /src/yk-pam \
	        && curl -L https://developers.yubico.com/yubico-pam/Releases/pam_yubico-2.26.tar.gz \
		| tar -xzvf - -C /src/yk-pam --strip-components 1 \
		&& (cd /src/yk-pam \
			&& ./configure --without-ldap \
			&& make check install) \
	&& rm -rf /src \
	&& apk del \
		build-base automake autoconf libtool libusb-dev curl-dev curl tar help2man linux-pam-dev \
	&& rm -rf /var/cache/apk/* \
	&& rm -rf /etc/ssh/ssh_host_*_key* \
	&& rm -f /etc/motd

ENV AUTH required
ENV DEBUG false

COPY ./sshd_config /etc/ssh/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN adduser -D -G users -s /bin/sh -h /bastion bastion \
	&& passwd -u bastion
RUN chmod +x /usr/local/bin/entrypoint.sh 

EXPOSE 22
VOLUME /etc/ssh /bastion
ENTRYPOINT ["entrypoint.sh"]
