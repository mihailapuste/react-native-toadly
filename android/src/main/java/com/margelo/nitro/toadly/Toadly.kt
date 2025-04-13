package com.margelo.nitro.toadly

import com.facebook.proguard.annotations.DoNotStrip
import android.content.Context
import kotlin.collections.Map
import com.margelo.nitro.toadly.dialog.BugReportDialog

@DoNotStrip
class Toadly : HybridToadlySpec() {
    private var hasSetupBeenCalled = false
    private var jsLogs = mutableListOf<String>()
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
        this.jsLogs.add(logs)
        LoggingService.info("Received JavaScript logs")
    }

    override fun createIssueWithTitle(title: String, reportType: String?) {
        LoggingService.info("Creating issue with title: $title, type: ${reportType ?: "bug"}")
        // GitHub integration will be implemented later
    }

    override fun show() {
        LoggingService.info("Show bug report dialog requested")

        val currentActivity = getCurrentActivity()

        if (currentActivity == null) {
            LoggingService.error("Cannot show bug report dialog: no activity found")
            return
        }

        BugReportDialog(currentActivity) { title, reportType ->
            createIssueWithTitle(title, reportType)
        }.show()
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
