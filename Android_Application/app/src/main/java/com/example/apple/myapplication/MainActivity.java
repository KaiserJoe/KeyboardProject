package com.example.apple.myapplication;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;

import com.bankeys.common.LogUtil;
import com.bankeys.view.OnSDKListener;
import com.bankeys.view.SDKAppActivity;
import com.bankeys.view.SDKHelper;

import org.json.JSONException;
import org.json.JSONObject;

public class MainActivity extends AppCompatActivity implements OnSDKListener {
    private Button button;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        button = (Button) findViewById(R.id.qiao);

        SDKHelper m_SDKHelper = new SDKHelper(MainActivity.this);
        m_SDKHelper.setOnSDKListener(this);

        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent();
                intent.setFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION);
                intent.setClass(MainActivity.this, SDKAppActivity.class);
                //明文接口
                startActivityForResult(intent, 1);

            }
        });
    }


    private static final String TAG = "MainActivity";
    @Override
    public void notifyKeyInput(String s) {
        Log.e(TAG, "notifyKeyInput:"+s );
    }
}
