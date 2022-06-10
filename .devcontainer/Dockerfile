FROM rust:slim-bullseye AS stylua-builder
RUN cargo install --root=/opt/stylua --version=0.12.4 stylua

FROM mcr.microsoft.com/vscode/devcontainers/python:0-bullseye
RUN pip3 install pre-commit
COPY --from=stylua-builder /opt/stylua /usr/local
