package c10.lang;

public class Rail[T] extends Atom[XRail[T]]{
	public def this() {super();}
	public def this(o:XRail[T]) {super(o);}
	
	public def map[S](f:(T)=>S): Rail[S] 
	  = new Rail(new XRail[S](atom.size, (i:XLong)=> f(this.atom(i))));
	
	public def reduce(f:Reducible[T]):T { 
	
		var r:T = f.zero();
		//Console.OUT.println("Golden: atom=" + atom + "r=" + r);
		for (v in atom) { 
			r = f(r,v);
		}
		return r;
	}
	//TODO: implement equateDerefed() and isoEquateDerefed()
	// Then we can simply use a Rail of terms to return the result of a computaiton.
	public def makeHerbrand()=new Rail[T]();
	public def makeHerbrand(t:XRail[T])=new Rail[T](t);
}