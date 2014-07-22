package c10.lang.probability;

import c10.compiler.Agent;
import x10.util.Random;
import c10.lang.*;

/**
 * Specifies a probablity distribution over the underlying domain Z.
 */
public abstract class ProbabilityDistribution[S]{
	
	/**
	 * The sample operation on a probability distribution.
	 * Under normal execution, samples this probability distribution
	 * to obtain a value s in S, and adds the constraint p=s to the store.
	 */
	@Agent public operator (p:Herbrand[S]) ~ this: void {
		try {
			val s= sample();
			//Console.OUT.println("Golden PD ~: p=" + p + " sample=" + s);
			p.equate(s);
		} catch (a:EmptyDomainException) {
			// inconsistent sampling constraint
			//Console.OUT.println("oi! EmptyDomainException??");
			throw new Abort();
		}
	}
	/**
	 * Sample the underlying observation. Can throw an EmptyDomainException
	 */
	public def sample():S = sample(new Random().nextDouble());
	
	/**
	 * An internal method that produces a sample from the underlying distribution
	 * given a random double between 0.0D and 1.0D.
	 */
	protected abstract def sample(random:XDouble):S;
}