package com.ubx.rfid_demo;

import android.os.Bundle;
import android.util.Log;
import android.view.Window;
import android.widget.Toast;

import com.google.android.material.tabs.TabLayout;

import androidx.appcompat.widget.Toolbar;
import androidx.fragment.app.Fragment;
import androidx.viewpager.widget.ViewPager;
import androidx.appcompat.app.AppCompatActivity;

import com.ubx.rfid_demo.databinding.ActivityMainBinding;
import com.ubx.rfid_demo.ui.main.SettingFragment;
import com.ubx.rfid_demo.ui.main.TagManageFragment;

import com.ubx.rfid_demo.ui.main.SectionsPagerAdapter;
import com.ubx.rfid_demo.ui.main.TagScanFragment;
import com.ubx.rfid_demo.utils.SoundTool;
import com.ubx.usdk.USDKManager;
import com.ubx.usdk.rfid.RfidManager;
import com.ubx.usdk.rfid.aidl.RfidDate;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class MainActivity extends AppCompatActivity {
    public static final String TAG = "usdk";
    private ActivityMainBinding binding;

    public  boolean RFID_INIT_STATUS = false;
    public RfidManager mRfidManager;
    public RfidDate mRfidDate;
    public List<String> mDataParents;
    private List<Fragment> fragments ;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        supportRequestWindowFeature(Window.FEATURE_NO_TITLE);
        binding = ActivityMainBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());


        mDataParents = new ArrayList<>();

        SoundTool.getInstance(BaseApplication.getContext());
        initRfid();
//        initRfidService();

         fragments = Arrays.asList(TagScanFragment.newInstance(MainActivity.this)
                , TagManageFragment.newInstance(MainActivity.this)
                , SettingFragment.newInstance(MainActivity.this));
        SectionsPagerAdapter sectionsPagerAdapter = new SectionsPagerAdapter(this, getSupportFragmentManager(), fragments);
        ViewPager viewPager = binding.viewPager;
        viewPager.setAdapter(sectionsPagerAdapter);
        TabLayout tabs = binding.tabs;
        tabs.setupWithViewPager(viewPager);

    }


    private void initRfid() {
        // 在异步回调中拿到RFID实例
        USDKManager.getInstance().init(BaseApplication.getContext(),new USDKManager.InitListener() {
            @Override
            public void onStatus(USDKManager.STATUS status) {
                if ( status == USDKManager.STATUS.SUCCESS) {
                    Log.d(TAG, "initRfidService: 状态成功");
                    mRfidManager =   USDKManager.getInstance().getRfidManager();
//                mRfidManager.registerCallback(callback);
                    // 设置波特率
                    if (mRfidManager.connectCom("/dev/ttyHSL0", 115200)) {
                       final String mf = mRfidManager.getModuleFirmware();
                        Log.d(TAG, "initRfidService:   mf："+mf);
                        ((TagScanFragment)fragments.get(0)).setCallback();
                        mRfidManager.getFirmwareVersion(mRfidManager.getReadId());

//                         mRfidManager.setImpinjFastTid( mRfidManager.getReadId(),false,false);//设置是否盘存EPC+TID
//                    int outputPower = mRfidManager.getOutputPower(mRfidManager.getReadId());
//                    Log.d(TAG, "initRfidService: outputPower = " + outputPower);
                    }
                }else {
                    Log.d(TAG, "initRfidService: 状态失败。");
                }
            }
        });


    }
    private void initRfidService() {
        // 在异步回调中拿到RFID实例
        USDKManager.getInstance(BaseApplication.getContext()).getFeatureManagerAsync(USDKManager.FEATURE_TYPE.RFID, (featureType, status) -> {
            if (featureType == USDKManager.FEATURE_TYPE.RFID && status == USDKManager.STATUS.SUCCESS) {
                Log.d(TAG, "initRfidService: 成功拿到服务");
                mRfidManager = (RfidManager) USDKManager.getInstance(BaseApplication.getContext()).getFeatureManager(USDKManager.FEATURE_TYPE.RFID);
//                mRfidManager.registerCallback(callback);
                // 设置波特率
                if (mRfidManager.connectCom("/dev/ttyHSL0", 115200)) {
                    Log.d(TAG, "initRfidService: 成功連接到串口");
                    ((TagScanFragment)fragments.get(0)).setCallback();
                    mRfidManager.getFirmwareVersion(mRfidManager.getReadId());
                }
            }else {
                Log.d(TAG, "initRfidService: 失败");
            }
        });

    }
    @Override
    protected void onDestroy() {
        super.onDestroy();
        SoundTool.getInstance(BaseApplication.getContext()).release();
        RFID_INIT_STATUS = false;
        if (mRfidManager != null) {
            mRfidManager.disConnect();
            mRfidManager.release();
            Log.d(TAG, "onDestroyView: rfid服务关闭");
//            System.exit(0);
        }
    }

    /**
     * 设置盘存时间
     * @param interal 0-200 ms
     */
    private void setScanInteral(int interal){
        int setScanInterval =   mRfidManager.setScanInterval( mRfidManager.getReadId(),interal);
        Log.v(TAG,"--- setScanInterval()   ----"+setScanInterval);
    }

    /**
     * 获取盘存时间
     */
    private void getScanInteral(){
        int getScanInterval =   mRfidManager.getScanInterval( mRfidManager.getReadId() );
        Log.v(TAG,"--- getScanInterval()   ----"+getScanInterval);
    }
}