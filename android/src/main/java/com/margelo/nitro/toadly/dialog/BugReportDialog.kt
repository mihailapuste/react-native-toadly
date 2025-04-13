package com.margelo.nitro.toadly.dialog

import android.app.AlertDialog
import android.content.Context
import android.view.LayoutInflater
import android.widget.EditText
import android.widget.Spinner
import android.widget.ArrayAdapter
import android.widget.Toast
import android.os.Handler
import android.os.Looper
import com.margelo.nitro.toadly.LoggingService
import com.margelo.nitro.toadly.R

class BugReportDialog(private val context: Context, private val onSubmit: (String, String) -> Unit) {
    private val reportTypes = arrayOf("Bug 🐞", "Suggestion 💡", "Question ❓")

    fun show() {
        Handler(Looper.getMainLooper()).post {
            try {
                val layout = LayoutInflater.from(context).inflate(R.layout.dialog_bug_report, null)

                val emailEditText = layout.findViewById<EditText>(R.id.emailEditText)
                val reportTypeSpinner = layout.findViewById<Spinner>(R.id.reportTypeSpinner)
                val descriptionEditText = layout.findViewById<EditText>(R.id.descriptionEditText)
              
                val adapter = ArrayAdapter(context, android.R.layout.simple_spinner_item, reportTypes)
                adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
                reportTypeSpinner.adapter = adapter

                val dialog = AlertDialog.Builder(context)
                    .setTitle(R.string.bug_report_title)
                    .setView(layout)
                    .setPositiveButton(R.string.bug_report_submit) { _, _ ->
                        val email = emailEditText.text?.toString() ?: ""
                        val description = descriptionEditText.text?.toString() ?: ""
                        val reportType = reportTypes[reportTypeSpinner.selectedItemPosition]

                        if (email.isEmpty() || description.isEmpty()) {
                            Toast.makeText(context, "Please fill all fields", Toast.LENGTH_SHORT).show()
                            return@setPositiveButton
                        }

                        val title = if (description.length > 50) {
                            description.substring(0, 47) + "..."
                        } else {
                            description
                        }

                        onSubmit(title, reportType.split(" ")[0].lowercase())
                        Toast.makeText(context, "Bug report submitted", Toast.LENGTH_SHORT).show()
                    }
                    .setNegativeButton(R.string.bug_report_cancel, null)
                    .create()

                dialog.show()
                LoggingService.info("Bug report dialog shown")
            } catch (e: Exception) {
                LoggingService.error("Error showing bug report dialog: ${e.message}")
            }
        }
    }
}
