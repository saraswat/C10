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

public class Ask[T](p:Herbrand[T],other:Herbrand[T], a:Agent) extends BasicAgent {
	var n:Agent=Agent.IDLE;
	
	/** Run the agent a if execution in the current time instant
	 * is able to realize the promise p.
	 */
	public def this( p: Herbrand[T], a:Agent) {
		this( p, null, a);
	}
	public def this(p:Herbrand[T], q:Herbrand[T], a:Agent) {
		property(p,q,a);
	}
	public def this(p:Herbrand[T], q:T, a:Agent) {
		property(p,p.makeHerbrand(q),a);
	}
	
	public def now():void {
		p.runWhenRealized(()=>{
				if (other==null || p.equals(other)) {
					a.now();
					n=a;
				}
			});
	}
	public def next()=n.next();
}
