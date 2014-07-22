/**
 * Released under the Eclipse Public Licence. Please see C10 project licence.
 * (c) IBM 2014
 */
package c10.lang;

import x10.util.logging.*;
import c10.runtime.herbrand.FailureError;

/** An atom represents an indivisible symbolic entity.
 * 
 * @author vj
 */
public  class Atom[T](name:String) { T haszero} extends Herbrand[T]  {
	//public static val NULL = new Atom[Any]( null);
	 val atom:T;
	 
	 public def this(){this(null as String);}
	/** Create an unbound Atom. */
	public def this(s:String) {
		super( false );
		property(s);
		atom = Zero.get[T]();
	}
	public def this(o:T){this(o,null);}

	/** Create an atom that contains the object o.
	 */
	public def this(o:T, s:String) {
		super( true );
		property(s);
		atom = o;
	}
	public static operator[T] (x:T){T <: T,T haszero}:Atom[T] = new Atom[T](x);
	protected def getValueDerefed()=atom;

	/** An atom is considered equal to another object if that is
	 * an atom as well, and either both are null or their
	 * contained values are equal.
	 */
	protected def equalsDerefed( other:Herbrand[T] ):XBoolean {
		// TODO: BUG... this line used to be:
		// if (atom == null) return (other == null);
		// this should not work!
		if (this==other) return true;
		if (atom == Zero.get[T]()) return (other == Zero.get[T]());
		return atom.equals( (other as Atom[T]).atom );
	}
	/* The hashcode returned by the atom is that of the object if
	 * the contained atom is null; otherwise it is that of the
	 * contained object. This satisfies the property that if two
	 * atoms are equal then their corresponding hashcodes are
	 * equal. */
	protected def hashCodeDerefed():XInt {
		return (atom == null) ? super.hashCodeDerefed() : atom.hashCode();
	}
	
	protected def equateBothDerefedAndRealized( other:Herbrand[T]):void {
		val otherAtom =other as Atom[T];
		// TODO: File a jira. hmm used to be null == atom.. should not compile!
		if ( Zero.get[T]() == atom ) {
			if ( Zero.get[T]() != otherAtom.atom )
				throw new FailureError(" Null is equated to non-null " + otherAtom.atom);
			return;
		}
		if (! atom.equals( otherAtom.atom ))
			throw new FailureError( this
					+ " does not have the same atom as "
					+ otherAtom.atom);
	}
	protected def valueToStringDerefed(complete:XBoolean):String {
		return 
		complete 
		? "<" + typeName() + (atom == null ? "null" : atom) + ">"
				: (atom == null ? "null" : atom.toString());
	}
	public def makeHerbrand(o:T)=new Atom[T](o);
	public def makeHerbrand()=new Atom[T]();
    protected def isoEqualsDerefed(o:Herbrand[T]) = (o as Atom[T]).atom==atom;
    public def name()=name==null? super.name():name;
}
