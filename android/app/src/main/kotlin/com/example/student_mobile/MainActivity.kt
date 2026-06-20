package com.example.student_mobile

import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
import android.media.MediaMuxer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.nio.ByteBuffer
import kotlin.concurrent.thread
import kotlin.math.max

class MainActivity : FlutterActivity() {
    private val audioExtractorChannel = "readbloom/audio_extractor"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            audioExtractorChannel,
        ).setMethodCallHandler { call, result ->
            if (call.method != "extractAudio") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            val videoPath = call.argument<String>("videoPath")
            val outputPath = call.argument<String>("outputPath")
            if (videoPath.isNullOrBlank() || outputPath.isNullOrBlank()) {
                result.error("invalid_arguments", "Video and output paths are required.", null)
                return@setMethodCallHandler
            }

            thread(name = "readbloom-audio-extractor") {
                try {
                    extractAudioTrack(videoPath, outputPath)
                    runOnUiThread { result.success(outputPath) }
                } catch (error: Exception) {
                    File(outputPath).delete()
                    runOnUiThread {
                        result.error("audio_extraction_failed", error.message, null)
                    }
                }
            }
        }
    }

    private fun extractAudioTrack(videoPath: String, outputPath: String) {
        val inputFile = File(videoPath)
        require(inputFile.exists()) { "Recorded video does not exist." }

        val outputFile = File(outputPath)
        outputFile.delete()

        val extractor = MediaExtractor()
        var muxer: MediaMuxer? = null
        var muxerStarted = false
        try {
            extractor.setDataSource(videoPath)
            val audioTrackIndex = (0 until extractor.trackCount).firstOrNull { index ->
                extractor.getTrackFormat(index)
                    .getString(MediaFormat.KEY_MIME)
                    ?.startsWith("audio/") == true
            } ?: error("The recorded video does not contain an audio track.")

            val audioFormat = extractor.getTrackFormat(audioTrackIndex)
            extractor.selectTrack(audioTrackIndex)

            val mediaMuxer = MediaMuxer(
                outputPath,
                MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4,
            )
            muxer = mediaMuxer
            val outputTrackIndex = mediaMuxer.addTrack(audioFormat)
            mediaMuxer.start()
            muxerStarted = true

            val bufferSize = if (audioFormat.containsKey(MediaFormat.KEY_MAX_INPUT_SIZE)) {
                max(audioFormat.getInteger(MediaFormat.KEY_MAX_INPUT_SIZE), 64 * 1024)
            } else {
                1024 * 1024
            }
            val buffer = ByteBuffer.allocateDirect(bufferSize)
            val bufferInfo = MediaCodec.BufferInfo()

            while (true) {
                buffer.clear()
                val sampleSize = extractor.readSampleData(buffer, 0)
                if (sampleSize < 0) break

                bufferInfo.offset = 0
                bufferInfo.size = sampleSize
                bufferInfo.presentationTimeUs = extractor.sampleTime
                bufferInfo.flags = extractor.sampleFlags
                mediaMuxer.writeSampleData(outputTrackIndex, buffer, bufferInfo)
                extractor.advance()
            }
        } finally {
            extractor.release()
            try {
                if (muxerStarted) muxer?.stop()
            } finally {
                muxer?.release()
            }
        }
    }
}
