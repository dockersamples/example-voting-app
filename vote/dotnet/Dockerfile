FROM microsoft/dotnet:2.1-sdk as builder

WORKDIR /Vote
COPY Vote/Vote.csproj .
RUN dotnet restore

COPY /Vote .
RUN dotnet publish -c Release -o /out Vote.csproj

# app image
FROM microsoft/dotnet:2.1-aspnetcore-runtime

WORKDIR /app
ENTRYPOINT ["dotnet", "Vote.dll"]

COPY --from=builder /out .