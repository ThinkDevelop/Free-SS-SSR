FROM alpine:3.10
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories && apk add nodejs npm
RUN wget -O - https://github.com/shadowsocks/shadowsocks-rust/releases/download/v1.7.0/shadowsocks-v1.7.0-nightly.x86_64-unknown-linux-musl.tar.xz | tar -xJv -C /usr/local/bin sslocal
RUN cd /usr/local/bin && npm i cloudscraper@4 jsdom@15 request@2 --registry=https://registry.npm.taobao.org && \
  echo -e "#!/usr/bin/env node\nrequire('cloudscraper').get('https://www.flywind.ml/free-ss').then((x)=>{let document=new (require('jsdom').JSDOM)(x).window.document;console.log(JSON.stringify({local_address:'0.0.0.0',local_port:1080,servers:Array.from(document.querySelectorAll('#post-box > div > section > table > tbody > tr')).map((x)=>Array.from(x.children).map((x)=>x.innerHTML)).map((x)=>({address:x[0],port:Number(x[1]),password:x[2],method:x[3],country:x[5]})).filter((x)=>x.method!=='aes-128-ctr')}));},console.error)" > /usr/local/bin/genss && \
  chmod +x /usr/local/bin/genss
RUN apk add privoxy && echo -e "\
user-manual /usr/share/doc/privoxy/user-manual/\n\
confdir /etc/privoxy\n\
logdir /var/log/privoxy\n\
actionsfile match-all.action # Actions that are applied to all sites and maybe overruled later on.\n\
actionsfile default.action   # Main actions file\n\
actionsfile user.action      # User customizations\n\
filterfile default.filter\n\
filterfile user.filter      # User customizations\n\
logfile privoxy.log\n\
forward-socks5 / 127.0.0.1:1080 .\n\
listen-address  0.0.0.0:8118\n\
toggle  1\n\
enable-remote-toggle  0\n\
enable-remote-http-toggle  0\n\
enable-edit-actions 0\n\
enforce-blocks 0\n\
buffer-limit 4096\n\
enable-proxy-authentication-forwarding 0\n\
forwarded-connect-retries  0\n\
accept-intercepted-requests 0\n\
allow-cgi-request-crunching 0\n\
split-large-forms 0\n\
keep-alive-timeout 5\n\
tolerate-pipelining 1\n\
socket-timeout 300\n\
" > /etc/privoxy/config
RUN echo -e "#!/bin/sh\n/usr/local/bin/genss>~/ss.json\n/usr/sbin/privoxy /etc/privoxy/config\n/usr/local/bin/sslocal -c ~/ss.json" > /usr/local/bin/startss && chmod +x /usr/local/bin/startss
USER privoxy

EXPOSE 1080
EXPOSE 8118

CMD ["/usr/local/bin/startss"]
