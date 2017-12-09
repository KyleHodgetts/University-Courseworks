package criticalsection;

public class OneThread extends Thread {
	
	Buffer buffer;
	
	public OneThread(Buffer buffer) {
		this.buffer = buffer;
	}

	public void run() {
		for(int i = 0; i < 5; i++) {
			buffer.add(1, i);
			System.out.println(buffer.toString());
		}
	}
	
}
