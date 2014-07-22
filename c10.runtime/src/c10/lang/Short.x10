package c10.lang;

import c10.compiler.Constraint;
import x10.compiler.NoThisAccess;

public class Short extends Number[XShort] {
	// TODO: Copy the structure of Double
	public def this() {this(null as String);}
	public def this(o:XShort) {this(o,null);}
	public def this(s:String) {super(s);}
	public def this(o:XShort,s:String) {super(o,s);}
	
	public def makeHerbrand(t:XShort)=new Short(t);
	public def makeHerbrand()=new Short();
	@NoThisAccess protected def lowerBound() = XShort.MIN_VALUE;
	@NoThisAccess protected def upperBound() = XShort.MAX_VALUE;
	
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
	public static operator (x:XShort):Short = new Short(x);

}