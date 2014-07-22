package c10.runtime.agent;

/** An implementation of the clock B do A TCC combinator.

* @author vj
*/

public class ClockDo extends BasicAgent {
	var clock:Agent;
	var body:Agent;
	var tick: x10.lang.Boolean;
	public def this( c:Agent, b:Agent) {
	    this.clock = c;
	    this.body = b;
	}
	public def now()  {
	    clock.isQuiescentNow().runWhenRealized(()=>{
			tick = true;
			body.now();
		});
	}
	// TBD -- can we produce a meaningful isQuiescentNow promise?

	/** If the current time tick has been sent through by the controlling
	    clock, then execute for one step (both the clock and the body).
	*/
	public def next():Agent {
		if (tick) {
			tick = false;
			body = body.next();
			clock = clock.next();
		}
		return this;
	}
}
