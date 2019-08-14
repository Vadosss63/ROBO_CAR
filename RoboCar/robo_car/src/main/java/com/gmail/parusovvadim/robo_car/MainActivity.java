package com.gmail.parusovvadim.robo_car;

import android.annotation.SuppressLint;
import android.content.ComponentName;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.v7.app.AppCompatActivity;
import android.view.MotionEvent;
import android.widget.ImageView;

import com.gmail.parusovvadim.encoder_uart.CMD_DATA;
import com.gmail.parusovvadim.encoder_uart.EncoderMainHeader;
import com.gmail.parusovvadim.encoder_uart.EncoderTrack;

public class MainActivity extends AppCompatActivity
{
    enum MoveCMD
    {
        forward, back, left, right
    }

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        createActions();
    }

    @Override
    protected void onDestroy()
    {
        super.onDestroy();
    }

    @SuppressLint ("ClickableViewAccessibility")
    private void createActions()
    {
        ImageView upMove = findViewById(R.id.upMove);
        upMove.setOnTouchListener((v, event)->{

            switch(event.getAction())
            {
                case MotionEvent.ACTION_DOWN: // нажатие
                    sendMove(MoveCMD.forward);
                    break;
                case MotionEvent.ACTION_MOVE: // движение

                    break;
                case MotionEvent.ACTION_UP: // отпускание
                case MotionEvent.ACTION_CANCEL:
                    sendStop();
                    break;
            }
            return true;
        });

        ImageView backMove = findViewById(R.id.backMove);
        backMove.setOnTouchListener((v, event)->{

            switch(event.getAction())
            {
                case MotionEvent.ACTION_DOWN: // нажатие
                    sendMove(MoveCMD.back);
                    break;
                case MotionEvent.ACTION_MOVE: // движение

                    break;
                case MotionEvent.ACTION_UP: // отпускание
                case MotionEvent.ACTION_CANCEL:
                    sendStop();
                    break;
            }
            return true;
        });

        ImageView leftMove = findViewById(R.id.leftMove);
        leftMove.setOnTouchListener((v, event)->{

            switch(event.getAction())
            {
                case MotionEvent.ACTION_DOWN: // нажатие
                    sendMove(MoveCMD.left);
                    break;
                case MotionEvent.ACTION_MOVE: // движение

                    break;
                case MotionEvent.ACTION_UP: // отпускание
                case MotionEvent.ACTION_CANCEL:
                    sendStop();
                    break;
            }
            return true;
        });

        ImageView rightMove = findViewById(R.id.rightMove);
        rightMove.setOnTouchListener((v, event)->{

            switch(event.getAction())
            {
                case MotionEvent.ACTION_DOWN: // нажатие
                    sendMove(MoveCMD.right);
                    break;
                case MotionEvent.ACTION_MOVE: // движение

                    break;
                case MotionEvent.ACTION_UP: // отпускание
                case MotionEvent.ACTION_CANCEL:
                    sendStop();
                    break;
            }
            return true;
        });

        FloatingActionButton exit = findViewById(R.id.exit);
        exit.setOnClickListener(view->exitApp());

    }

    private void sendMove(MoveCMD cmd)
    {
        int cmdMove;

        switch(cmd)
        {
            case forward:
                cmdMove = 1;
                break;

            case back:
                cmdMove = 2;
                break;

            case right:
                cmdMove = 4;
                break;

            case left:
                cmdMove = 8;
                break;

            default:
                cmdMove = 0;
        }

        sendCMD(cmdMove);
    }

    private void sendCMD(int cmdMove)
    {
        EncoderTrack encoderTrack = new EncoderTrack(0);
        encoderTrack.SetTrackNumber(cmdMove);
        EncoderMainHeader mainHeader = new EncoderMainHeader(encoderTrack.GetVectorByte());
        mainHeader.AddMainHeader((byte) CMD_DATA.SELECTED_TRACK);
        mainHeader.GetDataByte();
        Intent intent = new Intent(this, UARTService.class);
        intent.putExtra("CMD", UARTService.CMD_SEND_DATA);
        intent.putExtra("Data", mainHeader.GetDataByte());
        StartService.start(this, intent);
    }

    private void sendStop()
    {
        int cmdStop = 0;
        sendCMD(cmdStop);
    }

    private void exitApp()
    {
        Intent intentUART = new Intent(this, UARTService.class);
        stopService(intentUART);
        finish();
    }
}
