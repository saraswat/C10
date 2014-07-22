/*
 *  This file is part of the X10 project (http://x10-lang.org).
 *
 *  This file is licensed to You under the Eclipse Public License (EPL);
 *  You may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *      http://www.opensource.org/licenses/eclipse-1.0.php
 *
 *  (C) Copyright IBM Corporation 2006-2014.
 */

package c10.lang;


/**
 * A set of common arithmetic operations.
 * Note: some operators changed to defs below because of XTENLANG-3402. Fix once
 * that is fixed.
 */
public interface Arithmetic[T] {
	def zero():T;
    /**
     * A unary plus operator.
     * A no-op.
     * @return the value of the current entity.
     */
   
    operator + this: T;

    /**
     * A unary minus operator.
     * Negates the operand.
     * @return the negated value of the current entity.
     */
  
    operator - this: T;

    /**
     * A binary plus operator.
     * Computes the result of the addition of the two operands.
     * @param that the other entity
     * @return the sum of the current entity and the other entity.
     */
   
    //operator this + (that: T): T;
def add(that:T):T;

    /**
     * A binary minus operator.
     * Computes the result of the subtraction of the two operands.
     * @param that the other entity
     * @return the difference of the current entity and the other entity.
     */
 
   // operator this - (that: T): T;
def sub(that:T):T;
    /**
     * A binary multiply operator.
     * Computes the result of the multiplication of the two operands.
     * @param that the other entity
     * @return the product of the current entity and the other entity.
     */
   
   // operator this * (that: T): T;
    def mul(that:T):T;
    /**
     * A binary divide operator.
     * Computes the result of the division of the two operands.
     * @param that the other entity
     * @return the quotient of the current entity and the other entity.
     */
  
    //operator this / (that: T): T;
    def div(that:T):T;
}
