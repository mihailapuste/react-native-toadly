package com.margelo.nitro.toadly.dialog

import android.app.AlertDialog
import android.content.Context
import android.view.LayoutInflater
import android.widget.EditText
import android.widget.Spinner
import android.widget.ArrayAdapter
import android.widget.Toast
import android.widget.ImageButton
import android.os.Handler
import android.os.Looper
import androidx.appcompat.widget.AppCompatSpinner
import com.margelo.nitro.toadly.LoggingService
import com.margelo.nitro.toadly.R

class BugReportDialog(private val context: Context, private val onSubmit: (String, String, String) -> Unit) {

    private val reportTypesMap = mapOf(
        "🐞 Bug" to "bug",
        "💡 Suggestion" to "suggestion",
        "❓ Question" to "question"
    )
    

    private val reportTypeDisplays = reportTypesMap.keys.toTypedArray()

    fun show() {
        Handler(Looper.getMainLooper()).post {
            try {
                val dialog = AlertDialog.Builder(context, R.style.CustomDialog)
                    .create()

                val layout = LayoutInflater.from(context).inflate(R.layout.dialog_bug_report, null)

                val emailEditText = layout.findViewById<EditText>(R.id.emailEditText)
                val reportTypeSpinner = layout.findViewById<AppCompatSpinner>(R.id.reportTypeSpinner)
                val descriptionEditText = layout.findViewById<EditText>(R.id.descriptionEditText)
                val closeButton = layout.findViewById<ImageButton>(R.id.closeButton)
                val sendButton = layout.findViewById<ImageButton>(R.id.sendButton)
              
                // Set up the spinner with report types
                val adapter = ArrayAdapter(context, android.R.layout.simple_spinner_item, reportTypeDisplays)
                adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
                reportTypeSpinner.adapter = adapter

                closeButton.setOnClickListener {
                    dialog.dismiss()
                }

                sendButton.setOnClickListener {
                    val email = emailEditText.text?.toString() ?: ""
                    val description = descriptionEditText.text?.toString() ?: ""
                    val selectedTypeDisplay = reportTypeSpinner.selectedItem.toString()
                    val typeLabel = reportTypesMap[selectedTypeDisplay] ?: "bug" // Get GitHub label without emoji

                    if (email.isEmpty() || description.isEmpty()) {
                        Toast.makeText(context, "Please fill all fields", Toast.LENGTH_SHORT).show()
                        return@setOnClickListener
                    }

                    val title = if (description.length > 50) {
                        description.substring(0, 47) + "..."
                    } else {
                        description
                    }

                    onSubmit(title, typeLabel, email)
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
