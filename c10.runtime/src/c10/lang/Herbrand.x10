package c10.lang;

import c10.runtime.herbrand.*;
import x10.util.logging.*;
import c10.runtime.agent.AbortAgent;

import x10.compiler.NonEscaping;
import x10.compiler.Native;

/** Promise is the root class for typed terms. Each type of term
 * is a subclass of Promise, e.g. Atom, Integer, List etc.
 * 
 * <p> Invariant for all public methods on this class:
 * ensureCurrent() needs to have been called before the main body of
 * the method is executed. This ensures that this term has a value
 * that is valid for the current time step. If it was bound at an
 * earlier time-step, then that value is reset.
 * 
 * <p> Invariant II: value = null => watcher = null.
 * 
 * @author vj
 */
public abstract class Herbrand[T] implements Teller[T], Backtrackable {
	public operator this ~ (o:Herbrand[T]) = new Constraint1[T](this, o);
	public operator this ~ (o:T) = new Constraint2(this, o);
	
	protected def myTypeName() = (this as Herbrand[T]).typeName();
	public operator this -> (o:HAgent) = new HAgent() {
		public operator this() {
			
			runWhenRealized(()=>{
			//	Console.OUT.println("Herbrand ->HAgent:" + Herbrand.this + " realized. Running " + o);
				o();});
		}
	};
	public operator this -> (o:()=>HAgent) = new HAgent() {
		public operator this() {
			
			runWhenRealized(()=>{
			//	Console.OUT.println("Herbrand ->(()=>HAgent):" +Herbrand.this + " realized. Running " + o);
				o()();
				});
		}
	};
	public operator this -> (oc:()=>void) = new HAgent() {
		public operator this(){
			runWhenRealized(()=>{
			//	Console.OUT.println("Herbrand ->(()=>void):" + Herbrand.this + " realized. Running " + oc);
				oc();});
		}
	};
	
	 public static val logger = LogFactory.getLog("c10");
	 
	
	/** The value to which this variable is bound. Is null if this
	 * term is realized. Otherwise, for an unbound variable,
	 * value = this.  The backupValue implements a local trail
	 * for value. Since value will be assigned only once, one
	 * backup value is sufficient.
	 */
	protected var value:Herbrand[T], backupValue:Herbrand[T];
	
	/** The watcher, if any, for this term. There is no backup
	 * value for this variable. Once a watcher is assigned to a
	 * promise, it remains assigned to the promise throughout this
	 * time instant. This is benign because changes to the watcher
	 * are separately trailed if necessary. We do now have to take
	 * into account the possibility that the watcher field could
	 * be non-empty, but the Watcher may not contain any Nows to
	 * be executed. This is easily done, however.
	 */
	protected var watcher:Watcher;
	
	/** The clock of the TCC vat containing this variable. This
	 * clock is incremented by the Vat when it moves from one
	 * time step to another. The variables are updated
	 * incrementally.
	 */
	//private var clock: Vat.Clock;
	
	/** The time at which this variable was last updated. 
	 * This is never updated on backtracking, since all backtracking
	 * occurs within the same time instant.
	 */
	private var myTimeStamp:XInt;
	
	/** Create a new Promise. A promise is created either realized
	 * (because a concrete value is being created), or unrealized and
	 * unwatched.
	 * 
	 * <p> The Promise's clock is intialized with the current
	 * Vat's. This will be used only when this object is not
	 * realized.
	 * 
	 */
	
	public def this( realized:XBoolean ) {
		super();
		if (! realized) {
			initValue();
			this.backupValue = value;
	//		this.clock = (Thread.currentThread() as Vat).clock;
			this.myTimeStamp = Vat.clock.timeStamp();
		}
	}
	public def this() {this( true);}

	// Hack to bypass X10's strict this-escaping-checks
	// so that this.value=this can be executed in the constructor
	@Native("java", "#this.value=#this")
	@NonEscaping // we can lie!
	private native def initValue():void;
	// ------------------ Implementation of backtracking
	
	/** Reset this entity because a backtrack is happening..
	 * restore its state from the backed up state, and clear
	 * the backed up state.
	 */
	public def resetOnBacktrack() {
		if ( logger.isDebugEnabled())
			logger.debug( this + " is being reset on backtrack.");
		this.value = this.backupValue;
		this.backupValue = null;
		// watchers are never reset on backtracking. However,
		// the watcher pointed to may have an empty stack.
		if ( logger.isDebugEnabled())
			logger.debug( this + " has been reset.");
	}
	
	/** Trail this guy if necessary.  
	 */
	protected def trailIfNecessary() {
	    val clockLastCP = Vat.clock.currentCP;
	    // Do not trail if there is no choice point on the trail.
	    // In this case the bindings are all final!
	    if ( clockLastCP == null) return;
	    clockLastCP.pushTrail( this);
	    this.backupValue = value;
	}
	// ------------------ Implementation of backtracking end.
	
	/** Return the current time stamp. Useful for writing error
	 * messages.
	 */
	public def currentTime() =Vat.clock.timeStamp();
	
	/** Ensure that this variable is current. If it has an old
	 * binding, reinitialize it. Note that if this method is
	 * invoked a second time in the same time step, it has no
	 * effect.
	 * 
	 * <p> Ideally, this method should be inline.
	 */
	
	protected  def ensureCurrent() {
	    // realized values are immutable across time at the top level
	    if (Vat.clock == null || this.myTimeStamp == Vat.clock.timeStamp()) // current
		return;
	    this.myTimeStamp = Vat.clock.timeStamp(); // make it current.
	    this.value = this.backupValue = this; // this is a variable, reset it.
	    this.watcher =  null; // get rid of watchers.
	}
	
	/** Is this Promise still unrealized?
	 * <pre>Precondition: ensureCurrent() has been called in this
	 * timestep.
	 */
	protected def isUnrealized() = value == this;
	
	/** Is this promise unrealized and not watched?
	 * <pre>Precondition: ensureCurrent() has been called in this
	 * timestep.
	 */
	protected def isUnrealizedAndUnwatched() = value == this && watcher == null;
	
	/** Is this promise unrealized and watched?
	 * <pre>Precondition: ensureCurrent() has been called in this
	 * timestep.
	 */
	protected def isUnrealizedAndWatched() = value == this && watcher != null;
	
	/** Is this promise bound?
	 * <pre>Precondition: ensureCurrent() has been called in this
	 * timestep.
	 */        
	protected def isBound() = value != this && value != null;
	
	/** Is this promise realized?
	 */                
	protected def isRealized() =  value == null;
	
	/** Equate this value to another promise, other, which is either
	 * realized or watched.
	 */
	
	protected def equateBothDerefed( other:Herbrand[T] )  throws Abort {
	    if ( this.isUnrealizedAndUnwatched() ) {
		// I am unrealized and unwatched. Make me point to the other.
		this.bind( other );
		return;
	    }
		
	    if ( other.isRealized() ) {
		this.equateDerefedToRealizedPromise( other );
		return;
	    }
		
	    // Logically, the only possibility left now is that
	    // other.isUnrealizedAndWatched(), and 
	    // this.isUnrealizedAndWatched() or this.isRealized().
	    // assert( this.isUnrealizedAndWatched() || this.isRealized());
	    if ( this.isUnrealizedAndWatched() ) other.forwardWatchers( this );
            else 	    // At this point, this.isRealized().
		other.realizeAndAwakenIfNecessary( this );
	}
	
	/** Equate this variable to a term that is known to be derefed
	 * and realized.
	 */
	private def equateToRealizedPromise(other:Herbrand[T] ) throws Abort {
	    val me = this.dereference();
	    me.equateDerefedToRealizedPromise( other );
	}
	
	/** I am dereferenced, and other is realized. Two cases.
	 * (a) I am unrealized. Then set value to other, and awaken watchers.
	 * (b) Else, call equateBothDerefedAndRealized.
	 */
	protected def equateDerefedToRealizedPromise( other: Herbrand[T] ) throws Abort {
	    // assert( other.isRealized());
	    if ( this.isUnrealized()) realizeAndAwakenIfNecessary( other ) ;
	    else equateBothDerefedAndRealized( other );
	}
	
	/** Bind to the given promise. Must not be called on a
	 *  realized value.  Should be private, not public. Added a
	 *  check for realized.
	 * <p>Preconditions: this.isUnrealized().
	 */
	
	protected def bind(other:Herbrand[T] ) {
	    if ( logger.isDebugEnabled())
		logger.debug( this.shortName()
			      + " is being bound to " + other);
	    if (isRealized()) { // error
		if (logger.isDebugEnabled())
		    logger.debug( this.shortName() + " is being bound to " + other);
		return;
	    }
	    trailIfNecessary();
	    value = other;
	}
	/** Forward watchers from this promise to other.
	 * <p>Preconditions: this.isUnrealizedAndWatched(), and
	 * other.isUnrealizedAndWatched().
	 * <p>Postcondition: this isBound.
	 */
	protected def forwardWatchers( other:Herbrand[T] ) {
		if ( logger.isDebugEnabled() ) 
			logger.debug(" Watchers from " + this.shortName()
					+ " are being forward to " + other.shortName());
		trailIfNecessary();
		other.mergeWatchers( watcher );
		watcher = null;
		value = other;        
	}
	
	protected def mergeWatchers( watcher:Watcher ) {
		this.watcher.addWatchers( watcher);
	}
	/** Bind this promise to other.
	 * 
	 * <p>Preconditions: this isUnrealizedAndWatched, and other
	 * isRealized.
	 * 
	 * <p>Postconditions: this isRealized.
	 */
	protected def realizeAndAwakenIfNecessary( other:Herbrand[T] ) 
	throws Abort {
		if ( logger.isDebugEnabled()) 
			logger.debug( this.shortName() + ", with watchers "
					+ watcher + " is being bound to the realized "
					+ other.shortName());
		trailIfNecessary();
		value = other;
		val pending = watcher;
		if ( null != pending ) pending.activate();
	}
	
	
	
	/** If you are unrealized, return this.  If you are realized,
	 * return the value.  If you are bound, return
	 * whatever your binding dereferences to.
	 * 
	 * <p>The net result is that the Promise returned after
	 * dereferencing is not bound: it is either unrealized or
	 * realized.
	 * 
	 * <p> vj Mon Apr 07 14:23:19 2003 Removed the shortening in
	 * order to simplify implementation of backtracking. Revisit
	 * later.
	 * 
	 */
	public final def dereference():Herbrand[T] {
		ensureCurrent();
		if (! isBound()) return this;
		//	    trailIfNecessary();
		return /*value =*/ value.dereference();
	}
	
	
	/** Equate this promise with another. The workhorse of constraint
	 * solving. The other promise and this object can be in any of
	 * the four states.
	 */
	public final def equate(other:Herbrand[T] ) throws Abort {
		if ( logger.isDebugEnabled()) {
			logger.debug( this + " being equated to " + other);
		}
		ensureCurrent();
		val otherPromise = other.dereference();
		if ( otherPromise.isUnrealizedAndUnwatched()) {
			other.bind( this );
			return;
		}
		val me = this.dereference();
		me.equateBothDerefed( otherPromise );
	}
	/**
	 * Equate this promise with a concrete value other of type T.
	 */
	public final def equate(other:T) throws Abort {
		if ( logger.isDebugEnabled()) {
			logger.debug( this + " being equated to " + other);
		}
		ensureCurrent();
		val me = this.dereference();
		me.equateBothDerefed( me.makeHerbrand(other) );
	}
	
	/** Return true iff this promise is equated to a realized term.
	 */        
	public def known( ):XBoolean {
		val me = this.dereference();
		if ( me != this ) {
			return me.known();
		}
		// me = this.
		return ( this.isRealized());
	}
	
	public def ensureKnown() throws Abort {
		if (! known())
			throw new Abort(this + "is not known.");
	}
	/** Returns true iff known() returns false.
	 */
	public def uninstantiated( ) =  ! known();
	
	/** Suspend this call on this variable, if the variable is
	 * unbound, execute it immediately otherwise.
	 * 
	 * <p>A generic extension mechanism for variables!!! Other
	 * subclasses can attach additional code through this mechanism!!
	 * 
	 */
	public def runWhenRealized( call:()=>void) throws Abort {
		if (call == null) return;
		val me = this.dereference();
		if ( me != this ) {
			me.runWhenRealized( call );
			return;
		}
		this.runWhenRealizedDerefed( call );
	}
	
	
	
	public def runWhenRealizedDerefed( call:()=>void) 
	throws Abort {
		if ( this.isUnrealizedAndUnwatched() ) {
			this.watcher = new Watcher(call);
			return;
		}
		if ( this.isUnrealizedAndWatched()) {
			this.watcher.add( call );
			return;
		}
		if ( logger.isDebugEnabled() )
			logger.debug("runWhenRealized: calling rightaway, " + this + " is realized.");
		call();
		if ( logger.isDebugEnabled() )
			logger.debug("runWhenRealized:  " + call + " terminated.");
	}
	
	
	public def abortWhenRealized( ) 
	throws Abort {
		val me = this.dereference();
		if ( me != this ) {
			me.abortWhenRealized();
			return;
		}
		this.abortWhenRealizedDerefed();
	}        
	
	public def abortWhenRealizedDerefed() 
	throws Abort {
		val call = ()=>{throw new Abort();};
		if ( this.isUnrealizedAndUnwatched() ) {
			this.watcher = new Watcher(call);
			return;
		}
		if ( this.isUnrealizedAndWatched()) {
			this.watcher.add( call );
			return;
		}
		if ( logger.isDebugEnabled() )
			logger.debug("Variable is realized. Aborting...");
		throw new Abort();
	}
	
	/** Are two terms equal?  Dereference both terms and check
	 * if they are equal. Subclasses should override equalsDerefed.
	 */
	
	public def equals( o: Any ):XBoolean {
		ensureCurrent();
		if (! (o instanceof Herbrand[T])) return false;
		val other = (o as Herbrand[T]).dereference();
		val me  = this.dereference();
		return me.equalsDerefed( other );
	}
	/** Subclasses may wish to override this to declare
	 * two derefed terms equal if they are structurally
	 * equal.
	 */
	protected def equalsDerefed( o:Herbrand[T]) = this == o;
	
	/** Are two terms isomorphic?  Two terms are isomorphic if they have the
	 * same shape, e.g. in the store X in [L,U], Y in [L, U] X and Y are 
	 * isomorphic. i.e. if (delta X.c)[Z/X] <-> (delta Y.c)[Z/Y],
	 * where Z is a fresh variable, and delta X.c equals exists Y1,...Yn.c 
	 * where the free variables of c are X, Y1, ..., Yn.
	 * 
	 * Dereference both terms and check
	 * if they are isomorphic. Subclasses should override isoEqualsDerefed.
	 */
	
	public def isoEquals( o: Any ):XBoolean {
		ensureCurrent();
		if (! (o instanceof Herbrand[T])) return false;
		val other = (o as Herbrand[T]).dereference();
		val me  = this.dereference();
		return me.isoEqualsDerefed( other );
	}
	/** Subclasses may wish to override this to declare
	 * two derefed terms equal if they are structurally
	 * equal.
	 */
	protected def isoEqualsDerefed( o:Herbrand[T]) = this == o;
	
	/** Return the hashcode of the object that you dereference
	 * to. This supports the notion that a variable equated to a term
	 * is considered equal to that term.
	 */
	public def hashCode():XInt {
		ensureCurrent();
		return dereference().hashCodeDerefed();
	}
	
	protected def hashCodeDerefed() = System.identityHashCode(this);
	
	/** This does not dereference its argument immediately, but
	 * prints out a string that says that this object is equal to
	 * its derefed value.
	 */
	public def toString():String {
		this.ensureCurrent();
		return  (
		this.isRealized() ? ("(" + name() +"=)"+valueToStringDerefed( false )) 
				: (this.isUnrealized() ? shortName() : "<" + name() + " = " + dereference()+">"));
	}
	/** This does not dereference its argument immediately, but
	 * prints out a string that says that this object is equal to
	 * its derefed value.
	 * @paremeter complete -- if true, behave as toString(), otherwise
	 * omit the surrounding "<" ... ">"
	 */
	public def toString( complete:XBoolean):String {
		this.ensureCurrent();
		if (complete) return toString( );
		return  (
		this.isRealized()
		? ("(" + name() +"=)"+ valueToStringDerefed( complete ))
				: this.isUnrealized()
				? shortName()
						: name() + " = " + dereference());
	}
	protected  def shortName():String =  "<" + name() + ">";
	protected  def name():String  = typeName() + " #" + System.identityHashCode(this);
	
	/** Suspend until this variable is realized, and then
	 * print the value to the given output stream.
	 */
	public def  print( o:x10.io.Printer) {
		if ( o == null ) return;
		val me = this.dereference();
		me.printDerefed( o );
	}
	protected def printDerefed( o:x10.io.Printer) {
		try {
			if ( this.isUnrealized()) {
				this.runWhenRealizedDerefed( ()=>{
						o.println( Herbrand.this.toString());
					});
				return;
			}
			o.println( this.toString());
		} catch (z:Abort) {
			// Wont happen.
		}
	}
	
	/** Produce the String version of a derefed object that is realized.
	 * @parameter complete -- as in toString.
	 */
	abstract protected def valueToStringDerefed( complete:XBoolean):String;
	
	/** Equate the current object to the argument, assuming that
	 * both are derefed and realized. Needs to be implemented by
	 * each subclass. This method contains the code that defines
	 * what happens when two instances of the data-structure are
	 * equated with each other. The implementation does not need
	 * to ensureCurrent the object or its argument, since they
	 * are realized.
	 * 
	 * @parameter other -- the object that this is being equated with.
	 */
	abstract protected def equateBothDerefedAndRealized(other:Herbrand[T]):void; 
	
	public def getValue():T = this.dereference().getValueDerefed();
	public operator this():T=getValue();
	abstract protected def getValueDerefed():T;
	abstract public def makeHerbrand(l:T):Herbrand[T];
	abstract public def makeHerbrand():Herbrand[T];
	
}
















