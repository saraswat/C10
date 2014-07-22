package c10.lang.probability;

import c10.lang.XDouble;
import c10.lang.XInt;
import c10.lang.Double;
/**
 * An imlementation of a Gaussian distribution with mean mean and variance
 * sigma.
 * @author vj
 */
public class Gaussian(mean:XInt, sigma:XInt) extends PD[XInt] {
	
	protected def sample(random:XDouble) = ((sigma*random)+mean) as XInt;
	
}