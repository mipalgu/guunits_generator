/*
 * SwiftFileCreatorTests.swift 
 * guunits_generator 
 *
 * Created by Morgan McColl.
 * Copyright © 2022 Morgan McColl. All rights reserved.
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
 *        This product includes software developed by Morgan McColl.
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

// swiftlint:disable file_length
// swiftlint:disable type_body_length

@testable import GUUnitsGeneratorConversions
import XCTest

/// Test class for SwiftFileCreator.
final class SwiftFileCreatorTests: XCTestCase {

    /// The creator being tested.
    let creator = SwiftFileCreator()

    // swiftlint:disable type_contents_order

    /// Test that the unit code is generated correctly.
    func testGenerate() {
        let result = creator.generate(for: FakeUnit.self)
        XCTAssertEqual(result, expected + "\n")
    }

    /// The expected output from the generate function.
    let expected = """
        /*
        * FakeUnit.swift
        * GUUnits
        *
        * Created by Callum McColl on 05/06/2019.
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

        import CGUUnits

        /// Provides a generic way of working with fakeunit units.
        ///
        /// This type is useful as it allows you to specify that you are
        /// working with a particular type of unit, without having to
        /// specify in which units you are working. This type allows you
        /// to convert to any of the related underlying unit types.
        ///
        /// It is recommended that if you are creating a library or public
        /// api of some sort, then this type should be used in your function
        /// declaration over the more specific underlying unit types that
        /// this type can convert to. If you are performing some
        /// sort of calculations then you obviously need to use one of the
        /// underlying unit types that this type can convert to; however,
        /// the public api should take this type which you should then
        /// convert to the underlying unit type you need.
        ///
        /// - Attention: Because this type is numeric, and therefore allows
        /// you to perform arithmetic, this type must behave like a double
        /// as a double has the highest precision. If this is not
        /// necessary, then you may opt to use one of the integer
        /// variants of the underlying unit types that this type can convert
        /// to.
        public struct FakeUnit: Sendable, Hashable, Codable {

        // MARK: - Converting Between The Internal Representation

            /// Always store internally as a `First_d`
            public let rawValue: First_d

            /// Initialise `FakeUnit` from its internally representation.
            public init(rawValue: First_d) {
                self.rawValue = rawValue
            }

        // MARK: - Converting To The Underlying Unit Types

            /// Create a `First_t`.
            public var first_t: First_t {
                return First_t(self.rawValue)
            }

            /// Create a `First_u`.
            public var first_u: First_u {
                return First_u(self.rawValue)
            }

            /// Create a `First_f`.
            public var first_f: First_f {
                return First_f(self.rawValue)
            }

            /// Create a `First_d`.
            public var first_d: First_d {
                return First_d(self.rawValue)
            }

            /// Create a `Second_t`.
            public var second_t: Second_t {
                return Second_t(self.rawValue)
            }

            /// Create a `Second_u`.
            public var second_u: Second_u {
                return Second_u(self.rawValue)
            }

            /// Create a `Second_f`.
            public var second_f: Second_f {
                return Second_f(self.rawValue)
            }

            /// Create a `Second_d`.
            public var second_d: Second_d {
                return Second_d(self.rawValue)
            }

        // MARK: - Converting From The Underlying Unit Types

            /// Create a `FakeUnit` by converting a `First_t`.
            ///
            /// - Parameter value: A `First_t` value to convert to a `FakeUnit`.
            public init(_ value: First_t) {
                self.rawValue = First_d(value)
            }

            /// Create a `FakeUnit` by converting a `First_u`.
            ///
            /// - Parameter value: A `First_u` value to convert to a `FakeUnit`.
            public init(_ value: First_u) {
                self.rawValue = First_d(value)
            }

            /// Create a `FakeUnit` by converting a `First_f`.
            ///
            /// - Parameter value: A `First_f` value to convert to a `FakeUnit`.
            public init(_ value: First_f) {
                self.rawValue = First_d(value)
            }

            /// Create a `FakeUnit` by converting a `First_d`.
            ///
            /// - Parameter value: A `First_d` value to convert to a `FakeUnit`.
            public init(_ value: First_d) {
                self.rawValue = value
            }

            /// Create a `FakeUnit` by converting a `Second_t`.
            ///
            /// - Parameter value: A `Second_t` value to convert to a `FakeUnit`.
            public init(_ value: Second_t) {
                self.rawValue = First_d(value)
            }

            /// Create a `FakeUnit` by converting a `Second_u`.
            ///
            /// - Parameter value: A `Second_u` value to convert to a `FakeUnit`.
            public init(_ value: Second_u) {
                self.rawValue = First_d(value)
            }

            /// Create a `FakeUnit` by converting a `Second_f`.
            ///
            /// - Parameter value: A `Second_f` value to convert to a `FakeUnit`.
            public init(_ value: Second_f) {
                self.rawValue = First_d(value)
            }

            /// Create a `FakeUnit` by converting a `Second_d`.
            ///
            /// - Parameter value: A `Second_d` value to convert to a `FakeUnit`.
            public init(_ value: Second_d) {
                self.rawValue = First_d(value)
            }

        // MARK: - Converting From Swift Numeric Types

            /// Create a `FakeUnit` equal to zero.
            public static var zero: FakeUnit {
                return FakeUnit(first: 0)
            }

            /// Create a `FakeUnit` by converting a `Double` first value.
            ///
            /// - Parameter value: A `Double` first value to convert to a `FakeUnit`.
            public static func first(_ value: Double) -> FakeUnit {
                return FakeUnit(first: value)
            }

            /// Create a `FakeUnit` by converting a `Double` second value.
            ///
            /// - Parameter value: A `Double` second value to convert to a `FakeUnit`.
            public static func second(_ value: Double) -> FakeUnit {
                return FakeUnit(second: value)
            }

            /// Create a `FakeUnit` by converting a `Float` first value.
            ///
            /// - Parameter value: A `Float` first value to convert to a `FakeUnit`.
            public static func first(_ value: Float) -> FakeUnit {
                return FakeUnit(first: value)
            }

            /// Create a `FakeUnit` by converting a `Float` second value.
            ///
            /// - Parameter value: A `Float` second value to convert to a `FakeUnit`.
            public static func second(_ value: Float) -> FakeUnit {
                return FakeUnit(second: value)
            }

            /// Create a `FakeUnit` by converting a `Int` first value.
            ///
            /// - Parameter value: A `Int` first value to convert to a `FakeUnit`.
            public static func first(_ value: Int) -> FakeUnit {
                return FakeUnit(first: value)
            }

            /// Create a `FakeUnit` by converting a `Int` second value.
            ///
            /// - Parameter value: A `Int` second value to convert to a `FakeUnit`.
            public static func second(_ value: Int) -> FakeUnit {
                return FakeUnit(second: value)
            }

            /// Create a `FakeUnit` by converting a `Int16` first value.
            ///
            /// - Parameter value: A `Int16` first value to convert to a `FakeUnit`.
            public static func first(_ value: Int16) -> FakeUnit {
                return FakeUnit(first: value)
            }

            /// Create a `FakeUnit` by converting a `Int16` second value.
            ///
            /// - Parameter value: A `Int16` second value to convert to a `FakeUnit`.
            public static func second(_ value: Int16) -> FakeUnit {
                return FakeUnit(second: value)
            }

            /// Create a `FakeUnit` by converting a `Int32` first value.
            ///
            /// - Parameter value: A `Int32` first value to convert to a `FakeUnit`.
            public static func first(_ value: Int32) -> FakeUnit {
                return FakeUnit(first: value)
            }

            /// Create a `FakeUnit` by converting a `Int32` second value.
            ///
            /// - Parameter value: A `Int32` second value to convert to a `FakeUnit`.
            public static func second(_ value: Int32) -> FakeUnit {
                return FakeUnit(second: value)
            }

            /// Create a `FakeUnit` by converting a `Int64` first value.
            ///
            /// - Parameter value: A `Int64` first value to convert to a `FakeUnit`.
            public static func first(_ value: Int64) -> FakeUnit {
                return FakeUnit(first: value)
            }

            /// Create a `FakeUnit` by converting a `Int64` second value.
            ///
            /// - Parameter value: A `Int64` second value to convert to a `FakeUnit`.
            public static func second(_ value: Int64) -> FakeUnit {
                return FakeUnit(second: value)
            }

            /// Create a `FakeUnit` by converting a `Int8` first value.
            ///
            /// - Parameter value: A `Int8` first value to convert to a `FakeUnit`.
            public static func first(_ value: Int8) -> FakeUnit {
                return FakeUnit(first: value)
            }

            /// Create a `FakeUnit` by converting a `Int8` second value.
            ///
            /// - Parameter value: A `Int8` second value to convert to a `FakeUnit`.
            public static func second(_ value: Int8) -> FakeUnit {
                return FakeUnit(second: value)
            }

            /// Create a `FakeUnit` by converting a `UInt` first value.
            ///
            /// - Parameter value: A `UInt` first value to convert to a `FakeUnit`.
            public static func first(_ value: UInt) -> FakeUnit {
                return FakeUnit(first: value)
            }

            /// Create a `FakeUnit` by converting a `UInt` second value.
            ///
            /// - Parameter value: A `UInt` second value to convert to a `FakeUnit`.
            public static func second(_ value: UInt) -> FakeUnit {
                return FakeUnit(second: value)
            }

            /// Create a `FakeUnit` by converting a `UInt16` first value.
            ///
            /// - Parameter value: A `UInt16` first value to convert to a `FakeUnit`.
            public static func first(_ value: UInt16) -> FakeUnit {
                return FakeUnit(first: value)
            }

            /// Create a `FakeUnit` by converting a `UInt16` second value.
            ///
            /// - Parameter value: A `UInt16` second value to convert to a `FakeUnit`.
            public static func second(_ value: UInt16) -> FakeUnit {
                return FakeUnit(second: value)
            }

            /// Create a `FakeUnit` by converting a `UInt32` first value.
            ///
            /// - Parameter value: A `UInt32` first value to convert to a `FakeUnit`.
            public static func first(_ value: UInt32) -> FakeUnit {
                return FakeUnit(first: value)
            }

            /// Create a `FakeUnit` by converting a `UInt32` second value.
            ///
            /// - Parameter value: A `UInt32` second value to convert to a `FakeUnit`.
            public static func second(_ value: UInt32) -> FakeUnit {
                return FakeUnit(second: value)
            }

            /// Create a `FakeUnit` by converting a `UInt64` first value.
            ///
            /// - Parameter value: A `UInt64` first value to convert to a `FakeUnit`.
            public static func first(_ value: UInt64) -> FakeUnit {
                return FakeUnit(first: value)
            }

            /// Create a `FakeUnit` by converting a `UInt64` second value.
            ///
            /// - Parameter value: A `UInt64` second value to convert to a `FakeUnit`.
            public static func second(_ value: UInt64) -> FakeUnit {
                return FakeUnit(second: value)
            }

            /// Create a `FakeUnit` by converting a `UInt8` first value.
            ///
            /// - Parameter value: A `UInt8` first value to convert to a `FakeUnit`.
            public static func first(_ value: UInt8) -> FakeUnit {
                return FakeUnit(first: value)
            }

            /// Create a `FakeUnit` by converting a `UInt8` second value.
            ///
            /// - Parameter value: A `UInt8` second value to convert to a `FakeUnit`.
            public static func second(_ value: UInt8) -> FakeUnit {
                return FakeUnit(second: value)
            }

            /// Create a `FakeUnit` by converting a `Double` first value.
            ///
            /// - Parameter value: A `Double` first value to convert to a `FakeUnit`.
            public init(first value: Double) {
                self.rawValue = First_d(value)
            }

            /// Create a `FakeUnit` by converting a `Double` second value.
            ///
            /// - Parameter value: A `Double` second value to convert to a `FakeUnit`.
            public init(second value: Double) {
                self.rawValue = First_d(Second_d(value))
            }

            /// Create a `FakeUnit` by converting a `Float` first value.
            ///
            /// - Parameter value: A `Float` first value to convert to a `FakeUnit`.
            public init(first value: Float) {
                self.rawValue = First_d(First_f(value))
            }

            /// Create a `FakeUnit` by converting a `Float` second value.
            ///
            /// - Parameter value: A `Float` second value to convert to a `FakeUnit`.
            public init(second value: Float) {
                self.rawValue = First_d(Second_f(value))
            }

            /// Create a `FakeUnit` by converting a `Int` first value.
            ///
            /// - Parameter value: A `Int` first value to convert to a `FakeUnit`.
            public init(first value: Int) {
                self.rawValue = First_d(First_t(value))
            }

            /// Create a `FakeUnit` by converting a `Int` second value.
            ///
            /// - Parameter value: A `Int` second value to convert to a `FakeUnit`.
            public init(second value: Int) {
                self.rawValue = First_d(Second_t(value))
            }

            /// Create a `FakeUnit` by converting a `Int16` first value.
            ///
            /// - Parameter value: A `Int16` first value to convert to a `FakeUnit`.
            public init(first value: Int16) {
                self.rawValue = First_d(First_t(value))
            }

            /// Create a `FakeUnit` by converting a `Int16` second value.
            ///
            /// - Parameter value: A `Int16` second value to convert to a `FakeUnit`.
            public init(second value: Int16) {
                self.rawValue = First_d(Second_t(value))
            }

            /// Create a `FakeUnit` by converting a `Int32` first value.
            ///
            /// - Parameter value: A `Int32` first value to convert to a `FakeUnit`.
            public init(first value: Int32) {
                self.rawValue = First_d(First_t(value))
            }

            /// Create a `FakeUnit` by converting a `Int32` second value.
            ///
            /// - Parameter value: A `Int32` second value to convert to a `FakeUnit`.
            public init(second value: Int32) {
                self.rawValue = First_d(Second_t(value))
            }

            /// Create a `FakeUnit` by converting a `Int64` first value.
            ///
            /// - Parameter value: A `Int64` first value to convert to a `FakeUnit`.
            public init(first value: Int64) {
                self.rawValue = First_d(First_t(value))
            }

            /// Create a `FakeUnit` by converting a `Int64` second value.
            ///
            /// - Parameter value: A `Int64` second value to convert to a `FakeUnit`.
            public init(second value: Int64) {
                self.rawValue = First_d(Second_t(value))
            }

            /// Create a `FakeUnit` by converting a `Int8` first value.
            ///
            /// - Parameter value: A `Int8` first value to convert to a `FakeUnit`.
            public init(first value: Int8) {
                self.rawValue = First_d(First_t(value))
            }

            /// Create a `FakeUnit` by converting a `Int8` second value.
            ///
            /// - Parameter value: A `Int8` second value to convert to a `FakeUnit`.
            public init(second value: Int8) {
                self.rawValue = First_d(Second_t(value))
            }

            /// Create a `FakeUnit` by converting a `UInt` first value.
            ///
            /// - Parameter value: A `UInt` first value to convert to a `FakeUnit`.
            public init(first value: UInt) {
                self.rawValue = First_d(First_u(value))
            }

            /// Create a `FakeUnit` by converting a `UInt` second value.
            ///
            /// - Parameter value: A `UInt` second value to convert to a `FakeUnit`.
            public init(second value: UInt) {
                self.rawValue = First_d(Second_u(value))
            }

            /// Create a `FakeUnit` by converting a `UInt16` first value.
            ///
            /// - Parameter value: A `UInt16` first value to convert to a `FakeUnit`.
            public init(first value: UInt16) {
                self.rawValue = First_d(First_u(value))
            }

            /// Create a `FakeUnit` by converting a `UInt16` second value.
            ///
            /// - Parameter value: A `UInt16` second value to convert to a `FakeUnit`.
            public init(second value: UInt16) {
                self.rawValue = First_d(Second_u(value))
            }

            /// Create a `FakeUnit` by converting a `UInt32` first value.
            ///
            /// - Parameter value: A `UInt32` first value to convert to a `FakeUnit`.
            public init(first value: UInt32) {
                self.rawValue = First_d(First_u(value))
            }

            /// Create a `FakeUnit` by converting a `UInt32` second value.
            ///
            /// - Parameter value: A `UInt32` second value to convert to a `FakeUnit`.
            public init(second value: UInt32) {
                self.rawValue = First_d(Second_u(value))
            }

            /// Create a `FakeUnit` by converting a `UInt64` first value.
            ///
            /// - Parameter value: A `UInt64` first value to convert to a `FakeUnit`.
            public init(first value: UInt64) {
                self.rawValue = First_d(First_u(value))
            }

            /// Create a `FakeUnit` by converting a `UInt64` second value.
            ///
            /// - Parameter value: A `UInt64` second value to convert to a `FakeUnit`.
            public init(second value: UInt64) {
                self.rawValue = First_d(Second_u(value))
            }

            /// Create a `FakeUnit` by converting a `UInt8` first value.
            ///
            /// - Parameter value: A `UInt8` first value to convert to a `FakeUnit`.
            public init(first value: UInt8) {
                self.rawValue = First_d(First_u(value))
            }

            /// Create a `FakeUnit` by converting a `UInt8` second value.
            ///
            /// - Parameter value: A `UInt8` second value to convert to a `FakeUnit`.
            public init(second value: UInt8) {
                self.rawValue = First_d(Second_u(value))
            }

        }

        public extension Double {

        // MARK: - Creating a Double From The FakeUnit Units

            init(_ value: FakeUnit) {
                self.init(value.rawValue)
            }

        }

        public extension Float {

        // MARK: - Creating a Float From The FakeUnit Units

            init(_ value: FakeUnit) {
                self.init(value.rawValue)
            }

        }

        public extension Int {

        // MARK: - Creating a Int From The FakeUnit Units

            init(_ value: FakeUnit) {
                self.init(value.rawValue)
            }

        }

        public extension Int16 {

        // MARK: - Creating a Int16 From The FakeUnit Units

            init(_ value: FakeUnit) {
                self.init(value.rawValue)
            }

        }

        public extension Int32 {

        // MARK: - Creating a Int32 From The FakeUnit Units

            init(_ value: FakeUnit) {
                self.init(value.rawValue)
            }

        }

        public extension Int64 {

        // MARK: - Creating a Int64 From The FakeUnit Units

            init(_ value: FakeUnit) {
                self.init(value.rawValue)
            }

        }

        public extension Int8 {

        // MARK: - Creating a Int8 From The FakeUnit Units

            init(_ value: FakeUnit) {
                self.init(value.rawValue)
            }

        }

        public extension UInt {

        // MARK: - Creating a UInt From The FakeUnit Units

            init(_ value: FakeUnit) {
                self.init(value.rawValue)
            }

        }

        public extension UInt16 {

        // MARK: - Creating a UInt16 From The FakeUnit Units

            init(_ value: FakeUnit) {
                self.init(value.rawValue)
            }

        }

        public extension UInt32 {

        // MARK: - Creating a UInt32 From The FakeUnit Units

            init(_ value: FakeUnit) {
                self.init(value.rawValue)
            }

        }

        public extension UInt64 {

        // MARK: - Creating a UInt64 From The FakeUnit Units

            init(_ value: FakeUnit) {
                self.init(value.rawValue)
            }

        }

        public extension UInt8 {

        // MARK: - Creating a UInt8 From The FakeUnit Units

            init(_ value: FakeUnit) {
                self.init(value.rawValue)
            }

        }

        /// A signed integer type for the first unit.
        public struct First_t: GUUnitsTType, Hashable, Codable {

        // MARK: - Converting Between The Underlying guunits C Type

            /// Convert to the guunits underlying C type `first_t`
            public let rawValue: first_t

            /// Create a `First_t` from the underlying guunits C type `first_t`.
            public init(rawValue: first_t) {
                self.rawValue = rawValue
            }

        // MARK: - Converting From Swift Numeric Types

            /// Create a `First_t` by converting a `Double`.
            ///
            /// - Parameter value: A `Double` value to convert to a `First_t`.
            public init(_ value: Double) {
                self.rawValue = d_to_ft_t(value)
            }

            /// Create a `First_t` by converting a `Float`.
            ///
            /// - Parameter value: A `Float` value to convert to a `First_t`.
            public init(_ value: Float) {
                self.rawValue = f_to_ft_t(value)
            }

            /// Create a `First_t` by converting a `Int`.
            ///
            /// - Parameter value: A `Int` value to convert to a `First_t`.
            public init(_ value: Int) {
                self.rawValue = i64_to_ft_t(Int64(value))
            }

            /// Create a `First_t` by converting a `Int16`.
            ///
            /// - Parameter value: A `Int16` value to convert to a `First_t`.
            public init(_ value: Int16) {
                self.rawValue = i16_to_ft_t(value)
            }

            /// Create a `First_t` by converting a `Int32`.
            ///
            /// - Parameter value: A `Int32` value to convert to a `First_t`.
            public init(_ value: Int32) {
                self.rawValue = i32_to_ft_t(value)
            }

            /// Create a `First_t` by converting a `Int64`.
            ///
            /// - Parameter value: A `Int64` value to convert to a `First_t`.
            public init(_ value: Int64) {
                self.rawValue = i64_to_ft_t(value)
            }

            /// Create a `First_t` by converting a `Int8`.
            ///
            /// - Parameter value: A `Int8` value to convert to a `First_t`.
            public init(_ value: Int8) {
                self.rawValue = i8_to_ft_t(value)
            }

            /// Create a `First_t` by converting a `UInt`.
            ///
            /// - Parameter value: A `UInt` value to convert to a `First_t`.
            public init(_ value: UInt) {
                self.rawValue = u64_to_ft_t(UInt64(value))
            }

            /// Create a `First_t` by converting a `UInt16`.
            ///
            /// - Parameter value: A `UInt16` value to convert to a `First_t`.
            public init(_ value: UInt16) {
                self.rawValue = u16_to_ft_t(value)
            }

            /// Create a `First_t` by converting a `UInt32`.
            ///
            /// - Parameter value: A `UInt32` value to convert to a `First_t`.
            public init(_ value: UInt32) {
                self.rawValue = u32_to_ft_t(value)
            }

            /// Create a `First_t` by converting a `UInt64`.
            ///
            /// - Parameter value: A `UInt64` value to convert to a `First_t`.
            public init(_ value: UInt64) {
                self.rawValue = u64_to_ft_t(value)
            }

            /// Create a `First_t` by converting a `UInt8`.
            ///
            /// - Parameter value: A `UInt8` value to convert to a `First_t`.
            public init(_ value: UInt8) {
                self.rawValue = u8_to_ft_t(value)
            }

        // MARK: - Converting From Other Units

            /// Create a `First_t` by converting a `FakeUnit`.
            ///
            /// - Parameter value: A `FakeUnit` value to convert to a `First_t`.
            public init(_ value: FakeUnit) {
                self.init(value.rawValue)
            }

            /// Create a `First_t` by converting a `Second_t`.
            ///
            /// - Parameter value: A `Second_t` value to convert to a `First_t`.
            public init(_ value: Second_t) {
                self.rawValue = snd_t_to_ft_t(value.rawValue)
            }

            /// Create a `First_t` by converting a `Second_u`.
            ///
            /// - Parameter value: A `Second_u` value to convert to a `First_t`.
            public init(_ value: Second_u) {
                self.rawValue = snd_u_to_ft_t(value.rawValue)
            }

            /// Create a `First_t` by converting a `Second_f`.
            ///
            /// - Parameter value: A `Second_f` value to convert to a `First_t`.
            public init(_ value: Second_f) {
                self.rawValue = snd_f_to_ft_t(value.rawValue)
            }

            /// Create a `First_t` by converting a `Second_d`.
            ///
            /// - Parameter value: A `Second_d` value to convert to a `First_t`.
            public init(_ value: Second_d) {
                self.rawValue = snd_d_to_ft_t(value.rawValue)
            }

        // MARK: - Converting From Other Precisions

            /// Create a `First_t` by converting a `First_d`.
            ///
            /// - Parameter value: A `First_d` value to convert to a `First_t`.
            public init(_ value: First_d) {
                self.rawValue = ft_d_to_ft_t(value.rawValue)
            }

            /// Create a `First_t` by converting a `First_f`.
            ///
            /// - Parameter value: A `First_f` value to convert to a `First_t`.
            public init(_ value: First_f) {
                self.rawValue = ft_f_to_ft_t(value.rawValue)
            }

            /// Create a `First_t` by converting a `First_u`.
            ///
            /// - Parameter value: A `First_u` value to convert to a `First_t`.
            public init(_ value: First_u) {
                self.rawValue = ft_u_to_ft_t(value.rawValue)
            }

        }

        /// An unsigned integer type for the first unit.
        public struct First_u: GUUnitsUType, Hashable, Codable {

        // MARK: - Converting Between The Underlying guunits C Type

            /// Convert to the guunits underlying C type `first_u`
            public let rawValue: first_u

            /// Create a `First_u` from the underlying guunits C type `first_u`.
            public init(rawValue: first_u) {
                self.rawValue = rawValue
            }

        // MARK: - Converting From Swift Numeric Types

            /// Create a `First_u` by converting a `Double`.
            ///
            /// - Parameter value: A `Double` value to convert to a `First_u`.
            public init(_ value: Double) {
                self.rawValue = d_to_ft_u(value)
            }

            /// Create a `First_u` by converting a `Float`.
            ///
            /// - Parameter value: A `Float` value to convert to a `First_u`.
            public init(_ value: Float) {
                self.rawValue = f_to_ft_u(value)
            }

            /// Create a `First_u` by converting a `Int`.
            ///
            /// - Parameter value: A `Int` value to convert to a `First_u`.
            public init(_ value: Int) {
                self.rawValue = i64_to_ft_u(Int64(value))
            }

            /// Create a `First_u` by converting a `Int16`.
            ///
            /// - Parameter value: A `Int16` value to convert to a `First_u`.
            public init(_ value: Int16) {
                self.rawValue = i16_to_ft_u(value)
            }

            /// Create a `First_u` by converting a `Int32`.
            ///
            /// - Parameter value: A `Int32` value to convert to a `First_u`.
            public init(_ value: Int32) {
                self.rawValue = i32_to_ft_u(value)
            }

            /// Create a `First_u` by converting a `Int64`.
            ///
            /// - Parameter value: A `Int64` value to convert to a `First_u`.
            public init(_ value: Int64) {
                self.rawValue = i64_to_ft_u(value)
            }

            /// Create a `First_u` by converting a `Int8`.
            ///
            /// - Parameter value: A `Int8` value to convert to a `First_u`.
            public init(_ value: Int8) {
                self.rawValue = i8_to_ft_u(value)
            }

            /// Create a `First_u` by converting a `UInt`.
            ///
            /// - Parameter value: A `UInt` value to convert to a `First_u`.
            public init(_ value: UInt) {
                self.rawValue = u64_to_ft_u(UInt64(value))
            }

            /// Create a `First_u` by converting a `UInt16`.
            ///
            /// - Parameter value: A `UInt16` value to convert to a `First_u`.
            public init(_ value: UInt16) {
                self.rawValue = u16_to_ft_u(value)
            }

            /// Create a `First_u` by converting a `UInt32`.
            ///
            /// - Parameter value: A `UInt32` value to convert to a `First_u`.
            public init(_ value: UInt32) {
                self.rawValue = u32_to_ft_u(value)
            }

            /// Create a `First_u` by converting a `UInt64`.
            ///
            /// - Parameter value: A `UInt64` value to convert to a `First_u`.
            public init(_ value: UInt64) {
                self.rawValue = u64_to_ft_u(value)
            }

            /// Create a `First_u` by converting a `UInt8`.
            ///
            /// - Parameter value: A `UInt8` value to convert to a `First_u`.
            public init(_ value: UInt8) {
                self.rawValue = u8_to_ft_u(value)
            }

        // MARK: - Converting From Other Units

            /// Create a `First_u` by converting a `FakeUnit`.
            ///
            /// - Parameter value: A `FakeUnit` value to convert to a `First_u`.
            public init(_ value: FakeUnit) {
                self.init(value.rawValue)
            }

            /// Create a `First_u` by converting a `Second_t`.
            ///
            /// - Parameter value: A `Second_t` value to convert to a `First_u`.
            public init(_ value: Second_t) {
                self.rawValue = snd_t_to_ft_u(value.rawValue)
            }

            /// Create a `First_u` by converting a `Second_u`.
            ///
            /// - Parameter value: A `Second_u` value to convert to a `First_u`.
            public init(_ value: Second_u) {
                self.rawValue = snd_u_to_ft_u(value.rawValue)
            }

            /// Create a `First_u` by converting a `Second_f`.
            ///
            /// - Parameter value: A `Second_f` value to convert to a `First_u`.
            public init(_ value: Second_f) {
                self.rawValue = snd_f_to_ft_u(value.rawValue)
            }

            /// Create a `First_u` by converting a `Second_d`.
            ///
            /// - Parameter value: A `Second_d` value to convert to a `First_u`.
            public init(_ value: Second_d) {
                self.rawValue = snd_d_to_ft_u(value.rawValue)
            }

        // MARK: - Converting From Other Precisions

            /// Create a `First_u` by converting a `First_d`.
            ///
            /// - Parameter value: A `First_d` value to convert to a `First_u`.
            public init(_ value: First_d) {
                self.rawValue = ft_d_to_ft_u(value.rawValue)
            }

            /// Create a `First_u` by converting a `First_f`.
            ///
            /// - Parameter value: A `First_f` value to convert to a `First_u`.
            public init(_ value: First_f) {
                self.rawValue = ft_f_to_ft_u(value.rawValue)
            }

            /// Create a `First_u` by converting a `First_t`.
            ///
            /// - Parameter value: A `First_t` value to convert to a `First_u`.
            public init(_ value: First_t) {
                self.rawValue = ft_t_to_ft_u(value.rawValue)
            }

        }

        /// A floating point type for the first unit.
        public struct First_f: GUUnitsFType, Hashable, Codable {

        // MARK: - Converting Between The Underlying guunits C Type

            /// Convert to the guunits underlying C type `first_f`
            public let rawValue: first_f

            /// Create a `First_f` from the underlying guunits C type `first_f`.
            public init(rawValue: first_f) {
                self.rawValue = rawValue
            }

        // MARK: - Converting From Swift Numeric Types

            /// Create a `First_f` by converting a `Double`.
            ///
            /// - Parameter value: A `Double` value to convert to a `First_f`.
            public init(_ value: Double) {
                self.rawValue = d_to_ft_f(value)
            }

            /// Create a `First_f` by converting a `Float`.
            ///
            /// - Parameter value: A `Float` value to convert to a `First_f`.
            public init(_ value: Float) {
                self.rawValue = f_to_ft_f(value)
            }

            /// Create a `First_f` by converting a `Int`.
            ///
            /// - Parameter value: A `Int` value to convert to a `First_f`.
            public init(_ value: Int) {
                self.rawValue = i64_to_ft_f(Int64(value))
            }

            /// Create a `First_f` by converting a `Int16`.
            ///
            /// - Parameter value: A `Int16` value to convert to a `First_f`.
            public init(_ value: Int16) {
                self.rawValue = i16_to_ft_f(value)
            }

            /// Create a `First_f` by converting a `Int32`.
            ///
            /// - Parameter value: A `Int32` value to convert to a `First_f`.
            public init(_ value: Int32) {
                self.rawValue = i32_to_ft_f(value)
            }

            /// Create a `First_f` by converting a `Int64`.
            ///
            /// - Parameter value: A `Int64` value to convert to a `First_f`.
            public init(_ value: Int64) {
                self.rawValue = i64_to_ft_f(value)
            }

            /// Create a `First_f` by converting a `Int8`.
            ///
            /// - Parameter value: A `Int8` value to convert to a `First_f`.
            public init(_ value: Int8) {
                self.rawValue = i8_to_ft_f(value)
            }

            /// Create a `First_f` by converting a `UInt`.
            ///
            /// - Parameter value: A `UInt` value to convert to a `First_f`.
            public init(_ value: UInt) {
                self.rawValue = u64_to_ft_f(UInt64(value))
            }

            /// Create a `First_f` by converting a `UInt16`.
            ///
            /// - Parameter value: A `UInt16` value to convert to a `First_f`.
            public init(_ value: UInt16) {
                self.rawValue = u16_to_ft_f(value)
            }

            /// Create a `First_f` by converting a `UInt32`.
            ///
            /// - Parameter value: A `UInt32` value to convert to a `First_f`.
            public init(_ value: UInt32) {
                self.rawValue = u32_to_ft_f(value)
            }

            /// Create a `First_f` by converting a `UInt64`.
            ///
            /// - Parameter value: A `UInt64` value to convert to a `First_f`.
            public init(_ value: UInt64) {
                self.rawValue = u64_to_ft_f(value)
            }

            /// Create a `First_f` by converting a `UInt8`.
            ///
            /// - Parameter value: A `UInt8` value to convert to a `First_f`.
            public init(_ value: UInt8) {
                self.rawValue = u8_to_ft_f(value)
            }

        // MARK: - Converting From Other Units

            /// Create a `First_f` by converting a `FakeUnit`.
            ///
            /// - Parameter value: A `FakeUnit` value to convert to a `First_f`.
            public init(_ value: FakeUnit) {
                self.init(value.rawValue)
            }

            /// Create a `First_f` by converting a `Second_t`.
            ///
            /// - Parameter value: A `Second_t` value to convert to a `First_f`.
            public init(_ value: Second_t) {
                self.rawValue = snd_t_to_ft_f(value.rawValue)
            }

            /// Create a `First_f` by converting a `Second_u`.
            ///
            /// - Parameter value: A `Second_u` value to convert to a `First_f`.
            public init(_ value: Second_u) {
                self.rawValue = snd_u_to_ft_f(value.rawValue)
            }

            /// Create a `First_f` by converting a `Second_f`.
            ///
            /// - Parameter value: A `Second_f` value to convert to a `First_f`.
            public init(_ value: Second_f) {
                self.rawValue = snd_f_to_ft_f(value.rawValue)
            }

            /// Create a `First_f` by converting a `Second_d`.
            ///
            /// - Parameter value: A `Second_d` value to convert to a `First_f`.
            public init(_ value: Second_d) {
                self.rawValue = snd_d_to_ft_f(value.rawValue)
            }

        // MARK: - Converting From Other Precisions

            /// Create a `First_f` by converting a `First_d`.
            ///
            /// - Parameter value: A `First_d` value to convert to a `First_f`.
            public init(_ value: First_d) {
                self.rawValue = ft_d_to_ft_f(value.rawValue)
            }

            /// Create a `First_f` by converting a `First_t`.
            ///
            /// - Parameter value: A `First_t` value to convert to a `First_f`.
            public init(_ value: First_t) {
                self.rawValue = ft_t_to_ft_f(value.rawValue)
            }

            /// Create a `First_f` by converting a `First_u`.
            ///
            /// - Parameter value: A `First_u` value to convert to a `First_f`.
            public init(_ value: First_u) {
                self.rawValue = ft_u_to_ft_f(value.rawValue)
            }

        }

        /// A double type for the first unit.
        public struct First_d: GUUnitsDType, Hashable, Codable {

        // MARK: - Converting Between The Underlying guunits C Type

            /// Convert to the guunits underlying C type `first_d`
            public let rawValue: first_d

            /// Create a `First_d` from the underlying guunits C type `first_d`.
            public init(rawValue: first_d) {
                self.rawValue = rawValue
            }

        // MARK: - Converting From Swift Numeric Types

            /// Create a `First_d` by converting a `Double`.
            ///
            /// - Parameter value: A `Double` value to convert to a `First_d`.
            public init(_ value: Double) {
                self.rawValue = d_to_ft_d(value)
            }

            /// Create a `First_d` by converting a `Float`.
            ///
            /// - Parameter value: A `Float` value to convert to a `First_d`.
            public init(_ value: Float) {
                self.rawValue = f_to_ft_d(value)
            }

            /// Create a `First_d` by converting a `Int`.
            ///
            /// - Parameter value: A `Int` value to convert to a `First_d`.
            public init(_ value: Int) {
                self.rawValue = i64_to_ft_d(Int64(value))
            }

            /// Create a `First_d` by converting a `Int16`.
            ///
            /// - Parameter value: A `Int16` value to convert to a `First_d`.
            public init(_ value: Int16) {
                self.rawValue = i16_to_ft_d(value)
            }

            /// Create a `First_d` by converting a `Int32`.
            ///
            /// - Parameter value: A `Int32` value to convert to a `First_d`.
            public init(_ value: Int32) {
                self.rawValue = i32_to_ft_d(value)
            }

            /// Create a `First_d` by converting a `Int64`.
            ///
            /// - Parameter value: A `Int64` value to convert to a `First_d`.
            public init(_ value: Int64) {
                self.rawValue = i64_to_ft_d(value)
            }

            /// Create a `First_d` by converting a `Int8`.
            ///
            /// - Parameter value: A `Int8` value to convert to a `First_d`.
            public init(_ value: Int8) {
                self.rawValue = i8_to_ft_d(value)
            }

            /// Create a `First_d` by converting a `UInt`.
            ///
            /// - Parameter value: A `UInt` value to convert to a `First_d`.
            public init(_ value: UInt) {
                self.rawValue = u64_to_ft_d(UInt64(value))
            }

            /// Create a `First_d` by converting a `UInt16`.
            ///
            /// - Parameter value: A `UInt16` value to convert to a `First_d`.
            public init(_ value: UInt16) {
                self.rawValue = u16_to_ft_d(value)
            }

            /// Create a `First_d` by converting a `UInt32`.
            ///
            /// - Parameter value: A `UInt32` value to convert to a `First_d`.
            public init(_ value: UInt32) {
                self.rawValue = u32_to_ft_d(value)
            }

            /// Create a `First_d` by converting a `UInt64`.
            ///
            /// - Parameter value: A `UInt64` value to convert to a `First_d`.
            public init(_ value: UInt64) {
                self.rawValue = u64_to_ft_d(value)
            }

            /// Create a `First_d` by converting a `UInt8`.
            ///
            /// - Parameter value: A `UInt8` value to convert to a `First_d`.
            public init(_ value: UInt8) {
                self.rawValue = u8_to_ft_d(value)
            }

        // MARK: - Converting From Other Units

            /// Create a `First_d` by converting a `FakeUnit`.
            ///
            /// - Parameter value: A `FakeUnit` value to convert to a `First_d`.
            public init(_ value: FakeUnit) {
                self.init(value.rawValue)
            }

            /// Create a `First_d` by converting a `Second_t`.
            ///
            /// - Parameter value: A `Second_t` value to convert to a `First_d`.
            public init(_ value: Second_t) {
                self.rawValue = snd_t_to_ft_d(value.rawValue)
            }

            /// Create a `First_d` by converting a `Second_u`.
            ///
            /// - Parameter value: A `Second_u` value to convert to a `First_d`.
            public init(_ value: Second_u) {
                self.rawValue = snd_u_to_ft_d(value.rawValue)
            }

            /// Create a `First_d` by converting a `Second_f`.
            ///
            /// - Parameter value: A `Second_f` value to convert to a `First_d`.
            public init(_ value: Second_f) {
                self.rawValue = snd_f_to_ft_d(value.rawValue)
            }

            /// Create a `First_d` by converting a `Second_d`.
            ///
            /// - Parameter value: A `Second_d` value to convert to a `First_d`.
            public init(_ value: Second_d) {
                self.rawValue = snd_d_to_ft_d(value.rawValue)
            }

        // MARK: - Converting From Other Precisions

            /// Create a `First_d` by converting a `First_f`.
            ///
            /// - Parameter value: A `First_f` value to convert to a `First_d`.
            public init(_ value: First_f) {
                self.rawValue = ft_f_to_ft_d(value.rawValue)
            }

            /// Create a `First_d` by converting a `First_t`.
            ///
            /// - Parameter value: A `First_t` value to convert to a `First_d`.
            public init(_ value: First_t) {
                self.rawValue = ft_t_to_ft_d(value.rawValue)
            }

            /// Create a `First_d` by converting a `First_u`.
            ///
            /// - Parameter value: A `First_u` value to convert to a `First_d`.
            public init(_ value: First_u) {
                self.rawValue = ft_u_to_ft_d(value.rawValue)
            }

        }

        public extension Double {

        // MARK: Creating a Double From The First Units

            /// Create a `Double` by converting a `First_t`.
            ///
            /// - Parameter value: A `First_t` value to convert to a `Double`.
            init(_ value: First_t) {
                self = ft_t_to_d(value.rawValue)
            }

            /// Create a `Double` by converting a `First_u`.
            ///
            /// - Parameter value: A `First_u` value to convert to a `Double`.
            init(_ value: First_u) {
                self = ft_u_to_d(value.rawValue)
            }

            /// Create a `Double` by converting a `First_f`.
            ///
            /// - Parameter value: A `First_f` value to convert to a `Double`.
            init(_ value: First_f) {
                self = ft_f_to_d(value.rawValue)
            }

            /// Create a `Double` by converting a `First_d`.
            ///
            /// - Parameter value: A `First_d` value to convert to a `Double`.
            init(_ value: First_d) {
                self = ft_d_to_d(value.rawValue)
            }

        }

        public extension Float {

        // MARK: Creating a Float From The First Units

            /// Create a `Float` by converting a `First_t`.
            ///
            /// - Parameter value: A `First_t` value to convert to a `Float`.
            init(_ value: First_t) {
                self = ft_t_to_f(value.rawValue)
            }

            /// Create a `Float` by converting a `First_u`.
            ///
            /// - Parameter value: A `First_u` value to convert to a `Float`.
            init(_ value: First_u) {
                self = ft_u_to_f(value.rawValue)
            }

            /// Create a `Float` by converting a `First_f`.
            ///
            /// - Parameter value: A `First_f` value to convert to a `Float`.
            init(_ value: First_f) {
                self = ft_f_to_f(value.rawValue)
            }

            /// Create a `Float` by converting a `First_d`.
            ///
            /// - Parameter value: A `First_d` value to convert to a `Float`.
            init(_ value: First_d) {
                self = ft_d_to_f(value.rawValue)
            }

        }

        public extension Int {

        // MARK: Creating a Int From The First Units

            /// Create a `Int` by converting a `First_t`.
            ///
            /// - Parameter value: A `First_t` value to convert to a `Int`.
            init(_ value: First_t) {
                self = Int(ft_t_to_i64(value.rawValue))
            }

            /// Create a `Int` by converting a `First_u`.
            ///
            /// - Parameter value: A `First_u` value to convert to a `Int`.
            init(_ value: First_u) {
                self = Int(ft_u_to_i64(value.rawValue))
            }

            /// Create a `Int` by converting a `First_f`.
            ///
            /// - Parameter value: A `First_f` value to convert to a `Int`.
            init(_ value: First_f) {
                self = Int(ft_f_to_i64(value.rawValue))
            }

            /// Create a `Int` by converting a `First_d`.
            ///
            /// - Parameter value: A `First_d` value to convert to a `Int`.
            init(_ value: First_d) {
                self = Int(ft_d_to_i64(value.rawValue))
            }

        }

        public extension Int16 {

        // MARK: Creating a Int16 From The First Units

            /// Create a `Int16` by converting a `First_t`.
            ///
            /// - Parameter value: A `First_t` value to convert to a `Int16`.
            init(_ value: First_t) {
                self = ft_t_to_i16(value.rawValue)
            }

            /// Create a `Int16` by converting a `First_u`.
            ///
            /// - Parameter value: A `First_u` value to convert to a `Int16`.
            init(_ value: First_u) {
                self = ft_u_to_i16(value.rawValue)
            }

            /// Create a `Int16` by converting a `First_f`.
            ///
            /// - Parameter value: A `First_f` value to convert to a `Int16`.
            init(_ value: First_f) {
                self = ft_f_to_i16(value.rawValue)
            }

            /// Create a `Int16` by converting a `First_d`.
            ///
            /// - Parameter value: A `First_d` value to convert to a `Int16`.
            init(_ value: First_d) {
                self = ft_d_to_i16(value.rawValue)
            }

        }

        public extension Int32 {

        // MARK: Creating a Int32 From The First Units

            /// Create a `Int32` by converting a `First_t`.
            ///
            /// - Parameter value: A `First_t` value to convert to a `Int32`.
            init(_ value: First_t) {
                self = ft_t_to_i32(value.rawValue)
            }

            /// Create a `Int32` by converting a `First_u`.
            ///
            /// - Parameter value: A `First_u` value to convert to a `Int32`.
            init(_ value: First_u) {
                self = ft_u_to_i32(value.rawValue)
            }

            /// Create a `Int32` by converting a `First_f`.
            ///
            /// - Parameter value: A `First_f` value to convert to a `Int32`.
            init(_ value: First_f) {
                self = ft_f_to_i32(value.rawValue)
            }

            /// Create a `Int32` by converting a `First_d`.
            ///
            /// - Parameter value: A `First_d` value to convert to a `Int32`.
            init(_ value: First_d) {
                self = ft_d_to_i32(value.rawValue)
            }

        }

        public extension Int64 {

        // MARK: Creating a Int64 From The First Units

            /// Create a `Int64` by converting a `First_t`.
            ///
            /// - Parameter value: A `First_t` value to convert to a `Int64`.
            init(_ value: First_t) {
                self = ft_t_to_i64(value.rawValue)
            }

            /// Create a `Int64` by converting a `First_u`.
            ///
            /// - Parameter value: A `First_u` value to convert to a `Int64`.
            init(_ value: First_u) {
                self = ft_u_to_i64(value.rawValue)
            }

            /// Create a `Int64` by converting a `First_f`.
            ///
            /// - Parameter value: A `First_f` value to convert to a `Int64`.
            init(_ value: First_f) {
                self = ft_f_to_i64(value.rawValue)
            }

            /// Create a `Int64` by converting a `First_d`.
            ///
            /// - Parameter value: A `First_d` value to convert to a `Int64`.
            init(_ value: First_d) {
                self = ft_d_to_i64(value.rawValue)
            }

        }

        public extension Int8 {

        // MARK: Creating a Int8 From The First Units

            /// Create a `Int8` by converting a `First_t`.
            ///
            /// - Parameter value: A `First_t` value to convert to a `Int8`.
            init(_ value: First_t) {
                self = ft_t_to_i8(value.rawValue)
            }

            /// Create a `Int8` by converting a `First_u`.
            ///
            /// - Parameter value: A `First_u` value to convert to a `Int8`.
            init(_ value: First_u) {
                self = ft_u_to_i8(value.rawValue)
            }

            /// Create a `Int8` by converting a `First_f`.
            ///
            /// - Parameter value: A `First_f` value to convert to a `Int8`.
            init(_ value: First_f) {
                self = ft_f_to_i8(value.rawValue)
            }

            /// Create a `Int8` by converting a `First_d`.
            ///
            /// - Parameter value: A `First_d` value to convert to a `Int8`.
            init(_ value: First_d) {
                self = ft_d_to_i8(value.rawValue)
            }

        }

        public extension UInt {

        // MARK: Creating a UInt From The First Units

            /// Create a `UInt` by converting a `First_t`.
            ///
            /// - Parameter value: A `First_t` value to convert to a `UInt`.
            init(_ value: First_t) {
                self = UInt(ft_t_to_u64(value.rawValue))
            }

            /// Create a `UInt` by converting a `First_u`.
            ///
            /// - Parameter value: A `First_u` value to convert to a `UInt`.
            init(_ value: First_u) {
                self = UInt(ft_u_to_u64(value.rawValue))
            }

            /// Create a `UInt` by converting a `First_f`.
            ///
            /// - Parameter value: A `First_f` value to convert to a `UInt`.
            init(_ value: First_f) {
                self = UInt(ft_f_to_u64(value.rawValue))
            }

            /// Create a `UInt` by converting a `First_d`.
            ///
            /// - Parameter value: A `First_d` value to convert to a `UInt`.
            init(_ value: First_d) {
                self = UInt(ft_d_to_u64(value.rawValue))
            }

        }

        public extension UInt16 {

        // MARK: Creating a UInt16 From The First Units

            /// Create a `UInt16` by converting a `First_t`.
            ///
            /// - Parameter value: A `First_t` value to convert to a `UInt16`.
            init(_ value: First_t) {
                self = ft_t_to_u16(value.rawValue)
            }

            /// Create a `UInt16` by converting a `First_u`.
            ///
            /// - Parameter value: A `First_u` value to convert to a `UInt16`.
            init(_ value: First_u) {
                self = ft_u_to_u16(value.rawValue)
            }

            /// Create a `UInt16` by converting a `First_f`.
            ///
            /// - Parameter value: A `First_f` value to convert to a `UInt16`.
            init(_ value: First_f) {
                self = ft_f_to_u16(value.rawValue)
            }

            /// Create a `UInt16` by converting a `First_d`.
            ///
            /// - Parameter value: A `First_d` value to convert to a `UInt16`.
            init(_ value: First_d) {
                self = ft_d_to_u16(value.rawValue)
            }

        }

        public extension UInt32 {

        // MARK: Creating a UInt32 From The First Units

            /// Create a `UInt32` by converting a `First_t`.
            ///
            /// - Parameter value: A `First_t` value to convert to a `UInt32`.
            init(_ value: First_t) {
                self = ft_t_to_u32(value.rawValue)
            }

            /// Create a `UInt32` by converting a `First_u`.
            ///
            /// - Parameter value: A `First_u` value to convert to a `UInt32`.
            init(_ value: First_u) {
                self = ft_u_to_u32(value.rawValue)
            }

            /// Create a `UInt32` by converting a `First_f`.
            ///
            /// - Parameter value: A `First_f` value to convert to a `UInt32`.
            init(_ value: First_f) {
                self = ft_f_to_u32(value.rawValue)
            }

            /// Create a `UInt32` by converting a `First_d`.
            ///
            /// - Parameter value: A `First_d` value to convert to a `UInt32`.
            init(_ value: First_d) {
                self = ft_d_to_u32(value.rawValue)
            }

        }

        public extension UInt64 {

        // MARK: Creating a UInt64 From The First Units

            /// Create a `UInt64` by converting a `First_t`.
            ///
            /// - Parameter value: A `First_t` value to convert to a `UInt64`.
            init(_ value: First_t) {
                self = ft_t_to_u64(value.rawValue)
            }

            /// Create a `UInt64` by converting a `First_u`.
            ///
            /// - Parameter value: A `First_u` value to convert to a `UInt64`.
            init(_ value: First_u) {
                self = ft_u_to_u64(value.rawValue)
            }

            /// Create a `UInt64` by converting a `First_f`.
            ///
            /// - Parameter value: A `First_f` value to convert to a `UInt64`.
            init(_ value: First_f) {
                self = ft_f_to_u64(value.rawValue)
            }

            /// Create a `UInt64` by converting a `First_d`.
            ///
            /// - Parameter value: A `First_d` value to convert to a `UInt64`.
            init(_ value: First_d) {
                self = ft_d_to_u64(value.rawValue)
            }

        }

        public extension UInt8 {

        // MARK: Creating a UInt8 From The First Units

            /// Create a `UInt8` by converting a `First_t`.
            ///
            /// - Parameter value: A `First_t` value to convert to a `UInt8`.
            init(_ value: First_t) {
                self = ft_t_to_u8(value.rawValue)
            }

            /// Create a `UInt8` by converting a `First_u`.
            ///
            /// - Parameter value: A `First_u` value to convert to a `UInt8`.
            init(_ value: First_u) {
                self = ft_u_to_u8(value.rawValue)
            }

            /// Create a `UInt8` by converting a `First_f`.
            ///
            /// - Parameter value: A `First_f` value to convert to a `UInt8`.
            init(_ value: First_f) {
                self = ft_f_to_u8(value.rawValue)
            }

            /// Create a `UInt8` by converting a `First_d`.
            ///
            /// - Parameter value: A `First_d` value to convert to a `UInt8`.
            init(_ value: First_d) {
                self = ft_d_to_u8(value.rawValue)
            }

        }




        /// A signed integer type for the second unit.
        public struct Second_t: GUUnitsTType, Hashable, Codable {

        // MARK: - Converting Between The Underlying guunits C Type

            /// Convert to the guunits underlying C type `second_t`
            public let rawValue: second_t

            /// Create a `Second_t` from the underlying guunits C type `second_t`.
            public init(rawValue: second_t) {
                self.rawValue = rawValue
            }

        // MARK: - Converting From Swift Numeric Types

            /// Create a `Second_t` by converting a `Double`.
            ///
            /// - Parameter value: A `Double` value to convert to a `Second_t`.
            public init(_ value: Double) {
                self.rawValue = d_to_snd_t(value)
            }

            /// Create a `Second_t` by converting a `Float`.
            ///
            /// - Parameter value: A `Float` value to convert to a `Second_t`.
            public init(_ value: Float) {
                self.rawValue = f_to_snd_t(value)
            }

            /// Create a `Second_t` by converting a `Int`.
            ///
            /// - Parameter value: A `Int` value to convert to a `Second_t`.
            public init(_ value: Int) {
                self.rawValue = i64_to_snd_t(Int64(value))
            }

            /// Create a `Second_t` by converting a `Int16`.
            ///
            /// - Parameter value: A `Int16` value to convert to a `Second_t`.
            public init(_ value: Int16) {
                self.rawValue = i16_to_snd_t(value)
            }

            /// Create a `Second_t` by converting a `Int32`.
            ///
            /// - Parameter value: A `Int32` value to convert to a `Second_t`.
            public init(_ value: Int32) {
                self.rawValue = i32_to_snd_t(value)
            }

            /// Create a `Second_t` by converting a `Int64`.
            ///
            /// - Parameter value: A `Int64` value to convert to a `Second_t`.
            public init(_ value: Int64) {
                self.rawValue = i64_to_snd_t(value)
            }

            /// Create a `Second_t` by converting a `Int8`.
            ///
            /// - Parameter value: A `Int8` value to convert to a `Second_t`.
            public init(_ value: Int8) {
                self.rawValue = i8_to_snd_t(value)
            }

            /// Create a `Second_t` by converting a `UInt`.
            ///
            /// - Parameter value: A `UInt` value to convert to a `Second_t`.
            public init(_ value: UInt) {
                self.rawValue = u64_to_snd_t(UInt64(value))
            }

            /// Create a `Second_t` by converting a `UInt16`.
            ///
            /// - Parameter value: A `UInt16` value to convert to a `Second_t`.
            public init(_ value: UInt16) {
                self.rawValue = u16_to_snd_t(value)
            }

            /// Create a `Second_t` by converting a `UInt32`.
            ///
            /// - Parameter value: A `UInt32` value to convert to a `Second_t`.
            public init(_ value: UInt32) {
                self.rawValue = u32_to_snd_t(value)
            }

            /// Create a `Second_t` by converting a `UInt64`.
            ///
            /// - Parameter value: A `UInt64` value to convert to a `Second_t`.
            public init(_ value: UInt64) {
                self.rawValue = u64_to_snd_t(value)
            }

            /// Create a `Second_t` by converting a `UInt8`.
            ///
            /// - Parameter value: A `UInt8` value to convert to a `Second_t`.
            public init(_ value: UInt8) {
                self.rawValue = u8_to_snd_t(value)
            }

        // MARK: - Converting From Other Units

            /// Create a `Second_t` by converting a `FakeUnit`.
            ///
            /// - Parameter value: A `FakeUnit` value to convert to a `Second_t`.
            public init(_ value: FakeUnit) {
                self.init(value.rawValue)
            }

            /// Create a `Second_t` by converting a `First_t`.
            ///
            /// - Parameter value: A `First_t` value to convert to a `Second_t`.
            public init(_ value: First_t) {
                self.rawValue = ft_t_to_snd_t(value.rawValue)
            }

            /// Create a `Second_t` by converting a `First_u`.
            ///
            /// - Parameter value: A `First_u` value to convert to a `Second_t`.
            public init(_ value: First_u) {
                self.rawValue = ft_u_to_snd_t(value.rawValue)
            }

            /// Create a `Second_t` by converting a `First_f`.
            ///
            /// - Parameter value: A `First_f` value to convert to a `Second_t`.
            public init(_ value: First_f) {
                self.rawValue = ft_f_to_snd_t(value.rawValue)
            }

            /// Create a `Second_t` by converting a `First_d`.
            ///
            /// - Parameter value: A `First_d` value to convert to a `Second_t`.
            public init(_ value: First_d) {
                self.rawValue = ft_d_to_snd_t(value.rawValue)
            }

        // MARK: - Converting From Other Precisions

            /// Create a `Second_t` by converting a `Second_d`.
            ///
            /// - Parameter value: A `Second_d` value to convert to a `Second_t`.
            public init(_ value: Second_d) {
                self.rawValue = snd_d_to_snd_t(value.rawValue)
            }

            /// Create a `Second_t` by converting a `Second_f`.
            ///
            /// - Parameter value: A `Second_f` value to convert to a `Second_t`.
            public init(_ value: Second_f) {
                self.rawValue = snd_f_to_snd_t(value.rawValue)
            }

            /// Create a `Second_t` by converting a `Second_u`.
            ///
            /// - Parameter value: A `Second_u` value to convert to a `Second_t`.
            public init(_ value: Second_u) {
                self.rawValue = snd_u_to_snd_t(value.rawValue)
            }

        }

        /// An unsigned integer type for the second unit.
        public struct Second_u: GUUnitsUType, Hashable, Codable {

        // MARK: - Converting Between The Underlying guunits C Type

            /// Convert to the guunits underlying C type `second_u`
            public let rawValue: second_u

            /// Create a `Second_u` from the underlying guunits C type `second_u`.
            public init(rawValue: second_u) {
                self.rawValue = rawValue
            }

        // MARK: - Converting From Swift Numeric Types

            /// Create a `Second_u` by converting a `Double`.
            ///
            /// - Parameter value: A `Double` value to convert to a `Second_u`.
            public init(_ value: Double) {
                self.rawValue = d_to_snd_u(value)
            }

            /// Create a `Second_u` by converting a `Float`.
            ///
            /// - Parameter value: A `Float` value to convert to a `Second_u`.
            public init(_ value: Float) {
                self.rawValue = f_to_snd_u(value)
            }

            /// Create a `Second_u` by converting a `Int`.
            ///
            /// - Parameter value: A `Int` value to convert to a `Second_u`.
            public init(_ value: Int) {
                self.rawValue = i64_to_snd_u(Int64(value))
            }

            /// Create a `Second_u` by converting a `Int16`.
            ///
            /// - Parameter value: A `Int16` value to convert to a `Second_u`.
            public init(_ value: Int16) {
                self.rawValue = i16_to_snd_u(value)
            }

            /// Create a `Second_u` by converting a `Int32`.
            ///
            /// - Parameter value: A `Int32` value to convert to a `Second_u`.
            public init(_ value: Int32) {
                self.rawValue = i32_to_snd_u(value)
            }

            /// Create a `Second_u` by converting a `Int64`.
            ///
            /// - Parameter value: A `Int64` value to convert to a `Second_u`.
            public init(_ value: Int64) {
                self.rawValue = i64_to_snd_u(value)
            }

            /// Create a `Second_u` by converting a `Int8`.
            ///
            /// - Parameter value: A `Int8` value to convert to a `Second_u`.
            public init(_ value: Int8) {
                self.rawValue = i8_to_snd_u(value)
            }

            /// Create a `Second_u` by converting a `UInt`.
            ///
            /// - Parameter value: A `UInt` value to convert to a `Second_u`.
            public init(_ value: UInt) {
                self.rawValue = u64_to_snd_u(UInt64(value))
            }

            /// Create a `Second_u` by converting a `UInt16`.
            ///
            /// - Parameter value: A `UInt16` value to convert to a `Second_u`.
            public init(_ value: UInt16) {
                self.rawValue = u16_to_snd_u(value)
            }

            /// Create a `Second_u` by converting a `UInt32`.
            ///
            /// - Parameter value: A `UInt32` value to convert to a `Second_u`.
            public init(_ value: UInt32) {
                self.rawValue = u32_to_snd_u(value)
            }

            /// Create a `Second_u` by converting a `UInt64`.
            ///
            /// - Parameter value: A `UInt64` value to convert to a `Second_u`.
            public init(_ value: UInt64) {
                self.rawValue = u64_to_snd_u(value)
            }

            /// Create a `Second_u` by converting a `UInt8`.
            ///
            /// - Parameter value: A `UInt8` value to convert to a `Second_u`.
            public init(_ value: UInt8) {
                self.rawValue = u8_to_snd_u(value)
            }

        // MARK: - Converting From Other Units

            /// Create a `Second_u` by converting a `FakeUnit`.
            ///
            /// - Parameter value: A `FakeUnit` value to convert to a `Second_u`.
            public init(_ value: FakeUnit) {
                self.init(value.rawValue)
            }

            /// Create a `Second_u` by converting a `First_t`.
            ///
            /// - Parameter value: A `First_t` value to convert to a `Second_u`.
            public init(_ value: First_t) {
                self.rawValue = ft_t_to_snd_u(value.rawValue)
            }

            /// Create a `Second_u` by converting a `First_u`.
            ///
            /// - Parameter value: A `First_u` value to convert to a `Second_u`.
            public init(_ value: First_u) {
                self.rawValue = ft_u_to_snd_u(value.rawValue)
            }

            /// Create a `Second_u` by converting a `First_f`.
            ///
            /// - Parameter value: A `First_f` value to convert to a `Second_u`.
            public init(_ value: First_f) {
                self.rawValue = ft_f_to_snd_u(value.rawValue)
            }

            /// Create a `Second_u` by converting a `First_d`.
            ///
            /// - Parameter value: A `First_d` value to convert to a `Second_u`.
            public init(_ value: First_d) {
                self.rawValue = ft_d_to_snd_u(value.rawValue)
            }

        // MARK: - Converting From Other Precisions

            /// Create a `Second_u` by converting a `Second_d`.
            ///
            /// - Parameter value: A `Second_d` value to convert to a `Second_u`.
            public init(_ value: Second_d) {
                self.rawValue = snd_d_to_snd_u(value.rawValue)
            }

            /// Create a `Second_u` by converting a `Second_f`.
            ///
            /// - Parameter value: A `Second_f` value to convert to a `Second_u`.
            public init(_ value: Second_f) {
                self.rawValue = snd_f_to_snd_u(value.rawValue)
            }

            /// Create a `Second_u` by converting a `Second_t`.
            ///
            /// - Parameter value: A `Second_t` value to convert to a `Second_u`.
            public init(_ value: Second_t) {
                self.rawValue = snd_t_to_snd_u(value.rawValue)
            }

        }

        /// A floating point type for the second unit.
        public struct Second_f: GUUnitsFType, Hashable, Codable {

        // MARK: - Converting Between The Underlying guunits C Type

            /// Convert to the guunits underlying C type `second_f`
            public let rawValue: second_f

            /// Create a `Second_f` from the underlying guunits C type `second_f`.
            public init(rawValue: second_f) {
                self.rawValue = rawValue
            }

        // MARK: - Converting From Swift Numeric Types

            /// Create a `Second_f` by converting a `Double`.
            ///
            /// - Parameter value: A `Double` value to convert to a `Second_f`.
            public init(_ value: Double) {
                self.rawValue = d_to_snd_f(value)
            }

            /// Create a `Second_f` by converting a `Float`.
            ///
            /// - Parameter value: A `Float` value to convert to a `Second_f`.
            public init(_ value: Float) {
                self.rawValue = f_to_snd_f(value)
            }

            /// Create a `Second_f` by converting a `Int`.
            ///
            /// - Parameter value: A `Int` value to convert to a `Second_f`.
            public init(_ value: Int) {
                self.rawValue = i64_to_snd_f(Int64(value))
            }

            /// Create a `Second_f` by converting a `Int16`.
            ///
            /// - Parameter value: A `Int16` value to convert to a `Second_f`.
            public init(_ value: Int16) {
                self.rawValue = i16_to_snd_f(value)
            }

            /// Create a `Second_f` by converting a `Int32`.
            ///
            /// - Parameter value: A `Int32` value to convert to a `Second_f`.
            public init(_ value: Int32) {
                self.rawValue = i32_to_snd_f(value)
            }

            /// Create a `Second_f` by converting a `Int64`.
            ///
            /// - Parameter value: A `Int64` value to convert to a `Second_f`.
            public init(_ value: Int64) {
                self.rawValue = i64_to_snd_f(value)
            }

            /// Create a `Second_f` by converting a `Int8`.
            ///
            /// - Parameter value: A `Int8` value to convert to a `Second_f`.
            public init(_ value: Int8) {
                self.rawValue = i8_to_snd_f(value)
            }

            /// Create a `Second_f` by converting a `UInt`.
            ///
            /// - Parameter value: A `UInt` value to convert to a `Second_f`.
            public init(_ value: UInt) {
                self.rawValue = u64_to_snd_f(UInt64(value))
            }

            /// Create a `Second_f` by converting a `UInt16`.
            ///
            /// - Parameter value: A `UInt16` value to convert to a `Second_f`.
            public init(_ value: UInt16) {
                self.rawValue = u16_to_snd_f(value)
            }

            /// Create a `Second_f` by converting a `UInt32`.
            ///
            /// - Parameter value: A `UInt32` value to convert to a `Second_f`.
            public init(_ value: UInt32) {
                self.rawValue = u32_to_snd_f(value)
            }

            /// Create a `Second_f` by converting a `UInt64`.
            ///
            /// - Parameter value: A `UInt64` value to convert to a `Second_f`.
            public init(_ value: UInt64) {
                self.rawValue = u64_to_snd_f(value)
            }

            /// Create a `Second_f` by converting a `UInt8`.
            ///
            /// - Parameter value: A `UInt8` value to convert to a `Second_f`.
            public init(_ value: UInt8) {
                self.rawValue = u8_to_snd_f(value)
            }

        // MARK: - Converting From Other Units

            /// Create a `Second_f` by converting a `FakeUnit`.
            ///
            /// - Parameter value: A `FakeUnit` value to convert to a `Second_f`.
            public init(_ value: FakeUnit) {
                self.init(value.rawValue)
            }

            /// Create a `Second_f` by converting a `First_t`.
            ///
            /// - Parameter value: A `First_t` value to convert to a `Second_f`.
            public init(_ value: First_t) {
                self.rawValue = ft_t_to_snd_f(value.rawValue)
            }

            /// Create a `Second_f` by converting a `First_u`.
            ///
            /// - Parameter value: A `First_u` value to convert to a `Second_f`.
            public init(_ value: First_u) {
                self.rawValue = ft_u_to_snd_f(value.rawValue)
            }

            /// Create a `Second_f` by converting a `First_f`.
            ///
            /// - Parameter value: A `First_f` value to convert to a `Second_f`.
            public init(_ value: First_f) {
                self.rawValue = ft_f_to_snd_f(value.rawValue)
            }

            /// Create a `Second_f` by converting a `First_d`.
            ///
            /// - Parameter value: A `First_d` value to convert to a `Second_f`.
            public init(_ value: First_d) {
                self.rawValue = ft_d_to_snd_f(value.rawValue)
            }

        // MARK: - Converting From Other Precisions

            /// Create a `Second_f` by converting a `Second_d`.
            ///
            /// - Parameter value: A `Second_d` value to convert to a `Second_f`.
            public init(_ value: Second_d) {
                self.rawValue = snd_d_to_snd_f(value.rawValue)
            }

            /// Create a `Second_f` by converting a `Second_t`.
            ///
            /// - Parameter value: A `Second_t` value to convert to a `Second_f`.
            public init(_ value: Second_t) {
                self.rawValue = snd_t_to_snd_f(value.rawValue)
            }

            /// Create a `Second_f` by converting a `Second_u`.
            ///
            /// - Parameter value: A `Second_u` value to convert to a `Second_f`.
            public init(_ value: Second_u) {
                self.rawValue = snd_u_to_snd_f(value.rawValue)
            }

        }

        /// A double type for the second unit.
        public struct Second_d: GUUnitsDType, Hashable, Codable {

        // MARK: - Converting Between The Underlying guunits C Type

            /// Convert to the guunits underlying C type `second_d`
            public let rawValue: second_d

            /// Create a `Second_d` from the underlying guunits C type `second_d`.
            public init(rawValue: second_d) {
                self.rawValue = rawValue
            }

        // MARK: - Converting From Swift Numeric Types

            /// Create a `Second_d` by converting a `Double`.
            ///
            /// - Parameter value: A `Double` value to convert to a `Second_d`.
            public init(_ value: Double) {
                self.rawValue = d_to_snd_d(value)
            }

            /// Create a `Second_d` by converting a `Float`.
            ///
            /// - Parameter value: A `Float` value to convert to a `Second_d`.
            public init(_ value: Float) {
                self.rawValue = f_to_snd_d(value)
            }

            /// Create a `Second_d` by converting a `Int`.
            ///
            /// - Parameter value: A `Int` value to convert to a `Second_d`.
            public init(_ value: Int) {
                self.rawValue = i64_to_snd_d(Int64(value))
            }

            /// Create a `Second_d` by converting a `Int16`.
            ///
            /// - Parameter value: A `Int16` value to convert to a `Second_d`.
            public init(_ value: Int16) {
                self.rawValue = i16_to_snd_d(value)
            }

            /// Create a `Second_d` by converting a `Int32`.
            ///
            /// - Parameter value: A `Int32` value to convert to a `Second_d`.
            public init(_ value: Int32) {
                self.rawValue = i32_to_snd_d(value)
            }

            /// Create a `Second_d` by converting a `Int64`.
            ///
            /// - Parameter value: A `Int64` value to convert to a `Second_d`.
            public init(_ value: Int64) {
                self.rawValue = i64_to_snd_d(value)
            }

            /// Create a `Second_d` by converting a `Int8`.
            ///
            /// - Parameter value: A `Int8` value to convert to a `Second_d`.
            public init(_ value: Int8) {
                self.rawValue = i8_to_snd_d(value)
            }

            /// Create a `Second_d` by converting a `UInt`.
            ///
            /// - Parameter value: A `UInt` value to convert to a `Second_d`.
            public init(_ value: UInt) {
                self.rawValue = u64_to_snd_d(UInt64(value))
            }

            /// Create a `Second_d` by converting a `UInt16`.
            ///
            /// - Parameter value: A `UInt16` value to convert to a `Second_d`.
            public init(_ value: UInt16) {
                self.rawValue = u16_to_snd_d(value)
            }

            /// Create a `Second_d` by converting a `UInt32`.
            ///
            /// - Parameter value: A `UInt32` value to convert to a `Second_d`.
            public init(_ value: UInt32) {
                self.rawValue = u32_to_snd_d(value)
            }

            /// Create a `Second_d` by converting a `UInt64`.
            ///
            /// - Parameter value: A `UInt64` value to convert to a `Second_d`.
            public init(_ value: UInt64) {
                self.rawValue = u64_to_snd_d(value)
            }

            /// Create a `Second_d` by converting a `UInt8`.
            ///
            /// - Parameter value: A `UInt8` value to convert to a `Second_d`.
            public init(_ value: UInt8) {
                self.rawValue = u8_to_snd_d(value)
            }

        // MARK: - Converting From Other Units

            /// Create a `Second_d` by converting a `FakeUnit`.
            ///
            /// - Parameter value: A `FakeUnit` value to convert to a `Second_d`.
            public init(_ value: FakeUnit) {
                self.init(value.rawValue)
            }

            /// Create a `Second_d` by converting a `First_t`.
            ///
            /// - Parameter value: A `First_t` value to convert to a `Second_d`.
            public init(_ value: First_t) {
                self.rawValue = ft_t_to_snd_d(value.rawValue)
            }

            /// Create a `Second_d` by converting a `First_u`.
            ///
            /// - Parameter value: A `First_u` value to convert to a `Second_d`.
            public init(_ value: First_u) {
                self.rawValue = ft_u_to_snd_d(value.rawValue)
            }

            /// Create a `Second_d` by converting a `First_f`.
            ///
            /// - Parameter value: A `First_f` value to convert to a `Second_d`.
            public init(_ value: First_f) {
                self.rawValue = ft_f_to_snd_d(value.rawValue)
            }

            /// Create a `Second_d` by converting a `First_d`.
            ///
            /// - Parameter value: A `First_d` value to convert to a `Second_d`.
            public init(_ value: First_d) {
                self.rawValue = ft_d_to_snd_d(value.rawValue)
            }

        // MARK: - Converting From Other Precisions

            /// Create a `Second_d` by converting a `Second_f`.
            ///
            /// - Parameter value: A `Second_f` value to convert to a `Second_d`.
            public init(_ value: Second_f) {
                self.rawValue = snd_f_to_snd_d(value.rawValue)
            }

            /// Create a `Second_d` by converting a `Second_t`.
            ///
            /// - Parameter value: A `Second_t` value to convert to a `Second_d`.
            public init(_ value: Second_t) {
                self.rawValue = snd_t_to_snd_d(value.rawValue)
            }

            /// Create a `Second_d` by converting a `Second_u`.
            ///
            /// - Parameter value: A `Second_u` value to convert to a `Second_d`.
            public init(_ value: Second_u) {
                self.rawValue = snd_u_to_snd_d(value.rawValue)
            }

        }

        public extension Double {

        // MARK: Creating a Double From The Second Units

            /// Create a `Double` by converting a `Second_t`.
            ///
            /// - Parameter value: A `Second_t` value to convert to a `Double`.
            init(_ value: Second_t) {
                self = snd_t_to_d(value.rawValue)
            }

            /// Create a `Double` by converting a `Second_u`.
            ///
            /// - Parameter value: A `Second_u` value to convert to a `Double`.
            init(_ value: Second_u) {
                self = snd_u_to_d(value.rawValue)
            }

            /// Create a `Double` by converting a `Second_f`.
            ///
            /// - Parameter value: A `Second_f` value to convert to a `Double`.
            init(_ value: Second_f) {
                self = snd_f_to_d(value.rawValue)
            }

            /// Create a `Double` by converting a `Second_d`.
            ///
            /// - Parameter value: A `Second_d` value to convert to a `Double`.
            init(_ value: Second_d) {
                self = snd_d_to_d(value.rawValue)
            }

        }

        public extension Float {

        // MARK: Creating a Float From The Second Units

            /// Create a `Float` by converting a `Second_t`.
            ///
            /// - Parameter value: A `Second_t` value to convert to a `Float`.
            init(_ value: Second_t) {
                self = snd_t_to_f(value.rawValue)
            }

            /// Create a `Float` by converting a `Second_u`.
            ///
            /// - Parameter value: A `Second_u` value to convert to a `Float`.
            init(_ value: Second_u) {
                self = snd_u_to_f(value.rawValue)
            }

            /// Create a `Float` by converting a `Second_f`.
            ///
            /// - Parameter value: A `Second_f` value to convert to a `Float`.
            init(_ value: Second_f) {
                self = snd_f_to_f(value.rawValue)
            }

            /// Create a `Float` by converting a `Second_d`.
            ///
            /// - Parameter value: A `Second_d` value to convert to a `Float`.
            init(_ value: Second_d) {
                self = snd_d_to_f(value.rawValue)
            }

        }

        public extension Int {

        // MARK: Creating a Int From The Second Units

            /// Create a `Int` by converting a `Second_t`.
            ///
            /// - Parameter value: A `Second_t` value to convert to a `Int`.
            init(_ value: Second_t) {
                self = Int(snd_t_to_i64(value.rawValue))
            }

            /// Create a `Int` by converting a `Second_u`.
            ///
            /// - Parameter value: A `Second_u` value to convert to a `Int`.
            init(_ value: Second_u) {
                self = Int(snd_u_to_i64(value.rawValue))
            }

            /// Create a `Int` by converting a `Second_f`.
            ///
            /// - Parameter value: A `Second_f` value to convert to a `Int`.
            init(_ value: Second_f) {
                self = Int(snd_f_to_i64(value.rawValue))
            }

            /// Create a `Int` by converting a `Second_d`.
            ///
            /// - Parameter value: A `Second_d` value to convert to a `Int`.
            init(_ value: Second_d) {
                self = Int(snd_d_to_i64(value.rawValue))
            }

        }

        public extension Int16 {

        // MARK: Creating a Int16 From The Second Units

            /// Create a `Int16` by converting a `Second_t`.
            ///
            /// - Parameter value: A `Second_t` value to convert to a `Int16`.
            init(_ value: Second_t) {
                self = snd_t_to_i16(value.rawValue)
            }

            /// Create a `Int16` by converting a `Second_u`.
            ///
            /// - Parameter value: A `Second_u` value to convert to a `Int16`.
            init(_ value: Second_u) {
                self = snd_u_to_i16(value.rawValue)
            }

            /// Create a `Int16` by converting a `Second_f`.
            ///
            /// - Parameter value: A `Second_f` value to convert to a `Int16`.
            init(_ value: Second_f) {
                self = snd_f_to_i16(value.rawValue)
            }

            /// Create a `Int16` by converting a `Second_d`.
            ///
            /// - Parameter value: A `Second_d` value to convert to a `Int16`.
            init(_ value: Second_d) {
                self = snd_d_to_i16(value.rawValue)
            }

        }

        public extension Int32 {

        // MARK: Creating a Int32 From The Second Units

            /// Create a `Int32` by converting a `Second_t`.
            ///
            /// - Parameter value: A `Second_t` value to convert to a `Int32`.
            init(_ value: Second_t) {
                self = snd_t_to_i32(value.rawValue)
            }

            /// Create a `Int32` by converting a `Second_u`.
            ///
            /// - Parameter value: A `Second_u` value to convert to a `Int32`.
            init(_ value: Second_u) {
                self = snd_u_to_i32(value.rawValue)
            }

            /// Create a `Int32` by converting a `Second_f`.
            ///
            /// - Parameter value: A `Second_f` value to convert to a `Int32`.
            init(_ value: Second_f) {
                self = snd_f_to_i32(value.rawValue)
            }

            /// Create a `Int32` by converting a `Second_d`.
            ///
            /// - Parameter value: A `Second_d` value to convert to a `Int32`.
            init(_ value: Second_d) {
                self = snd_d_to_i32(value.rawValue)
            }

        }

        public extension Int64 {

        // MARK: Creating a Int64 From The Second Units

            /// Create a `Int64` by converting a `Second_t`.
            ///
            /// - Parameter value: A `Second_t` value to convert to a `Int64`.
            init(_ value: Second_t) {
                self = snd_t_to_i64(value.rawValue)
            }

            /// Create a `Int64` by converting a `Second_u`.
            ///
            /// - Parameter value: A `Second_u` value to convert to a `Int64`.
            init(_ value: Second_u) {
                self = snd_u_to_i64(value.rawValue)
            }

            /// Create a `Int64` by converting a `Second_f`.
            ///
            /// - Parameter value: A `Second_f` value to convert to a `Int64`.
            init(_ value: Second_f) {
                self = snd_f_to_i64(value.rawValue)
            }

            /// Create a `Int64` by converting a `Second_d`.
            ///
            /// - Parameter value: A `Second_d` value to convert to a `Int64`.
            init(_ value: Second_d) {
                self = snd_d_to_i64(value.rawValue)
            }

        }

        public extension Int8 {

        // MARK: Creating a Int8 From The Second Units

            /// Create a `Int8` by converting a `Second_t`.
            ///
            /// - Parameter value: A `Second_t` value to convert to a `Int8`.
            init(_ value: Second_t) {
                self = snd_t_to_i8(value.rawValue)
            }

            /// Create a `Int8` by converting a `Second_u`.
            ///
            /// - Parameter value: A `Second_u` value to convert to a `Int8`.
            init(_ value: Second_u) {
                self = snd_u_to_i8(value.rawValue)
            }

            /// Create a `Int8` by converting a `Second_f`.
            ///
            /// - Parameter value: A `Second_f` value to convert to a `Int8`.
            init(_ value: Second_f) {
                self = snd_f_to_i8(value.rawValue)
            }

            /// Create a `Int8` by converting a `Second_d`.
            ///
            /// - Parameter value: A `Second_d` value to convert to a `Int8`.
            init(_ value: Second_d) {
                self = snd_d_to_i8(value.rawValue)
            }

        }

        public extension UInt {

        // MARK: Creating a UInt From The Second Units

            /// Create a `UInt` by converting a `Second_t`.
            ///
            /// - Parameter value: A `Second_t` value to convert to a `UInt`.
            init(_ value: Second_t) {
                self = UInt(snd_t_to_u64(value.rawValue))
            }

            /// Create a `UInt` by converting a `Second_u`.
            ///
            /// - Parameter value: A `Second_u` value to convert to a `UInt`.
            init(_ value: Second_u) {
                self = UInt(snd_u_to_u64(value.rawValue))
            }

            /// Create a `UInt` by converting a `Second_f`.
            ///
            /// - Parameter value: A `Second_f` value to convert to a `UInt`.
            init(_ value: Second_f) {
                self = UInt(snd_f_to_u64(value.rawValue))
            }

            /// Create a `UInt` by converting a `Second_d`.
            ///
            /// - Parameter value: A `Second_d` value to convert to a `UInt`.
            init(_ value: Second_d) {
                self = UInt(snd_d_to_u64(value.rawValue))
            }

        }

        public extension UInt16 {

        // MARK: Creating a UInt16 From The Second Units

            /// Create a `UInt16` by converting a `Second_t`.
            ///
            /// - Parameter value: A `Second_t` value to convert to a `UInt16`.
            init(_ value: Second_t) {
                self = snd_t_to_u16(value.rawValue)
            }

            /// Create a `UInt16` by converting a `Second_u`.
            ///
            /// - Parameter value: A `Second_u` value to convert to a `UInt16`.
            init(_ value: Second_u) {
                self = snd_u_to_u16(value.rawValue)
            }

            /// Create a `UInt16` by converting a `Second_f`.
            ///
            /// - Parameter value: A `Second_f` value to convert to a `UInt16`.
            init(_ value: Second_f) {
                self = snd_f_to_u16(value.rawValue)
            }

            /// Create a `UInt16` by converting a `Second_d`.
            ///
            /// - Parameter value: A `Second_d` value to convert to a `UInt16`.
            init(_ value: Second_d) {
                self = snd_d_to_u16(value.rawValue)
            }

        }

        public extension UInt32 {

        // MARK: Creating a UInt32 From The Second Units

            /// Create a `UInt32` by converting a `Second_t`.
            ///
            /// - Parameter value: A `Second_t` value to convert to a `UInt32`.
            init(_ value: Second_t) {
                self = snd_t_to_u32(value.rawValue)
            }

            /// Create a `UInt32` by converting a `Second_u`.
            ///
            /// - Parameter value: A `Second_u` value to convert to a `UInt32`.
            init(_ value: Second_u) {
                self = snd_u_to_u32(value.rawValue)
            }

            /// Create a `UInt32` by converting a `Second_f`.
            ///
            /// - Parameter value: A `Second_f` value to convert to a `UInt32`.
            init(_ value: Second_f) {
                self = snd_f_to_u32(value.rawValue)
            }

            /// Create a `UInt32` by converting a `Second_d`.
            ///
            /// - Parameter value: A `Second_d` value to convert to a `UInt32`.
            init(_ value: Second_d) {
                self = snd_d_to_u32(value.rawValue)
            }

        }

        public extension UInt64 {

        // MARK: Creating a UInt64 From The Second Units

            /// Create a `UInt64` by converting a `Second_t`.
            ///
            /// - Parameter value: A `Second_t` value to convert to a `UInt64`.
            init(_ value: Second_t) {
                self = snd_t_to_u64(value.rawValue)
            }

            /// Create a `UInt64` by converting a `Second_u`.
            ///
            /// - Parameter value: A `Second_u` value to convert to a `UInt64`.
            init(_ value: Second_u) {
                self = snd_u_to_u64(value.rawValue)
            }

            /// Create a `UInt64` by converting a `Second_f`.
            ///
            /// - Parameter value: A `Second_f` value to convert to a `UInt64`.
            init(_ value: Second_f) {
                self = snd_f_to_u64(value.rawValue)
            }

            /// Create a `UInt64` by converting a `Second_d`.
            ///
            /// - Parameter value: A `Second_d` value to convert to a `UInt64`.
            init(_ value: Second_d) {
                self = snd_d_to_u64(value.rawValue)
            }

        }

        public extension UInt8 {

        // MARK: Creating a UInt8 From The Second Units

            /// Create a `UInt8` by converting a `Second_t`.
            ///
            /// - Parameter value: A `Second_t` value to convert to a `UInt8`.
            init(_ value: Second_t) {
                self = snd_t_to_u8(value.rawValue)
            }

            /// Create a `UInt8` by converting a `Second_u`.
            ///
            /// - Parameter value: A `Second_u` value to convert to a `UInt8`.
            init(_ value: Second_u) {
                self = snd_u_to_u8(value.rawValue)
            }

            /// Create a `UInt8` by converting a `Second_f`.
            ///
            /// - Parameter value: A `Second_f` value to convert to a `UInt8`.
            init(_ value: Second_f) {
                self = snd_f_to_u8(value.rawValue)
            }

            /// Create a `UInt8` by converting a `Second_d`.
            ///
            /// - Parameter value: A `Second_d` value to convert to a `UInt8`.
            init(_ value: Second_d) {
                self = snd_d_to_u8(value.rawValue)
            }

        }
        """

    // swiftlint:enable type_contents_order

}

// swiftlint:enable type_body_length
// swiftlint:enable file_length
