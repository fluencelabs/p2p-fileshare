from caddy
copy ./build /build
entrypoint ["caddy", "file-server", "--root", "/build", "--browse"]