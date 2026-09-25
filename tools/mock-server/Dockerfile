# Speakr mock server — container image.
#
# Build context is `tools/mock-server/`, NOT the repo root:
#
#   docker build -t speakr-mock-server tools/mock-server
#
# That matters: the mock server has no package dependencies and no
# pubspec.yaml, and `dart compile exe` only needs one when a pubspec is
# actually in scope. Building from the repo root would drag the Flutter
# package's pubspec into the picture and the compile would fail.

# ---------- build ----------
FROM dart:stable AS build

WORKDIR /app
COPY bin/ bin/

# Two AOT binaries: the server itself, and the probe HEALTHCHECK runs
# (the runtime stage below has no shell, curl or wget).
RUN dart compile exe bin/speakr_mock_server.dart -o bin/server \
 && dart compile exe bin/healthcheck.dart -o bin/healthcheck

# ---------- runtime ----------
# `/runtime/` is the minimal set of shared libraries the official Dart images
# ship for exactly this purpose; nothing else is needed.
FROM scratch

COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/server
COPY --from=build /app/bin/healthcheck /app/bin/healthcheck

ENV SPEAKR_MOCK_PORT=8420
EXPOSE 8420

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD ["/app/bin/healthcheck"]

# --host 0.0.0.0 is the default, but be explicit: binding to loopback inside a
# container would make the published port unreachable.
ENTRYPOINT ["/app/bin/server"]
CMD ["--host", "0.0.0.0", "--port", "8420"]
