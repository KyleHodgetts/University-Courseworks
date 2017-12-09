package pageswapping;

public class AllocationTest {
    public static void main(String[] args) {
        // create an MMU for 8 pages, assuming the offset is 10 bits (so each page is 2^10 bytes)       
        MemoryManagementUnit mmu = new MemoryManagementUnit(8,10);
        
        int[] pageSequence = {0,   1,   2,   3,   4,   1,    7,   2,   0,   7,    6,   5,   4,   3,   2,   6,   2,    1,   5};
        boolean[] answers =  {true,true,true,true,true,false,true,true,true,false,true,true,true,true,true,true,false,true,true};
        
        for (int i = 0; i < pageSequence.length; ++i) {
            // access some memory address
            if (mmu.accessMemoryAddress((pageSequence[i] << 10) | (7 * i))) {
                if (answers[i]) {
                    System.out.println("true = correct");
                } else {
                    System.out.println("true but should have been false");
                }
            } else {
                if (!answers[i]) {
                    System.out.println("false = correct");
                } else {
                    System.out.println("false but should have been true");
                }
            }
            System.out.println("");
        }
        
        System.out.println("");
    }
}

