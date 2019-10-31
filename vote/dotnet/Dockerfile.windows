FROM microsoft/dotnet:2.1-sdk-nanoserver-sac2016 as builder

WORKDIR /Vote
COPY Vote/Vote.csproj .
RUN dotnet restore

COPY /Vote .
RUN dotnet publish -c Release -o /out Vote.csproj

# app image
FROM microsoft/dotnet:2.1-aspnetcore-runtime-nanoserver-sac2016

WORKDIR /app
ENTRYPOINT ["dotnet", "Vote.dll"]

COPY --from=builder /out .