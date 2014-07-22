/**
 * Released under the Eclipse Public Licence. Please see C10 project licence.
 * (c) IBM 2014
 */

package c10.lang;
import c10.runtime.agent.*;
import c10.lang.probability.*;
import x10.util.Pair;
public class Boolean extends Atom[XBoolean]{
	public operator this~(p:Probability):ProbValueItem[XBoolean] = ProbValueItem[XBoolean](atom,p);
	public operator this ** (b:Boolean)=Pair[Boolean,Boolean](this,b);
	public static val FALSE = new Boolean(false);
	public static val TRUE = new Boolean(true);
	public def this() {this(null as String);}
	public def this(o:XBoolean){this(o,null);}
	public def this(name:String){super(name);}
	public def this(o:XBoolean, name:String) {super(o,name);}
	public def makeHerbrand(t:XBoolean)=new Boolean(t);
	public def makeHerbrand()=new Boolean();
	public static operator(x:XBoolean):Boolean = new Boolean(x);
	
	public operator this && (x:XBoolean):Boolean = x? this : FALSE;
	public operator (x:XBoolean) && this:Boolean = x? this : FALSE;
	public operator (x:Boolean) && this:Boolean = {
		val result = new Boolean();
		(new Case2(x, this, (a:XBoolean, b:XBoolean)=> new Tell(result, (a&&b) as Boolean))).now();
		result
	}
	public operator this || (x:XBoolean):Boolean = x? TRUE : this;
	public operator (x:XBoolean) || this:Boolean = x? TRUE :this;
	public operator (x:Boolean) || this:Boolean = {
		val result = new Boolean();
		(new Case2(x, this, (a:XBoolean, b:XBoolean)=> new Tell(result, (a||b) as Boolean))).now();
		result
	}
	
	
}