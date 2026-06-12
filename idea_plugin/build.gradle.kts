plugins {
    id("java")
    id("org.jetbrains.kotlin.jvm") version "1.9.21"
    id("org.jetbrains.intellij.platform") version "2.1.0"
}

group = "com.fastclean"
version = "1.2.1"

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
    }
}

intellijPlatform {
    pluginConfiguration {
        id.set("com.fastclean.generator")
        name.set("Fast Clean Generator")
        version.set("1.2.1")
        
        vendor {
            name.set("Saeid Parvizi")
            email.set("saeidparvizi@gmail.com")
            url.set("https://github.com/saeidparvizi")
        }
        
        ideaVersion {
            sinceBuild.set("232")
            untilBuild.set("261.*") // This will definitely cover your AI-253 build
        }
    }
}

java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(17))
    }
}

tasks {
    // Standard build tasks
}
