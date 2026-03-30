package com.ubx.rfid_demo.ui.main;

import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Toast;

import com.ubx.rfid_demo.BaseApplication;
import com.ubx.rfid_demo.MainActivity;
import com.ubx.rfid_demo.databinding.FragmentTagManageBinding;
import com.ubx.rfid_demo.pojo.ManageFormInfo;
import com.ubx.rfid_demo.pojo.TagManage;
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
 * Use the {@link TagManageFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class TagManageFragment extends Fragment {

    public static final String TAG = "usdk-"+TagManageFragment.class.getSimpleName();
    private FragmentTagManageBinding binding;
    private ManageFormInfo formInfo;

    /**
     * (0x00:RESERVED, 0x01:EPC, 0x02:TID, 0x03:USER)
     */
    private int btMemBank;
    private ManageListAdapterRv manageListAdapterRv;
    private Callback callback;
    private static MainActivity mActivity;
    private ArrayAdapter epcArrayAdapter;
    private List<TagManage> data;
    private HashMap<String, TagManage> map = new HashMap<>();

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @return A new instance of fragment TagManageFragment.
     */
    // TODO: Rename and change types and number of parameters
    public static TagManageFragment newInstance(MainActivity activity) {
        mActivity = activity;
        TagManageFragment fragment = new TagManageFragment();
        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        binding = FragmentTagManageBinding.inflate(inflater, container, false);
        return binding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        binding.manageListRv.setLayoutManager(new LinearLayoutManager(getActivity(), RecyclerView.VERTICAL, false));
        binding.manageListRv.addItemDecoration(new DividerItemDecoration(getActivity(), DividerItemDecoration.VERTICAL));
        manageListAdapterRv = new ManageListAdapterRv(null, getActivity());
        binding.manageListRv.setAdapter(manageListAdapterRv);

        initEvents();

    }

    @Override
    public void onStart() {
        super.onStart();
    }

    private void initEvents() {
        binding.manageBankSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                switch (position) {
                    case 0:
                        btMemBank = 0x00;
                        break;
                    case 1:
                        btMemBank = 0x01;
                        break;
                    case 2:
                        btMemBank = 0x02;
                        break;
                    case 3:
                        btMemBank = 0x03;
                        break;
                }
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });
        binding.manageBankSpinner.setSelection(1, true);

        //创建适配器，并设置给spinner2
        epcArrayAdapter = new ArrayAdapter(getActivity(),android.R.layout.simple_list_item_1,mActivity.mDataParents);
        binding.manageEpcDatasSpinner.setAdapter(epcArrayAdapter);
        binding.manageEpcDatasSpinner.setSelection(0, true);
        binding.manageEpcDatasSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
              List<String> datas = mActivity.mDataParents;
              if (datas!=null && datas.size()>0){
                String epc =  datas.get(position).replace(" ", "");
                byte[] bytes = hexStringToBytes(epc);
                binding.manageWriteEdit.setText(epc);
               mActivity.mRfidManager.setAccessEpcMatch(mActivity.mRfidManager.getReadId(), (byte) bytes.length, bytes);
              }
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });


        manageListAdapterRv.setOnItemSelectedListener((v, position, data) -> {
            binding.manageWriteEdit.setText(data.getData());
            byte[] bytes = hexStringToBytes(data.getEpc());
            mActivity.mRfidManager.setAccessEpcMatch(mActivity.mRfidManager.getReadId(), (byte) bytes.length, bytes);
        });
        binding.manageReadBtn.setOnClickListener(v -> {
            map.clear();
            setCallback();






            byte cnt = Integer.valueOf(binding.manageCntEdit.getText().toString()).byteValue();
            byte address = Integer.valueOf(binding.manageAddressEdit.getText().toString()).byteValue();
            Log.d(TAG, "initEvents: cnt = " + cnt + ", address = " + address);
            String strPwd = binding.managePasswordEdit.getText().toString();
            Log.d(TAG, "initEvents: strPwd = " + Arrays.toString(hexStringToBytes(strPwd)));
            byte[] pwd = hexStringToBytes(strPwd);
            Log.d(TAG, "initEvents: pwd" + Arrays.toString(pwd));
            formInfo = new ManageFormInfo(cnt, address, (byte) btMemBank, pwd, null);
            mActivity.mRfidManager.readTag(mActivity.mRfidManager.getReadId(), (byte) btMemBank, address, cnt, pwd);
        });
        binding.manageWriteBtn.setOnClickListener(v -> {
            Log.d(TAG, "initEvents: 写标签");
            map.clear();
            setCallback();
            byte[] pwd = hexStringToBytes(binding.managePasswordEdit.getText().toString());
            int add = Integer.parseInt(binding.manageAddressEdit.getText().toString());
            int cnt = Integer.parseInt(binding.manageCntEdit.getText().toString());
            String data = binding.manageWriteEdit.getText().toString();
            byte[] btAryData = hexStringToBytes(data);
            Log.d(TAG, "data.length() == "+data.length());
            Log.d(TAG, "data:"+data);
            Log.d(TAG, "initEvents: id = "+mActivity.mRfidManager.getReadId()
                    + "; pwd = " + Arrays.toString(pwd)
                    + "; btMemBank = " + btMemBank
                    + "; add = " + add
                    + "; cnt = " + cnt
                    + "; btAryData" + Arrays.toString(btAryData));
            mActivity.mRfidManager.writeTag(mActivity.mRfidManager.getReadId(), pwd, (byte) btMemBank, (byte) add, (byte) cnt, btAryData);


//            mActivity.mRfidManager.writeEpcString(mActivity.mRfidManager.getReadId(),"AAABBBCCCDDD","00000000");

        });
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




    class Callback implements IRfidCallback {
        @Override
        public void onInventoryTag(byte b, String s, String s1, String s2, byte b1, String s3, String s4, int i, int i1, String s5)  {

        }

        @Override
        public void onInventoryTagEnd(int i, int i1, int i2, int i3, byte b)  {
        }

        /**
         * 操作标签回调(Read/Write Tag Callback)
         *
         * @param s  PC Value
         * @param s1 CRC Check Value
         * @param s2 EPC Data
         * @param s3 Read Data
         * @param i  Data lenght
         * @param b  Ant ID
         * @param b1 Command cmd
         * @
         */
        @Override
        public void onOperationTag(String s, String s1, String s2, String s3, int i, byte b, byte b1)  {
            Log.d(TAG, "onOperationTag: 读取的数据：" + s3);
            getActivity().runOnUiThread(() -> {
                if (!map.containsKey(s2)) {
                    TagManage tagManage = new TagManage(s2, s, s3, s1, false);
                    map.put(s2, tagManage);
                } else {
                    TagManage tagManage = map.get(s2);
                    tagManage.setData(s3);
                    map.put(s2, tagManage);
                }
                data = new ArrayList<>(map.values());
                Log.d(TAG, "onOperationTag: data = " + Arrays.toString(data.toArray()));
                manageListAdapterRv.setData(data);
                SoundTool.getInstance(BaseApplication.getContext()).playBeep(1);

            });
        }

        /**
         * 单次操作标签数量(Read/Write Tag Command Operate End)
         *
         * @param i
         * @
         */
        @Override
        public void onOperationTagEnd(int i)  {
            Log.d(TAG, "onOperationTagEnd: 单次操作标签数量 = " + i);
        }

        @Override
        public void refreshSetting(RfidDate rfidDate)  {
            Log.v(TAG, "refreshSetting");
            mActivity.mRfidDate = rfidDate;
        }

        @Override
        public void onExeCMDStatus(byte b, byte b1)  {
            Log.d(TAG, "onExeCMDStatus: b = " + b + ", b1 = " + b1);
            String format = CMDCode.format(b) + ErrorCode.format(b1);
            Log.v(TAG, "onExeCMDStatus format:" + format);
             if (b == CMDCode.READ_TAG) {
                toast(ErrorCode.format(b1));
            }
            if (b == CMDCode.WRITE_TAG ) {
                if (  b1 == ErrorCode.SUCCESS){
                    toast("写标签成功");
                }else{
                    toast("写标签失败 "+b1);
                }

            }
            if (b == CMDCode.SET_ACCESS_EPC_MATCH && b1 == ErrorCode.SUCCESS) {
                toast("选择标签成功");
            }
//            toast(format);
        }
    }

    private void toast(String message) {
        getActivity().runOnUiThread(() -> Toast.makeText(getActivity(), message, Toast.LENGTH_SHORT).show());
    }
    @Override
    public void onResume() {
        super.onResume();
    }
    @Override
    public void setUserVisibleHint(boolean isVisibleToUser) {
        super.setUserVisibleHint(isVisibleToUser);
        if (isVisibleToUser) {
            epcArrayAdapter.notifyDataSetChanged();
            setCallback();
        }
    }
    private void setCallback(){
        if (mActivity.RFID_INIT_STATUS) {
            if (mActivity.mRfidManager!=null) {
                if (callback == null){
                    callback = new Callback();
                }
                    mActivity.mRfidManager.registerCallback(callback);
            }
        }
    }

}