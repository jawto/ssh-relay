FROM debian:stable-slim

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      autoconf \
      build-essential \
      curl \
      iputils-ping \
      libpam0g \
      libpam0g-dev \
      libtool \
      openssh-client \
      openssh-server \
      procps \
    && mkdir -p /src/ga \
	    && curl -L https://github.com/google/google-authenticator/tarball/1.02 \
	    | tar -xzvf - -C /src/ga --strip-components 1 \
	    && (cd /src/ga/libpam \
		    && ./bootstrap.sh \
		    && ./configure \
			    --prefix=/ \
		    && make \
		    && make install) \
    && rm -rf /src \
    && DEBIAN_FRONTEND=noninteractive apt-get purge -y autoconf build-essential libpam0g-dev libtool \
    && DEBIAN_FRONTEND=noninteractive apt -y autoremove \
    && DEBIAN_FRONTEND=noninteractive apt-get -y clean \
    && mkdir -p /run/sshd \
    && rm -rf /etc/ssh/ssh_host_*_key* \
    && rm -f /etc/motd

COPY ./sshd_config /etc/ssh/
COPY ./sshd.pam /etc/pam.d/sshd
COPY ./run.sh run.sh

RUN adduser --disabled-password --ingroup users --shell /bin/sh --home /bastion --gecos '' bastion
RUN echo '[ -e .google_authenticator ] || google-authenticator' >> /etc/profile

EXPOSE 22
VOLUME /etc/ssh /bastion
CMD ./run.sh
