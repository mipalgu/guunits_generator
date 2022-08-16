/*
 * DelegatingNumericConverter.swift
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

/// Helper struct that generates C function calls that convert between numeric
/// types and unit types.
public struct DelegatingNumericConverter: NumericConverterProtocol {

    /// Default init.
    public init() {}

    /// Generate the function call that would convert between a numeric type and a unit type.
    /// - Parameters:
    ///   - str: The value to convert from.
    ///   - type: The numeric type of str.
    ///   - unit: The unit type to convert to.
    ///   - sign: The sign of the unit type.
    /// - Returns: The generated c-code for the function call that performs the conversion.
    public func convert<Unit: UnitProtocol>(
        _ str: String, from type: NumericTypes, to unit: Unit, sign: Signs
    ) -> String {
        let helpers: FunctionHelpers<Unit> = FunctionHelpers()
        let cFunction = helpers.functionName(from: type, to: unit, sign: sign)
        return "::" + cFunction + "(\(str))"
    }

    /// Generate the function call that would convert between a unit type and a numeric type.
    /// - Parameters:
    ///   - str: The value to convert.
    ///   - unit: The unit type of the value.
    ///   - sign: The sign of the unit type.
    ///   - type: The numeric type to convert into.
    /// - Returns: The generated C function call that would perform the conversion.
    public func convert<Unit: UnitProtocol>(
        _ str: String, from unit: Unit, sign: Signs, to type: NumericTypes
    ) -> String {
        let helpers: FunctionHelpers<Unit> = FunctionHelpers()
        let cFunction = helpers.functionName(forUnit: unit, sign: sign, to: type)
        return "::" + cFunction + "(\(str))"
    }

}
