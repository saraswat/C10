package c10.lang.probability;

import x10.lang.Double;
import c10.lang.Herbrand;
import x10.lang.Comparable;
import c10.lang.XBoolean;
/**
 * The Uniform Distribution in the range [a,b].
 * 
 * @author vj
 */
public class Uniform[T]{T <: Arithmetic[T], T <: Comparable[T] } extends PD[T] {
	val a:T, b:T, conv:(Double)=>T;
	/**
	 * The job of conv is to take the probability value p and convert
	 * it into a T value drawn uniformly from the bounds.
	 */
	public def this(a:T,b:T, conv:(Double)=>T){this.a=a; this.b=b;this.conv=conv;}
	public def sample(p:Double):T = conv(p);
	public def isLegal(t:T):XBoolean= a.compareTo(a) <= 0 & t.compareTo(b) <= 0;
}