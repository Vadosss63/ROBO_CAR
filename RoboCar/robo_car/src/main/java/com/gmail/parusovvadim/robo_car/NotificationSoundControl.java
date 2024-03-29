package com.gmail.parusovvadim.robo_car;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Context;
import android.os.Build;
import android.support.v4.app.NotificationCompat;
import android.support.v4.content.ContextCompat;

class NotificationRunnableService {

    static final private String CHANEL_ID = "RoboCar";
    static final private String CHANEL_NAME = "RoboCar";
    static final private int NOTIFICATION_ID = 1991;

    NotificationRunnableService(Service service) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationManager notificationManager = (NotificationManager) service.getSystemService(Context.NOTIFICATION_SERVICE);
            int importance = NotificationManager.IMPORTANCE_HIGH;
            NotificationChannel notificationChannel = new NotificationChannel(CHANEL_ID, CHANEL_NAME, importance);
            notificationChannel.enableLights(false);
            notificationChannel.enableVibration(true);
            notificationChannel.setVibrationPattern(new long[]{0L});
            notificationChannel.setLockscreenVisibility(Notification.VISIBILITY_PUBLIC);

            if (notificationManager != null)
                notificationManager.createNotificationChannel(notificationChannel);
        }
    }

    void showNotification(Service service, String msg, String title) {
        service.startForeground(NOTIFICATION_ID, getNotification(service, msg, title));
    }

    private Notification getNotification(Service service, String msg, String title) {
        NotificationCompat.Builder builder = new NotificationCompat.Builder(service, CHANEL_ID);
        builder.setContentTitle(title)
                .setContentText(msg)
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setSmallIcon(R.mipmap.t_box)
                .setColor(ContextCompat.getColor(service, R.color.colorNotif))
                .setShowWhen(false)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setOnlyAlertOnce(true)
                .setAutoCancel(true);
        return builder.build();
    }

}