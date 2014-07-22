package c10.lang;

import c10.compiler.Constraint;
import x10.compiler.NoThisAccess;

public class Long extends Number[XLong] {
	// TODO: Copy the structure of Double
	public def this() {this(null as String);}
	public def this(o:XLong) {this(o,null);}
	public def this(s:String) {super(s);}
	public def this(o:XLong,s:String) {super(o,s);}
	
	public def makeHerbrand(t:XLong)=new Long(t);
	public def makeHerbrand()=new Long();
	@NoThisAccess protected def lowerBound() = XLong.MIN_VALUE;
	@NoThisAccess protected def upperBound() = XLong.MAX_VALUE;
	
	@Constraint    public  operator this < (x:Int): x10.lang.Boolean {
		return false;
	}
	@Constraint    public  operator this > (x:Int): x10.lang.Boolean {
		return false;
	}
	@Constraint    public  operator this <= (x:Int): x10.lang.Boolean {
		return false;
	}
	@Constraint    public  operator this >= (x:Int): x10.lang.Boolean {
		return false;
	}
	public static operator (x:x10.lang.Long):Long = new Long(x);

}