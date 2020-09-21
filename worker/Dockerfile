FROM microsoft/dotnet:2.0.0-sdk

WORKDIR /code

COPY src/Worker /code/src/Worker

RUN dotnet restore -v minimal src/Worker \
    && dotnet publish -c Release -o "./" "src/Worker/" 

CMD dotnet src/Worker/Worker.dll