// GUUnitsPrimitiveConversions.swift 
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

// swiftlint:disable file_length
// swiftlint:disable type_body_length
// swiftlint:disable line_length

/// These properties provide custom swift source code that is needed to provide additional
/// common operations to the unit types in swift.
enum GUUnitsPrimitiveHelpers {

    /// The source code that implements floating type operations in GUUnits.
    static let float = """
        /*
        * GUUnitsFloat.swift
        * GUUnits
        *
        * Created by Callum McColl on 29/7/20.
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

        public protocol GUUnitsFloat: GUUnitsType,
            BinaryFloatingPoint,
            CustomDebugStringConvertible,
            CustomReflectable,
            Decodable,
            Encodable,
            LosslessStringConvertible,
            TextOutputStreamable
            where RawValue: BinaryFloatingPoint,
            RawValue: CustomDebugStringConvertible,
            RawValue: CustomReflectable,
            RawValue: Decodable,
            RawValue: Encodable,
            RawValue: LosslessStringConvertible,
            RawValue: TextOutputStreamable
        {
            associatedtype Exponent = RawValue.Exponent
            associatedtype FloatLiteralType = RawValue.FloatLiteralType
            associatedtype IntegerLiteralType = RawValue.IntegerLiteralType
            associatedtype RawSignificand = RawValue.RawSignificand
            associatedtype RawExponent = RawValue.RawExponent
            associatedtype Stride = RawValue.Stride
        }

        public protocol GUUnitsFType: GUUnitsFloat {}

        public protocol GUUnitsDType: GUUnitsFloat {}

        extension GUUnitsFloat {

            public static func < (lhs: Self, rhs: Self) -> Bool {
                return lhs.rawValue < rhs.rawValue
            }

            public static var radix: Int {
                RawValue.radix
            }

            public func isTotallyOrdered(belowOrEqualTo other: Self) -> Bool {
                return self.rawValue.isTotallyOrdered(belowOrEqualTo: other.rawValue)
            }

            public init?<T>(exactly source: T) where T : BinaryInteger {
                guard let value = RawValue(exactly: source) else {
                    return nil
                }
                self.init(rawValue: value)
            }

            public var magnitude: Self {
                Self(rawValue: self.rawValue.magnitude)
            }

            public static var exponentBitCount: Int {
                return RawValue.exponentBitCount
            }

            public static var significandBitCount: Int {
                return RawValue.significandBitCount
            }

            public var binade: Self {
                return Self(rawValue: self.rawValue.binade)
            }

            public var significandWidth: Int {
                return self.rawValue.significandWidth
            }

            public var debugDescription: String {
                return self.rawValue.debugDescription
            }

            public init?(_ description: String) {
                guard let value = RawValue(description) else {
                    return nil
                }
                self.init(rawValue: value)
            }

            public func write<Target>(to target: inout Target) where Target : TextOutputStream {
                self.rawValue.write(to: &target)
            }

            public static var nan: Self {
                Self(rawValue: RawValue.nan)
            }

            public static var signalingNaN: Self {
                Self(rawValue: RawValue.signalingNaN)
            }

            public static var infinity: Self {
                Self(rawValue: RawValue.infinity)
            }

            public static var greatestFiniteMagnitude: Self {
                Self(rawValue: RawValue.greatestFiniteMagnitude)
            }

            public static var pi: Self {
                Self(rawValue: RawValue.pi)
            }

            public var ulp: Self {
                Self(rawValue: self.rawValue.ulp)
            }

            public static var leastNormalMagnitude: Self {
                Self(rawValue: RawValue.leastNormalMagnitude)
            }

            public static var leastNonzeroMagnitude: Self {
                Self(rawValue: RawValue.leastNonzeroMagnitude)
            }

            public var sign: FloatingPointSign {
                return self.rawValue.sign
            }

            public var significand: Self {
                return Self(rawValue: self.rawValue.significand)
            }

            public mutating func formRemainder(dividingBy other: Self) {
                var raw = self.rawValue
                raw.formRemainder(dividingBy: other.rawValue)
                self = Self(rawValue: raw)
            }

            public mutating func formTruncatingRemainder(dividingBy other: Self) {
                var raw = self.rawValue
                raw.formTruncatingRemainder(dividingBy: other.rawValue)
                self = Self(rawValue: raw)
            }

            public mutating func formSquareRoot() {
                var raw = self.rawValue
                raw.formSquareRoot()
                self = Self(rawValue: raw)
            }

            public mutating func addProduct(_ lhs: Self, _ rhs: Self) {
                var raw = self.rawValue
                raw.addProduct(lhs.rawValue, rhs.rawValue)
                self = Self(rawValue: raw)
            }

            public var nextUp: Self {
                return Self(rawValue: self.rawValue.nextUp)
            }

            public func isEqual(to other: Self) -> Bool {
                return self.rawValue.isEqual(to: other.rawValue)
            }

            public func isLess(than other: Self) -> Bool {
                return self.rawValue.isLess(than: other.rawValue)
            }

            public func isLessThanOrEqualTo(_ other: Self) -> Bool {
                return self.rawValue.isLessThanOrEqualTo(other.rawValue)
            }

            public var isNormal: Bool {
                return self.rawValue.isNormal
            }

            public var isFinite: Bool {
                return self.rawValue.isFinite
            }

            public var isZero: Bool {
                return self.rawValue.isZero
            }

            public var isSubnormal: Bool {
                return self.rawValue.isSubnormal
            }

            public var isInfinite: Bool {
                return self.rawValue.isInfinite
            }

            public var isNaN: Bool {
                return self.rawValue.isNaN
            }

            public var isSignalingNaN: Bool {
                return self.rawValue.isSignalingNaN
            }

            public var isCanonical: Bool {
                return self.rawValue.isCanonical
            }

            public var description: String {
                return self.rawValue.description
            }

            public static func + (lhs: Self, rhs: Self) -> Self {
                return Self(rawValue: lhs.rawValue + rhs.rawValue)
            }

            public static func - (lhs: Self, rhs: Self) -> Self {
                return Self(rawValue: lhs.rawValue - rhs.rawValue)
            }

            public static func * (lhs: Self, rhs: Self) -> Self {
                return Self(rawValue: lhs.rawValue * rhs.rawValue)
            }

            public static func *= (lhs: inout Self, rhs: Self) {
                var raw = lhs.rawValue
                raw *= rhs.rawValue
                lhs = Self(rawValue: raw)
            }

            public static func / (lhs: Self, rhs: Self) -> Self {
                return Self(rawValue: lhs.rawValue / rhs.rawValue)
            }

            public static func /= (lhs: inout Self, rhs: Self) {
                var raw = lhs.rawValue
                raw /= rhs.rawValue
                lhs = Self(rawValue: raw)
            }

            public mutating func round(_ rule: FloatingPointRoundingRule) {
                var raw = self.rawValue
                raw.round(rule)
                self = Self(rawValue: raw)
            }

            public init(sign: FloatingPointSign, exponentBitPattern: RawValue.RawExponent, significandBitPattern: RawValue.RawSignificand) {
                self.init(rawValue: RawValue(sign: sign, exponentBitPattern: exponentBitPattern, significandBitPattern: significandBitPattern))
            }

            public init(sign: FloatingPointSign, exponent: RawValue.Exponent, significand: Self) {
                self.init(rawValue: RawValue(sign: sign, exponent: exponent, significand: significand.rawValue))
            }

            public var exponentBitPattern: RawValue.RawExponent {
                return self.rawValue.exponentBitPattern
            }

            public var significandBitPattern: RawValue.RawSignificand {
                return self.rawValue.significandBitPattern
            }

            public var exponent: RawValue.Exponent {
                return self.rawValue.exponent
            }

            public func distance(to other: Self) -> RawValue.Stride {
                return self.rawValue.distance(to: other.rawValue)
            }

            public func advanced(by n: RawValue.Stride) -> Self {
                return Self(rawValue: self.rawValue.advanced(by: n))
            }

            public init(integerLiteral value: RawValue.IntegerLiteralType) {
                self.init(rawValue: RawValue(integerLiteral: value))
            }

            public init(floatLiteral value: RawValue.FloatLiteralType) {
                self.init(rawValue: RawValue(floatLiteral: value))
            }

        }

        """

    /// The source code that provides integer type operations.
    static let integer = """
        /*
        * GUUnitsInteger.swift
        * GUUnits
        *
        * Created by Callum McColl on 29/7/20.
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

        public protocol GUUnitsInteger:
            GUUnitsType,
            CVarArg,
            CustomReflectable,
            Decodable,
            Encodable,
            FixedWidthInteger
            where RawValue: CVarArg,
            RawValue: CustomReflectable,
            RawValue: Decodable,
            RawValue: Encodable,
            RawValue: FixedWidthInteger
        {

            associatedtype Magnitude = RawValue.Magnitude
            associatedtype Words = RawValue.Words

        }

        public protocol GUUnitsTType: GUUnitsInteger, SignedInteger {}

        public protocol GUUnitsUType: GUUnitsInteger, UnsignedInteger {}

        extension GUUnitsInteger {

            public typealias Magnitude = RawValue.Magnitude

            public static func < (lhs: Self, rhs: Self) -> Bool {
                return lhs.rawValue < rhs.rawValue
            }

            public static var bitWidth: Int {
                return RawValue.bitWidth
            }

            public var byteSwapped: Self {
                Self(rawValue: self.rawValue.byteSwapped)
            }

            public var leadingZeroBitCount: Int {
                self.rawValue.leadingZeroBitCount
            }

            public var nonzeroBitCount: Int {
                self.rawValue.nonzeroBitCount
            }

            public var magnitude: RawValue.Magnitude {
                return self.rawValue.magnitude
            }

            public init(integerLiteral value: RawValue.IntegerLiteralType) {
                self.init(rawValue: RawValue(integerLiteral: value))
            }

            public init(_truncatingBits bits: UInt) {
                self.init(rawValue: RawValue(_truncatingBits: bits))
            }

            public static func +(lhs: Self, rhs: Self) -> Self {
                return Self(rawValue: lhs.rawValue + rhs.rawValue)
            }

            public static func - (lhs: Self, rhs: Self) -> Self {
                return Self(rawValue: lhs.rawValue - rhs.rawValue)
            }

            public static func / (lhs: Self, rhs: Self) -> Self {
                return Self(rawValue: lhs.rawValue / rhs.rawValue)
            }

            public func addingReportingOverflow(_ rhs: Self) -> (partialValue: Self, overflow: Bool) {
                let (partial, overflow) = self.rawValue.addingReportingOverflow(rhs.rawValue)
                return (Self(rawValue: partial), overflow)
            }

            public func subtractingReportingOverflow(_ rhs: Self) -> (partialValue: Self, overflow: Bool) {
                let (partial, overflow) = self.rawValue.subtractingReportingOverflow(rhs.rawValue)
                return (Self(rawValue: partial), overflow)
            }

            public func multipliedReportingOverflow(by rhs: Self) -> (partialValue: Self, overflow: Bool) {
                let (partial, overflow) = self.rawValue.multipliedReportingOverflow(by: rhs.rawValue)
                return (Self(rawValue: partial), overflow)
            }

            public func dividedReportingOverflow(by rhs: Self) -> (partialValue: Self, overflow: Bool) {
                let (partial, overflow) = self.rawValue.dividedReportingOverflow(by: rhs.rawValue)
                return (Self(rawValue: partial), overflow)
            }

            public func remainderReportingOverflow(dividingBy rhs: Self) -> (partialValue: Self, overflow: Bool) {
                let (partial, overflow) = self.rawValue.remainderReportingOverflow(dividingBy: rhs.rawValue)
                return (Self(rawValue: partial), overflow)
            }

            public func dividingFullWidth(_ dividend: (high: Self, low: RawValue.Magnitude)) -> (quotient: Self, remainder: Self) {
                let (quotient, remainder) = self.rawValue.dividingFullWidth((dividend.high.rawValue, dividend.low))
                return (Self(rawValue: quotient), Self(rawValue: remainder))
            }

            public var words: RawValue.Words {
                return self.rawValue.words
            }

            public var trailingZeroBitCount: Int {
                return self.rawValue.trailingZeroBitCount
            }

            public static func * (lhs: Self, rhs: Self) -> Self {
                return Self(rawValue: lhs.rawValue * rhs.rawValue)
            }

            public static func *= (lhs: inout Self, rhs: Self) {
                var raw = lhs.rawValue
                raw *= rhs.rawValue
                lhs = Self(rawValue: raw)
            }

            public static func /= (lhs: inout Self, rhs: Self) {
                var raw = lhs.rawValue
                raw /= rhs.rawValue
                lhs = Self(rawValue: raw)
            }

            public static func % (lhs: Self, rhs: Self) -> Self {
                return Self(rawValue: lhs.rawValue % rhs.rawValue)
            }

            public static func %= (lhs: inout Self, rhs: Self) {
                var raw = lhs.rawValue
                raw %= rhs.rawValue
                lhs = Self(rawValue: raw)
            }

            public static func &= (lhs: inout Self, rhs: Self) {
                var raw = lhs.rawValue
                raw &= rhs.rawValue
                lhs = Self(rawValue: raw)
            }

            public static func |= (lhs: inout Self, rhs: Self) {
                var raw = lhs.rawValue
                raw |= rhs.rawValue
                lhs = Self(rawValue: raw)
            }

            public static func ^= (lhs: inout Self, rhs: Self) {
                var raw = lhs.rawValue
                raw ^= rhs.rawValue
                lhs = Self(rawValue: raw)
            }

        }

        """

    /// The source code that provides common swift operations to GUUnits types.
    static let type = """
        /*
        * GUUnitsType.swift
        * GUUnits
        *
        * Created by Callum McColl on 29/07/2020.
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

        public protocol GUUnitsType: Sendable {

            associatedtype RawValue

            var rawValue: RawValue { get }

            init(rawValue: RawValue)

        }

        extension GUUnitsType where Self: CVarArg, Self.RawValue: CVarArg {

            public var _cVarArgEncoding: [Int] {
                self.rawValue._cVarArgEncoding
            }

        }

        extension GUUnitsType where Self: Equatable, Self.RawValue: Equatable {

            public static func == (lhs: Self, rhs: Self) -> Bool {
                return lhs.rawValue == rhs.rawValue
            }

        }

        extension GUUnitsType where Self: CustomReflectable, Self.RawValue: CustomReflectable {

            public var customMirror: Mirror {
                return self.rawValue.customMirror
            }

        }

        extension GUUnitsType where Self: Decodable, Self.RawValue: Decodable {

            public init(from decoder: Decoder) throws {
                self.init(rawValue: try RawValue(from: decoder))
            }

        }

        extension GUUnitsType where Self: Encodable, Self.RawValue: Encodable {

            public func encode(to encoder: Encoder) throws {
                return try self.rawValue.encode(to: encoder)
            }

        }

        extension GUUnitsType where Self: Hashable, Self.RawValue: Hashable {

            public func hash(into hasher: inout Hasher) {
                self.rawValue.hash(into: &hasher)
            }

        }

        extension GUUnitsType where Self: BinaryInteger, Self.RawValue: BinaryInteger {

            public init?(exactly source: Self) {
                guard let value = RawValue(exactly: source.rawValue) else {
                    return nil
                }
                self.init(rawValue: value)
            }

            public init?<T>(exactly source: T) where T: BinaryFloatingPoint, T: GUUnitsType {
                fatalError("You cannot convert \\(T.self) to \\(Self.self).")
            }

            public init<T>(_ source: T) where T: BinaryFloatingPoint, T: GUUnitsType {
                fatalError("You cannot convert \\(T.self) to \\(Self.self).")
            }

            public init(_ source: Self) {
                self.init(rawValue: RawValue(source.rawValue))
            }

            public init<T>(_: T) where T: BinaryInteger, T: GUUnitsType {
                fatalError("You cannot convert \\(T.self) to \\(Self.self).")
            }

            public init(truncatingIfNeeded source: Self) {
                self.init(rawValue: RawValue(truncatingIfNeeded: source.rawValue))
            }

            public init<T>(truncatingIfNeeded source: T) where T: BinaryInteger, T: GUUnitsType {
                fatalError("You cannot convert \\(T.self) to \\(Self.self).")
            }

            public init(clamping source: Self) {
                self.init(rawValue: RawValue(clamping: source.rawValue))
            }

            public init<T>(clamping source: T) where T: BinaryInteger, T: GUUnitsType {
                fatalError("You cannot convert \\(T.self) to \\(Self.self).")
            }

        }

        extension GUUnitsType where Self: BinaryFloatingPoint, Self.RawValue: BinaryFloatingPoint {

            public init(_ source: Self) {
                self.init(rawValue: RawValue(source.rawValue))
            }

            public init<T>(_ source: T) where T: BinaryFloatingPoint, T: GUUnitsType {
                fatalError("You cannot convert \\(T.self) to \\(Self.self).")
            }

            public init?(exactly source: Self) {
                guard let value = RawValue(exactly: source.rawValue) else {
                    return nil
                }
                self.init(rawValue: value)
            }

            public init?<T>(exactly source: T) where T: BinaryFloatingPoint, T: GUUnitsType {
                fatalError("You cannot convert \\(T.self) to \\(Self.self).")
            }

        }

        extension GUUnitsType where Self: BinaryFloatingPoint, Self.RawValue: BinaryFloatingPoint, Self.RawSignificand : FixedWidthInteger {

            public init(_ value: Self) {
                self.init(rawValue: RawValue(value.rawValue))
            }

            public init<Source>(_ value: Source) where Source: BinaryInteger, Source: GUUnitsType {
                fatalError("You cannot convert \\(Source.self) to \\(Self.self).")
            }

            public init?(exactly value: Self) {
                guard let value = RawValue(exactly: value.rawValue) else {
                    return nil
                }
                self.init(rawValue: value)
            }

            public init?<Source>(exactly value: Source) where Source: BinaryInteger, Source: GUUnitsType {
                fatalError("You cannot convert \\(Source.self) to \\(Self.self).")
            }

        }

        """

}

// swiftlint:enable line_length
// swiftlint:enable type_body_length
// swiftlint:enable file_length
