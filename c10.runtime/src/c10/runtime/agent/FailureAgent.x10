package c10.runtime.agent;
import c10.runtime.herbrand.FailureError;

/** Throws a Failure Error when executed. Useful for triggering backtracking.
 @author vj
 */
public class FailureAgent extends BasicAgent {
       	public def now():void {
	    throw new FailureError("Aborting...");
	}

}
