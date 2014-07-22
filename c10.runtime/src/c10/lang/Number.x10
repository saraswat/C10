package c10.lang;
import c10.compiler.Constraint;
import x10.compiler.NoThisAccess;
import c10.util.XOrdered;
import c10.util.Ordered;
import c10.runtime.agent.Case;
import c10.runtime.agent.Now;
import c10.runtime.herbrand.Watcher;
/**
 * For the numeric C10 types S (Byte, Short, Int, Long, Double, Float) implements the following
 * constraints (for Y:S, and v: XS, i.e XByte, XInt etc.)
 * Y < v | Y <= v | Y > v | Y >= v | X = Y
 * 
 * This is done by associating with each Y an interval {lower..upper} where the left
 * and right bounds could be strict or not. 
 * 
 * The constraints
 * Y < Z | Y > Z | Y <= Z | Y >= Z
 * 
 * are also supported but they implicitly ask for one of their variables to be
 * realized, thus reducing this case to the cases above.
 * 
 */
public abstract class Number[T]{T haszero, T<: XArithmetic[T], T <: XOrdered[T]} 
extends Atom[T] implements Ordered[Number[T]] {
	
	
	public def this() {super(null as String);}
	public def this(o:T){this(o,null);}
	public def this(name:String){super(name);}
	public def this(o:T, name:String) {super(o,name);}
	
	@NoThisAccess protected abstract def lowerBound():T;
	@NoThisAccess protected abstract def upperBound():T;
	static class Interval[T]{T haszero, T<: XArithmetic[T], T <: XOrdered[T]} {
		protected var lowerBound:T;
		protected var upperBound:T;
		def this(lb:T, ub:T){lowerBound=lb; upperBound=ub;}
		protected var lstrict:XBoolean=false; // if strict, then pt is excluded
		protected var ustrict:XBoolean=false;
		/**
		 * Update bounds. This may cause an inconsistency, or it may
		 * cause this variable to become equated to a single value.
		 */
		def updateLowerBound(lower:T, ls:XBoolean):void {
			if (lowerBound < lower) { // so we have a new lower bound!
				lowerBound=lower;
				lstrict=ls;
			} else if (lowerBound == lower) 
				lstrict = lstrict || ls;
			
		}
		def updateUpperBound(upper:T, us:XBoolean):void {
			if (upper < upperBound) {
				upperBound=upper;
				ustrict=us;
			} else if (upper==upperBound)
				ustrict = ustrict || us;
			
		}
		def updateBounds(v:Interval[T]):void{
			updateLowerBound(v.lowerBound, v.lstrict);
			updateUpperBound(v.upperBound, v.ustrict);
		}
		def empty()=lowerBound > upperBound 
		   || (lowerBound==upperBound && (lstrict || ustrict));
		def onePointed():XBoolean= lowerBound==upperBound && (! lstrict) && (! ustrict);
		public def toString():String 
		= (lstrict? "(":"[") + lowerBound + ".." + upperBound + (ustrict? ")":"]");
		
	}
	protected def check():void{
		if (interval.empty()) throw new Abort("Inconsistent:" + Number.this);
		if (interval.onePointed()) { // should be within EPS 
			// now x is equal to lowerBound.
			bind(makeHerbrand(interval.lowerBound));
		}
	}
	
	protected var interval:Interval[T]=new Interval(lowerBound(),upperBound());
	
	//abstract public def makeHerbrand():Number[T]{self!=null};
	//abstract public def makeHerbrand(t:T):Number[T]{self!=null};
	@Constraint public operator (d:T) >  this: void {this <  d;}
	@Constraint public operator (d:T) >= this: void {this <= d;}
	@Constraint public operator (d:T) <  this: void {this >  d;}
	@Constraint public operator (d:T) <= this: void {this >= d;}
	
	@Constraint public operator this > (d:T): void {
		val x = dereference() as Number[T];
		interval.updateLowerBound(d,true);
		check();
	}
	
	@Constraint public operator this >= (d:T): void {
		val x = dereference() as Number[T];
		interval.updateLowerBound(d, false);
		check();
	}
	@Constraint public operator this <= (d:T): void {
		val x = dereference() as Number[T];
		interval.updateUpperBound(d, false);
		check();
	}
	@Constraint public operator this < (d:T): void {
		val x = dereference() as Number[T];
		interval.updateUpperBound(d, true);
		check();
	}
	
	@Constraint public operator this < (d:Number[T]): void {
		// add propagation rules both ways.
		new Case[T](this, (a:T)=> new Now(()=>{a < d;})).now();
		new Case[T](d, (a:T)=> new Now(()=>{this < a;})).now();
		
	}
	@Constraint public  operator this > (d:Number[T]): void {
		new Case[T](this, (a:T)=> new Now(()=>{a > d;})).now();
		new Case[T](d, (a:T)=> new Now(()=>{this > a;})).now();
	}
	@Constraint public operator this <= (d:Number[T]): void {
		new Case[T](this, (a:T)=> new Now(()=>{a <= d;})).now();
		new Case[T](d, (a:T)=> new Now(()=>{this <= a;})).now();
	}
	@Constraint public operator this >= (d:Number[T]): void {
		new Case[T](this, (a:T)=> new Now(()=>{a >= d;})).now();
		new Case[T](d, (a:T)=> new Now(()=>{this >= a;})).now();
	}
	
	/**
	 * Override to propagate lower and upper bounds.
	 */
	protected def bind(o:Herbrand[T] ) {
		val other = o as Number[T];
		super.bind(other);
		other.interval.updateBounds(interval);
		other.check();
	}
	
	protected def realizeAndAwakenIfNecessary( o:Herbrand[T] ) throws Abort {
		val other = o as Number[T];
		super.realizeAndAwakenIfNecessary(other);
		other.interval.updateBounds(interval);
		other.check();
		if (boundsWatcher != null) boundsWatcher.activate();
	}
	
	
	/**
	 * The Double+XDouble operator.
	 * Computes the result of the addition of the two operands.
	 * @param x the other XDouble
	 * @return the sum of this Double and the other Double.
	 */
	public operator this + (x:T): Number[T] = {
		val result = makeHerbrand();
		runWhenRealized(()=> {result.equate(getValue()+x);});
		result as Number[T]
	}
	
	/**
	 * The Double-XDouble operator.
	 * Computes the result of the subtraction of the two operands.
	 * @param x the other XDouble
	 * @return the difference of this Double and the other Double.
	 */
	public operator this - (x:T): Number[T] = {
		val result = makeHerbrand();
		runWhenRealized(()=> {result.equate(getValue()-x);});
		result as Number[T]
	}
	
	/**
	 * The Double*XDouble operator.
	 * Computes the result of the multiplication of the two operands.
	 * @param x the other T
	 * @return the product of this Double and the other Double.
	 */
	public operator this * (x:T): Number[T] = {
		val result = makeHerbrand();
		runWhenRealized(()=> {result.equate(getValue()*x);});
		result as Number[T]
	}
	
	/**
	 * The Double/XDouble operator.
	 * Computes the result of the division of the two operands.
	 * @param x the other XDouble
	 * @return the quotient of this Double and the other Double.
	 */
	public operator this / (x:T): Number[T] = {
		val result = makeHerbrand();
		runWhenRealized(()=> {result.equate(getValue()/x);});
		result as Number[T]
	}
	
	/**
	 * The XDouble+Double operator.
	 * Computes the result of the addition of the two operands.
	 * @param x the other Double
	 * @return the sum of this Double and the other Double.
	 */
	public operator (x:T) + this: Number[T] = {
		val result = makeHerbrand();
		runWhenRealized(()=> {result.equate(x+getValue());});
		result as Number[T]
	}
	
	/**
	 * The XDouble-Double operator.
	 * Computes the result of the subtraction of the two operands.
	 * @param x the other Double
	 * @return the difference of this Double and the other Double.
	 */
	public operator (x:T) - this: Number[T] = {
		val result = makeHerbrand();
		runWhenRealized(()=> {result.equate(x-getValue());});
		result as Number[T]
	}
	
	/**
	 * The XDouble*Double operator.
	 * Computes the result of the multiplication of the two operands.
	 * @param x the other Double
	 * @return the product of this Double and the other Double.
	 */
	public operator (x:T) * this: Number[T] = {
		val result = makeHerbrand();
		runWhenRealized(()=> {result.equate(x*getValue());});
		result as Number[T]
	}
	
	/**
	 * The XDouble / Double operator.
	 * Computes the result of the division of the two operands.
	 * @param x the other Double
	 * @return the quotient of this Double and the other Double.
	 */
	public operator  (x:T) / this: Number[T] = {
		val result = makeHerbrand();
		runWhenRealized(()=> {result.equate(x/getValue());});
		result as Number[T]
	}
	
	/**
	 * The + Double operator.
	 * A no-op.
	 * @return the value of this Double.
	 */
	public operator + this: Number[T] = this;
		
	/**
	* The - Double operator.
	* Negates the operand.
	* @return the negated value of this Double.
	*/
	public operator - this: Number[T] = {
		val result = makeHerbrand();
		runWhenRealized(()=> {result.equate(-getValue());});
		result as Number[T]
	}
		
	/** Suspend this call on this variable, if the variable is
	 * unbound, execute it immediately otherwise.
	 * 
	 */
	var boundsWatcher:Watcher=null;
    protected def ensureCurrent() {
	    super.ensureCurrent();
        boundsWatcher=null;
	}
	public def runWhenBoundsChange( call:()=>XBoolean) throws Abort {
	    if (call == null) return;
	    val me = this.dereference() as Number[T];
	    if ( me != this ) me.runWhenBoundsChange( call );
	    else runWhenBoundsChangeDerefed( call );
	}
		
	public def runWhenBoundsChangeDerefed( call:()=>XBoolean) 
	    throws Abort {
	    if (call()) return;
            // failed, add it to boundWatcher.
	    if ( this.isUnrealized() ) {
                if (boundsWatcher==null) boundsWatcher = new Watcher(call);
                else boundsWatcher.add(call);
		return;
	    }
	}

}
