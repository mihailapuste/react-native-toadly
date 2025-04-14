import UIKit
import ImageIO
import UniformTypeIdentifiers
import MobileCoreServices

class SessionReplayService {
    // Singleton instance
    static let shared = SessionReplayService()
    
    // Configuration
    private let captureInterval: TimeInterval = 1.0  // Capture every 1 second
    private let maxFrameCount = 15  // Keep last 15 frames
    private let imageQuality: CGFloat = 0.5  // Lower quality to save memory
    private let imageScale: CGFloat = 0.5  // Scale down images to 50%
    
    // State
    private var isRecording = false
    private var captureTimer: Timer?
    private var frameBuffer: [UIImage] = []
    private var lastCaptureTime: Date?
    
    // Initialize as private to enforce singleton
    private init() {}
    
    // Start recording session
    func startRecording() {
        guard !isRecording else { return }
        
        LoggingService.info("Starting session replay recording")
        isRecording = true
        frameBuffer.removeAll()
        
        // Schedule timer to capture screenshots
        captureTimer = Timer.scheduledTimer(withTimeInterval: captureInterval, repeats: true) { [weak self] _ in
            self?.captureScreenshot()
        }
        
        // Make sure timer runs even when scrolling
        if let timer = captureTimer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    // Stop recording session
    func stopRecording() {
        guard isRecording else { return }
        
        LoggingService.info("Stopping session replay recording")
        captureTimer?.invalidate()
        captureTimer = nil
        isRecording = false
    }
    
    // Capture a single screenshot and add to buffer
    private func captureScreenshot() {
        guard isRecording else { return }
        
        // Throttle captures to avoid performance issues
        let now = Date()
        if let lastCapture = lastCaptureTime, now.timeIntervalSince(lastCapture) < captureInterval * 0.9 {
            return
        }
        lastCaptureTime = now
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Get key window
            guard let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? UIApplication.shared.windows.first else {
                return
            }
            
            // Create screenshot at reduced size and quality
            let format = UIGraphicsImageRendererFormat()
            format.scale = self.imageScale
            format.opaque = false
            
            let size = CGSize(
                width: keyWindow.bounds.width * self.imageScale,
                height: keyWindow.bounds.height * self.imageScale
            )
            
            let renderer = UIGraphicsImageRenderer(size: size, format: format)
            let screenshot = renderer.image { context in
                keyWindow.drawHierarchy(in: CGRect(origin: .zero, size: size), afterScreenUpdates: false)
            }
            
            // Add to buffer and maintain max size
            self.frameBuffer.append(screenshot)
            if self.frameBuffer.count > self.maxFrameCount {
                self.frameBuffer.removeFirst()
            }
        }
    }
    
    // Create a GIF from the buffered frames
    func createReplayGif() -> Data? {
        guard !frameBuffer.isEmpty else {
            LoggingService.info("No frames available to create replay GIF")
            return nil
        }
        
        LoggingService.info("Creating replay GIF from \(frameBuffer.count) frames")
        
        let gifData = createAnimatedGIF(from: frameBuffer, duration: Double(frameBuffer.count) * captureInterval, loopCount: 1)
        
        if gifData == nil {
            LoggingService.error("Failed to create replay GIF")
        } else {
            LoggingService.info("Successfully created replay GIF (\(gifData?.count ?? 0) bytes)")
        }
        
        return gifData
    }
    
    // Helper method to create animated GIF
    private func createAnimatedGIF(from images: [UIImage], duration: TimeInterval, loopCount: Int) -> Data? {
        let frameProperties = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFDelayTime as String: duration / Double(images.count)
            ]
        ]
        
        let gifProperties = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFLoopCount as String: loopCount
            ]
        ]
        
        let data = NSMutableData()
        
        guard let destination = CGImageDestinationCreateWithData(data as CFMutableData, kUTTypeGIF, images.count, nil) else {
            return nil
        }
        
        CGImageDestinationSetProperties(destination, gifProperties as CFDictionary)
        
        for image in images {
            guard let cgImage = image.cgImage else { continue }
            CGImageDestinationAddImage(destination, cgImage, frameProperties as CFDictionary)
        }
        
        guard CGImageDestinationFinalize(destination) else {
            return nil
        }
        
        return data as Data
    }
    
    // Reset the service
    func reset() {
        stopRecording()
        frameBuffer.removeAll()
    }
}
