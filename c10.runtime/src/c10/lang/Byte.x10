package c10.lang;

import c10.compiler.Constraint;
import x10.compiler.NoThisAccess;

public class Byte extends Number[XByte] {
	// TODO: Copy the structure of Double
	public def this() {super(null as String);}
	public def this(o:XByte){this(o,null);}
	public def this(name:String){super(name);}
	public def this(o:XByte, name:String) {super(o,name);}
	public def makeHerbrand(t:XByte)=new Byte(t);
	public def makeHerbrand()=new Byte();
	@NoThisAccess protected def lowerBound() = XByte.MIN_VALUE;
	@NoThisAccess protected def upperBound() = XByte.MAX_VALUE;
	
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
	public static operator (x:XByte):Byte = new Byte(x);

}