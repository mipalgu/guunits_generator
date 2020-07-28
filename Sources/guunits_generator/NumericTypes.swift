/*
 * NumericTypes.swift
 * guunits_generator
 *
 * Created by Callum McColl on 21/6/19.
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

enum NumericTypes: String {
    
    case int = "int", int8 = "int8_t", int16 = "int16_t", int32 = "int32_t", int64 = "int64_t"
    case uint = "unsigned int", uint8 = "uint8_t", uint16 = "uint16_t", uint32 = "uint32_t", uint64 = "uint64_t"
    case float = "float", double = "double"
    
}

extension NumericTypes {
    
    var abbreviation: String {
        switch self {
        case .int:
            return "i"
        case .int8:
            return "i8"
        case .int16:
            return "i16"
        case .int32:
            return "i32"
        case .int64:
            return "i64"
        case .uint:
            return "u"
        case .uint8:
            return "u8"
        case .uint16:
            return "u16"
        case .uint32:
            return "u32"
        case .uint64:
            return "u64"
        case .float:
            return "f"
        case .double:
            return "d"
        }
    }
    
    var isSigned: Bool {
        switch self {
        case .int, .int8, .int16, .int32, .int64, .float, .double:
            return true
        default:
            return false
        }
    }
    
    var isFloat: Bool {
        switch self {
        case .float, .double:
            return true
        default:
            return false
        }
    }
    
    var opposite: NumericTypes {
        switch self {
        case .int:
            return .uint
        case .int8:
            return .uint8
        case .int16:
            return .uint16
        case .int32:
            return .uint32
        case .int64:
            return .uint64
        case .uint:
            return .int
        case .uint8:
            return .int8
        case .uint16:
            return .int16
        case .uint32:
            return .int32
        case .uint64:
            return .int64
        case .float:
            return .float
        case .double:
            return .double
        }
    }
    
    var limits: (String, String) {
        switch self {
        case .int, .int32:
            return ("INT_MIN", "INT_MAX")
        case .int8:
            return ("-128", "127")
        case .int16:
            return ("SHRT_MIN", "SHRT_MAX")
        case .int64:
            return ("LONG_MIN", "LONG_MAX")
        case .uint, .uint32:
            return ("0", "UINT_MAX")
        case .uint8:
            return ("0", "255")
        case .uint16:
            return ("0", "USHRT_MAX")
        case .uint64:
            return ("0", "ULONG_MAX")
        case .float:
            return ("FLT_MIN", "FLT_MAX")
        case .double:
            return ("DBL_MIN", "DBL_MAX")
        }
    }
    
    var swiftType: SwiftNumericTypes {
        switch self {
        case .int8:
            return .Int8
        case .int16:
            return .Int16
        case .int32:
            return .Int32
        case .int64:
            return .Int64
        case .int:
            return .CInt
        case .uint8:
            return .UInt8
        case .uint16:
            return .UInt16
        case .uint32:
            return .UInt32
        case .uint64:
            return .UInt64
        case .uint:
            return .CUnsignedInt
        case .float:
            return .Float
        case .double:
            return .Double
        }
    }
    
    func smallerThan(_ other: NumericTypes) -> Bool {
        if self.isSigned != other.isSigned {
            fatalError("Can only compare numeric types of the same sort (int with other ints, floats with other floats).")
        }
        switch self {
        case .int8:
            return other != .int8
        case .int16:
            return other != .int8 && other != .int16
        case .int32, .int:
            return other != .int8 && other != .int16 && other != .int32 && other != .int
        case .int64:
            return false
        case .uint8:
            return true
        case .uint16:
            return other != .uint8
        case .uint32, .uint:
            return other != .uint8 && other != .uint16 && other != .uint32 && other != .uint
        case .uint64:
            return false
        case .float:
            return other != .float && other != .double
        case .double:
            return false
        }
    }
        
    func largerThan(_ other: NumericTypes) -> Bool {
        return other.smallerThan(self)
    }
    
}

extension NumericTypes: CaseIterable {}

extension NumericTypes: Hashable {}
