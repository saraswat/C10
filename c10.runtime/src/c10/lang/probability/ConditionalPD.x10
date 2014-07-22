package c10.lang.probability;

import c10.compiler.Agent;
import x10.util.Random;
import c10.lang.*;
import c10.runtime.agent.*;

/**
 * Specifies a probablity distribution over the underlying domain Z.
 */
public abstract class ConditionalPD[S,T](d1:Herbrand[T]){
	
	/**
	 * The sample operation on a probability distribution.
	 * Under normal execution, samples this probability distribution
	 * to obtain a value s in S, and adds the constraint p=s to the store.
	 */
	@Agent public operator (p:Herbrand[S]) ~ this: void {
		try {
			// suspend until the dependent variables have a value,
			// then use this value to obtain the underlying PD[S],
			// and sample it.
			(new Case[T](d1,  (t:T) => new Sample(p, caseOf(t)))).now();
		} catch (a:EmptyDomainException) {
			throw new Abort();
		}
	}
	/**
	 * Given a value for each of the dependent variables, return a probability
	 * distribution over S.
	 */
	public abstract def caseOf(t:T):ProbabilityDistribution[S];
	
}