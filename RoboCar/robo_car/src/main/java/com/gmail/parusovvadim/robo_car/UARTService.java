package com.gmail.parusovvadim.robo_car;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.util.Log;

import java.util.ArrayDeque;

public class UARTService extends Service
{
    public static final int CMD_SEND_DATA = 0xAA;
    public static final int CMD_RESET = 0x00;
    // Поток отправки сообщений в port
    private SenderThread m_senderThread;
    // класс подключения для COM
    private DataPort m_UARTPort = null;
    private volatile boolean m_isStartThread = true;

    @Override
    public void onCreate()
    {
        super.onCreate();
        createUART();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId)
    {
        if(m_UARTPort.isConfigured() && m_UARTPort.isConnected())
        {
            m_senderThread.AddCMD(intent);
            showNotification("Соединено с T-BOX data", "Статус Bluetooth");
        }
        else
        {
            stopSelf();
            Log.d("BluetoothReceiver", "UART stop");

        }
        return super.onStartCommand(intent, flags, startId);
    }

    @Override
    public void onDestroy()
    {
        super.onDestroy();
        m_isStartThread = false;
        try
        {
            if(m_senderThread != null)
                if(m_senderThread.isAlive()) m_senderThread.interrupt(); // завершам поток
        } catch(RuntimeException e)
        {
            e.fillInStackTrace();
        }

        m_senderThread = null;
        Log.d("UARTService", "onDestroy: ");
        try
        {
            m_UARTPort.disconnect();
        } catch(RuntimeException e)
        {
            e.fillInStackTrace();
        }
    }

    @Override
    public IBinder onBind(Intent intent)
    {
        return null;
    }

    private void showNotification(String msg, String title)
    {
        NotificationRunnableService notification = new NotificationRunnableService(this);
        notification.showNotification(this, msg, title);
    }

      // Создание соединения
    private void createUART()
    {
        setPort();
        createUARTPort();
    }

    // Выбор типа соединения
    private void setPort()
    {
        m_UARTPort = new BluetoothPort();
    }

    private void parser(Intent intent)
    {
        if(intent == null) return;

        if(!m_UARTPort.isConnected()) return;

        int cmd = intent.getIntExtra("CMD", 0);
        switch(cmd)
        {
            case CMD_SEND_DATA:
                sendDataByte(intent);
                break;

            case CMD_RESET:
                stopSelf();
                break;
            default:
                break;
        }
    }

    // Отправка произвольных данных
    private void sendDataByte(Intent intent)
    {
        if(intent == null) return;
        byte[] data = intent.getByteArrayExtra("Data");
        m_UARTPort.writeData(data);
    }

    private void createUARTPort()
    {
        String msg;
        if(m_UARTPort.initialisation(this))
        {
            m_UARTPort.connect();

            if(m_UARTPort.isConnected())
            {
                m_UARTPort.setReadRunnable(this::readCommand);
                // Запускаем прослушку команд управления
                m_UARTPort.runReadData();

                msg = m_UARTPort.getTextLog();
                // запускаем поток отправки
                m_isStartThread = true;
                m_senderThread = new SenderThread();
                m_senderThread.start();

            } else
            {
                msg = "Нет соединения";
            }
        } else
        {
            msg = "Error";
        }
        showNotification(msg, "Статус Bluetooth");
    }

    // Обработка пришедших команд с порта
    private void readCommand()
    {
        byte[] data = m_UARTPort.getReadDataByte();

        if(data.length == 1)
        {
            m_senderThread.SetAnswer(data[0]);
            return;
        }
    }


    private class SenderThread extends Thread
    {
        class ErrorSender
        {
            Byte m_answer = -1;
        }

        // Класс синхронизации задач между потоками
        private class PoolTaskCMD
        {
            // лист команд на выполнения
            private final ArrayDeque<Intent> m_listCMD = new ArrayDeque<>();

            // Добавление задачи в пул и оповещаем другой поток о наличии данных
            private synchronized void addCMD(Intent intent)
            {
                m_listCMD.addLast(intent);
                notify();
            }

            // Получение задачи из пула задач
            private synchronized Intent getCMD() throws InterruptedException
            {

                while(m_listCMD.isEmpty()) // если очередь пуста блокируем поток пока не поступят новые данные
                    wait();

                Intent cmd = m_listCMD.getFirst();
                m_listCMD.pollFirst();

                return cmd;
            }
        }

        // лист команд на выполнения
        private final PoolTaskCMD m_poolTaskCMD = new PoolTaskCMD();

        // статус ответа
        final ErrorSender m_errorSender = new ErrorSender();


        SenderThread()
        {
        }

        @Override
        public void run()
        {
            try
            {
                while(m_isStartThread) Execute();
            } catch(InterruptedException e)
            {
                Log.d("ThreadPool", "Error");
                m_isStartThread = false;
            }
        }

        private void Execute() throws InterruptedException
        {
            parser(GetCMD()); // получаем команду и распознаем ее
            GetAnswer(); // проверяем ответ
        }

        private void SetAnswer(byte answer)
        {
            synchronized(m_errorSender)
            {
                m_errorSender.m_answer = answer;
                m_errorSender.notify();
            }
        }

        // блокирует поток на 5 секунд
        private byte GetAnswer() throws InterruptedException
        {
            byte answer;
            synchronized(m_errorSender)
            {
                if(m_errorSender.m_answer == -1) m_errorSender.wait(5000);
                answer = m_errorSender.m_answer;
                m_errorSender.m_answer = (byte) -1; // Выполняем сброс ответа
            }
            return answer;
        }

        // Добавление задачи в пул
        private void AddCMD(Intent intent)
        {
            m_poolTaskCMD.addCMD(intent);
        }

        // Получение задачи из пула задач метод является блокирующим
        private Intent GetCMD() throws InterruptedException
        {
            return m_poolTaskCMD.getCMD();
        }

    }

}