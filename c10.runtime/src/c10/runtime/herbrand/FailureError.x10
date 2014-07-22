package c10.runtime.herbrand;

/** A FailureError is thrown when the store has become inconsistent.
    @author vj
 */
public class FailureError extends Error {
    public def this()            {super();}
    public def this(z:Exception) { super( z.toString());}
    public def this(z:String)    { super(z); }
}
