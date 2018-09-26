FROM microsoft/dotnet:2.1-sdk-nanoserver-sac2016 as builder

WORKDIR /Worker
COPY Worker/Worker.csproj .
RUN dotnet restore

COPY /Worker .
RUN dotnet publish -c Release -o /out Worker.csproj

# app image
FROM microsoft/dotnet:2.1-runtime-nanoserver-sac2016

WORKDIR /app
ENTRYPOINT ["dotnet", "Worker.dll"]

COPY --from=builder /out .