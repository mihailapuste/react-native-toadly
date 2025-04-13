package com.margelo.nitro.toadly

import android.util.Log
import android.R
import java.text.SimpleDateFormat
import java.util.*

/**
 * LoggingService manages log collection and provides logging utilities
 */
object LoggingService {
    private const val TAG = "Toadly"
    private const val MAX_LOGS = 50
    private val logs = mutableListOf<String>()
    private val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS", Locale.US).apply {
        timeZone = TimeZone.getTimeZone("UTC")
    }

    /**
     * Log a message with the specified level
     */
    private fun log(message: String, level: String = "INFO") {
        val timestamp = dateFormat.format(Date())
        val logEntry = "[$timestamp] [$level] $message"
        
        synchronized(logs) {
            logs.add(logEntry)
            
            if (logs.size > MAX_LOGS) {
                logs.removeAt(0)
            }
        }
        
        when (level) {
            "INFO" -> Log.i(TAG, message)
            "WARN" -> Log.w(TAG, message)
            "ERROR" -> Log.e(TAG, message)
            else -> Log.d(TAG, message)
        }
    }
    
    /**
     * Log an info message
     */
    fun info(message: String) {
        log(message, "INFO")
    }
    
    /**
     * Log a warning message
     */
    fun warn(message: String) {
        log(message, "WARN")
    }
    
    /**
     * Log an error message
     */
    fun error(message: String) {
        log(message, "ERROR")
    }
    
    /**
     * Get all recent logs as a single string
     */
    fun getRecentLogs(): String {
        synchronized(logs) {
            return logs.joinToString("\n")
        }
    }
    
    /**
     * Clear all stored logs
     */
    fun clearLogs() {
        synchronized(logs) {
            logs.clear()
        }
    }
}
