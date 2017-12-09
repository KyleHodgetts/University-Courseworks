package heap;
public class Heap {
    
    /** The first hole in the heap */
    public MemControlBlock firstBlock;
    
    /** Create a heap, with holes of sizes as given in the array
     */
    public Heap(int[] holes) {
        
        firstBlock = new MemControlBlock(holes[0]);
        MemControlBlock previousBlock = firstBlock;
        
        for (int i = 1; i < holes.length; ++i) {
            MemControlBlock nextBlock = new MemControlBlock(holes[i]);
            previousBlock.next = nextBlock;
            nextBlock.previous = previousBlock;
            
            previousBlock = nextBlock;            
        }
    }
    
    /** For debugging: print out a string representation of the heap
     * 
     * You can change the code in this method.  It just prints out the first block */
    public String toString() {
        // You can change the implementation of this if you want, but there are no marks for doing so
        // This presently just prints out the first block        
    	String toReturn = "";
    	MemControlBlock block = firstBlock;
    	while(block != null) {
    		toReturn += " -> " + block;
    		block = block.next;
    	}
//        return "A heap, with the first memory control block as " + firstBlock;
    	return toReturn;
    }
    
    /** Your implementation of worst-fit-first
     *
     * All your code must go in this method.  You must not change the method signature.
     * 
     * @return True if the memory request was successful (there was a hole big enough)
     *         False if the memory request was not successful (there was no hole big enough)
     */
    public boolean requestMemoryWorstFit(int allocationSize) {
    	/**
    	 * Find largest block size with enough space for allocation.
    	 * Split the block to make two new blocks, one to allocate and one to be left over
    	 * Link the blocks up
    	*/
    	
    	/*
    	 * Find the largest block that is available
    	 */
    	MemControlBlock biggest = firstBlock;
    	MemControlBlock currentBlock = firstBlock;
    	while(currentBlock != null) {
    		if(currentBlock.available && (currentBlock.size > biggest.size)) {
    			biggest = currentBlock;
    		}
    		currentBlock = currentBlock.next;
    	}
    	System.out.println("Attempting to allocate: " + biggest);
    	
    	final int FULL_ALLOCATION_SIZE = allocationSize + MemControlBlock.SIZE_OF_MEMORY_CONTROL_BLOCK;
    	
    	/* GUARD CLAUSE: If the largest block cannot satisfy allocation request, return false */
    	if(biggest.size < FULL_ALLOCATION_SIZE) { return false; }
    	
    	int spare = biggest.size - FULL_ALLOCATION_SIZE;
    	
    	/*
    	 * Split the block
    	 */
    	MemControlBlock toAllocate = new MemControlBlock(false, FULL_ALLOCATION_SIZE, biggest.previous, null);
    	MemControlBlock toRemain = biggest.next;
    	if (spare > 0) {
        	toRemain = new MemControlBlock(true, (spare - MemControlBlock.SIZE_OF_MEMORY_CONTROL_BLOCK), toAllocate, biggest.next);
    	}
    	
    	/*
    	 * Re-link blocks and unlink the old, now split, biggest block  
    	 */
    	toAllocate.next = toRemain;
    	(biggest.previous).next = toAllocate;
    	(biggest.next).previous = toRemain;
    	biggest.previous = null;
    	biggest.next = null;
    	
    	return true;
    }
}
