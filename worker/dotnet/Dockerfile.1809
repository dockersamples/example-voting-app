FROM microsoft/dotnet:2.1-sdk-nanoserver-1809 as builder

WORKDIR /Worker
COPY Worker/Worker.csproj .
RUN dotnet restore

COPY /Worker .
RUN dotnet publish -c Release -o /out Worker.csproj

# app image
FROM microsoft/dotnet:2.1-aspnetcore-runtime-nanoserver-1809

WORKDIR /app
ENTRYPOINT ["dotnet", "Worker.dll"]

COPY --from=builder /out .