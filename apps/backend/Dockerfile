FROM dart:3.11.1-sdk AS build
WORKDIR /src

COPY pubspec.yaml pubspec.lock ./
COPY packages/api_contract/pubspec.yaml packages/api_contract/
COPY apps/backend/pubspec.yaml apps/backend/
RUN sed -i '/apps\/mobile/d' pubspec.yaml && dart pub get

COPY packages/api_contract packages/api_contract
COPY apps/backend apps/backend
RUN dart compile exe apps/backend/bin/server.dart -o /server

FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /server /app/server
USER 65532:65532
EXPOSE 8080
ENTRYPOINT ["/app/server"]
