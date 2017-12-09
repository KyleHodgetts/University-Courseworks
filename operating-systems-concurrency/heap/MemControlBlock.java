package heap;
public class MemControlBlock {

    /** Use this as the value of sizeof(MemControlBlock) */
    public static final int SIZE_OF_MEMORY_CONTROL_BLOCK = 16;
    
    /** True if this memory control block is at the start of a hole
     *  False if it is at the start of a block of memory that has been occupied */
    public boolean available;
    
    
    /** The size of the block of memory */
    public int size;
    
    /** The previous block on the heap */
    public MemControlBlock previous;
    
    /** The next block on the heap */
    public MemControlBlock next;
    
    /** Create a hole, of the given size
     * 
     * It is assumed to be a hole, i.e. available is set to true.
     * 
     * previous and next are given default values of null */
    public MemControlBlock(int size) {
        available = true;
        this.size = size;
        previous = null;
        next = null;
    }
    
    /** Create a memory control block, for either a hole, or a region that is in use
     * 
     * This assigns the values given, to the member variables of the object */
    public MemControlBlock(boolean available, int size,
                           MemControlBlock previous,
                           MemControlBlock next) {
        
        this.available = available;
        this.size = size;
        
        this.previous = previous;
        this.next = next;
    }
    
    /** For debugging: print out a string representation of this hole */
    public String toString() {
        if (available) {
            return "Empty block of size " + size;
        } else {
            return "Occupied block of size " + size;
        }    
    }       
}
