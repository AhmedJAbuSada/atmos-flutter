package dev.ahmedabusada.atmos.flutter

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * The Android side of the app's small system channel (ADR-0017): open a web page, and open the
 * app's language page (Android 13+), or the app's settings page on older versions.
 */
class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openUrl" -> result.success(openUrl(call.arguments as? String))
                "openLanguageSettings" -> result.success(openLanguageSettings())
                else -> result.notImplemented()
            }
        }
    }

    /** Web pages only: the channel never opens another app's deep link. */
    private fun openUrl(url: String?): Boolean {
        val uri = url?.let(Uri::parse) ?: return false
        return uri.scheme == "https" && start(Intent(Intent.ACTION_VIEW, uri))
    }

    private fun openLanguageSettings(): Boolean {
        val app = Uri.fromParts("package", packageName, null)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            start(Intent(Settings.ACTION_APP_LOCALE_SETTINGS, app))
        ) {
            return true
        }
        return start(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, app))
    }

    private fun start(intent: Intent): Boolean =
        try {
            startActivity(intent)
            true
        } catch (_: ActivityNotFoundException) {
            false
        }

    private companion object {
        const val CHANNEL = "dev.ahmedabusada.atmos/system"
    }
}
