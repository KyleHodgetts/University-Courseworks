package pageswapping;

/** A class denoting a page table entry, comprising an address, reference bit, and valid bit */
public class PageTableEntry {

    /** A page table entry, comprising an address; a reference bit; and a valid bit
     *
     * The right-most bit (bit value 1) is the valid bit
     * The bit with value 2 is the reference bit
     * The remaining bits are the memory address
     */
    private int addressAndBits;
   
    /** Create an empty, invalid page table entry
     *
     * This sets the valid bit to false */
    public PageTableEntry() {
        addressAndBits = 0;
        setValidBit(false);
    }
   
    /** Create a page table entry, containing the given frame address
     *
     * This creates an entry with the given address; reference bit 0, valid bit 1 */
    public PageTableEntry(int address) {
        addressAndBits = address;
        setValidBit(true);
    }
    
    /** Get the frame address */
    public int getAddress() {
        // do a logical 'and' with 'not 3': an integer that has every bit set, other than 1 and 2
        return (addressAndBits & ~3);
    }
    
    /** Get the value of the reference bit */
    public boolean getReferenceBit() {
        // do a logical and with 2, getting just the reference bit
        return ((addressAndBits & 2) != 0);
    }
    
    /** Get the value of the valid bit */
    public boolean getValidBit() {
        // do a logical and with 1, getting just the valid bit
        return ((addressAndBits & 1) != 0);
    }
    
    /** Set the reference bit to the value given */
    public void setReferenceBit(boolean value) {
        if (value) {
            addressAndBits = (addressAndBits | 2); // bitwise-or with 2: sets the reference bit
        } else {
            addressAndBits = (addressAndBits & ~2); // bitwise-and with 'not 2' - i.e. every other bit set to 2, guaranteeing that the address and valid bit are unchaged, but the reference bit is zeroed
        }
    }

    /** Set the valid bit to the value given */
    public void setValidBit(boolean value) {
        if (value) {
            addressAndBits = (addressAndBits | 1); // bitwise-or with 1: sets the valid bit
        } else {
            addressAndBits = (addressAndBits & ~1); // bitwise-and with 'not 1' - i.e. everything but the bit with value 1
        }
    }
    
    
}
