package com.fastclean.plugin.actions

import com.intellij.openapi.project.DumbAwareAction
import com.intellij.openapi.actionSystem.AnActionEvent
import com.intellij.openapi.actionSystem.ActionUpdateThread
import com.fastclean.plugin.ui.GenerateFeatureDialog
import com.fastclean.plugin.generator.CliInvoker

abstract class BaseGenerateAction(private val mode: String, private val component: String) : DumbAwareAction() {
    override fun getActionUpdateThread(): ActionUpdateThread = ActionUpdateThread.BGT

    override fun actionPerformed(e: AnActionEvent) {
        val project = e.project ?: return
        val dialog = GenerateFeatureDialog(project, mode)
        
        if (dialog.showAndGet()) {
            val featureName = dialog.getFeatureName()
            val rootClassName = dialog.getRootClassName()
            val jsonSchema = dialog.getJson()
            val crudMethods = dialog.getSelectedCrud()
            val components = dialog.getSelectedComponents()

            val invoker = CliInvoker(project)
            invoker.generateFeature(featureName, rootClassName, jsonSchema, crudMethods, components)
        }
    }
}
