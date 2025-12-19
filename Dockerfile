FROM alpine:3.23.2 AS nginx-builder

ARG NGINX_VERSION=1.28.0
ARG PCRE2_VERSION=10.47
ARG ZLIB_VERSION=1.3.1
WORKDIR /app

RUN apk -U upgrade && apk add --no-cache \
    cmake \
    make \
    gcc \
    git \
    musl-dev \
    linux-headers \
    libressl-dev \
    libressl-static

RUN git clone  --recurse-submodules --depth 1 --shallow-submodules --branch pcre2-${PCRE2_VERSION} -j$(nproc) https://github.com/PCRE2Project/pcre2.git

RUN wget https://www.zlib.net/zlib-${ZLIB_VERSION}.tar.xz && \
    tar Jxvf zlib-${ZLIB_VERSION}.tar.xz

RUN wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
    tar zxvf nginx-${NGINX_VERSION}.tar.gz && \
    cd nginx-${NGINX_VERSION} && \
    export CFLAGS="-m64 -march=native -mtune=native -Ofast -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections -static" && \
    export LDFLAGS="-m64 -Wl,-s -Wl,--gc-sections -static" && \
    ./configure \
      --with-ld-opt="-static" \
      --prefix=/usr/local/nginx \
      --sbin-path=/usr/bin/nginx \
      --modules-path=/lib/nginx/modules \
      --conf-path=/etc/nginx/nginx.conf \
      --error-log-path=/var/log/nginx/error.log \
      --http-log-path=/var/log/nginx/access.log \
      --pid-path=/run/nginx.pid \
      --lock-path=/run/nginx.lock \
      --with-threads \
      --with-file-aio \
      --with-pcre=../pcre2 \
      --with-zlib=../zlib-${ZLIB_VERSION} \
      --with-pcre-jit \
      --with-http_ssl_module \
      --with-http_v2_module \
      --with-http_realip_module && \
  make && make install

FROM gcr.io/distroless/static-debian13:latest

WORKDIR /app

COPY --from=nginx-builder /usr/local/nginx /usr/local/nginx
COPY --from=nginx-builder /etc/nginx /etc/nginx
COPY --from=nginx-builder /var/log/nginx /var/log/nginx
COPY --from=nginx-builder /usr/bin/nginx /usr/bin/nginx

EXPOSE 80

ENTRYPOINT ["/usr/bin/nginx", "-g", "daemon off;"]