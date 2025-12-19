# Arulog // NGINX for Black Eye

This repository contains a Dockerfile to build a custom NGINX container created specifically for Black Eye cluster.

## Features

- NGINX v1.28.0
- PCRE2 v10.47
- ZLIB v1.3.1
- LibreSSL (static) from Build Container
- Build Container based on Alpine Linux v3.23.2
- Runtime Container based on Distroless Debian 13
- The following NGINX modules are included:
  - HTTP SSL module
  - HTTP V2 module
  - HTTP Real IP module
  - Thread Pool module
  - File AIO module
  - PCRE2 module
  - PCRE JIT module
  - All other default modules

## FAQ

### Why LibreSSL from Build Container?

OpenSSL takes a very long time to compile making the build process a pain, so using pre-compiled LibreSSL from Alpine Linux speeds up the build process significantly while still providing a secure SSL/TLS implementation.

### Why LibreSSL and not OpenSSL?

Looks like LibreSSL works better on Alpine than OpenSSL, I'm only using the Alpine's recommended SSL library.
