FROM microsoft/dotnet:2.1-sdk-alpine AS build

WORKDIR /code

ADD src/Worker /code/src/Worker

RUN dotnet restore -v minimal src/Worker \
    && dotnet publish -c Release -o "./" "src/Worker/" 

FROM microsoft/dotnet:2.1-runtime-alpine

WORKDIR /code

COPY --from=build /code/src/Worker .

CMD dotnet Worker.dll