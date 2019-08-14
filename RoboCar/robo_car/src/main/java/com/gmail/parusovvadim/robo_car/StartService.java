package com.gmail.parusovvadim.robo_car;

import android.content.Context;
import android.content.Intent;
import android.os.Build;


class StartService
{
    //Выполняет корректный запуск фонвых процессов
    static void start(Context context, Intent intent)
    {
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
            context.startForegroundService(intent);
        else
            context.startService(intent);
    }

}
