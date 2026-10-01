##Stage 1 - application preparation process
##Base image containing Java runtime
#FROM eclipse-temurin:21-jdk as build
#
##Add maintainer info
#LABEL maintainer="cheptanui"
#
##Application's jar file
#ARG JAR_FILE
#
##Add the application's jar to the container
#COPY ${JAR_FILE} app.jar
#
##Unpack jar file
#RUN mkdir -p target/dependency && (cd target/dependency; jar -xf /app.jar)
#
#
#
##Stage 2 - runtime environment
#FROM eclipse-temurin:21-jdk
#
##Add volume pointing to /tmp
#VOLUME /tmp
#
##Copy unpackaged application to new container
#ARG DEPENDENCY=/target/dependency
#COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib
#COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
#COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app
#
##execute the application
#ENTRYPOINT ["java", "-cp", "app:app/lib/*", "com.optimagrowth.license.LicencingServiceApplication"]
#
#

FROM eclipse-temurin:21-jdk AS builder

WORKDIR /builder

ARG JAR_FILE=target/licencing-service-0.0.1-SNAPSHOT.jar

COPY ${JAR_FILE} application.jar

RUN java -Djarmode=tools -jar application.jar extract \
    --layers \
    --destination extracted


FROM eclipse-temurin:21-jre

WORKDIR /application

COPY --from=builder /builder/extracted/dependencies/ ./
COPY --from=builder /builder/extracted/spring-boot-loader/ ./
COPY --from=builder /builder/extracted/snapshot-dependencies/ ./
COPY --from=builder /builder/extracted/application/ ./

ENTRYPOINT ["java", "-jar", "application.jar"]