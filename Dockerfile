FROM dart:stable-sdk
LABEL authors="ilase"
WORKDIR /app
COPY . .
RUN \
    dart pub get && \
    dart compile exe bin/mocker.dart -o ./mocker

EXPOSE 8080
CMD ["./mocker"]

#ENTRYPOINT ["top", "-b"]