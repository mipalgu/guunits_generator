/*
 * GradualFunctionCreator.swift
 * guunits_generator
 *
 * Created by Callum McColl on 15/6/19.
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

struct GradualFunctionCreator<Unit: UnitProtocol>: FunctionCreator where Unit.AllCases.Index == Int {
    
    fileprivate(set) var unitDifference: [Unit: Int]
    fileprivate let helpers: FunctionHelpers<Unit> = FunctionHelpers()
    
    func createFunction(unit: Unit, to otherUnit: Unit, sign: Signs) -> String {
        let allCases = Unit.allCases
        if unit == otherUnit {
            fatalError("Unable to generate functions from \(unit) to \(otherUnit)")
        }
        guard
            let unitIndex = allCases.firstIndex(where: { $0 == unit }),
            let otherUnitIndex = allCases.firstIndex(where: { $0 == otherUnit })
            else {
                fatalError("Unable to fetch index of \(unit) or \(otherUnit)")
        }
        let increasing = unitIndex < otherUnitIndex
        let smallest = increasing ? unitIndex : otherUnitIndex
        let biggest = increasing ? otherUnitIndex : unitIndex
        let cases = allCases.dropFirst(smallest).dropLast(allCases.count - biggest)
        print("unit: \(unit), otherUnit: \(otherUnit), cases: \(cases), allCases: \(allCases)")
        let difference = cases.reduce(1) { $0 * (self.unitDifference[$1] ?? 1) }
        let value = self.helpers.modify(value: difference, forSign: sign)
        let definition = self.helpers.functionDefinition(forUnit: unit, to: otherUnit, sign: sign)
        return increasing
            ? self.increasingFunc(forUnit: unit, to: otherUnit, sign: sign, withDefinition: definition, andValue: value)
            : self.decreasingFunc(forUnit: unit, to: otherUnit, sign: sign, withDefinition: definition, andValue: difference)
    }
    
    fileprivate func increasingFunc(
        forUnit unit: Unit,
        to otherUnit: Unit,
        sign: Signs,
        withDefinition definition: String,
        andValue value: String
        ) -> String {
        return """
        \(definition)
        {
        return ((\(otherUnit)_\(sign.rawValue)) \(unit)) / \(value);
        }
        """
    }
    
    fileprivate func decreasingFunc(
        forUnit unit: Unit,
        to otherUnit: Unit,
        sign: Signs,
        withDefinition definition: String,
        andValue value: Int
        ) -> String {
        guard let lastSign: Signs = Signs.allCases.last else {
            fatalError("Signs is empty.")
        }
        let lastValue = self.helpers.modify(value: value, forSign: lastSign)
        if sign == lastSign {
            return """
            \(definition)
            {
            return ((\(otherUnit)_\(sign.rawValue)) \(unit)) * \(lastValue);
            }
            """
        }
        return """
        \(definition)
        {
        return (\(otherUnit)_\(sign.rawValue)) round((\(unit)_\(lastSign.rawValue) \(unit)) * \(lastValue));
        }
        """
    }
    
}
