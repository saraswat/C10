package c10.compiler;

import x10.lang.annotations.MethodAnnotation;

/**
 * @Agent marks those methods whose body should be interpreted as queries.
 */
public interface query extends MethodAnnotation { }
