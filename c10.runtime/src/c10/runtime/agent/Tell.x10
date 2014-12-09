package c10.runtime.agent;

/** The basic TCC combinator tell c. Takes two promises and equates
 * the second to the first.
 * @author vj
 */
import c10.lang.Herbrand;
import c10.lang.Abort;


public class Tell[T](p:Herbrand[T],q:Herbrand[T]) extends BasicAgent {
	public def this(p:Herbrand[T], q:Herbrand[T]) {
		property(p,q);
	}
	public def this(p:Herbrand[T], l:T) {
		property(p, p.makeHerbrand(l));
	}
	public def now() throws Abort {
	    p~q;
	}

	/** A tell is quiescent if the corresponding ask succeeds. 
	 */
	public def isQuiescentNow() {
	    val result = neverQuiescent();      
	    try {
		(new Ask(p, q, new Tell(result, alwaysQuiescent()))).now();
	    } catch(z:Abort) {
	    }
	    return result;
	}
}
