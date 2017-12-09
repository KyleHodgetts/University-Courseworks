package criticalsection;

public class CriticalSection {
	
	static Buffer buffer;
	static OneThread oneThread;
	static TwoThread twoThread;

	public static void main(String[] args) {
		buffer = new Buffer(10);
		oneThread = new OneThread(buffer);
		twoThread = new TwoThread(buffer);
		oneThread.start();
		twoThread.start();
	}


}
