package com.fastclean.plugin.generator

import com.intellij.openapi.project.Project
import com.intellij.testFramework.fixtures.BasePlatformTestCase
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.Test

class CliInvokerTest : BasePlatformTestCase() {

    @Test
    fun testBuildCommandLine() {
        val invoker = CliInvoker(project)
        val commandLine = invoker.buildCommandLine(
            projectPath = "/test/path",
            featureName = "booking",
            rootClassName = "Payment",
            jsonSchema = "{\"id\": 1}",
            crudMethods = listOf("list", "get"),
            components = "entity,model"
        )

        val fullCommand = commandLine.commandLineString
        
        // Assert shell is used
        assertTrue("Shell should be zsh or cmd.exe, but was: $fullCommand", 
            fullCommand.contains("zsh") || fullCommand.contains("cmd.exe"))
        
        // Assert all arguments are present
        assertTrue("Missing feature flag in: $fullCommand", fullCommand.contains("--feature=booking"))
        assertTrue("Missing class flag in: $fullCommand", fullCommand.contains("--class=Payment"))
        assertTrue("Missing crud flag in: $fullCommand", fullCommand.contains("--crud=list,get"))
        assertTrue("Missing components flag in: $fullCommand", fullCommand.contains("--components=entity,model"))
        
        // Assert json flag (careful with quotes in the command string representation)
        assertTrue("Missing json flag in: $fullCommand", fullCommand.contains("--json="))
        assertTrue("JSON value mismatch in: $fullCommand", fullCommand.contains("id") && fullCommand.contains("1"))
        
        // Assert fallback logic is present
        assertTrue("Missing fallback operator '||' in: $fullCommand", fullCommand.contains("||"))
    }
    
    @Test
    fun testJsonSanitization() {
        val invoker = CliInvoker(project)
        val commandLine = invoker.buildCommandLine(
            projectPath = "/test/path",
            featureName = "test",
            rootClassName = "Test",
            jsonSchema = "{\n  \"name\": \"Saeid\"\n}",
            crudMethods = listOf("list")
        )
        
        val fullCommand = commandLine.commandLineString
        // Assert no newlines in the command string representation
        assertFalse("Command should not contain newlines: $fullCommand", fullCommand.contains("\n"))
        // Check for sanitized content (checking substrings for reliability)
        assertTrue("JSON key 'name' not found in: $fullCommand", fullCommand.contains("name"))
        assertTrue("JSON value 'Saeid' not found in: $fullCommand", fullCommand.contains("Saeid"))
    }
}
