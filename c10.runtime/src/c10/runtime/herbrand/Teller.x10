package c10.runtime.herbrand;
import c10.lang.Herbrand;

/** The basic interface implemented by a handle to a Port.
 * @author vj
 */
public interface Teller[T] {
    def equate( p:Herbrand[T]):void;
}
