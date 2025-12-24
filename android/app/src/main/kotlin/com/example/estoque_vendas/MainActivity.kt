package com.example.estoque_vendas

import android.content.ContentValues
import android.os.Build
import android.provider.MediaStore
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.OutputStream

class MainActivity: FlutterActivity() {

  private val CHANNEL = "media_store_excel"

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(
      flutterEngine.dartExecutor.binaryMessenger,
      CHANNEL
    ).setMethodCallHandler { call, result ->

      if (call.method == "saveExcel") {
        val fileName = call.argument<String>("fileName")!!
        val bytes = call.argument<ByteArray>("bytes")!!

        try {
          saveToDownloads(fileName, bytes)
          result.success(true)
        } catch (e: Exception) {
          result.error("ERROR", e.message, null)
        }

      } else {
        result.notImplemented()
      }
    }
  }

  private fun saveToDownloads(fileName: String, bytes: ByteArray) {
    val resolver = contentResolver

    val contentValues = ContentValues().apply {
      put(MediaStore.Downloads.DISPLAY_NAME, fileName)
      put(
        MediaStore.Downloads.MIME_TYPE,
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      )

      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
        put(MediaStore.Downloads.IS_PENDING, 1)
      }
    }

    val uri = resolver.insert(
      MediaStore.Downloads.EXTERNAL_CONTENT_URI,
      contentValues
    ) ?: throw Exception("Erro ao criar arquivo")

    val outputStream: OutputStream =
      resolver.openOutputStream(uri)
        ?: throw Exception("Erro ao abrir OutputStream")

    outputStream.write(bytes)
    outputStream.close()

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
      contentValues.clear()
      contentValues.put(MediaStore.Downloads.IS_PENDING, 0)
      resolver.update(uri, contentValues, null, null)
    }
  }
}
