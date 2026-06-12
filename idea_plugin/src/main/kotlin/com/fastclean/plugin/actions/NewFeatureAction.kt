package com.fastclean.plugin.actions

import com.intellij.openapi.actionSystem.AnAction
import com.intellij.openapi.actionSystem.AnActionEvent
import com.intellij.openapi.ui.Messages
import com.fastclean.plugin.ui.GenerateFeatureDialog
import com.fastclean.plugin.generator.CliInvoker

class NewFeatureAction : AnAction() {
    override fun actionPerformed(e: AnActionEvent) {
        val project = e.project ?: return
        val dialog = GenerateFeatureDialog(project)
        
        if (dialog.showAndGet()) {
            val featureName = dialog.getFeatureName()
            val rootClassName = dialog.getRootClassName()
            val jsonSchema = dialog.getJson()
            val crudMethods = dialog.getSelectedCrud()

            if (featureName.isEmpty() || rootClassName.isEmpty()) {
                Messages.showErrorDialog(project, "Feature name and Root class name are required.", "Error")
                return
            }

            val invoker = CliInvoker(project)
            invoker.generateFeature(featureName, rootClassName, jsonSchema, crudMethods)
        }
    }
}
