package com.ubx.rfid_demo.ui.main;

import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.ubx.rfid_demo.databinding.TagManageItemBinding;
import com.ubx.rfid_demo.pojo.TagManage;

import java.util.List;

public class ManageListAdapterRv extends RecyclerView.Adapter<ManageListAdapterRv.ViewHolder> {

    private List<TagManage> data;
    private Context context;
    private onItemSelectedListener onItemSelectedListener;
    private int currentItem = -1;
    private int temp = -1;

    public ManageListAdapterRv(List<TagManage> data, Context context) {
        this.data = data;
        this.context = context;
    }

    public List<TagManage> getData() {
        return data;
    }

    public void setData(List<TagManage> data) {
        this.data = data;
        notifyDataSetChanged();
    }

    public ManageListAdapterRv.onItemSelectedListener getOnItemSelectedListener() {
        return onItemSelectedListener;
    }

    public void setOnItemSelectedListener(ManageListAdapterRv.onItemSelectedListener onItemSelectedListener) {
        this.onItemSelectedListener = onItemSelectedListener;
    }

    @NonNull
    @Override
    public ManageListAdapterRv.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        TagManageItemBinding binding = TagManageItemBinding.inflate(LayoutInflater.from(context), parent, false);
        return new ViewHolder(binding);
    }

    @Override
    public void onBindViewHolder(@NonNull ManageListAdapterRv.ViewHolder holder, int position) {
        holder.refreshView(position, data.get(position));
        holder.itemView.setSelected(holder.getLayoutPosition() == currentItem);
        holder.itemView.setOnClickListener(v -> {
            holder.itemView.setSelected(true);
            temp = currentItem;
            currentItem = holder.getLayoutPosition();
            notifyItemChanged(temp);
            onItemSelectedListener.onItemSelected(holder.itemView, position, data.get(position));
        });
    }

    @Override
    public int getItemCount() {
        return null != data ? data.size() : 0;
    }

    public class ViewHolder extends RecyclerView.ViewHolder {

        private TagManageItemBinding binding;

        public ViewHolder(@NonNull TagManageItemBinding binding) {
            super(binding.getRoot());
            this.binding = binding;
        }

        private void refreshView(int position, TagManage data) {
            Log.d("usdk", "refreshView: data = " + data + ", i = " + position);
            binding.manageEpcText.setText(data.getEpc());
            binding.managePcText.setText(data.getPc());
            binding.manageDataText.setText(data.getData());
            binding.manageCrcText.setText(data.getCrc());
        }
    }

    interface onItemSelectedListener {

        void onItemSelected(View v, int position, TagManage data);

    }
}
