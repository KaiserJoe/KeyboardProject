package com.bankeys.data;

import java.io.Serializable;

public class CustomeData  implements Serializable {
	int binLen;
	int len;
	String data;
	
	public CustomeData() {
		super();
	}

	public CustomeData(int binLen, int len, String data) {
		super();
		this.binLen = binLen;
		this.len = len;
		this.data = data;
	}

	public int getBinLen() {
		return binLen;
	}

	public void setBinLen(int binLen) {
		this.binLen = binLen;
	}

	public int getLen() {
		return len;
	}

	public void setLen(int len) {
		this.len = len;
	}

	public String getData() {
		return data;
	}

	public void setData(String data) {
		this.data = data;
	}
}
