# Etapa 1: compila com o Maven Wrapper do projeto
FROM eclipse-temurin:17-jdk AS build
WORKDIR /app
COPY .mvn .mvn
COPY mvnw pom.xml ./
RUN chmod +x mvnw && ./mvnw -q -B dependency:go-offline
COPY src src
RUN ./mvnw -q -B package -DskipTests

# Etapa 2: só o JRE e o .jar
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/target/clyvo-vet-1.0.0.jar app.jar

# O H2 em arquivo fica em /app/data. No Render gratuito o disco não é persistente: a cada deploy
# o Flyway recria o banco com a mesma carga do grupo (a carga é sempre igual).
ENV DB_PATH=/app/data/clyvovet
EXPOSE 8080
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75", "-jar", "app.jar"]
