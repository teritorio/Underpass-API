FROM archlinux:base AS builder

RUN pacman -Sy && pacman -S --noconfirm \
    base-devel \
    git \
    rust \
    cargo

# Install yay
RUN useradd -m build
USER build
RUN cd /tmp/ && \
    git clone https://aur.archlinux.org/yay-bin.git && \
    cd yay-bin && \
    makepkg
USER root
RUN pacman -U --noconfirm /tmp/yay-bin/*.pkg.tar.zst
USER build
# Install duckdb from yay
RUN cd /tmp && \
    yay -G --noconfirm aur/duckdb-bin && \
    cd duckdb-bin && \
    makepkg
USER root
RUN pacman -U --noconfirm /tmp/duckdb-bin/*.pkg.tar.zst

WORKDIR /usr/src/underpass-api
RUN mkdir src && echo "fn main() {}" > src/main.rs && \
    mkdir -p underpass-wasm/src && echo "fn main() {}" > underpass-wasm/src/lib.rs
COPY Cargo.toml Cargo.lock ./
COPY underpass-wasm/Cargo.toml ./underpass-wasm/Cargo.toml
RUN cargo build --release && rm -rf src

COPY src ./src
RUN cargo build --release && \
    cp target/release/underpass-api /usr/local/bin/

# Runtime stage
FROM archlinux:base AS runtime

COPY --from=builder /tmp/duckdb-bin/*.pkg.tar.zst /tmp/duckdb-bin/
RUN pacman -U --noconfirm /tmp/duckdb-bin/*.pkg.tar.zst

COPY --from=builder /usr/local/bin/underpass-api /usr/local/bin/underpass-api

WORKDIR /usr/src/underpass-api
COPY src ./src

CMD ["underpass-api"]
