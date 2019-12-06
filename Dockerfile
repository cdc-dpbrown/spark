FROM mcr.microsoft.com/dotnet/core/aspnet:2.2-stretch-slim AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/core/sdk:2.2-stretch AS build
WORKDIR /src
COPY ["./src/Spark/", "Spark/"]
COPY ["./src/Spark.Web/", "Spark.Web/"]
COPY ["./src/Spark.Engine/", "Spark.Engine/"]
COPY ["./src/Spark.Mongo/", "Spark.Mongo/"]
RUN dotnet restore "/src/Spark.Web/Spark.Web.csproj"
COPY . .
RUN dotnet build "/src/Spark.Web/Spark.Web.csproj" -c Release -o /app

FROM build AS publish
RUN dotnet publish "/src/Spark.Web/Spark.Web.csproj" -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .

# running on port 80 results in an error when not running the container as root, so we'll use a different port instead
EXPOSE 8080/tcp
ENV ASPNETCORE_URLS=http://*:8080

# don't run as root user
RUN chown 1001:0 /app/Spark.Web.dll
RUN chmod g+rwx /app/Spark.Web.dll
USER 1001

ENTRYPOINT ["dotnet", "Spark.Web.dll"]