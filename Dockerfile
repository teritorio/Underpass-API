# Build stage
FROM rust:1.88.0-slim-bullseye AS builder

RUN apt update && apt install -y \
        build-essential

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
FROM rust:1.88.0-slim-bullseye AS runtime

COPY --from=builder /usr/local/bin/underpass-api /usr/local/bin/underpass-api

WORKDIR /usr/src/underpass-api
COPY src ./src

CMD ["underpass-api"]
