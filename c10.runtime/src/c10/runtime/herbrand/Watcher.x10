/*
 * jcc -- The Java Concurrent Constraint Programming Language
 * Copyright (C) 2003 Vijay A Saraswat
 * Please see ../../CopyRight.txt for the copyright declaration.
 */
package c10.runtime.herbrand;

import x10.util.logging.*;
import x10.util.Stack;
import c10.runtime.agent.Agent;
import c10.lang.*;

/** Represent the watchers of an object. Now made backtrackable. A
 * watcher may be trailed multiple times -- in fact it will be trailed
 * as many times as add/addWatchers is called on it after a choice
 * point has been established. On backtracking, the last element added
 * is popped.
 * 
 * @author vj
 */

public class Watcher  implements Backtrackable {
	public static val logger = LogFactory.getLog("c10");
	
	var stack:Stack[Any];
	//private val clock: Vat.Clock;
	public def this( agent:()=>void ) {
		stack = new Stack[Any]();
		stack.push( agent );
		// clock = Vat.clock;
	}
	public def this( agent:()=>XBoolean ) {
		stack = new Stack[Any]();
		stack.push( agent );
		// clock = Vat.clock;
	}
	
	public def add( agent:()=>void ) {
		trailIfNecessary();
		stack.push( agent );
	}
	public def add( agent:()=>XBoolean ) {
		trailIfNecessary();
		stack.push( agent );
	}
	public def resetOnBacktrack() {
		if ( logger.isDebugEnabled()) logger.debug( this + " is being reset on backtrack.");
		if (! stack.isEmpty()) stack.pop();
		if ( logger.isDebugEnabled()) logger.debug( this + " has been reset.");
	}
	protected def trailIfNecessary() {
		val clockLastCP = Vat.clock.currentCP;
		if (clockLastCP == null) return;
		clockLastCP.pushTrail( this );
	}
	
	public def addWatchers( watcher:Watcher) {
		trailIfNecessary();
		stack.add( watcher.stack);
	}
	
	public def activate()  {
		// Clone the stack -- so it is not destroyed on activation.
		// Backtracking is implemented assuming that the stack
		// of calls is not destroyed.
		stack = this.activate(stack.clone() as Stack[Any], new Stack[Any]());
	}
	private def activate( stack:Stack[Any], result:Stack[Any] ):Stack[Any]  {
		if (stack == null) return result;
		for (next in stack) {
			if (next instanceof ()=>void) {
				(next as ()=>void)();
				result.add(next); // retain these guys
			}
			else if (next instanceof ()=>XBoolean) {
				val x= (next as ()=>XBoolean)();
				if (! x) result.add(next);
			}
			else result.add(activate(next as Stack[Any], new Stack[Any]()));
		}
		return result;
	}
}


