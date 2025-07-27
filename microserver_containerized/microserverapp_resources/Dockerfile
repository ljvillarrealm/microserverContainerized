FROM eclipse-temurin:latest
WORKDIR /app
COPY ./microserverapp_files .
EXPOSE 8085
#RUN javac -jar ./MicroServer-0.5.0.jar
RUN ls
RUN chmod +x wait-for-it.sh
RUN ./wait-for-it.sh www.google.com:80 -- echo "google is up"
CMD ["java", "-jar", "MicroServer.jar", "data.conf"]