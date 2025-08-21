FROM haskell:8.10.7-buster

# buster is EOL
RUN sed -i 's|deb.debian.org/debian|archive.debian.org/debian|g' /etc/apt/sources.list \
 && sed -i '/security.debian.org/d' /etc/apt/sources.list \
 && echo "deb http://archive.debian.org/debian-security buster/updates main" >> /etc/apt/sources.list \
 && apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false \
 && apt-get install -y --no-install-recommends \
    bash vim nano \
    gnupg ca-certificates \
    autoconf automake cmake dpkg-dev file make patch libc6-dev \
 && rm -rf /var/lib/apt/lists/*

# Install dependencies
RUN apt-get -qq update \
    && apt-get install -qqy --no-install-recommends \
    # Install tools
    bash vim nano \
    # Install LLVM dependencies
    gnupg2 ca-certificates apt-transport-https \
    autoconf automake cmake dpkg-dev file make patch libc6-dev \
    # Remove apt cache
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

## Set LLVM repository key
# RUN wget -nv -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
ADD --checksum=sha256:ce6eee4130298f79b0e0f09a89f93c1bc711cd68e7e3182d37c8e96c5227e2f0 \
    https://apt.llvm.org/llvm-snapshot.gpg.key /tmp/llvm-snapshot.gpg.key
RUN apt-key add /tmp/llvm-snapshot.gpg.key
## Set LLVM repository
RUN echo "deb http://apt.llvm.org/buster/ llvm-toolchain-buster-12 main" > /etc/apt/sources.list.d/llvm.list;
RUN apt-get -qq update && apt-get install -qqy -t llvm-toolchain-buster-12 clang-12 clang-tidy-12 clang-format-12 lld-12
RUN for f in /usr/lib/llvm-12/bin/*; do ln -sf "$f" /usr/bin; done && rm -rf /var/lib/apt/lists/*

# Install Haskell Language Server
# RUN wget -nv https://github.com/haskell/haskell-language-server/releases/download/2.2.0.0/haskell-language-server-2.2.0.0-x86_64-linux-deb10.tar.xz && tar xf haskell-language-server-2.2.0.0-x86_64-linux-deb10.tar.xz
ADD --checksum=sha256:a39d15fbb2dc04c6de7f01f9a735930687488e064ea27e0b0b9bb845710d669e \ 
    https://github.com/haskell/haskell-language-server/releases/download/2.2.0.0/haskell-language-server-2.2.0.0-x86_64-linux-deb10.tar.xz /
RUN tar xf haskell-language-server-2.2.0.0-x86_64-linux-deb10.tar.xz
WORKDIR /haskell-language-server-2.2.0.0
RUN make && make install

# Update cabal
RUN cabal update && cabal install cabal-install

# Compile the C sources
COPY /lambdakal/src/StdLib/cbits /lambdakal/src/StdLib/cbits

WORKDIR /lambdakal/src/StdLib/cbits
# put the shared object file (.so) under /usr/lib -> this is passed to ghc options in the cabal file
RUN gcc -fPIC -shared -o /usr/lib/liblambdakal.so io.c list.c

WORKDIR /lambdakal

# Add just the .cabal file to capture dependencies
COPY /lambdakal/cabal.project /lambdakal/lambdakal.cabal ./

RUN cabal build --only-dependencies -j8

COPY /lambdakal /lambdakal
RUN cabal install

CMD ["bash"]
