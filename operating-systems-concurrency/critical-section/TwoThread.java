package criticalsection;

public class TwoThread extends Thread {
	Buffer buffer;
	
	public TwoThread(Buffer buffer) {
		this.buffer = buffer;
	}

	public void run() {
		for(int i = 0; i < 5; i++) {
			buffer.add(2, i);
			System.out.println(buffer.toString());
		}
	}

}
