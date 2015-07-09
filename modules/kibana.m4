ENV KIBANA_VERSION 4.1.1
ENV KIBANA_SHA1 d43e039adcea43e1808229b9d55f3eaee6a5edb9

#Install kibana
RUN set -x \
	&& curl -fSL "https://download.elastic.co/kibana/kibana/kibana-${KIBANA_VERSION}-linux-x64.tar.gz" -o kibana.tar.gz \
	&& echo "${KIBANA_SHA1}  kibana.tar.gz" | sha1sum -c - \
	&& mkdir -p /opt/kibana \
	&& tar -xz --strip-components=1 -C /opt/kibana -f kibana.tar.gz \
	&& rm kibana.tar.gz

#Add kibana to path
ENV PATH /opt/kibana/bin:$PATH