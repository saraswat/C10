package c10.lang.probability;

import x10.lang.Double;
import c10.lang.Herbrand;
/**
 * The Uniform Distribution in the range [a,b] over x10.lang.Double.
 * 
 * @author vj
 */
public class Uniform[T]{T <: Arithmetic[T]} extends PD[T] {
	val a:T, b:T, conv:(Double)=>T;
	/**
	 * The job of conv is to take the probability value p and convert
	 * it into a T value drawn uniformly from the bounds.
	 */
	public def this(a:T,b:T, conv:(Double)=>T){this.a=a; this.b=b;this.conv=conv;}
	public def sample(p:Double):T = conv(p);
}