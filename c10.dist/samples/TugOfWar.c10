
import x10.util.Random;
import x10.util.List;
import c10.lang.*;
import c10.lang.probability.*;
import c10.lang.Rail;
import c10.lang.Double;
import c10.lang.Int;
import c10.lang.Boolean;
import c10.lang.Reducible;
import c10.runtime.agent.*;
import c10.compiler.Agent;
import c10.runtime.herbrand.Vat;
import c10.util.SamplingDriver;

public class TugOfWar extends Vat.BasicInitCall[XInt] {
	static struct Person(name:String){
		/**
		 * strength is an intrinsic value, so determined once (and stored in a local variable)
		 */
		val strength  =  s();
		static def s():Int= {
			val x = new Int();
			x ~ new Gaussian(100n, 20n);
			x
		};
		// determined per call, a guy’s laziness level can vary with time
		def lazy():Boolean = {
			val x = new Boolean();
			x ~ new ProbabilisticValue([
			                            ProbValueItem(true as XBoolean,0.9),
			                            ProbValueItem(false as XBoolean,0.1)]);
			x 
		}
		def pulling():Int = {
			//lazy() ? strength/2 : strength;
			val x=new Int();
			new Par(new Ask[XBoolean](lazy(), true, new Tell(x, strength/2n)),
					new Ask[XBoolean](lazy(), false, new Tell(x, strength)));
			x
		}
		public def toString()="Person<"+name+ " " + strength + ">";
	}

	static class Team extends Atom[Rail[Person]] {
		def this(){super();}
		def this(t:XRail[Person]){super(new Rail(t));}
		def totalPulling() = { // atom.map((p:Person)=>p.pulling()).reduce(Reducible.SumReducer[Double]());
			val x = new Double();
			runWhenRealized(()=> {
				getValue().map((p:Person)=>p.pulling()).reduce(Reducible.IntSumReducer());
			});
			x
		};
		def winner(other:Team) = { 
			// totalPulling > other.totalPulling ? this : other;
			val x = new Team();
			(new Case2(totalPulling(), other.totalPulling(), 
					(a:XDouble, b:XDouble) => new Tell(x, a>b? this : other))).now();
			x
		}
	}
	static def results(Bob:Person) {
		val Mark=Person("mark"), Tom=Person("tom"), Sam=Person("sam"), 
		Fred=Person("fred"), Jon=Person("jon"), Jim=Person("jim");
		val BM = new Team([Bob, Mark]), TS = new Team([Tom,Sam]), 
		BF=new Team([Bob,Fred]), JJ = new Team([Jon,Jim]); 
		BM.winner(TS);
		BF.winner(JJ);
	}
	
	public def this() {super((i:XInt)=>new Int("r"+i));}
	public def varName()="Bob.strength";
	public def getAgent() =  {
		val Bob = Person("bob");
		new Now(()=>{
			p.equate(Bob.strength); // result variable
			results(Bob); 
		})};
	// The program will print out the posterior probability distribution for Bob, the logical variable
	// in the body of main. The other variables Mark, Tom etc are local to the body of results,
	// and hence marginalized over.
	@Agent public static def main(args: XRail[String]) {
		new SamplingDriver[XInt](1000).run(args, ()=>new TugOfWar());
	}
}