package com.fastclean.plugin.ui

import com.intellij.openapi.project.Project
import com.intellij.openapi.ui.DialogWrapper
import com.intellij.ui.components.JBLabel
import com.intellij.ui.components.JBScrollPane
import com.intellij.ui.components.JBTextArea
import com.intellij.ui.components.JBTextField
import com.intellij.openapi.ui.ValidationInfo
import java.awt.GridBagConstraints
import java.awt.GridBagLayout
import java.awt.Insets
import javax.swing.JCheckBox
import javax.swing.JComponent
import javax.swing.JPanel

class GenerateFeatureDialog(
    project: Project?,
    private val mode: String = "all" // "all", "entity", "model", "repository", "controller"
) : DialogWrapper(project) {

    private val featureNameField = JBTextField()
    private val rootClassField = JBTextField()
    private val jsonArea = JBTextArea(10, 50)
    
    private val listCheck = JCheckBox("List", true)
    private val getCheck = JCheckBox("Get", true)
    private val addCheck = JCheckBox("Add", true)
    private val updateCheck = JCheckBox("Update", true)
    private val deleteCheck = JCheckBox("Delete", true)

    // Component Checkboxes
    private val entityCheck = JCheckBox("Entity", true)
    private val modelCheck = JCheckBox("Model", true)
    private val useCaseCheck = JCheckBox("Use Cases", true)
    private val repoCheck = JCheckBox("Repository", true)
    private val dataCheck = JCheckBox("Remote Data", true)
    private val bindingCheck = JCheckBox("Bindings", true)
    private val controllerCheck = JCheckBox("Controller", true)
    private val pageCheck = JCheckBox("Page", true)
    private val formCheck = JCheckBox("Form", true)
    private val routeCheck = JCheckBox("Route", true)

    init {
        title = when(mode) {
            "entity" -> "Generate Domain Entity"
            "model" -> "Generate Data Model"
            "repository" -> "Generate Repository"
            "controller" -> "Generate GetX Controller"
            else -> "Generate New Clean Feature"
        }
        
        // Adjust default selections based on mode
        if (mode != "all") {
            setAllComponents(false)
            when(mode) {
                "entity" -> entityCheck.isSelected = true
                "model" -> {
                    modelCheck.isSelected = true
                    entityCheck.isSelected = true // Model usually needs Entity
                }
                "repository" -> {
                    repoCheck.isSelected = true
                    dataCheck.isSelected = true
                }
                "controller" -> {
                    controllerCheck.isSelected = true
                    bindingCheck.isSelected = true
                }
            }
        }
        
        init()
    }

    private fun setAllComponents(selected: Boolean) {
        entityCheck.isSelected = selected
        modelCheck.isSelected = selected
        useCaseCheck.isSelected = selected
        repoCheck.isSelected = selected
        dataCheck.isSelected = selected
        bindingCheck.isSelected = selected
        controllerCheck.isSelected = selected
        pageCheck.isSelected = selected
        formCheck.isSelected = selected
        routeCheck.isSelected = selected
    }

    override fun doValidate(): ValidationInfo? {
        if (getFeatureName().isEmpty()) {
            return ValidationInfo("Feature name is required", featureNameField)
        }
        if (getRootClassName().isEmpty()) {
            return ValidationInfo("Root class name is required", rootClassField)
        }
        
        if (getJson().isNotEmpty() && !getJson().startsWith("{")) {
            return ValidationInfo("JSON must start with {", jsonArea)
        }
        
        if (getSelectedCrud().isEmpty() && (controllerCheck.isSelected || repoCheck.isSelected)) {
            return ValidationInfo("Select at least one CRUD method")
        }

        if (getSelectedComponents().isEmpty()) {
            return ValidationInfo("Select at least one component to generate")
        }
        
        return null
    }

    override fun createCenterPanel(): JComponent {
        val panel = JPanel(GridBagLayout())
        val gbc = GridBagConstraints()
        gbc.fill = GridBagConstraints.HORIZONTAL
        gbc.insets = Insets(5, 5, 5, 5)

        var row = 0

        // Feature Name
        gbc.gridx = 0; gbc.gridy = row++
        panel.add(JBLabel("Feature Name:"), gbc)
        gbc.gridx = 1
        panel.add(featureNameField, gbc)

        // Root Class
        gbc.gridx = 0; gbc.gridy = row++
        panel.add(JBLabel("Class Name:"), gbc)
        gbc.gridx = 1
        panel.add(rootClassField, gbc)

        // CRUD Selection
        gbc.gridx = 0; gbc.gridy = row++
        panel.add(JBLabel("CRUD Methods:"), gbc)
        val crudPanel = JPanel()
        crudPanel.add(listCheck)
        crudPanel.add(getCheck)
        crudPanel.add(addCheck)
        crudPanel.add(updateCheck)
        crudPanel.add(deleteCheck)
        gbc.gridx = 1
        panel.add(crudPanel, gbc)

        // Components Selection
        gbc.gridx = 0; gbc.gridy = row++
        panel.add(JBLabel("Components:"), gbc)
        val compPanel1 = JPanel()
        compPanel1.add(entityCheck)
        compPanel1.add(modelCheck)
        compPanel1.add(useCaseCheck)
        compPanel1.add(repoCheck)
        compPanel1.add(dataCheck)
        gbc.gridx = 1
        panel.add(compPanel1, gbc)

        gbc.gridx = 1; gbc.gridy = row++
        val compPanel2 = JPanel()
        compPanel2.add(bindingCheck)
        compPanel2.add(controllerCheck)
        compPanel2.add(pageCheck)
        compPanel2.add(formCheck)
        compPanel2.add(routeCheck)
        panel.add(compPanel2, gbc)

        // JSON Input
        gbc.gridx = 0; gbc.gridy = row++
        gbc.gridwidth = 2
        panel.add(JBLabel("JSON Schema:"), gbc)
        
        gbc.weighty = 1.0
        gbc.fill = GridBagConstraints.BOTH
        jsonArea.font = JBTextArea().font.deriveFont(14f)
        panel.add(JBScrollPane(jsonArea), gbc)

        return panel
    }

    fun getFeatureName() = featureNameField.text.trim()
    fun getRootClassName() = rootClassField.text.trim()
    fun getJson() = jsonArea.text.trim()
    
    fun getSelectedCrud(): List<String> {
        val list = mutableListOf<String>()
        if (listCheck.isSelected) list.add("list")
        if (getCheck.isSelected) list.add("get")
        if (addCheck.isSelected) list.add("add")
        if (updateCheck.isSelected) list.add("update")
        if (deleteCheck.isSelected) list.add("delete")
        return list
    }

    fun getSelectedComponents(): String {
        val list = mutableListOf<String>()
        if (entityCheck.isSelected) list.add("entity")
        if (modelCheck.isSelected) list.add("model")
        if (useCaseCheck.isSelected) list.add("usecase")
        if (repoCheck.isSelected) list.add("repository")
        if (dataCheck.isSelected) list.add("data")
        if (bindingCheck.isSelected) list.add("binding")
        if (controllerCheck.isSelected) list.add("controller")
        if (pageCheck.isSelected) list.add("page")
        if (formCheck.isSelected) list.add("form")
        if (routeCheck.isSelected) list.add("route")
        
        if (list.size == 10) return "all"
        return list.joinToString(",")
    }
}
