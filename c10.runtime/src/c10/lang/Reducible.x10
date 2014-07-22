package c10.lang;
import x10.util.Ordered;
import c10.runtime.agent.*;
import c10.lang.Int;

public interface Reducible[T] extends x10.lang.Reducible[T] {
	public static struct AndReducer implements Reducible[Boolean] {
		public def zero():Boolean = true as XBoolean;
		public operator this(a:Boolean, b:Boolean):Boolean = {
			val x = new Boolean();
			new Case2(a, b, (m:boolean, n:boolean)=>new Tell[boolean](x, m && n)).now();
			x
		}
	}
	
	public static struct OrReducer implements Reducible[Boolean] {
		public def zero():Boolean = false;
		public operator this(a:Boolean, b:Boolean):Boolean = {
			val x = new Boolean();
			new Case2(a, b, (m:boolean, n:boolean)=>new Tell[boolean](x, m || n)).now();
			x
		}
	}
	
	public static struct SumReducer[T] { T <: c10.lang.Arithmetic[T], T haszero} 
	implements Reducible[T] {
		public def zero():T = Zero.get[T]();
		public operator this(a:T, b:T):T = a.add(b);
		}
	
	public static struct IntSumReducer  implements Reducible[Int] {
		public def zero():Int = new Int(0n);
		public operator this(a:Int, b:Int) = a.add(b);
	}
	
	public static struct MinReducer[T] {T <: Ordered[T], T haszero} implements Reducible[T] {
		private val zeroVal:T;
		public def this(maxValue:T) { zeroVal = maxValue; }
		public def zero():T = zeroVal;
		public operator this(a:T, b:T):T = a<=b?a:b;
	}

	public static struct MaxReducer[T] {T <: Ordered[T], T haszero} implements Reducible[T] {
		private val zeroVal:T;
		public def this(minValue:T) { zeroVal = minValue; }
		public def zero():T = zeroVal;
		public operator this(a:T, b:T):T = a<=b?b:a; 
	}
}