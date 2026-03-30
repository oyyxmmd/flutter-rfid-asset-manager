package com.ubx.rfid_demo.ui.main;

import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;


import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import com.ubx.rfid_demo.MainActivity;
import com.ubx.rfid_demo.databinding.FragmentSettingBinding;
import com.ubx.usdk.rfid.aidl.IRfidCallback;
import com.ubx.usdk.rfid.aidl.RfidDate;
import com.ubx.usdk.rfid.util.CMDCode;
import com.ubx.usdk.rfid.util.ErrorCode;

/**
 * A simple {@link Fragment} subclass.
 * Use the {@link SettingFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class SettingFragment extends Fragment {
    public static final String TAG = "usdk-"+SettingFragment.class.getSimpleName();

    private FragmentSettingBinding binding;

    public static SettingFragment newInstance(MainActivity activity) {
        mActivity = activity;
        return new SettingFragment();
    }

    private Callback callback  = new Callback();
    private static MainActivity mActivity;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        binding = FragmentSettingBinding.inflate(inflater, container, false);
        return binding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initEvents();
    }


    private void initEvents() {
        binding.btnGetPower.setOnClickListener(v -> {
            setCallback();
            int outputPower = mActivity.mRfidManager.getOutputPower(mActivity.mRfidManager.getReadId());
        });

        binding.btnSetPower.setOnClickListener(v -> {
            setCallback();
            String str = binding.etSetPower.getText().toString().trim();
            if (TextUtils.isEmpty(str)) {
                Toast.makeText(getActivity(), "输入参数不能为空！", Toast.LENGTH_SHORT).show();
                return;
            }
            int power = Integer.parseInt(str);
            if (power<0 || power>33) {
                Toast.makeText(getActivity(), "输入的值不在功率范围！", Toast.LENGTH_SHORT).show();
                return;
            }

            mActivity.mRfidManager.setOutputPower(mActivity.mRfidManager.getReadId(), (byte) power);
        });
    }

    private class Callback implements IRfidCallback {

        @Override
        public void onInventoryTag(byte b, String s, String s1, String s2, byte b1, String s3, String s4, int i, int i1, String s5)  {

        }

        @Override
        public void onInventoryTagEnd(int i, int i1, int i2, int i3, byte b)  {

        }

        @Override
        public void onOperationTag(String s, String s1, String s2, String s3, int i, byte b, byte b1)  {

        }

        @Override
        public void onOperationTagEnd(int i)  {

        }

        @Override
        public void refreshSetting(RfidDate rfidDate)  {
            Log.d(TAG, "refreshSetting: test");
            mActivity.mRfidDate = rfidDate;
            String s = String.valueOf(mActivity.mRfidDate.getbtAryOutputPower()[0]);
            getActivity().runOnUiThread(() -> {
                Toast.makeText(getActivity(), s, Toast.LENGTH_SHORT).show();
            });
            Log.v(TAG, "Module OutPutPower get success：" + s);

        }

        @Override
        public void onExeCMDStatus(byte b, byte b1) {
            Log.d(TAG, "onExeCMDStatus: test");
            String format = CMDCode.format(b) + ErrorCode.format(b1);
            Log.v(TAG, "onExeCMDStatus format:" + format);
        }
    }

    @Override
    public void onResume() {
        super.onResume();
    }
    @Override
    public void setUserVisibleHint(boolean isVisibleToUser) {
        super.setUserVisibleHint(isVisibleToUser);
        if (isVisibleToUser) {
            setCallback();
        }
    }

    private void setCallback(){
        if (mActivity.RFID_INIT_STATUS) {
            if (mActivity.mRfidManager!=null) {
                if (callback == null) {
                    callback = new Callback();
                }
                    mActivity.mRfidManager.registerCallback(callback);
            }
        }
    }
}