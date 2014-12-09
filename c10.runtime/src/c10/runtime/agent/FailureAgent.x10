package c10.runtime.agent;
import c10.runtime.herbrand.FailureException;

/** Throws a Failure Exception when executed. Useful for triggering backtracking.
 @author vj
 */
public class FailureAgent extends BasicAgent {
       	public def now():void {
	    throw new FailureException("Aborting...");
	}

}
