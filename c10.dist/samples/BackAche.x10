import c10.lang.Boolean;
import c10.lang.XBoolean;
import c10.lang.XInt;
import c10.lang.XRail;
import c10.lang.*;
import c10.lang.probability.*;
import c10.runtime.herbrand.*;
import c10.runtime.agent.*;
import c10.compiler.agent;
import c10.util.*;

public class BackAche extends Vat.BasicInitCall[XBoolean]{
    val T = Boolean.TRUE, F = Boolean.FALSE;
    static type PV=ProbabilisticValue[XBoolean];
    def backache(Chair:Boolean, Sport:Boolean, Worker:Boolean,Back:Boolean, Ache:Boolean) {
        tell (Chair ~ new PV([T~0.8,F~0.2]));
        tell (Sport ~ new PV([T~0.02,F~0.98]));
        ask( (Chair ~ T) -> (()=> (Worker ~ new PV([T~0.9,F~0.1]))));
        ask( (Chair ~ F) -> (()=>(Worker ~ new PV([T~0.01,F~0.99]))));
        ask( (Chair ~ T) -> ((Sport~T) -> (()=>(Back ~ new PV([T~0.9,F~0.1])))));
        ask( (Chair ~ T) -> ((Sport~F) -> (()=>(Back ~ new PV([T~0.2,F~0.8])))));
        ask( (Chair ~ F) -> ((Sport~T) -> (()=>(Back ~ new PV([T~0.9,F~0.1])))));
        ask( (Chair ~ F) -> ((Sport~F) -> (()=>(Back ~ new PV([T~0.01,F~0.99])))));
        ask( (Back  ~ T) -> (()=>(Ache ~ new PV([T~0.7,F~0.3]))));
        ask( (Back  ~ F) -> (()=>(Ache ~ new PV([T~0.1,F~0.9]))));
        //ask( Ache -> (()=> {Console.OUT.println("Ache is " + Ache);}));
    }
    public def this() {super((i:XInt)=>new Boolean());}
    public def getAgent() =  {
        val Chair = new Boolean("Chair"), 
            Sport = new Boolean("Sport"), Worker=new Boolean("Worker"), 
            Back=new Boolean("Back"), Ache=new Boolean("Ache");
        
        new Now(()=>{
        	    tell(p~ Ache);
                tell(Chair ~ T);
                tell(Sport ~ F);
                backache(Chair,Sport,Worker,Back,Ache);
            })
    };
    @agent public static def main(args: XRail[String]) {
        new MHSampler[XBoolean](10n).run(args, ()=>new BackAche());
    }
}
