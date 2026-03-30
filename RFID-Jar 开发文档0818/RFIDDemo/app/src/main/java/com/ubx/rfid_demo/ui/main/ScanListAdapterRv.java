package com.ubx.rfid_demo.ui.main;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import androidx.viewbinding.ViewBinding;

import com.ubx.rfid_demo.databinding.TagScanItemBinding;
import com.ubx.rfid_demo.pojo.TagScan;

import java.util.List;

public class ScanListAdapterRv extends RecyclerView.Adapter<ScanListAdapterRv.ViewHolder> {

    private List<TagScan> data;
    private Context context;
    public OnClickListener onClickListener;

    public ScanListAdapterRv(List<TagScan> data, Context context) {
        this.data = data;
        this.context = context;
    }

    public void setData(List<TagScan> data) {
        this.data = data;
        if (this.data.size()>0) {
            notifyItemRangeChanged(0, data.size());
        }else {
            notifyDataSetChanged();
        }
    }

    public void setOnClickListener(OnClickListener onClickListener) {
        this.onClickListener = onClickListener;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        TagScanItemBinding binding = TagScanItemBinding.inflate(LayoutInflater.from(context), parent, false);
        return new ViewHolder(binding);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        if (onClickListener != null) {
            holder.itemView.setOnClickListener(v -> onClickListener.onSelectEpc(data.get(position), position));
        }
        holder.refreshView(position, data.get(position));
    }

    public interface OnClickListener {
        void onSelectEpc(TagScan data, int position);
    }

    @Override
    public int getItemCount() {
        return null != data ? data.size() : 0;
    }

    public class ViewHolder extends RecyclerView.ViewHolder {

        private TagScanItemBinding binding;

        public ViewHolder(@NonNull ViewBinding binding) {
            super(binding.getRoot());
            this.binding = (TagScanItemBinding) binding;
        }

        private void refreshView(int position, TagScan data) {
            binding.listEpcText.setText(data.getEpc());
            binding.listTotalText.setText(data.getCount() + "");
            binding.listRssiText.setText(data.getRssi());
        }
    }
}
