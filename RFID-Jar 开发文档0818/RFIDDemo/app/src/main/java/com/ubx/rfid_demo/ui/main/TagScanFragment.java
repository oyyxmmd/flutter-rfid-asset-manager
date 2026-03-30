package com.ubx.rfid_demo.ui.main;

import android.bluetooth.le.ScanCallback;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.os.Trace;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.Toast;

import com.ubx.rfid_demo.BaseApplication;
import com.ubx.rfid_demo.MainActivity;
import com.ubx.rfid_demo.databinding.FragmentTagScanBinding;
import com.ubx.rfid_demo.pojo.TagScan;
import com.ubx.rfid_demo.utils.SoundTool;
import com.ubx.usdk.rfid.aidl.IRfidCallback;
import com.ubx.usdk.rfid.aidl.RfidDate;
import com.ubx.usdk.rfid.util.CMDCode;
import com.ubx.usdk.rfid.util.ErrorCode;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;

/**
 * A simple {@link Fragment} subclass.
 * Use the {@link TagScanFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class TagScanFragment extends Fragment {

    public static final String TAG = "usdk-"+TagScanFragment.class.getSimpleName();
    private FragmentTagScanBinding binding;
    private List<TagScan> data;
    private HashMap<String, TagScan> mapData;
    private ScanCallback callback  ;
    private ScanListAdapterRv scanListAdapterRv;
    private static  MainActivity mActivity;
    private int tagTotal = 0;

    private Handler handler = new Handler(Looper.getMainLooper()){
        @Override
        public void handleMessage(@NonNull Message msg) {
            super.handleMessage(msg);
            showFirmware();
        }
    };

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @return A new instance of fragment ScanFragment.
     */
    // TODO: Rename and change types and number of parameters
    public static TagScanFragment newInstance(MainActivity activity) {
        mActivity = activity;
        TagScanFragment fragment = new TagScanFragment();
        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        // Inflate the layout for this fragment
        binding = FragmentTagScanBinding.inflate(inflater, container, false);
        return binding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        Button scanStartBtn = binding.scanStartBtn;
        scanStartBtn.setOnClickListener(v -> {


            if (mActivity.RFID_INIT_STATUS) {
                if (scanStartBtn.getText().equals("开始扫描")) {
                    setCallback();
                    scanStartBtn.setText("停止扫描");
                    setScanStatus(true);
                } else {
                    scanStartBtn.setText("开始扫描");
                    setScanStatus(false);
                }
            }else {
                Log.d(TAG, "scanStartBtn  RFID未初始化 "  );
                Toast.makeText(getContext(),"RFID未初始化",Toast.LENGTH_SHORT).show();
            }
        });

        mapData = new HashMap<>();

        RecyclerView scanListRv = binding.scanListRv;
        scanListRv.setLayoutManager(new LinearLayoutManager(getActivity(), RecyclerView.VERTICAL, false));
        scanListRv.addItemDecoration(new DividerItemDecoration(getActivity(), DividerItemDecoration.VERTICAL));
        scanListAdapterRv = new ScanListAdapterRv(null, getActivity());
        scanListRv.setAdapter(scanListAdapterRv);

        binding.checkBox.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton compoundButton, boolean b) {
                if (mActivity.mRfidManager !=null  ) {
                    if (b) {
                       mActivity.mRfidManager.setImpinjFastTid(mActivity.mRfidManager.getReadId(),true,true);
                    } else {
                        mActivity.mRfidManager.setImpinjFastTid(mActivity.mRfidManager.getReadId(),false,true);
                    }
                }
            }
        });

    }






    @Override
    public void onStart() {
        super.onStart();
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                if (mActivity.mRfidManager!=null) {
                    Log.v(TAG,"--- getFirmwareVersion()   ----");
                    mActivity.mRfidManager.getFirmwareVersion(mActivity.mRfidManager.getReadId());
                }else {
                    Log.v(TAG,"onStart()  --- getFirmwareVersion()   ----  mActivity.mRfidManager == null");
                }
            }
        }, 5000);
    }

    private void setScanStatus(boolean isScan) {

            if (isScan) {
                tagTotal = 0;
                if (mapData!=null){
                    mapData.clear();
                }
                if (mActivity.mDataParents != null){
                    mActivity.mDataParents.clear();
                }
                if (data!=null) {
                    data.clear();
                    scanListAdapterRv.setData(data);
                }

                Log.v(TAG,"--- customizedSessionTargetInventory()   ----");
//                readTagOnce();

                mActivity.mRfidManager.customizedSessionTargetInventory(mActivity.mRfidManager.getReadId(), (byte) 1, (byte) 0, (byte) 1);
            } else {
                Log.v(TAG,"--- stopInventory()   ----");
                mActivity.mRfidManager.stopInventory();
            }
    }

    private long time = 0l;

    /**
     * 单个读取EPC 或tid
     */
    private void readTagOnce(){
        //读取TID的起始地址。
        //读取TID长度，如果长度为0，则读取EPC号
       int ret =  mActivity.mRfidManager.readTagOnce(mActivity.mRfidManager.getReadId(), (byte) 0, (byte) 0);
       if (ret == -6){
           Toast.makeText(mActivity, "固件不支持", Toast.LENGTH_SHORT).show();
       }
    }

    /**
     * 通过TID写入标签数据
     * @param TID   选中的TID
     * @param Mem   标签区域：0-密码区，前2个字是销毁密码，后2个字是访问密码      1-EPC区   2-TID区    3-用户区
     * @param WordPtr  写入的起始字地址
     * @param pwd   密码
     * @param  datas  待写入数据
     */
    private void writeTagByTid(String TID,byte Mem,byte WordPtr,byte[] pwd,String datas){
//                String TID = "E280110C20007642903D094D";
//                 byte[] pwd = hexStringToBytes("00000000");
//                 String datas = "1111111111111111";
              int ret =  mActivity.mRfidManager.writeTagByTid(mActivity.mRfidManager.getReadId(), TID,(byte) 1,(byte) 2, pwd,datas);
        if (ret == -6){
            Toast.makeText(mActivity, "固件不支持", Toast.LENGTH_SHORT).show();
        }
    }

    /**
     * 随机对一张标签写入EPC
     * @param epc   待写入的EPC值 16进制字符串
     * @param password  标签访问密码
     */
    private void writeEpcString(String epc,String password){
       mActivity.mRfidManager.writeEpcString(mActivity.mRfidManager.getReadId(), epc, password);
    }

    class ScanCallback implements IRfidCallback  {



        /**
         * 盘存数据回调（Inventory TAG Callback）
         *
         * @param b  cmd
         * @param s  pc值
         * @param s1 CRC Check Value
         * @param s2 EPC Data
         * @param b1 Ant
         * @param s3 RSSI
         * @param s4 Frequency
         * @param i
         * @param i1 Inventory Count
         * @param s5 Read id
         * @
         */
        @Override
        public void onInventoryTag(byte b, String s, String s1, String s2, byte b1, String s3, String s4, int i, int i1, String s5)  {
//            byte[] pwd = hexStringToBytes("00000000");
//            byte[] bytes = hexStringToBytes(s2);
//            mActivity.mRfidManager.setAccessEpcMatch(mActivity.mRfidManager.getReadId(), (byte)bytes.length,bytes);
//            mActivity.mRfidManager.readTag(mActivity.mRfidManager.getReadId(),(byte) 2,(byte)0,(byte) 6,pwd);

                        Log.d(TAG, "onInventoryTag: EPC: " + s2);
            SoundTool.getInstance(BaseApplication.getContext()).playBeep(1);
            getActivity().runOnUiThread(() -> {
                if (mapData.containsKey(s2)) {
                    TagScan tagScan = mapData.get(s2);
                    tagScan.setCount(mapData.get(s2).getCount() + 1);
                    tagScan.setRssi(s3);
                    mapData.put(s2, tagScan);
                } else {
                    mActivity.mDataParents.add(s2);
                    mapData.put(s2, new TagScan(s3, s2, 1));
                }
                long nowTime = System.currentTimeMillis();
                if ((nowTime - time)>1){
                    time = nowTime;
                    data = new ArrayList<>(mapData.values());
                    Log.d(TAG, "onInventoryTag: data = " + Arrays.toString(data.toArray()));
                    scanListAdapterRv.setData(data);
                    binding.scanCountText.setText(mapData.keySet().size() + "");
                    binding.scanTotalText.setText(++tagTotal + "");
                }


            });
        }

        /**
         * 盘存结束回调(Inventory Command Operate End)
         *
         * @param i  当前天线ID
         * @param i1 当前指令盘存标签数量
         * @param i2 读取速度
         * @param i3 总共读取次数
         * @param b  指令cmd
         * @
         */
        @Override
        public void onInventoryTagEnd(int i, int i1, int i2, int i3, byte b)  {
            Log.d(TAG, "onInventoryTag: 当前指令盘存标签数量" + i1);
        }

        @Override
        public void onOperationTag(String s, String s1, String s2, String s3, int i, byte b, byte b1)  {
            Log.d(TAG, "onInventoryTag: EPC: " + s2);
        }

        @Override
        public void onOperationTagEnd(int i)  {

        }

        @Override
        public void refreshSetting(RfidDate rfidDate)  {
            mActivity.mRfidDate = rfidDate;
            final String power = String.valueOf(rfidDate.getbtAryOutputPower()[0] & 0xFF);
            Log.v(TAG, "power:" + power);
//           showFirmware();
           handler.sendEmptyMessageDelayed(0,1);
        }

        /**
         * (指令操作状态回调)Command operate status
         * @param b  指令cmd对应CMDCode.class
         * @param b1 执行状态对应ErrorCode.class
         * @
         */
        @Override
        public void onExeCMDStatus(byte b, byte b1)  {
            String format = CMDCode.format(b) + ErrorCode.format(b1);
            Log.v(TAG, "onExeCMDStatus format:" + format);
            if (b == CMDCode.SET_OUTPUT_POWER) {
                String message = b1 == 16? "Success":"failed";
                Log.v(TAG,"Set OutputPower：" + message);
            } else if ((b == CMDCode.GET_OUTPUT_POWER) && b1 == ErrorCode.SUCCESS) {
                Log.v(TAG,"Module OutPutPower get success：" + String.valueOf(mActivity.mRfidDate.getbtAryOutputPower()[0]));
            } else if (b == CMDCode.SET_ACCESS_EPC_MATCH){
                Log.v(TAG,"Match EPC：" + (b1 == ErrorCode.SUCCESS ? "Success":"failed"));
            }
        }
    }
    @Override
    public void onResume() {
        super.onResume();


        showFirmware();
    }
    @Override
    public void setUserVisibleHint(boolean isVisibleToUser) {
        super.setUserVisibleHint(isVisibleToUser);
        if (isVisibleToUser) {
            setCallback();
        }
    }

    private void showFirmware(){
        try {
            if (mActivity.mRfidDate!=null) {
                mActivity.RFID_INIT_STATUS = true;
                String firmware = String.valueOf(mActivity.mRfidDate.getbtMajor() & 0xFF) + "." + String.valueOf(mActivity.mRfidDate.getbtMinor() & 0xFF);
                Log.v(TAG, "refreshSetting()  固件版本：" + firmware);
                binding.textFirmware.setText("固件：v"+firmware);
            }else {
                Log.v(TAG,"mActivty.mRfidDate == null");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    public void setCallback(){
            if (mActivity.mRfidManager!=null) {

                if (callback == null){
                    callback = new ScanCallback();
                }
                    mActivity.mRfidManager.registerCallback(callback);
            }
    }
    /**
     * 将Hex String转换为Byte数组
     *
     * @param hexString the hex string
     * @return the byte [ ]
     */
    public static byte[] hexStringToBytes(String hexString) {
        hexString = hexString.toLowerCase();
        final byte[] byteArray = new byte[hexString.length() >> 1];
        int index = 0;
        for (int i = 0; i < hexString.length(); i++) {
            if (index > hexString.length() - 1) {
                return byteArray;
            }
            byte highDit = (byte) (Character.digit(hexString.charAt(index), 16) & 0xFF);
            byte lowDit = (byte) (Character.digit(hexString.charAt(index + 1), 16) & 0xFF);
            byteArray[i] = (byte) (highDit << 4 | lowDit);
            index += 2;
        }
        return byteArray;
    }
}