package pageswapping;

import java.util.LinkedList;

public class MemoryManagementUnit {
    /** The page table */
    private PageTableEntry[] pageTable;
    
    /** How many bits of logical memory addresses are used for the offset */
    private int bitsForOffset;
    
    /** A bitmask, where the bits for the offset are set to 1; and everything else is 0 */
    private int offsetMask;
    
    /** A bitmask, where the bits for the page number are set to 1; and everything else is 0 */
    private int pageNumberMask;
    
    /** The free frames list */
    private LinkedList<Integer> freeFrames;
    
    private int secondChanceIndex;
    
    /** Create an MMU
     *
     * @param pageTableSize  The number of entries in the page table
     * @param bitsForOffset  How many bits of logical memory addresses are used for the offset.  The rest are assumed to be the page number.
     */
    public MemoryManagementUnit(int pageTableSize, int bitsForOffset) {
        this.bitsForOffset = bitsForOffset;
        this.secondChanceIndex = 0;
        
        offsetMask = 0;
        for (int o = 0; o < bitsForOffset; ++o) {
            offsetMask = offsetMask | (1 << o);
        }
        
        pageNumberMask = ~offsetMask;
        
        
        pageTable = new PageTableEntry[pageTableSize];
        
        // Initialise all the page table entries to invalid, by making default page table entries
        for (int i = 0; i < pageTableSize; ++i) {
            pageTable[i] = new PageTableEntry();
        }
        
        freeFrames = new LinkedList<>();
        
        // assume there are half as many frames, as there are pages        
        for (int i = 0; i < (pageTableSize / 2); ++i) {
            freeFrames.addLast((2 << offsetMask) * i);
        }
        
    }
    
    /** Access a memory address; returning true if there was a page fault */
    public boolean accessMemoryAddress(int address) {
        int offset = address & offsetMask;
        int pageNumber = (address & pageNumberMask) >> bitsForOffset;
        
        System.out.println("Accessing memory with page " + pageNumber + ", offset " + offset);
        
        if (pageTable[pageNumber].getValidBit()) {
            // no page fault, woot
            // set the reference bit            
            pageTable[pageNumber].setReferenceBit(true);            
            return false; // no page fault - return false
        } else {
            pageFaultHandler(pageNumber);
            return true; // page fault - return true
        }
    }
    
    /** An implementation of the second-chance page-fault handler algorithm
     *
     * Your task is to implement this
     *
     * @param pageNumber
     */
    private void pageFaultHandler(int pageNumber) {
    	System.out.println("Amount of free frames: " + freeFrames.size());
    	if(!freeFrames.isEmpty()) {
    		pageTable[pageNumber] = new PageTableEntry(freeFrames.remove());
    	}
    	else {
    		System.out.println("Current page index: " + this.secondChanceIndex);
    		while(pageTable[secondChanceIndex].getReferenceBit()) {
    			pageTable[secondChanceIndex].setReferenceBit(false);
    			secondChanceIndex += 1;
        		System.out.println("Current page index: " + this.secondChanceIndex);
    			if (secondChanceIndex >= pageTable.length) secondChanceIndex = 0;
    		}
    		pageTable[secondChanceIndex].setValidBit(false);
    		pageTable[pageNumber] = new PageTableEntry(pageTable[secondChanceIndex].getAddress());
    	}
    }
}
