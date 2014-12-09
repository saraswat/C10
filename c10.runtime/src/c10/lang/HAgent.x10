package c10.lang;

public  class HAgent {
	public operator this():void{
		Console.OUT.println("Golden: Should never ever happen " + this);
	}
	public operator this & (o:HAgent) = new HAgent() {
		public operator this() = {
			HAgent.this();
			o();
		}
	};
	public def toString() = " HAgent ?" + hashCode();
}