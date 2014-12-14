package c10.lang.probability;

import c10.compiler.agent;
import x10.util.Random;
import c10.lang.*;
import c10.runtime.agent.*;

/**
 * Specifies a conditional probablity distribution over the underlying domain S,
 * dependent on Herbrand variables over T and U.
 * 
 * @author vj
 */
public abstract class ConditionalPD2[S,T,U](d1:Herbrand[T], d2:Herbrand[U]){
	
	/**
	 * The sample operation on a probability distribution.
	 * Under normal execution, samples this probability distribution
	 * to obtain a value s in S, and adds the constraint p=s to the store.
	 */
	@agent public operator (p:Herbrand[S]) ~ this: void {
		try {
			// suspend until the dependent variables have a value,
			// then use this value to obtain the underlying PD[S],
			// and sample it.
			(new Case2[T,U](d1, d2, (t:T,u:U) => new Sample(p, caseOf(t,u)))).now();
		} catch (a:EmptyDomainException) {
			throw new Abort();
		}
	}
	/**
	 * Given a value for each of the dependent variables, return a probability
	 * distribution over S.
	 */
	public abstract def caseOf(t:T,u:U):ProbabilityDistribution[S];
	
}