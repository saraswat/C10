package c10.runtime.herbrand;

/* The basic interface implemented by an Agent. The method returns a
 * Promise that is instantiated if the agent is quiescent at the
 * current time instant. This allows ClockDo to be implemented.

 * @seeAlso jcc.lang.ClockDo

 * @author vj
 */
import c10.lang.Boolean;
public interface Quiescent {
   def isQuiescentNow():Boolean;
}
