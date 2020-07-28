/*
 * SwiftNumericTypes.swift
 * guunits_generator
 *
 * Created by Callum McColl on 28/7/20.
 * Copyright © 2020 Callum McColl. All rights reserved.
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

enum SwiftNumericTypes: String, Hashable, CaseIterable {
    
    case Int8, Int16, Int32, Int64, Int, CInt
    case UInt8, UInt16, UInt32, UInt64, UInt, CUnsignedInt
    case Float, Double
    
    var numericType: NumericTypes {
        switch self {
        case .Int8:
            return .int8
        case .Int16:
            return .int16
        case .Int32:
            return .int32
        case .Int64:
            return .int64
        case .Int:
            return .int64
        case .CInt:
            return .int32
        case .UInt8:
            return .uint8
        case .UInt16:
            return .uint16
        case .UInt32:
            return .uint32
        case .UInt64:
            return .uint64
        case .CUnsignedInt:
            return .uint32
        case .UInt:
            return .uint64
        case .Float:
            return .float
        case .Double:
            return .double
        }
    }
    
    var sign: Signs {
        switch self {
        case .Int8, .Int16, .Int32, .Int64, .Int, .CInt:
            return .t
        case .UInt8, .UInt16, .UInt32, .UInt64, .UInt, .CUnsignedInt:
            return .u
        case .Float:
            return .f
        case .Double:
            return .d
        }
    }
    
    public static var uniqueTypes: [SwiftNumericTypes] {
        Array(Set(SwiftNumericTypes.allCases).subtracting([.CInt, .CUnsignedInt]).sorted { $0.rawValue < $1.rawValue })
    }
    
}
