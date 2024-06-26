/*
 * CompositeFunctionCreator.swift
 * guunits_generator
 *
 * Created by Callum McColl on 29/10/19.
 * Copyright © 2019 Callum McColl. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above
 *    copyright notice, this list of conditions and the following
 *    disclaimer in the documentation and/or other materials
 *    provided with the distribution.
 *
 * 3. All advertising materials mentioning features or use of this
 *    software must display the following acknowledgement:
 *
 *        This product includes software developed by Callum McColl.
 *
 * 4. Neither the name of the author nor the names of contributors
 *    may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * -----------------------------------------------------------------------
 * This program is free software; you can redistribute it and/or
 * modify it under the above terms or under the terms of the GNU
 * General Public License as published by the Free Software Foundation;
 * either version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see http://www.gnu.org/licenses/
 * or write to the Free Software Foundation, Inc., 51 Franklin Street,
 * Fifth Floor, Boston, MA  02110-1301, USA.
 *
 */

/// A function creator that delegates all methods to stored body creators, definition creators,
/// and numeric converters.
public struct CompositeFunctionCreator<
    BodyCreator: FunctionBodyCreator,
    DefinitionCreator: FunctionDefinitionCreator,
    NumericConverter: NumericConverterProtocol
>: FunctionCreator where BodyCreator.Unit == DefinitionCreator.Unit {

    /// The Unit is concistent between the different creators.
    public typealias Unit = DefinitionCreator.Unit

    /// The body creator which will create function bodies.
    var bodyCreator: BodyCreator

    /// The definition creator which will generate function definitions.
    var definitionCreator: DefinitionCreator

    /// The numeric converter which will generate conversion code.
    var numericConverter: NumericConverter

    /// Generate a statement that converts a numeric typed value to a unit type.
    /// - Parameters:
    ///   - str: The value to convert.
    ///   - type: The type of the value.
    ///   - unit: The unit to convert to.
    ///   - sign: The sign of the unit.
    /// - Returns: The statements which converts *str* to a unit.
    public func convert(
        _ str: String, from type: NumericTypes, to unit: DefinitionCreator.Unit, sign: Signs
    ) -> String {
        numericConverter.convert(str, from: type, to: unit, sign: sign)
    }

    /// Generate a statement that converts a unit typed value into a numeric typed value.
    /// - Parameters:
    ///   - str: The value to convert.
    ///   - unit: The unit of the current value.
    ///   - sign: The sign of the unit.
    ///   - type: The type to convert into.
    /// - Returns: The statement which performs the conversion.
    public func convert(
        _ str: String, from unit: DefinitionCreator.Unit, sign: Signs, to type: NumericTypes
    ) -> String {
        numericConverter.convert(str, from: unit, sign: sign, to: type)
    }

    /// Generate a function body that converts a unit into another unit.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - otherUnit: The unit to convert to.
    ///   - sign: The sign of the first unit.
    ///   - otherSign: The sign of the second unit.
    /// - Returns: The function body which converts the unit.
    public func createFunction(unit: Unit, to otherUnit: Unit, sign: Signs, otherSign: Signs) -> String {
        bodyCreator.createFunction(
            unit: unit,
            to: otherUnit,
            sign: sign,
            otherSign: otherSign
        )
    }

    /// Generate a function definition for a function that converts a unit into another unit.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - otherUnit: The unit to convert to.
    ///   - sign: The sign of the first unit.
    ///   - otherSign: The sign of the second unit.
    /// - Returns: The function definition for a function that would perform this conversion.
    public func functionDefinition(
        forUnit unit: Unit, to otherUnit: Unit, sign: Signs, otherSign: Signs
    ) -> String {
        definitionCreator.functionDefinition(
            forUnit: unit,
            to: otherUnit,
            sign: sign,
            otherSign: otherSign
        )
    }

    /// Generate a function definition for a function that converts a unit type into a numeric type.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - sign: The sign of the unit.
    ///   - type: The numeric type to convert to.
    /// - Returns: The function definition of this conversion function.
    public func functionDefinition(forUnit unit: Unit, sign: Signs, to type: NumericTypes) -> String {
        definitionCreator.functionDefinition(forUnit: unit, sign: sign, to: type)
    }

    /// Generate a function definition for a function that converts a numeric type into a unit type.
    /// - Parameters:
    ///   - type: The numeric type to convert from.
    ///   - unit: The unit type to convert to.
    ///   - sign: The sign of the unit type.
    /// - Returns: The function definition for this conversion function.
    public func functionDefinition(from type: NumericTypes, to unit: Unit, sign: Signs) -> String {
        definitionCreator.functionDefinition(from: type, to: unit, sign: sign)
    }

}
