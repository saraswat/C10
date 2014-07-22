/*
* jcc -- The Java Concurrent Constraint Programming Language
* Copyright (C) 2003 Vijay A Saraswat
* Please see ../../CopyRight.txt for the copyright declaration.
*/
package c10.tests.cc;

import c10.lang.*;
import c10.lang.Long;
import c10.lang.Rail;
import c10.runtime.herbrand.*;
import c10.util.SamplingDriver;
import c10.runtime.agent.*;
import c10.lang.probability.Uniform;

/** 
 * @author vj
 */
public class UniformSampler extends Vat.BasicInitCall[XLong] {
	public def this() {super((i:XInt)=>new Long());}
	
	public def getAgent() =  new Now(()=>{
		p ~ new Uniform[XLong](1, 10, (a:XDouble)=> (1+9*a) as XLong);
		});
    
    public static def main(args:XRail[String]) {
    	new SamplingDriver[XLong](10).run(args, ()=>new UniformSampler());
    }
}
