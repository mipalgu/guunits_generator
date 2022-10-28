// Literal.swift 
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

/// Enumeration for representating different types of primitive values. These types represent
/// different real and rational numbers with differing precision.
public enum Literal: Hashable {

    /// An integer.
    case integer(value: Int)

    /// A decimal number that would contain a decimal point. This value is approximated
    /// as a `Double`.
    case decimal(value: Double)

    /// A concise string representation of the underlying value.
    var abbreviation: String {
        switch self {
        case .integer(let value):
            return value.abbreviation
        case .decimal(let value):
            return value.abbreviation
        }
    }

    /// The underlying value represented as a `Double` type.
    var asDouble: Double {
        switch self {
        case .integer(let value):
            return Double(value)
        case .decimal(let value):
            return value
        }
    }

    /// The underlying value represented as an `Int` type.
    var asInteger: Int {
        switch self {
        case .integer(let value):
            return value
        case .decimal(let value):
            return Int(value.rounded())
        }
    }

    /// The underlying value represented as a `String`.
    var asString: String {
        switch self {
        case .integer(let value):
            return "\(value)"
        case .decimal(let value):
            return "\(value)"
        }
    }

    /// True when the underlying value is a floating point number. False otherwise.
    var isFloat: Bool {
        switch self {
        case .integer:
            return false
        case .decimal:
            return true
        }
    }

}

/// Add abbreviation to Int.
private extension Int {

    /// The abbreviation of the Int.
    var abbreviation: String {
        guard self > 0 else {
            return "neg" + abs(self).abbreviation
        }
        return "\(self)"
    }

}

/// Add abbreviation to Double.
private extension Double {

    /// An small string representation of a Double value.
    var abbreviation: String {
        guard self > 0 else {
            return "neg" + abs(self).abbreviation
        }
        return String(format: "%.2f", arguments: [self]).replacingOccurrences(of: ".", with: "_")
    }

}
