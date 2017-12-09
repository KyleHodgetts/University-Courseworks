package stack;

public class SomeCode {
	public static int v = 8;
	public static int w = 6;
	
	public static void a() {
		int t = 2;
		v = v + t;
		
		t = t * 2;
		w = w + t;
		
		b(t);
		
		System.out.println(v + w);
	}
	
	public static void b(int param) {
		int s = 1;
		for(int i = 0; i < 3; i++) {
			s = s + param;
		}
		
		v = v + 1;
	}
	
	public static void main(String[] args) {
		int douglas = 40;
		douglas = douglas + 2;
		a();
		System.exit(0);
	}

}
