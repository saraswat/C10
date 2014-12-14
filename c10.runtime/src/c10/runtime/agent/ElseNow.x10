/*
* jcc -- The Java Concurrent Constraint Programming Language
* Copyright (C) 2003 Vijay A Saraswat
* Please see ../../CopyRight.txt for the copyright declaration.
*/

package c10.runtime.agent;

import x10.util.logging.*;
import x10.util.Stack;
import c10.lang.Herbrand;
import c10.runtime.herbrand.*;
import c10.lang.Abort;

/** An implementation of the if c elseNow A combinator. The workhorse
 * for defaults. Defaults are implemented by backtracking.

 * @author vj 
 * Change History:
 * Tue Apr 08 05:54:50 2003 Created. 
 */

public class ElseNow[T] extends BasicAgent implements ChoicePoint {
	public static val logger = LogFactory.getLog("c10.runtime.agent");
	
	var p:Herbrand[Any];
	var a:Agent;
	var clock:Vat.Clock;

	// Determines whether this agent has a continuation across
	// time or not. If the default is not admissible, then there
	// is no future.

	private var isFuture:Boolean;
	/** The failure continuation. */
	protected var previousCP:ChoicePoint; // upstream, has already been invoked.
	
	/** The success continuation. */
	protected var nextCP:ChoicePoint; // downstream, in success continuation.
	
	/** The trail associated with the current choice point. */
	var trail:Stack[Backtrackable];
	/** The list of conditions that must be checked on successful termination. */
	var ensureKnown:Stack[Herbrand[Any]] = new Stack[Herbrand[Any]]();

    public def this(p:Herbrand[Any], a:Agent) {
	    this.p = p;
	    this.a = a;
	    //clock = (Thread.currentThread() as Vat).clock;
	}

	public def now() throws Abort {
	    // The promise is realized -- nothing else needs to be done!
	    if (p.known()) {
		isFuture = false;
		return;
	    }
	    // Add this CP to the list of collected CPs.
	    if (clock.currentCP == null) {
		// Phase I execution.
		if ( logger.isDebugEnabled())
		    logger.debug( this + " pushed onto collectedCP");
		this.nextCP = Vat.clock.collectedCP;
		clock.collectedCP = this;
	    } else {
		// Phase II execution. 
		if ( logger.isDebugEnabled())
		    logger.debug( this + " being executed");
		// splice yourself onto the stack.
		try {
		    this.previousCP = clock.currentCP;
		    this.nextCP = (previousCP as ElseNow[T]).nextCP; // fix it
		    run();
		} finally {
		    // unsplice this CP out of the CP stack.
		    clock.currentCP = this.previousCP;

		    //this cast needs to be removed..vj Sun Apr 13
		    //06:36:00 2003
		    (previousCP as ElseNow[T]).nextCP = this.nextCP;
		}
	    }
	}
	
    public def next():Agent {

	    // Reinitialize the variables used for choice points.
	    this.nextCP = this.previousCP = null;
	    // cant just reuse trail and ensureKnown -- could be nonempty.
	    this.trail = new Stack[Backtrackable](); 
	    this.ensureKnown = new Stack[Herbrand[Any]]();

	    return isFuture ? a.next() : Agent.IDLE;
	}

	// --------Implementation of ChoicePoint interface ------------------
	/** The first or the second branch has succeeded. Continue with the
	    success continuation. */
	protected def cont() throws Abort {
	    if (this.nextCP == null) {
		// Now we have truly terminated the current phase provided
		// that all the ensureKnowns can be verified.
		clock.baseCP.ensureKnowns(); // may throw an Abort.
		// Yea, at this point we have succeeded!!!
		return;
	    }
	    this.nextCP.run();
	}

	/** The first branch has failed. Revert to the previous CP. */
	protected def fail()  {

	    // Reestablish the previous CP as the current CP
	    if ( logger.isDebugEnabled())
		logger.debug( "clock.currentCP being reset to " +
			      previousCP +".");
	    clock.currentCP = this.previousCP;

	    if ( logger.isDebugEnabled())
		logger.debug( "Trail " + trail + " is being reset.");

	    // Reset the trailed variables.
	    for (item in trail) 
	    	item.resetOnBacktrack();

	    try {
		// Make sure that you set up this promise to be checked.
		clock.baseCP.pushEnsureKnown( p );
		// Cont with the success continuation.
		cont();
	    } catch (z:Abort) {
		clock.baseCP.popEnsureKnown();
		throw z;
	    } catch (z:FailureException) {
		clock.baseCP.popEnsureKnown();
		throw z;
	    }
	}

	/** Push this backtrackable entity onto the trail maintained
	    by this active choice point.
	*/
    public def pushTrail(p:Backtrackable):void {
	    if ( logger.isDebugEnabled())
		logger.debug( "Pushed " + p + " onto " +
			      this + "'s trail.");
	    trail.push(p);
	}

	/** Activate this choice point.
	 */
    public def run() throws Abort, FailureException {
	if (p.known()) {
	    isFuture = false;
	    cont();
	    return;
	}

	try {
	    // Push this onto the CP stack
	    if ( logger.isDebugEnabled())
		logger.debug( this + " is setting up the default case." );
	    this.previousCP = clock.currentCP;
	    clock.currentCP = this;

	    // Check if this is the first entry on the CP stack
	    if (previousCP == null) {
		    // This is the very first CP. 
		    if ( logger.isDebugEnabled())
			logger.debug( this + 
				      " is established as clock.baseCP.");
		    clock.baseCP = this;
		}

		// Initialize the trail.
		trail = new Stack[Backtrackable]();
		// Now set up p to abort if it is realized.
		p.abortWhenRealized();
		isFuture = true;

		// Execute the agent.
		a.now();
		if ( logger.isDebugEnabled())
		    logger.debug( this +
				  " has succeeded locally with the default.");
		cont(); // with the success continuation.
		return;
	} catch (z:FailureException) {
		// Failure of unification triggers backtracking
		if ( logger.isDebugEnabled())
		    logger.debug( this + " has failed out of the default.");

		isFuture = false;
		fail();
	    } catch (z:Abort) {
		// Abort triggers backtracking
		if ( logger.isDebugEnabled())
		    logger.debug( this + " has failed out of the default.");
		isFuture = false;
		fail();
	    }
	}


	/** Ensure that all the promises that should have been known
	 * are now known.
	 */
    public def ensureKnowns():void {
	if ( logger.isDebugEnabled())
	    logger.debug( this + "is testing ensureKnowns.");

	for (promise in ensureKnown) 
	    promise.ensureKnown(); // may throw Abort.
    }

    public def popEnsureKnown():void {
	if ( logger.isDebugEnabled())
	    logger.debug( this + "is popping an ensureKnown.");
	ensureKnown.pop();
    }
    /** Establish this promise as one that will have to be known
     * at successful termination.  This method will be invoked on
     * only one ChoicePoint at a time instant, namely the baseCP.
     */
    public def pushEnsureKnown( p:Herbrand[Any]) {
	if ( logger.isDebugEnabled())
	    logger.debug( this + "has accepted " + p + 
			  " as an ensureKnown.");
	ensureKnown.push( p );
    }
}
