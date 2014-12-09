package c10.lang;

import c10.compiler.constraint;
import x10.compiler.NoThisAccess;
import c10.runtime.agent.Case2;
import c10.runtime.agent.Tell;

public class Int extends Number[XInt] implements Comparable[Int], Arithmetic[Int] {
	
	public def this() {this(null as String);}
	public def this(o:XInt) {this(o,null);}
	public def this(s:String) {super(s);}
	public def this(o:XInt,s:String) {super(o,s);}
	
	public def makeHerbrand(t:XInt)=new Int(t);
	public def makeHerbrand()=new Int();
	@NoThisAccess protected def lowerBound() = XInt.MIN_VALUE;
	@NoThisAccess protected def upperBound() = XInt.MAX_VALUE;
	public def zero()=makeHerbrand(0n);
	/*
	 * @Constraint    public  operator this < (x:Int): XBoolean {
	 * return false;
	 * }
	 * @Constraint    public  operator this > (x:Int): XBoolean {
	 * return false;
	 * }
	 * @Constraint    public  operator this <= (x:Int): XBoolean {
	 * return false;
	 * }
	 * @Constraint    public  operator this >= (x:Int): XBoolean {
	 * return false;
	 * }*/
	
	//public static operator[T](x:T){T <: XInt}:Int= new Int(x);
	public static operator (x:XInt):Int= new Int(x);
	
	
	/**
	 * The Int+Int operator.
	 * Computes the result of the addition of the two operands.
	 * @param x the other Int
	 * @return the sum of this Int and the other Int.
	 */
	/*XTENLANG-3402*/
	public def add(x:Int): Int = {
		val result = new Int();
		runWhenRealized(()=> {result.equate(getValue()+x);});
		result
	}
	
	/**
	 * The Int-Int operator
	 * Computes the result of the subtraction of the two operands.
	 * @param x the other Int
	 * @return the difference of this Int and the other Int.
	 */
	/*XTENLANG-3402*/
	public def sub(x:Int): Int = {
		val result = new Int();
		runWhenRealized(()=> {result.equate(getValue()-x);});
		result
	}
	
	/**
	 * The Int*Int operator
	 * Computes the result of the multiplication of the two operands.
	 * @param x the other Int
	 * @return the product of this Int and the other Int.
	 */
	/*XTENLANG-3402*/
	public def mul(x:Int): Int = {
		val result = new Int();
		runWhenRealized(()=> {result.equate(getValue()*x);});
		result
	}
	
	
	/**
	 * The Int/Int operator
	 * Computes the result of the division of the two operands.
	 * @param x the other Int
	 * @return the quotient of this Int and the other Int.
	 */
	/*XTENLANG-3402*/
	public def div (x:Int): Int = {
		val result = new Int();
		runWhenRealized(()=> {result.equate(getValue()/x);});
		result
	}
	
	
	public def compareTo(other:Int):Int {
		val x = new Int();
		new Case2(this, other, (a:XInt, b:XInt) 
				=> new Tell(x, new Int(a.compareTo(b)))).now();
		return x;	
	}
	public operator + this: Int = (+ (this as Number[XInt])) as Int;
	public operator - this: Int = (- (this as Number[XInt])) as Int;
	// TODO: Add coercions from Byte, Short, Int, Long, UByte, UShort, UInt, ULong, Float
	
	public def toString(): String 
	=(isRealized())? "" + getValueDerefed() : 
		isBound() ? dereference().toString(): "<Int #" + hashCode()  +">";
		
		
		
}