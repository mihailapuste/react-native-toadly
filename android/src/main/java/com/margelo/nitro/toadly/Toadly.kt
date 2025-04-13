package com.margelo.nitro.toadly

import com.facebook.proguard.annotations.DoNotStrip
import android.os.Handler
import android.os.Looper
import android.app.AlertDialog
import android.content.Context
import android.view.LayoutInflater
import android.widget.EditText
import android.widget.Spinner
import android.widget.ArrayAdapter
import android.widget.Toast
import kotlin.collections.Map

@DoNotStrip
class Toadly : HybridToadlySpec() {
    private var hasSetupBeenCalled = false
    private var jsLogs = ""
    private var githubToken = ""
    private var repoOwner = ""
    private var repoName = ""

    override fun setup(githubToken: String, repoOwner: String, repoName: String) {
        if (hasSetupBeenCalled) {
            return
        }
        hasSetupBeenCalled = true
        
        this.githubToken = githubToken
        this.repoOwner = repoOwner
        this.repoName = repoName
        
        LoggingService.info("Setting up Toadly with GitHub integration")
    }

    override fun addJSLogs(logs: String) {
        this.jsLogs = logs
        LoggingService.info("Received JavaScript logs")
    }

    override fun createIssueWithTitle(title: String, reportType: String?) {
        LoggingService.info("Creating issue with title: $title, type: ${reportType ?: "bug"}")
        // GitHub integration will be implemented later
    }

    override fun show() {
        LoggingService.info("Show bug report dialog requested")
        
        // Get the current activity
        val currentActivity = getCurrentActivity()
        if (currentActivity == null) {
            LoggingService.error("Cannot show bug report dialog: no activity found")
            return
        }
        
        // Show the bug report dialog on the UI thread
        Handler(Looper.getMainLooper()).post {
            try {
                // Create a simple dialog with EditText fields
                val layout = LayoutInflater.from(currentActivity).inflate(R.layout.dialog_bug_report, null)
                
                // Get references to the views
                val emailEditText = layout.findViewById<EditText>(R.id.emailEditText)
                val reportTypeSpinner = layout.findViewById<Spinner>(R.id.reportTypeSpinner)
                val descriptionEditText = layout.findViewById<EditText>(R.id.descriptionEditText)
                
                // Set up the report type spinner
                val reportTypes = arrayOf("Bug 🐞", "Suggestion 💡", "Question ❓", "Crash 🚨")
                val adapter = ArrayAdapter(currentActivity, android.R.layout.simple_spinner_item, reportTypes)
                adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
                reportTypeSpinner.adapter = adapter
                
                // Create and show the dialog
                val dialog = AlertDialog.Builder(currentActivity)
                    .setTitle(R.string.bug_report_title)
                    .setView(layout)
                    .setPositiveButton(R.string.bug_report_submit) { _, _ ->
                        val email = emailEditText.text?.toString() ?: ""
                        val description = descriptionEditText.text?.toString() ?: ""
                        val reportType = reportTypes[reportTypeSpinner.selectedItemPosition]
                        
                        if (email.isEmpty() || description.isEmpty()) {
                            Toast.makeText(currentActivity, "Please fill all fields", Toast.LENGTH_SHORT).show()
                            return@setPositiveButton
                        }
                        
                        // Generate a title from the description
                        val title = if (description.length > 50) {
                            description.substring(0, 47) + "..."
                        } else {
                            description
                        }
                        
                        // Submit the issue
                        createIssueWithTitle(title, reportType.split(" ")[0].lowercase())
                        Toast.makeText(currentActivity, "Bug report submitted", Toast.LENGTH_SHORT).show()
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

    override fun crashNative() {
        LoggingService.warn("Crash native requested - this is for testing only")
        throw RuntimeException("Manually triggered crash from Toadly")
    }
    
    // Helper method to get the current activity
    private fun getCurrentActivity(): Context? {
        try {
            val activityThreadClass = Class.forName("android.app.ActivityThread")
            val activityThread = activityThreadClass.getMethod("currentActivityThread").invoke(null)
            val activityField = activityThreadClass.getDeclaredField("mActivities")
            activityField.isAccessible = true
            
            @Suppress("UNCHECKED_CAST")
            val activities = activityField.get(activityThread) as? Map<Any, Any>
            if (activities == null) {
                return null
            }
            
            activities.values.forEach { activityRecord ->
                activityRecord?.let { record ->
                    val activityRecordClass = record::class.java
                    val pausedField = activityRecordClass.getDeclaredField("paused")
                    pausedField.isAccessible = true
                    if (!pausedField.getBoolean(record)) {
                        val activityField = activityRecordClass.getDeclaredField("activity")
                        activityField.isAccessible = true
                        val activity = activityField.get(record)
                        if (activity is Context) {
                            return activity
                        }
                    }
                }
            }
            
            return null
        } catch (e: Exception) {
            LoggingService.error("Error getting current activity: ${e.message}")
            return null
        }
    }
}
