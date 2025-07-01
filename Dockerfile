# Build stage
FROM rust:1.88.0-slim-bullseye AS builder

WORKDIR /usr/src/underpass-api
COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release && rm -rf src

COPY src ./src
RUN cargo build --release --no-default-features --features "postgres" && \
    cp target/release/underpass-api /usr/local/bin/

# Runtime stage
FROM rust:1.88.0-slim-bullseye AS runtime

COPY --from=builder /usr/local/bin/underpass-api /usr/local/bin/underpass-api

WORKDIR /usr/src/underpass-api
COPY src ./src

CMD ["underpass-api"]
