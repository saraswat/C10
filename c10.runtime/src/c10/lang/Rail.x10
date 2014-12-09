package c10.lang;
import c10.runtime.herbrand.FailureException;
// XTENLANG 
// Does not work -- Atom[XRail[T]] is a problem. 
public class Rail[T] extends Atom[XRail[T]]{
	public def this() {super();}
	public def this(o:XRail[T]) {super(o);}
	
	public static def map[T,S](r:XRail[T], f:(XLong, T)=>S): XRail[S] 
	  = new XRail[S](r.size, (i:XLong)=> f(i, r(i)));
	public static def map[T,S](r:XRail[T], f:(T)=>S): XRail[S] 
	= new XRail[S](r.size, (i:XLong)=> f(r(i)));
	
	public static def reduce[T](r:XRail[T], f:Reducible[T]):T { 
		var a:T = f.zero();
		for (v in r) a = f(a,v);
		return a;
	}
	protected def equalsDerefed(o:Herbrand[XRail[T]]):XBoolean {
		if (! (o instanceof Rail[T])) return false;
		val oo = o as Rail[T];
		return equalsCheck(atom, oo.atom);
	}
	
	protected def equalsCheck(a:XRail[T], b:XRail[T]):XBoolean {
		if (a.range() != b.range()) return false;
		for (i in a.range()) if (! a(i).equals(b(i))) return false;
		return true;
	}
	//TODO: implement equateDerefed() and isoEquateDerefed()
	// Then we can simply use a Rail of terms to return the result of a computaiton.
	public def makeHerbrand()=new Rail[T]();
	public def makeHerbrand(t:XRail[T])=new Rail[T](t);
}