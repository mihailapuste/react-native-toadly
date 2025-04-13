package com.margelo.nitro.toadly.dialog

import android.app.AlertDialog
import android.content.Context
import android.view.LayoutInflater
import android.widget.EditText
import android.widget.AutoCompleteTextView
import android.widget.ArrayAdapter
import android.widget.Toast
import android.widget.ImageButton
import android.os.Handler
import android.os.Looper
import com.margelo.nitro.toadly.LoggingService
import com.margelo.nitro.toadly.R

class BugReportDialog(private val context: Context, private val onSubmit: (String, String) -> Unit) {
    private val reportTypes = arrayOf("Bug 🐞", "Suggestion 💡", "Question ❓")

    fun show() {
        Handler(Looper.getMainLooper()).post {
            try {
                val dialog = AlertDialog.Builder(context, R.style.CustomDialog)
                    .create()

                val layout = LayoutInflater.from(context).inflate(R.layout.dialog_bug_report, null)

                val emailEditText = layout.findViewById<EditText>(R.id.emailEditText)
                val reportTypeSpinner = layout.findViewById<AutoCompleteTextView>(R.id.reportTypeSpinner)
                val descriptionEditText = layout.findViewById<EditText>(R.id.descriptionEditText)
                val closeButton = layout.findViewById<ImageButton>(R.id.closeButton)
                val sendButton = layout.findViewById<ImageButton>(R.id.sendButton)
              
                val adapter = ArrayAdapter(context, android.R.layout.simple_dropdown_item_1line, reportTypes)
                reportTypeSpinner.setAdapter(adapter)
                reportTypeSpinner.setText(reportTypes[0], false)

                closeButton.setOnClickListener {
                    dialog.dismiss()
                }

                sendButton.setOnClickListener {
                    val email = emailEditText.text?.toString() ?: ""
                    val description = descriptionEditText.text?.toString() ?: ""
                    val reportType = reportTypeSpinner.text?.toString() ?: reportTypes[0]

                    if (email.isEmpty() || description.isEmpty()) {
                        Toast.makeText(context, "Please fill all fields", Toast.LENGTH_SHORT).show()
                        return@setOnClickListener
                    }

                    val title = if (description.length > 50) {
                        description.substring(0, 47) + "..."
                    } else {
                        description
                    }

                    onSubmit(title, reportType.split(" ")[0].lowercase())
                    Toast.makeText(context, "Bug report submitted", Toast.LENGTH_SHORT).show()
                    dialog.dismiss()
                }

                dialog.setView(layout)
                dialog.window?.setBackgroundDrawableResource(android.R.color.transparent)
                dialog.show()
                LoggingService.info("Bug report dialog shown")
            } catch (e: Exception) {
                LoggingService.error("Error showing bug report dialog: ${e.message}")
            }
        }
    }
}
