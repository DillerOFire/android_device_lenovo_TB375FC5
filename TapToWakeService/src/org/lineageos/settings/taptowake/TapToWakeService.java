/*
 * SPDX-FileCopyrightText: The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

package org.lineageos.settings.taptowake;

import android.app.Service;
import android.content.Intent;
import android.database.ContentObserver;
import android.os.Handler;
import android.os.IBinder;
import android.provider.Settings;
import android.util.Log;

import java.io.FileWriter;
import java.io.IOException;

public class TapToWakeService extends Service {

    private static final String TAG = "TapToWakeService";
    private static final String GESTURE_CONTROL_PATH = "/proc/gesture_control";
    private static final String VALUE_ENABLE = "enable";
    private static final String VALUE_DISABLE = "disable";

    private ContentObserver mObserver;

    @Override
    public void onCreate() {
        super.onCreate();
        Log.i(TAG, "Service starting");

        // Apply current setting once at boot.
        applyDoubleTapToWake();

        // Watch for future toggles from Settings UI.
        mObserver = new ContentObserver(new Handler()) {
            @Override
            public void onChange(boolean selfChange) {
                applyDoubleTapToWake();
            }
        };
        getContentResolver().registerContentObserver(
                Settings.Secure.getUriFor(Settings.Secure.DOUBLE_TAP_TO_WAKE),
                false,
                mObserver);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        // Re-sync on every start in case Settings changed before we attached.
        applyDoubleTapToWake();
        return START_STICKY;
    }

    @Override
    public void onDestroy() {
        if (mObserver != null) {
            getContentResolver().unregisterContentObserver(mObserver);
            mObserver = null;
        }
        super.onDestroy();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    private void applyDoubleTapToWake() {
        int value = Settings.Secure.getInt(getContentResolver(),
                Settings.Secure.DOUBLE_TAP_TO_WAKE, 0);
        String write = value == 1 ? VALUE_ENABLE : VALUE_DISABLE;
        try (FileWriter fw = new FileWriter(GESTURE_CONTROL_PATH)) {
            fw.write(write);
            Log.i(TAG, "Wrote '" + write + "' to " + GESTURE_CONTROL_PATH);
        } catch (IOException e) {
            Log.e(TAG, "Failed to write '" + write + "' to " + GESTURE_CONTROL_PATH, e);
        }
    }
}
