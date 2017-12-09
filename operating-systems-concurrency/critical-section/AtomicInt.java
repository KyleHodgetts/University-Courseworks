package criticalsection;

public class AtomicInt {
	int value;
	public AtomicInt(int initialValue){
		value = initialValue;
	}
	public synchronized void assign(int newValue){
		value = newValue;
	}
}
