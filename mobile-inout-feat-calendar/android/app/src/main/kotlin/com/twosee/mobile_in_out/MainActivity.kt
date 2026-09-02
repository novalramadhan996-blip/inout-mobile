package com.twosee.mobile_in_out

import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "app_usage_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "openUsageSettings" -> {
                    startActivity(
                        Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
                    )
                    result.success(null)
                }

                "hasUsagePermission" -> {
                    result.success(hasUsagePermission())
                }

                "getLastUsedApps" ->
                    result.success(getLastUsedApps())

                "getMostUsedApps" ->
                    result.success(getMostUsedApps())

                else -> result.notImplemented()
            }
        }
    }

    private fun hasUsagePermission(): Boolean {
        val usm =
            getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val end = System.currentTimeMillis()
        val start = end - 1000L * 60 * 1000

        val stats = usm.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            start,
            end
        )

        return stats.isNotEmpty()
    }

    private fun getLastUsedApps(): List<Map<String, Any>> {
        val usm =
            getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

        val end = System.currentTimeMillis()
        val start = end - 1000L * 60 * 60 * 24 * 7

        val result = mutableListOf<Map<String, Any>>()
        val addedPackages = mutableSetOf<String>()

        usm.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            start,
            end
        )
            .filter { it.lastTimeUsed > 0 }
            .sortedByDescending { it.lastTimeUsed }
            .forEach { usage ->
                if (addedPackages.contains(usage.packageName)) return@forEach

                val appInfo = getAppInfo(usage.packageName) ?: return@forEach

                result.add(
                    appInfo + mapOf(
                        "lastTimeUsed" to usage.lastTimeUsed,
                        "totalTime" to usage.totalTimeInForeground
                    )
                )

                addedPackages.add(usage.packageName)

                if (result.size == 10) return@forEach
            }

        return result
    }


    private fun getMostUsedApps(): List<Map<String, Any>> {
        val usm =
            getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

        val end = System.currentTimeMillis()
        val start = end - 1000L * 60 * 60 * 24 * 7

        val result = mutableListOf<Map<String, Any>>()
        val addedPackages = mutableSetOf<String>()

        usm.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            start,
            end
        )
            .filter { it.totalTimeInForeground > 0 }
            .sortedByDescending { it.totalTimeInForeground }
            .forEach { usage ->
                if (addedPackages.contains(usage.packageName)) return@forEach

                val appInfo = getAppInfo(usage.packageName) ?: return@forEach

                result.add(
                    appInfo + mapOf(
                        "lastTimeUsed" to usage.lastTimeUsed,
                        "totalTime" to usage.totalTimeInForeground
                    )
                )

                addedPackages.add(usage.packageName)

                if (result.size == 10) return@forEach
            }

        return result
    }

    private fun getAppInfo(packageName: String): Map<String, Any>? {
        return try {
            val pm = packageManager
            val packageInfo = pm.getPackageInfo(packageName, 0)
            val appInfo = packageInfo.applicationInfo ?: return null

            mapOf(
                "app_name" to pm.getApplicationLabel(appInfo).toString(),
                "package_name" to packageName,
                "version_name" to (packageInfo.versionName ?: ""),
                "version_code" to packageInfo.longVersionCode,
                "installed_at" to packageInfo.firstInstallTime,
                "updated_at" to packageInfo.lastUpdateTime
            )
        } catch (e: Exception) {
            null
        }
    }

}
