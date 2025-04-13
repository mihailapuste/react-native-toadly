package com.margelo.nitro.toadly

enum class ReportType(val displayName: String, val icon: String) {
    BUG("Bug", "🐞"),
    SUGGESTION("Suggestion", "💡"),
    QUESTION("Question", "❓"),
    CRASH("Crash", "🚨");

    val displayText: String
        get() = "$icon $displayName"

    companion object {
        fun getDefault(): ReportType = BUG
    }
}
