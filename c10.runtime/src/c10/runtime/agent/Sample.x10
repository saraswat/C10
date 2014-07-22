package c10.runtime.agent;

/** The basic TCC combinator tell c. Takes two promises and equates
 * the second to the first.
 * @author vj
 */
import c10.lang.Herbrand;
import c10.lang.Abort;
import c10.lang.probability.ProbabilityDistribution;


public class Sample[T](p:Herbrand[T],pd:ProbabilityDistribution[T]) extends BasicAgent {
	
	public def now() throws Abort {
	    p ~ pd;
	}

	/** A tell is quiescent if the corresponding ask succeeds. 
	 */
	//public def isQuiescentNow()=new Boolean(p.isRealized());
}
