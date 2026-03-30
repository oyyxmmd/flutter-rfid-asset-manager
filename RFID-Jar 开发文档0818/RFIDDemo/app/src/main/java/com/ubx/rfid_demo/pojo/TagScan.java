package com.ubx.rfid_demo.pojo;

import java.util.Objects;

public class TagScan {

    private String rssi;
    private String epc;
    private int count;

    public TagScan() {
    }

    public TagScan(String rssi, String epc, int count) {
        this.rssi = rssi;
        this.epc = epc;
        this.count = count;
    }

    public String getRssi() {
        return rssi;
    }

    public void setRssi(String rssi) {
        this.rssi = rssi;
    }

    public String getEpc() {
        return epc;
    }

    public void setEpc(String epc) {
        this.epc = epc;
    }

    public int getCount() {
        return count;
    }

    public void setCount(int count) {
        this.count = count;
    }

    @Override
    public String toString() {
        return "TagScan{" +
                "rssi='" + rssi + '\'' +
                ", epc='" + epc + '\'' +
                ", count=" + count +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        TagScan tagScan = (TagScan) o;
        return Objects.equals(epc, tagScan.epc);
    }

    @Override
    public int hashCode() {
        return Objects.hash(rssi, epc, count);
    }
}
