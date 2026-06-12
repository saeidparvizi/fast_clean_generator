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

class GenerateFeatureDialog(project: Project?) : DialogWrapper(project) {

    private val featureNameField = JBTextField()
    private val rootClassField = JBTextField()
    private val jsonArea = JBTextArea(10, 50)
    
    private val listCheck = JCheckBox("List", true)
    private val getCheck = JCheckBox("Get", true)
    private val addCheck = JCheckBox("Add", true)
    private val updateCheck = JCheckBox("Update", true)
    private val deleteCheck = JCheckBox("Delete", true)

    init {
        title = "Generate New Clean Feature"
        init()
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
        if (getSelectedCrud().isEmpty()) {
            return ValidationInfo("Select at least one CRUD method")
        }
        return null
    }

    override fun createCenterPanel(): JComponent {
        val panel = JPanel(GridBagLayout())
        val gbc = GridBagConstraints()
        gbc.fill = GridBagConstraints.HORIZONTAL
        gbc.insets = Insets(5, 5, 5, 5)

        // Feature Name
        gbc.gridx = 0
        gbc.gridy = 0
        panel.add(JBLabel("Feature Name (camelCase):"), gbc)
        gbc.gridx = 1
        panel.add(featureNameField, gbc)

        // Root Class
        gbc.gridx = 0
        gbc.gridy = 1
        panel.add(JBLabel("Root Class Name (PascalCase):"), gbc)
        gbc.gridx = 1
        panel.add(rootClassField, gbc)

        // CRUD Selection
        gbc.gridx = 0
        gbc.gridy = 2
        panel.add(JBLabel("CRUD Methods:"), gbc)
        val crudPanel = JPanel()
        crudPanel.add(listCheck)
        crudPanel.add(getCheck)
        crudPanel.add(addCheck)
        crudPanel.add(updateCheck)
        crudPanel.add(deleteCheck)
        gbc.gridx = 1
        panel.add(crudPanel, gbc)

        // JSON Input
        gbc.gridx = 0
        gbc.gridy = 3
        gbc.gridwidth = 2
        panel.add(JBLabel("JSON Schema (Paste your JSON here):"), gbc)
        
        gbc.gridy = 4
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
}
