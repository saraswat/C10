/**
 * Released under the Eclipse Public Licence. Please see C10 project licence.
 * (c) IBM 2014
 */
package c10.lang;

import c10.util.Ordered;
import c10.compiler.constraint;
import x10.compiler.NoThisAccess;
import c10.runtime.agent.*;


public class Double extends Number[XDouble] 
    implements Comparable[Double], Arithmetic[Double] 
{
	
	public def this() {this(null as String);}
	public def this(o:XDouble) {this(o,null);}
	public def this(s:String) {super(s);}
	public def this(o:XDouble,s:String) {super(o,s);}
//	public operator this ~ (O:XDouble):c10.lang.Constraint[XDouble]= new c10.lang.Constraint(this, new Double(O));
	
	public def makeHerbrand(t:XDouble)=new Double(t);
	public def makeHerbrand()=new Double();
	@NoThisAccess protected def lowerBound() = XDouble.MIN_VALUE;
	@NoThisAccess protected def upperBound() = XDouble.MAX_VALUE;
	
	public def zero()=makeHerbrand(0.0D);
	
	public static operator (x:XDouble):Double = new Double(x);
	
	
	/**
	 * The Double % XDouble operator.
	 * Computes a remainder from the division of the two operands.
	 * @param x the other Double
	 * @return the remainder from dividing this Double by the other Double.
	 */
	public operator this % (x:XDouble): Double = {
		val result = new Double();
		runWhenRealized(()=> {result.equate((getValue()%x) as Double);});
		result
	}
	
		
	/**
	 * The Double+Double operator.
	 * Computes the result of the addition of the two operands.
	 * @param x the other Double
	 * @return the sum of this Double and the other Double.
	 */
	/*XTENLANG-3402*/
	public def add(x:Double): Double = {
		val result = new Double();
		runWhenRealized(()=> {result.equate(getValue()+x);});
		result
	}
	
	/**
	 * The Double-Double operator
	 * Computes the result of the subtraction of the two operands.
	 * @param x the other Double
	 * @return the difference of this Double and the other Double.
	 */
	/*XTENLANG-3402*/
	  public def sub(x:Double): Double = {
		val result = new Double();
		runWhenRealized(()=> {result.equate(getValue()-x);});
		result
	}
	
	/**
	 * The Double*Double operator
	 * Computes the result of the multiplication of the two operands.
	 * @param x the other Double
	 * @return the product of this Double and the other Double.
	 */
	/*XTENLANG-3402*/
	public def mul(x:Double): Double = {
		val result = new Double();
		runWhenRealized(()=> {result.equate(getValue()*x);});
		result
	}

	
	/**
	 * The Double/Double operator
	 * Computes the result of the division of the two operands.
	 * @param x the other Double
	 * @return the quotient of this Double and the other Double.
	 */
	/*XTENLANG-3402*/
	public def div (x:Double): Double = {
		val result = new Double();
		runWhenRealized(()=> {result.equate(getValue()/x);});
		result
	}
	 
	
	public def compareTo(other:Double):Int {
		val x = new Int();
		new Case2(this, other, (a:double, b:double) 
				=> new Tell(x, new Int(a.compareTo(b)))).now();
		return x;	
	}
	public operator + this: Double = (+ (this as Number[XDouble])) as Double;
	public operator - this: Double = (- (this as Number[XDouble])) as Double;
	// TODO: Add coercions from Byte, Short, Int, Long, UByte, UShort, UInt, ULong, Float
	
	public def toString(): String 
	=(isRealized())? "" + getValueDerefed() : 
		isBound() ? dereference().toString(): "<Double #" + hashCode()  
				+ interval.toString()+">";
		
			
}