FROM microsoft/dotnet:2.1-sdk-nanoserver-1809 as builder

WORKDIR /Vote
COPY Vote/Vote.csproj .
RUN dotnet restore

COPY /Vote .
RUN dotnet publish -c Release -o /out Vote.csproj

# app image
FROM microsoft/dotnet:2.1-aspnetcore-runtime-nanoserver-1809

WORKDIR /app
ENTRYPOINT ["dotnet", "Vote.dll"]

COPY --from=builder /out .