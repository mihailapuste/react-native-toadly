package com.margelo.nitro.toadly

import android.app.Activity
import android.content.Context
import com.facebook.react.bridge.UiThreadUtil
import com.facebook.proguard.annotations.DoNotStrip
import com.margelo.nitro.toadly.dialog.BugReportDialog
import com.margelo.nitro.toadly.github.GitHubService
import kotlin.collections.Map

@DoNotStrip
object Toadly : HybridToadlySpec() {
    private var hasSetupBeenCalled = false
    private val jsLogs = mutableListOf<String>()
    private var githubToken: String = ""
    private var repoOwner: String = ""
    private var repoName: String = ""
    private lateinit var githubService: GitHubService

    override fun setup(githubToken: String, repoOwner: String, repoName: String) {
        if (hasSetupBeenCalled) {
            return
        }
        hasSetupBeenCalled = true

        this.githubToken = githubToken
        this.repoOwner = repoOwner
        this.repoName = repoName
        this.githubService = GitHubService(githubToken, repoOwner, repoName)

        LoggingService.info("Setting up Toadly with GitHub integration")
    }

    override fun addJSLogs(logs: String) {
        this.jsLogs.add(logs)
        LoggingService.info("Received JavaScript logs")
    }

    override fun createIssueWithTitle(title: String, reportType: String?) {
        LoggingService.info("Creating issue with title: $title, type: ${reportType ?: "bug"}")
        
        val description = "User submitted bug report"
        val type = reportType ?: "bug"
        val email = "auto-generated@toadly.app"
        val jsLogsContent = jsLogs.joinToString("\n")
        val nativeLogs = LoggingService.getLogs()
        
        val currentActivity = getCurrentActivity()

        if (currentActivity == null) {
            LoggingService.error("Cannot create GitHub issue: no activity context found")
            return
        }
        
        Thread {
            try {
                val success = githubService.createIssue(
                    context = currentActivity,
                    title = title,
                    details = description,
                    email = email,
                    jsLogs = jsLogsContent,
                    nativeLogs = nativeLogs,
                    reportType = type
                )
                
                if (success) {
                    LoggingService.info("Successfully created GitHub issue")
                } else {
                    LoggingService.info("Failed to create GitHub issue")
                }
            } catch (e: Exception) {
                LoggingService.error("Error creating GitHub issue: ${e.message}")
            }
        }.start()
    }

    override fun show() {
        LoggingService.info("Show bug report dialog requested")

        val currentActivity = getCurrentActivity()

        if (currentActivity == null) {
            LoggingService.error("Cannot show bug report dialog: no activity found")
            return
        }

        BugReportDialog(currentActivity) { title, reportType, email ->
            createIssueWithEmailAndTitle(title, reportType, email)
        }.show()
    }

    private fun createIssueWithEmailAndTitle(title: String, reportType: String, email: String) {
        LoggingService.info("Creating issue with title: $title, type: $reportType, email: $email")
        
        val description = "User submitted bug report"
        val type = reportType
        val jsLogsContent = jsLogs.joinToString("\n")
        val nativeLogs = LoggingService.getLogs()
        
        val currentActivity = getCurrentActivity()

        if (currentActivity == null) {
            LoggingService.error("Cannot create GitHub issue: no activity context found")
            return
        }
        
        Thread {
            try {
                val success = githubService.createIssue(
                    context = currentActivity,
                    title = title,
                    details = description,
                    email = email,
                    jsLogs = jsLogsContent,
                    nativeLogs = nativeLogs,
                    reportType = type
                )
                
                if (success) {
                    LoggingService.info("Successfully created GitHub issue")
                } else {
                    LoggingService.info("Failed to create GitHub issue")
                }
            } catch (e: Exception) {
                LoggingService.error("Error creating GitHub issue: ${e.message}")
            }
        }.start()
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
