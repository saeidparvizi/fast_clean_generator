import org.jetbrains.intellij.platform.gradle.TestFrameworkType

plugins {
    id("java")
    id("org.jetbrains.kotlin.jvm") version "1.9.21"
    id("org.jetbrains.intellij.platform") version "2.1.0"
}

group = "com.fastclean"
version = "1.2.2"

repositories {
    mavenCentral()
    intellijPlatform {
        defaultRepositories()
    }
}

dependencies {
    intellijPlatform {
        // Target 2024.2.1 as a stable base for building
        intellijIdeaCommunity("2024.2.1") 
        
        bundledPlugin("com.intellij.java")
        
        // Plugin IDs for Dart and Flutter
        plugin("Dart", "242.21829.3")
        plugin("io.flutter", "82.0.1")
        
        instrumentationTools()
        
        // Add test framework
        testFramework(TestFrameworkType.Platform)

        // Added for verifyPlugin task
        pluginVerifier()
    }
    
    testImplementation("org.junit.jupiter:junit-jupiter:5.10.0")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")
    
    // Explicitly add JUnit 4 for IntelliJ Test Framework compatibility
    testImplementation("junit:junit:4.13.2")
    testImplementation("org.opentest4j:opentest4j:1.3.0")
}

intellijPlatform {
    pluginConfiguration {
        id.set("com.fastclean.generator")
        name.set("Fast Clean Generator")
        version.set("1.2.2")
        
        vendor {
            name.set("Saeid Parvizi")
            email.set("saeidparvizi@gmail.com")
            url.set("https://github.com/saeidparvizi")
        }
        
        description.set("""
            A powerful productivity tool to generate Flutter Clean Architecture and GetX boilerplate code instantly.
            <br><br>
            <b>Key Features:</b>
            <ul>
                <li>Full Project Bootstrapping (create command)</li>
                <li>Recursive Class Generation for deep JSON schemas</li>
                <li>Unified Network Layer (Dio/GetConnect supported)</li>
                <li>Smart UI component generation (Forms, Screens, Dialogs)</li>
                <li>Granular control over component generation (Entity, Model, Repository, etc.)</li>
            </ul>
        """.trimIndent())

        ideaVersion {
            sinceBuild.set("242") // Matched with IntelliJ 2024.2 base
            untilBuild.set("261.*")
        }
    }

    signing {
        certificateChain.set(providers.environmentVariable("CERTIFICATE_CHAIN"))
        privateKey.set(providers.environmentVariable("PRIVATE_KEY"))
        password.set(providers.environmentVariable("PRIVATE_KEY_PASSWORD"))
    }

    publishing {
        token.set(providers.environmentVariable("JETBRAINS_MARKETPLACE_TOKEN"))
    }
}

java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(21))
    }
}

tasks {
    // Standard build tasks
}
