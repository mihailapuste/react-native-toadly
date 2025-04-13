package com.margelo.nitro.toadly.github

import android.content.Context
import com.margelo.nitro.toadly.LoggingService
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import org.json.JSONArray
import java.io.IOException
import java.util.Date

class GitHubService(
    private val token: String,
    private val repoOwner: String,
    private val repoName: String
) {
    private val client = OkHttpClient()
    private val baseUrl = "https://api.github.com"
    private val jsonMediaType = "application/json; charset=utf-8".toMediaType()
    
    private val labelMap = mapOf(
        "🐞 Bug" to "bug",
        "💡 Suggestion" to "enhancement",
        "❓ Question" to "question"
    )

    fun createIssue(
        context: Context,
        title: String, 
        details: String, 
        jsLogs: String,
        nativeLogs: String,
        reportType: String
    ): Boolean {
        val url = "$baseUrl/repos/$repoOwner/$repoName/issues"
        
        val issueBody = GitHubIssueTemplate.generateIssueBody(
            context = context,
            email = "auto-generated@toadly.app", // TODO: Update with other
            details = details,
            jsLogs = jsLogs,
            nativeLogs = nativeLogs,
            reportType = reportType
        )
        
        val label = labelMap[reportType] ?: "bug" // Default to "bug" if type not found in map
        val labels = JSONArray().apply {
            put(label)
        }
        
        val jsonBody = JSONObject().apply {
            put("title", title)
            put("body", issueBody)
            put("labels", labels)
        }

        val request = Request.Builder()
            .url(url)
            .addHeader("Authorization", "token $token")
            .addHeader("Accept", "application/vnd.github.v3+json")
            .post(jsonBody.toString().toRequestBody(jsonMediaType))
            .build()

        return try {
            val response = client.newCall(request).execute()
            val success = response.isSuccessful
            if (success) {
                LoggingService.info("Successfully created GitHub issue: $title")
            } else {
                val responseBody = response.body?.string() ?: ""
                LoggingService.info("Failed to create GitHub issue. Status: ${response.code}. Body: $responseBody")
                response.body?.close()
            }
            response.body?.close()
            success
        } catch (e: IOException) {
            LoggingService.info("Error creating GitHub issue: ${e.message}")
            false
        }
    }
}
