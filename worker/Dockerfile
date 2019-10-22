FROM mcr.microsoft.com/dotnet/core/sdk:2.1 AS build

WORKDIR /code

# copy csproj and restore as distinct layers
COPY src/Worker/*.csproj ./
RUN dotnet restore

# copy everything else and build app
COPY src/Worker/. ./
RUN dotnet publish -c Release -o out

FROM mcr.microsoft.com/dotnet/core/runtime:2.1

WORKDIR /app

COPY --from=build /code/out ./

ENTRYPOINT ["dotnet", "Worker.dll"]