package c10.lang;

public class Constraint2[T] extends Constraint {
	val a:Herbrand[T];
	val b:T;
	public def this(a:Herbrand[T],b:T) {
		//Console.OUT.println("Constructing constraint2 " + a + " equals " + b);
		this.a=a; this.b=b;
	}
	public operator this():void{
		//Console.OUT.println("Executing constraint2 " + a + " equals " + b);
		a.equate(b);
		//Console.OUT.println("Done Executing constraint2 " + a + " equals " + b);
	}
	public operator this -> (o:()=>HAgent):HAgent = new HAgent() {
		public operator this()  {
			a.runWhenRealized(()=>{
			//	Console.OUT.println("Realized0 " + a + " Executing " + o);
				if (b==null || a().equals(b)) {
					o()();
				}
			});
		};
		public def toString()="()=>HAgent " + o;
	};
	public operator this -> (o:HAgent):HAgent = new HAgent() {
		public operator this() {
			a.runWhenRealized(()=>{
		//		Console.OUT.println("Realized1 " + a + "Executing " + o);
				if (b==null || a().equals(b)) {
					o();
				}
			}); 
		
		};
		public def toString()="HAgent " + o;
	};
	public operator this -> (o:()=>void):HAgent = new HAgent() {
		public operator this()  {
			a.runWhenRealized(()=>{
			//	Console.OUT.println("Realized2 " + a + "Executing " + o);
				if (b==null || a().equals(b)) {
					o();
				}
			});
		};
		public def toString()="()=>void  " + o;
	};
	public def toString()=a + "~"  +b;
}