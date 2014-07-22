package c10.lang;

import c10.compiler.Constraint;
import x10.compiler.NoThisAccess;

public class Float extends Number[XFloat] {
	// TODO: Copy the structure of Double
	public def this() {this(null as String);}
	public def this(o:XFloat) {this(o,null);}
	public def this(s:String) {super(s);}
	public def this(o:XFloat,s:String) {super(o,s);}
	
	
	public def makeHerbrand(t:XFloat)=new Float(t);
	public def makeHerbrand()=new Float();
	@NoThisAccess protected def lowerBound() = XFloat.MIN_VALUE;
	@NoThisAccess protected def upperBound() = XFloat.MAX_VALUE;
	
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
	public static operator (x:XFloat):Float = new Float(x);
	

}