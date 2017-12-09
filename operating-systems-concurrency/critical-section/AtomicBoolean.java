package criticalsection;

public class AtomicBoolean {
	boolean value;
	
	public AtomicBoolean(boolean initialValue) {
		value = initialValue;
	}
	
	public synchronized void assign(boolean newValue) {
		value = newValue;
	}
}
