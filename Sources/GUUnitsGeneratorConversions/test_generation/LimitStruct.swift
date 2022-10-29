// LimitStruct.swift 
// guunits_generator 
// 
// Created by Morgan McColl.
// Copyright © 2022 Morgan McColl. All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above
//    copyright notice, this list of conditions and the following
//    disclaimer in the documentation and/or other materials
//    provided with the distribution.
// 
// 3. All advertising materials mentioning features or use of this
//    software must display the following acknowledgement:
// 
//    This product includes software developed by Morgan McColl.
// 
// 4. Neither the name of the author nor the names of contributors
//    may be used to endorse or promote products derived from this
//    software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 
// -----------------------------------------------------------------------
// This program is free software; you can redistribute it and/or
// modify it under the above terms or under the terms of the GNU
// General Public License as published by the Free Software Foundation;
// either version 2 of the License, or (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, see http://www.gnu.org/licenses/
// or write to the Free Software Foundation, Inc., 51 Franklin Street,
// Fifth Floor, Boston, MA  02110-1301, USA.
// 

/// Provides helper properties for common unit conversion used in a test function.
struct LimitStruct<UnitType> where
    UnitType: UnitProtocol,
    UnitType: RawRepresentable,
    UnitType.RawValue == String {

    /// Helper object to sanitise literals.
    private let creator = TestFunctionBodyCreator<UnitType>()

    /// The unit to convert from.
    let unit: UnitType

    /// The sign of the unit.
    let sign: Signs

    /// The unit to convert to.
    let otherUnit: UnitType

    /// The sign of the unit to convert to.
    let otherSign: Signs

    /// A zero literal expressed as a unit.
    var sanitisedZero: String {
        creator.sanitiseLiteral(literal: "0", sign: sign)
    }

    /// A zero literal expressed as the other unit type.
    var otherSanitisedZero: String {
        creator.sanitiseLiteral(literal: "0", sign: otherSign)
    }

    /// The C unit type.
    private var unitType: String {
        "\(unit.rawValue)_\(sign.rawValue)"
    }

    /// The limits of the unit expressed using swift types. The tuple represents
    /// (min, max) values.
    private var limits: (String, String) {
        sign.numericType.swiftType.limits
    }

    /// The lower limit of the unit.
    private var lowerLimit: String {
        limits.0
    }

    /// The upper limit of the unit.
    private var upperLimit: String {
        limits.1
    }

    /// The lower limit expressed as the unit type.
    var castedLowerLimit: String {
        "\(unitType)(\(lowerLimit))"
    }

    /// The upper limit expressed as the unit type.
    var castedUpperLimit: String {
        "\(unitType)(\(upperLimit))"
    }

    /// The other unit C type.
    private var otherUnitType: String {
        "\(unit.rawValue)_\(otherSign.rawValue)"
    }

    /// The lower limit expressed using the other sign.
    private var sanitisedLowerLimit: String {
        creator.sanitiseLiteral(literal: lowerLimit, sign: otherSign)
    }

    /// The upper limit expressed using the other sign.
    private var sanitisedUpperLimit: String {
        creator.sanitiseLiteral(literal: upperLimit, sign: otherSign)
    }

    /// The lower limit expressed as the other unit type.
    var lowerLimitAsOther: String {
        "\(otherUnitType)(\(sanitisedLowerLimit))"
    }

    /// The upper limit expressed as the other unit type.
    var upperLimitAsOther: String {
        "\(otherUnitType)(\(sanitisedUpperLimit))"
    }

    /// The other units limits.
    private var otherLimits: (String, String) {
        otherSign.numericType.swiftType.limits
    }

    /// The other units lower limit.
    private var otherLowerLimit: String {
        otherLimits.0
    }

    /// The other units upper limit.
    private var otherUpperLimit: String {
        otherLimits.1
    }

    /// The other units lower limit casted to the other unit type.
    var otherCastedLowerLimit: String {
        "\(otherUnitType)(\(otherLowerLimit))"
    }

    /// The other units upper limit casted to the other unit type.
    var otherCastedUpperLimit: String {
        "\(otherUnitType)(\(otherUpperLimit))"
    }

}
