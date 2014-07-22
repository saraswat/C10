import c10.lang.Boolean;
import c10.lang.XBoolean;
import c10.lang.XInt;
import c10.lang.probability.*;
import c10.runtime.herbrand.*;
import c10.runtime.agent.*;
import c10.compiler.Agent;
import c10.util.*;

public class BackAche extends Vat.BasicInitCall[XBoolean]{
    val True = Boolean.TRUE, False = Boolean.FALSE;
    static type PV=ProbabilisticValue[XBoolean];
    def backache(Chair:Boolean, Sport:Boolean, Worker:Boolean,Back:Boolean, Ache:Boolean) {
        Chair ~ new PV([True~0.8,False~0.2]);
        Sport ~ new PV([True~0.02,False~0.98]);
        Worker ~ new BooleanCasePD(Chair, [new PV([True~0.9,False~0.1]) as PD[XBoolean],
                                           new PV([True~0.01,False~0.99])]);
        Back ~ new BooleanCasePD2(Chair, Sport, [new PV([True~0.9,False~0.1]) as PD[XBoolean],
                                                 new PV([True~0.2,False~0.8]),
                                                 new PV([True~0.9,False~0.1]),
                                                 new PV([True~0.01,False~0.99])
                                                 ]);
        Ache ~ new BooleanCasePD(Back, [new PV([True~0.7,False~0.3]) as PD[XBoolean],
                                        new PV([True~0.1,False~0.9])]);
    }
        
    public def this() {super((i:XInt)=>new Boolean());}
    public def varName()="Ache";
    public def getAgent() =  {
        val Chair = new Boolean("Chair"), 
        Sport = new Boolean("Sport"), Worker=new Boolean("Worker"), Back=new Boolean("Back"),
        Ache=new Boolean("Ache");
        new Now(()=>{
                p.equate(Ache); // result variable
                Chair.equate( True);
                Sport.equate(True);
                backache(Chair,Sport,Worker,Back,Ache);
            })
    };
    @Agent public static def main(args: XRail[String]) {
        new SamplingDriver[XBoolean](1000n).run(args, ()=>new BackAche());
    }
}
