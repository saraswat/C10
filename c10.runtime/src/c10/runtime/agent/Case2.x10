/*
 * jcc -- The Java Concurrent Constraint Programming Language
 * Copyright (C) 2003 Vijay A Saraswat
 * Please see ../../CopyRight.txt for the copyright declaration.
 */

package c10.runtime.agent;
import c10.lang.Herbrand;

/* A simple implementation of the basic TCC Ask agent.
 * 
 * @author vj
 */

public class Case2[S,T](p:Herbrand[S],q:Herbrand[T], f:(S,T)=>Agent) extends BasicAgent {
	var n:Agent=Agent.IDLE;
	
	public def now():void {
		p.runWhenRealized(()=>{
			q.runWhenRealized( () => {
			n= f(p.getValue(), q.getValue());
			n.now();
			});
		});
	}
	public def next()=n.next();
}
