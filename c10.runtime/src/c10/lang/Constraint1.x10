package c10.lang;

public class Constraint1[T](a:Herbrand[T],b:Herbrand[T]) extends Constraint {
	public operator this(){
		//Console.OUT.println("Executing constraint1 " + a + " equals " + b);
		a.equate(b);
		//Console.OUT.println("Done Executing constraint1 " + a + " equals " + b);
	}
	public operator this -> (o:()=>HAgent):HAgent = new HAgent() {
		public operator this()  {
			a.runWhenRealized(()=>{
				//Console.OUT.println("Realized 3" + a + " b=" + b + " Executing " + o);
				if (b==null || a.equals(b)) {
					val x = o();
					//Console.OUT.println("Realized 3 executing " + x);
					x();
				}
			});
		};
		public def toString()="()=>HAgent " + o;
	};
	public operator this -> (o:HAgent):HAgent = new HAgent() {
		public operator this()  {
			a.runWhenRealized(()=>{
				//Console.OUT.println("Realized 4" + a + "Executing " + o);
				if (b==null || a.equals(b)) {
					o();
				}
			});
		};
		public def toString()="HAgent " + o;
	};
	public operator this -> (o:()=>void):HAgent = new HAgent() {
		public operator this()  {
			a.runWhenRealized(()=>{
			//	Console.OUT.println("Realized 5" + a + "Executing " + o);
				if (b==null || a.equals(b)) {
					o();
				}
			});
		};
	};
	public def toString()=a + "~"  +b;
}