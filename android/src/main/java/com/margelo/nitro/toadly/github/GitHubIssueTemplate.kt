package com.margelo.nitro.toadly.github

import android.os.Build
import android.content.Context
import android.content.pm.PackageManager
import android.os.Environment
import android.os.StatFs
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class GitHubIssueTemplate {
    companion object {
        fun generateIssueBody(
            context: Context,
            email: String,
            details: String,
            jsLogs: String,
            nativeLogs: String,
            reportType: String? = null
        ): String {
            val packageInfo = try {
                context.packageManager.getPackageInfo(context.packageName, 0)
            } catch (e: PackageManager.NameNotFoundException) {
                null
            }
            
            val appVersion = packageInfo?.versionName ?: "Unknown"
            val buildNumber = packageInfo?.versionCode?.toString() ?: "Unknown"
            val deviceModel = Build.MODEL
            val systemName = "Android"
            val systemVersion = Build.VERSION.RELEASE
            val deviceName = Build.DEVICE
            val deviceIdentifier = Build.FINGERPRINT
            
            val timestamp = Date()
            val dateFormatter = SimpleDateFormat("MMM dd, yyyy HH:mm:ss", Locale.US)
            val dateString = dateFormatter.format(timestamp)
            
            // Get memory information
            val memoryInfo = android.app.ActivityManager.MemoryInfo()
            val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as android.app.ActivityManager
            activityManager.getMemoryInfo(memoryInfo)
            val totalMemory = formatSize(memoryInfo.totalMem)
            
            // Get screen information
            val displayMetrics = context.resources.displayMetrics
            val screenWidth = displayMetrics.widthPixels
            val screenHeight = displayMetrics.heightPixels
            val screenDensity = displayMetrics.density
            
            // Get locale information
            val locale = Locale.getDefault()
            val language = locale.language
            val region = locale.country
            
            // Get disk space information
            val freeSpace = getFreeSpaceInBytes()
            val totalSpace = getTotalSpaceInBytes()
            val freeSpaceString = formatSize(freeSpace)
            val totalSpaceString = formatSize(totalSpace)
            
            // Get report type information
            val reportTypeText = reportType ?: "Bug"
            val reportTypeIcon = getIconForReportType(reportType)
            
            var issueBody = """
### Description
$details

### Report Information
| Property | Value |
| ----- | ----- |
| Report Type | $reportTypeIcon $reportTypeText |
| Email | $email |
| Timestamp | $dateString |

### Device & App Information
| Property | Value |
| ----- | ----- |
| App Version | $appVersion ($buildNumber) |
| Device Model | $deviceModel |
| Device Name | $deviceName |
| OS | $systemName $systemVersion |
| Device ID | $deviceIdentifier |
| Memory | $totalMemory |
| Free Disk Space | $freeSpaceString / $totalSpaceString |
| Screen | ${screenWidth}x${screenHeight} @${screenDensity}x |
| Language | ${language}_${region} |
"""
            
            issueBody += """

### Logs

#### JavaScript Logs
```
$jsLogs
```

#### Native Logs
```
$nativeLogs
```
"""
            
            return issueBody
        }
        
        private fun getIconForReportType(reportType: String?): String {
            if (reportType == null) return "🐛"
            
            return when (reportType.lowercase()) {
                "bug" -> "🐛"
                "enhancement" -> "💡"
                "question" -> "❓"
                else -> "🐛"
            }
        }
        
        private fun formatSize(size: Long): String {
            val kb = 1024L
            val mb = kb * 1024
            val gb = mb * 1024
            
            return when {
                size >= gb -> String.format("%.2f GB", size.toFloat() / gb)
                size >= mb -> String.format("%.2f MB", size.toFloat() / mb)
                size >= kb -> String.format("%.2f KB", size.toFloat() / kb)
                else -> "$size bytes"
            }
        }
        
        private fun getFreeSpaceInBytes(): Long {
            try {
                val stat = StatFs(Environment.getExternalStorageDirectory().path)
                return stat.availableBlocksLong * stat.blockSizeLong
            } catch (e: Exception) {
                return 0
            }
        }
        
        private fun getTotalSpaceInBytes(): Long {
            try {
                val stat = StatFs(Environment.getExternalStorageDirectory().path)
                return stat.blockCountLong * stat.blockSizeLong
            } catch (e: Exception) {
                return 0
            }
        }
    }
}