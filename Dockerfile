from caddy
copy ./build /build
cmd ["caddy", "file-server", "--root", "/build", "--browse"]