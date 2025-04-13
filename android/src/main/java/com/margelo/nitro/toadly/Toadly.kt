package com.margelo.nitro.toadly
  
import com.facebook.proguard.annotations.DoNotStrip
import android.os.Handler
import android.os.Looper

@DoNotStrip
class Toadly : HybridToadlySpec() {
  private var hasSetupBeenCalled = false
  private var jsLogs: String = ""


  override fun setup(githubToken: String, repoOwner: String, repoName: String) {
    if (hasSetupBeenCalled) {
      return
    }
    hasSetupBeenCalled = true

    LoggingService.info("Setting up Toadly (GitHub integration skipped for now)")
    // GitHub integration will be implemented later
  }

  override fun addJSLogs(logs: String) {
    this.jsLogs = logs
    LoggingService.info("Received JavaScript logs")
  }

  override fun createIssueWithTitle(title: String, reportType: String?) {
    LoggingService.info("Creating issue with title: $title (GitHub integration skipped for now)")
    
    // GitHub integration will be implemented later
    // For now, just log the request
    Handler(Looper.getMainLooper()).post {
      LoggingService.info("Would create issue: $title, type: ${reportType ?: "bug"}")
    }
  }

  override fun show() {
    LoggingService.info("Show bug report dialog requested (not implemented yet)")
    // Bug report dialog will be implemented later
  }

  override fun crashNative() {
    LoggingService.warn("Crash native requested - this is for testing only")
    throw RuntimeException("Manually triggered crash from Toadly")
  }
}
