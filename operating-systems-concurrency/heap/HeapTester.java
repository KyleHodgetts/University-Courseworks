package heap;
public class HeapTester {
            
    public static void main(String[] args) {
        int[] initialHoleSizes = {1000,4000,300,500,800};
        
        Heap h = new Heap(initialHoleSizes);
        System.out.println(h);;
        
        int[] allocationRequests = {170,480,210,4180,690};
        
        for (int request : allocationRequests) {
            System.out.println("Requesting " + request + " bytes of memory");
            if (h.requestMemoryWorstFit(request)) {
                System.out.println("-- Successful");
            } else {
                System.out.println("-- Unsuccessful");
            }             
        }
        
        System.out.println(h);
    }
}
