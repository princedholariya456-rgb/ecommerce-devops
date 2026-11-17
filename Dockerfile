
# ============================================
# Stage 1: Build application using Maven + JDK 25
# ============================================
FROM maven:3.9.16-eclipse-temurin-25-noble AS builder

WORKDIR /usr/src/app

# Copy Maven configuration
COPY pom.xml .

# Download dependencies
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Build WAR file
RUN mvn clean package -DskipTests -B


# ============================================
# Stage 2: Deploy using Tomcat 9 + JDK 25
# ============================================
FROM tomcat:9.0.124-jdk25-temurin-noble

WORKDIR /usr/local/tomcat/webapps/

# Remove default Tomcat applications
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy generated WAR file
COPY --from=builder /usr/src/app/target/EcommerceApp.war \
    /usr/local/tomcat/webapps/ROOT.war

# Expose Tomcat port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]