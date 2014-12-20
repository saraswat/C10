/**
 * Released under the Eclipse Public Licence. Please see C10 project licence.
 * (c) IBM 2014
 */
package c10.lang.probability;

import x10.util.ArrayList;
import x10.util.Map;
import x10.util.Pair;
import x10.util.Random;
import c10.lang.Double;
import c10.lang.XDouble;
import x10.lang.Arithmetic;
import c10.lang.*;
/**
 * A probabilistic value specifies a discrete probability distribution over
 * an underlying finite domain. One can think of it as of the form 
 * (v1~p1 | ... | vn~pn), specifying that the value is vi with probability pi.
 * Here each of the values vi are required to be distinct, and taken from T,
 * each pi >= 0.0D, and the sum of the pi is within EPS of 1.0D. 
 * 
 * ProbabilisticValue[T] is a monad with unit that takes the value t to t~1.0D,
 * and a bind operator that given an a:ProbabilisticValue[S], and 
 * an f:(S)=>ProbabilisticValue[T], returns a g:ProbabilisticValue[T] by enumerating
 * through the v~p in a, and for each entry w~q in f(v) adding w~q*p to g.
 * 
 * @author vj
 */
public class ProbabilisticValue[T] extends ProbabilityDistribution[T] 
    implements Iterable[Map.Entry[T,XDouble]]{
	public static val EPS=1.0E-16;
	
	val map:x10.util.HashMap[T,XDouble];
	
	def this() { 
		super();
		map = new x10.util.HashMap[T,XDouble]();
		}
	
	/**
	 * Create a probabilistic value with entries drawn from the argument
	 * a of ProbValueItems.
	 */
	public def this(a:XRail[ProbValueItem[T]]) {
		this();
		var sum:x10.lang.Double=0D;
		for (pv in a) {
			if (pv.p < 0D) 
				throw new IllegalProbabilisticValueException(pv + ": prob must be non-negative");
			sum +=pv.p;
			map.put(pv.t, pv.p+map.getOrElse(pv.t,0D));
		}
		if (Math.abs(sum-1D) > EPS) 
			throw new IllegalProbabilisticValueException(a+ ": sum of probs must be close to 1.0D");
	}
	/**
	 * Unsafe: Use with care. User's responsibility to ensure
	 * the argument m has values for each entry that are non-negative
	 * and the total across all sums up to 1.0D more or less.
	
	public def this(m:x10.util.HashMap[T,XDouble]) {
		map=m; // do not check
	}
	 *  */
	def addEntry(t:T, p:XDouble) {map.put(t, p+map.getOrElse(t,0D));}
	
	// Todo: Check that associated probability is non-zero.
	public def isLegal(t:T):XBoolean = {
		for (e in this) {
			if (e.getKey().equals(t)) return true;
		}
		return false;
	}

	/**
	 * Given a value, it returns the probability that the value is assumed.
	 */
    public def getProbability(t:T):XDouble{
    	return map.getOrElse(t,0D);
	}

	protected def sample(p:XDouble):Pair[T,XDouble]{
		var sum:XDouble=0;
		var first:XBoolean=true;
		for (e in this) {
			val nSum = sum + e.getValue();
			if (sum <= p&& p <= nSum) {
				
				return new Pair(e.getKey(), e.getValue());
			}
			sum = nSum;
		}
		throw new EmptyDomainException("p is " + p + " pv is " + this.toString());
	}
	public def iterator() = map.entries().iterator();
	//public static operator[T] (a:T) ~ (b:x10.lang.Double) = ProbValueItem(a,b);
	
	/**
	 * Return the cross product of this:ProbabilisticValue[T] and other:ProbablisticValue[S].
	 * This is a ProbablisticValue[Pair[T,S]], where each entry v~q in the result
	 * has the form v=Pair(a,b) and q=p1*p2 for a~p1 in this and b~p2 in other.
	 */
	public operator [S] this ** (other:ProbabilisticValue[S]):ProbabilisticValue[Pair[T,S]] {
		val result = new ProbabilisticValue[Pair[T,S]]();
		for (e1 in this) for (e2 in other)
			result.addEntry(Pair(e1.getKey(),e2.getKey()), e1.getValue()*e2.getValue());
		return result;
	}
	/** 
	 * Arithmetic operators: lift the operation on the domain to probabilistic values. 
	 * dom(op pv1) = {op a |a in dom(pv)},
	 * prob(op x) = prob(x)
	 * (Note probabilities of multiple occurrences of same value are summed.)
	 */
	public operator - this {T <: Arithmetic[T]}: ProbabilisticValue[T] {
		val result= new ProbabilisticValue[T]();
		for (e in this) result.addEntry(-e.getKey(), e.getValue());
		return result;
	}
	/** 
	 * Arithmetic operators: lift the operation on the domain to probabilistic values. 
	 * dom(pv1 op pv2) = {a op b |a in dom(pv1), b in dom(pv2)},
	 * prob(x1 op x2) = prob(x1)*prob(x2)
	 *  (Note probabilities of multiple occurrences of same value are summed.)
	 */
	public operator this + (other:ProbabilisticValue[T]){T <: Arithmetic[T]}  {
		val result= new ProbabilisticValue[T]();
		for (e1 in this) for (e2 in other) 
			result.addEntry(e1.getKey()+e2.getKey(), e1.getValue()*e2.getValue());
		return result;
	}
	
	/** 
	 * Arithmetic operators: lift the operation on the domain to probabilistic values. 
	 * dom(pv1 op pv2) = {a op b |a in dom(pv1), b in dom(pv2)},
	 * prob(x1 op x2) = prob(x1)*prob(x2)
	 *  (Note probabilities of multiple occurrences of same value are summed.)
	 */
	public operator this - (other:ProbabilisticValue[T]){T <: Arithmetic[T]}  {
		val result= new ProbabilisticValue[T]();
		for (e1 in this) for (e2 in other) 
			result.addEntry(e1.getKey()-e2.getKey(), e1.getValue()*e2.getValue());
		return result;
	}
	
	/** 
	 * Arithmetic operators: lift the operation on the domain to probabilistic values. 
	 * dom(pv1 op pv2) = {a op b |a in dom(pv1), b in dom(pv2)},
	 * prob(x1 op x2) = prob(x1)*prob(x2)
	 *  (Note probabilities of multiple occurrences of same value are summed.)
	 */
	public operator this * (other:ProbabilisticValue[T]){T <: Arithmetic[T]}  {
		val result= new ProbabilisticValue[T]();
		for (e1 in this) for (e2 in other) 
			result.addEntry(e1.getKey()*e2.getKey(), e1.getValue()*e2.getValue());
		return result;
	}
	
	/** 
	 * Arithmetic operators: lift the operation on the domain to probabilistic values. 
	 * dom(pv1 op pv2) = {a op b |a in dom(pv1), b in dom(pv2)},
	 * prob(x1 op x2) = prob(x1)*prob(x2)
	 * (Note probabilities of multiple occurrences of same value are summed.)
	 */
	public operator this / (other:ProbabilisticValue[T]){T <: Arithmetic[T]}  {
		val result= new ProbabilisticValue[T]();
		for (e1 in this) for (e2 in other) 
			result.addEntry(e1.getKey()/e2.getKey(), e1.getValue()*e2.getValue());
		return result;
	}
	
	/**
	 * This implements the conditional distribution:
	 * case (this) {
	 * a1: pv1;
	 * ..
	 * an: pvn;
	 * }
	 * (where the supplied map f generates pvi from each ai via pvi=f(ai)).
	 * The result is a "linear combination" of the pvi, with the probability
	 * value for each ai obtained from this. (this must be of the form
	 * a1~p1 | ... | an~pn.)
	 */
	public def conditionalDistribution[S](f:(T)=>ProbabilisticValue[S]):ProbabilisticValue[S] =
		bind(this, f);
	/**
	 * The eta of the monadic structure. Lifts a value a:T to the probability
	 * distribution a~1.0D.
	 */
	public static def eta[T](a:T)=new ProbabilisticValue[T]([ProbValueItem[T](a,1.0D)]);
	
	/**
	 * The mu of the monadic structure. 
	 */
	public static def mu[T](a:ProbabilisticValue[ProbabilisticValue[T]]):ProbabilisticValue[T] {
		val result = new ProbabilisticValue[T]();
		for (p in a) 
			for (e in p.getKey()) 
				result.addEntry(e.getKey(), e.getValue()*p.getValue());
		return result;
	}
	/**
	 * The bind of the monadic structure.
	 */
	public static def bind[S,T](a:ProbabilisticValue[S], b:(S)=>ProbabilisticValue[T])
	:ProbabilisticValue[T] {
		val result = new ProbabilisticValue[T]();
		for (p in a) 
			for (e in b(p.getKey()))
				result.addEntry(e.getKey(), e.getValue()*p.getValue());
		return result;
	}
	
	/*
	 * A "linear combination" of two probabilistic values over T, a1~p1 | a2~p2;
	 * each entry a~p in ai~pi shows up in the result as a~p*pi.
	 */
	public static def combine[T]( a1:ProbabilisticValue[T], p1:Probability, 
			a2:ProbabilisticValue[T], p2:Probability) {
		val result = new ProbabilisticValue[T]();
		for (e in a1) result.addEntry(e.getKey(), e.getValue());
		for (e in a2) result.addEntry(e.getKey(), e.getValue());
		return result;
	}
	
	/**
	 * A string representation. (May be inappropriate for values with large
	 * domains.)
	 */
	public def toString() {
		var result:String="";
		for (pv in map.entries()) 
			result += (result.equals("")? "" : "|") + pv.getKey() + "~" + pv.getValue();
		return result;
	}
			

	//val a = 1~0.2;
	//val x = new ProbabilisticValue[Int]([1~0.2D, 2~0.8D]);
	
}