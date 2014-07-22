package c10.lang.probability;

public struct ProbValueItem[T] {
	public val t:T;
	public val p:Probability;
	public def this(t:T, p:Probability) {
		this.t=t;
		this.p=p;
	}
}