package criticalsection;

public class Buffer {
	int[] buffer;
	int spaceUsed;
	
	public Buffer(int bufferSize) {
		buffer = new int[bufferSize];
		spaceUsed = 0;
	}
	
	public void add(int x, int pos) {
		buffer[pos] = x;
		spaceUsed += 1;
	}
	
	@Override
	public String toString() {
		String toReturn = "[";
		for(int i : buffer) {
			toReturn += i + ", ";
		}
		toReturn += "]";
		return toReturn;
	}
}
