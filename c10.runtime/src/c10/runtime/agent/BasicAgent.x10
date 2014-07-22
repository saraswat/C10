package c10.runtime.agent;

/** Basic Agent implements the Agent interface and is subclassed by
 * other Agents. A convenient place to hang default implementations of
 * now, isQuiescentNow and next. Subclassing agents need override only
 * those methods which are different for them.

 * @author vj
*/
import c10.lang.Herbrand;
import c10.lang.Boolean;

// vj TODO: check that neverQuiescent and alwaysQuiescent are set right.
public class BasicAgent implements Agent, java.lang.Cloneable {
	protected val neverQuiescent = new Boolean();
	protected val alwaysQuiescent = new Boolean(true);
	public def this() {}
	/** Does nothing at the current time instant.
	 */
	public def now():void {}
	/** The default behavior is that an Agent is never quiescent now. */
	public def isQuiescentNow():Boolean=neverQuiescent();
	protected def neverQuiescent()=neverQuiescent;
	protected def alwaysQuiescent()=alwaysQuiescent;
	
	/** Does nothing for subsequent time instants.
	 */
	public def next():Agent=Agent.IDLE;
	def clone():BasicAgent = new BasicAgent();

	public def copy():Agent = this.clone();
	public def toString():String = "<" + this.typeName() + " " + hashCode()+">";
}
