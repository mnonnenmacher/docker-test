plugins {
    application
    kotlin("jvm") version "1.9.22"
    alias(libs.plugins.jib)
//    alias(libs.plugins.kotlinJvm)
}

group = "org.example"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
}

kotlin {
    jvmToolchain(17)
}

application {
    applicationName = "docker-test"
    mainClass = "org.example.MainKt"
}

jib {
    from.image = "docker://docker-test-base:latest"
    to.image = "docker-test:latest"

    container {
        mainClass = "org.example.MainKt"
    }
}
