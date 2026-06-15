package com.fastclean.plugin.generator

import com.intellij.execution.configurations.GeneralCommandLine
import com.intellij.execution.process.OSProcessHandler
import com.intellij.execution.process.ProcessAdapter
import com.intellij.execution.process.ProcessEvent
import com.intellij.openapi.application.ApplicationManager
import com.intellij.openapi.project.Project
import com.intellij.openapi.ui.Messages
import com.intellij.openapi.vfs.VfsUtil
import com.intellij.openapi.util.Key
import java.io.File
import java.nio.charset.StandardCharsets

class CliInvoker(private val project: Project) {

    fun buildCommandLine(
        projectPath: String,
        featureName: String,
        rootClassName: String,
        jsonSchema: String,
        crudMethods: List<String>,
        components: String = "all"
    ): GeneralCommandLine {
        val commandLine = GeneralCommandLine()
        commandLine.withWorkDirectory(File(projectPath))
        commandLine.charset = StandardCharsets.UTF_8
        commandLine.withParentEnvironmentType(GeneralCommandLine.ParentEnvironmentType.CONSOLE)
        
        val isWindows = System.getProperty("os.name").lowercase().contains("win")
        val shell = if (isWindows) "cmd.exe" else "/bin/zsh"
        val shellFlag = if (isWindows) "/c" else "-cl" 
        
        commandLine.exePath = shell
        commandLine.addParameters(shellFlag)

        // Sanitize JSON
        val sanitizedJson = jsonSchema.replace("\n", " ").replace("\r", "").replace("'", "'\\''")
        val jsonArg = if (jsonSchema.isNotEmpty()) "--json='$sanitizedJson'" else ""
        val crudArg = "--crud=${crudMethods.joinToString(",")}"
        val componentArg = "--components=$components"
        
        val fullCommand = "dart pub global run fast_clean_generator generate --headless --feature=$featureName --class=$rootClassName $crudArg $jsonArg $componentArg || " +
                         "fcg generate --headless --feature=$featureName --class=$rootClassName $crudArg $jsonArg $componentArg"
        
        commandLine.addParameters(fullCommand)
        return commandLine
    }

    fun generateFeature(
        featureName: String,
        rootClassName: String,
        jsonSchema: String,
        crudMethods: List<String>,
        components: String = "all"
    ) {
        val projectPath = project.basePath ?: return
        val commandLine = buildCommandLine(projectPath, featureName, rootClassName, jsonSchema, crudMethods, components)

        try {
            val processHandler = OSProcessHandler(commandLine)
            val output = StringBuilder()

            processHandler.addProcessListener(object : ProcessAdapter() {
                override fun onTextAvailable(event: ProcessEvent, outputType: Key<*>) {
                    output.append(event.text)
                }

                override fun processTerminated(event: ProcessEvent) {
                    ApplicationManager.getApplication().invokeLater {
                        if (event.exitCode == 0) {
                            val virtualFile = VfsUtil.findFileByIoFile(File(projectPath), true)
                            if (virtualFile != null) {
                                VfsUtil.markDirtyAndRefresh(true, true, true, virtualFile)
                            }
                            Messages.showInfoMessage(project, "Feature '$featureName' generated successfully!", "Success")
                        } else {
                            val errorMsg = output.toString()
                            if (errorMsg.contains("Could not find an option named \"--headless\"")) {
                                Messages.showErrorDialog(project, 
                                    "Your global 'fcg' version is outdated.\n\n" +
                                    "Please run this command in your terminal to update:\n" +
                                    "dart pub global activate fast_clean_generator\n\n" +
                                    "Or for development:\n" +
                                    "dart pub global activate --source path <path_to_generator_project>", 
                                    "Version Mismatch")
                            } else {
                                Messages.showErrorDialog(project, "Generation failed with exit code ${event.exitCode}.\n\n--- CLI Output ---\n$output", "CLI Error")
                            }
                        }
                    }
                }
            })

            processHandler.startNotify()

        } catch (e: Exception) {
            Messages.showErrorDialog(project, "Critical Error: ${e.message}", "Error")
        }
    }
}
