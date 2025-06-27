FROM rust:1.88-alpine as builder

RUN apk add --no-cache build-base musl-dev openssl-dev pkgconf

# Create a new empty shell project
WORKDIR /usr/src/app
RUN cargo new --bin omistral
WORKDIR /usr/src/app/omistral

# Copy our manifests
COPY Cargo.toml ./

# Build only the dependencies to cache them
RUN cargo build --release
RUN rm src/*.rs

# Now copy in the actual source code
COPY src ./src
RUN cargo build --release

# Start a new stage
FROM debian:bullseye-slim

# Install required dependencies
RUN apt-get update && apt-get install -y libssl-dev ca-certificates && rm -rf /var/lib/apt/lists/*

# Copy the binary from the builder stage
COPY --from=builder /usr/src/app/omistral/target/release/omistral /usr/local/bin/omistral

# Create a non-root user to run the application
RUN useradd -ms /bin/bash rustuser
USER rustuser
WORKDIR /home/rustuser

# Expose the port the app will run on
EXPOSE 5555

# Command to run the application
CMD ["omistral"]