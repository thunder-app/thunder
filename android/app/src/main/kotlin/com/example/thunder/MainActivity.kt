package com.hjiangsu.thunder

import android.content.Intent
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import android.os.Bundle

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        java.lang.Thread.sleep(1000);
    }
    /**
 * When triggering an implicit deep link, the state of the back stack depends on whether the implicit Intent was launched with the Intent.FLAG_ACTIVITY_NEW_TASK flag:
 *
 * - If the flag is set, the task back stack is cleared and replaced with the deep link destination. As with explicit deep linking,
 * when nesting graphs, the start destination from each level of nesting—that is, the start destination from each element in the
 * hierarchy—is also added to the stack. This means that when a user presses the Back button from a deep link destination, they
 * navigate back up the navigation stack just as though they entered your app from its entry point.
 * - If the flag is not set, you remain on the task stack of the previous app where the implicit deep link was triggered. In this case,
 * the Back button takes you back to the previous app, while the Up button starts your app's task on the hierarchical parent destination within your navigation graph.
 *
 * TLDR: The app that launches your app can change this behavior.
 *
 * Source: https://developer.android.com/guide/navigation/navigation-deep-link#implicit
 */
    override fun onCreate(savedInstanceState: Bundle?) {
        if (intent.getIntExtra("org.chromium.chrome.extra.TASK_ID", -1) == this.taskId) {
            this.finish()
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(intent);
        }
        super.onCreate(savedInstanceState)
    }
}