FROM  microsoft/dotnet:2.1-sdk-nanoserver-1809 as builder

WORKDIR /Result
COPY Result/Result.csproj .
RUN dotnet restore

COPY /Result .
RUN dotnet publish -c Release -o /out Result.csproj

# app image
FROM microsoft/dotnet:2.1-aspnetcore-runtime-nanoserver-1809

WORKDIR /app
ENTRYPOINT ["dotnet", "Result.dll"]

COPY --from=builder /out .