package c10.dist;


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
import c10.compiler.agent;
import c10.runtime.herbrand.Vat;
import c10.util.SamplingDriver;

public class TugOfWar2 extends Vat.BasicInitCall[XInt] {
	static val T = Boolean.TRUE, F = Boolean.FALSE;
	static val Plus = Reducible.IntSumReducer();
	static type PV=ProbabilisticValue[XBoolean];
	static struct Person(name:String){
		val strength:Int  = s();
		static def s() = { 
			val x = new Int();
			tell(x ~ new Gaussian(100n, 20n));
			x
		};
		def lazy():Boolean = { // determined per call
			val x = new Boolean();
			tell(x ~ new PV([T~0.9,F~0.1]));
			x 
		}
		def pulling():Int = {
			val x=new Int(this+".pulling");
			val l = lazy();
			ask( (l~true) -> (x~(strength/2n)) );
			ask( (l~false) -> (x~strength) );
			x
		}
		public def toString()="Person<"+name+ " " + strength + ">";
	}
	static  struct Team (r:Rail[Person]) {
		def this(t:XRail[Person]){property(new Rail(t));}
		def totalPulling() = Rail.reduce(Rail.map(r(), (p:Person)=>p.pulling()), Plus)();
		def winner(other:Team) = (totalPulling()>other.totalPulling()) ? this : other;
		public def toString()="Team<" + r()+">";
	}
	static def results(Bob:Person) {
		val Mark=Person("mark"), Tom=Person("tom"), Sam=Person("sam"), 
		Fred=Person("fred"), Jon=Person("jon"), Jim=Person("jim");
		val BM = Team([Bob, Mark]), TS = Team([Tom,Sam]), 
		BF = Team([Bob,Fred]), JJ = Team([Jon,Jim]); 
		tell (BM.winner(TS).r ~ BM.r);
		tell (BF.winner(JJ).r ~ BF.r);
	}
	public def this() {super((i:XInt)=>new Int("r"+i));}
	public def varName()="Bob.strength";
	public def getAgent() =  {
		val Bob = Person("bob");
		new Now(()=>{
			tell(p ~ Bob.strength); // result variable
			results(Bob); 
		})};
	@agent public static def main(args: XRail[String]) {
		new SamplingDriver[XInt](1).run(args, ()=>new TugOfWar2());
	}
}