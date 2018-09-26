FROM microsoft/dotnet:2.1-sdk as builder

WORKDIR /Result
COPY Result/Result.csproj .
RUN dotnet restore

COPY /Result .
RUN dotnet publish -c Release -o /out Result.csproj

# app image
FROM microsoft/dotnet:2.1-aspnetcore-runtime

WORKDIR /app
ENTRYPOINT ["dotnet", "Result.dll"]

COPY --from=builder /out .