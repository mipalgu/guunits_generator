// RelatableUnitsGeneratorTests.swift 
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

@testable import GUUnitsGeneratorConversions
import XCTest

// swiftlint:disable file_length
// swiftlint:disable type_body_length

/// Test class for ``RelatableUnitsGenerator``.
final class RelatableUnitsGeneratorTests: XCTestCase {

    /// Generator under test.
    let generator: RelatableUnitsGenerator<
        CompositeFunctionCreator<
            OperationalFunctionBodyCreator<ReferenceAcceleration>,
            CFunctionDefinitionCreator<ReferenceAcceleration>,
            NumericTypeConverter
        >
    > = RelatableUnitsGenerator()

    /// Non-relational generator.
    let standardGenerator: UnitsGenerator<
        CompositeFunctionCreator<
            OperationalFunctionBodyCreator<ReferenceAcceleration>,
            CFunctionDefinitionCreator<ReferenceAcceleration>,
            NumericTypeConverter
        >
    > = UnitsGenerator()

    // swiftlint:disable type_contents_order

    /// Test relation functions are created correctly.
    func testGeneratorDeclarations() {
        guard
            let normalGenerator = standardGenerator.generateDeclarations(
                forUnits: ReferenceAcceleration.allCases
            )
        else {
            XCTFail("Failed to get normal generation")
            return
        }
        let result = generator.generateDeclarations(forUnits: ReferenceAcceleration.allCases)
        XCTAssertEqual(result, normalGenerator + "\n\n" + relationDeclarations)
    }

    /// Test implementations are generated correctly.
    func testGeneratorImplementations() {
        guard
            let normalGenerator = standardGenerator.generateImplementations(
                forUnits: ReferenceAcceleration.allCases
            )
        else {
            XCTFail("Failed to get normal generation")
            return
        }
        let result = generator.generateImplementations(forUnits: ReferenceAcceleration.allCases)
        XCTAssertEqual(result, normalGenerator + "\n\n" + relationImplementations)
    }

    /// Declarations for relation functions.
    let relationDeclarations = """
    /**
    * Convert earthG_t to metres_per_seconds_sq_t.
    */
    metres_per_seconds_sq_t gs_t_to_m_per_s_sq_t(earthG_t earthG);

    /**
    * Convert earthG_t to metres_per_seconds_sq_u.
    */
    metres_per_seconds_sq_u gs_t_to_m_per_s_sq_u(earthG_t earthG);

    /**
    * Convert earthG_t to metres_per_seconds_sq_f.
    */
    metres_per_seconds_sq_f gs_t_to_m_per_s_sq_f(earthG_t earthG);

    /**
    * Convert earthG_t to metres_per_seconds_sq_d.
    */
    metres_per_seconds_sq_d gs_t_to_m_per_s_sq_d(earthG_t earthG);

    /**
    * Convert earthG_u to metres_per_seconds_sq_t.
    */
    metres_per_seconds_sq_t gs_u_to_m_per_s_sq_t(earthG_u earthG);

    /**
    * Convert earthG_u to metres_per_seconds_sq_u.
    */
    metres_per_seconds_sq_u gs_u_to_m_per_s_sq_u(earthG_u earthG);

    /**
    * Convert earthG_u to metres_per_seconds_sq_f.
    */
    metres_per_seconds_sq_f gs_u_to_m_per_s_sq_f(earthG_u earthG);

    /**
    * Convert earthG_u to metres_per_seconds_sq_d.
    */
    metres_per_seconds_sq_d gs_u_to_m_per_s_sq_d(earthG_u earthG);

    /**
    * Convert earthG_f to metres_per_seconds_sq_t.
    */
    metres_per_seconds_sq_t gs_f_to_m_per_s_sq_t(earthG_f earthG);

    /**
    * Convert earthG_f to metres_per_seconds_sq_u.
    */
    metres_per_seconds_sq_u gs_f_to_m_per_s_sq_u(earthG_f earthG);

    /**
    * Convert earthG_f to metres_per_seconds_sq_f.
    */
    metres_per_seconds_sq_f gs_f_to_m_per_s_sq_f(earthG_f earthG);

    /**
    * Convert earthG_f to metres_per_seconds_sq_d.
    */
    metres_per_seconds_sq_d gs_f_to_m_per_s_sq_d(earthG_f earthG);

    /**
    * Convert earthG_d to metres_per_seconds_sq_t.
    */
    metres_per_seconds_sq_t gs_d_to_m_per_s_sq_t(earthG_d earthG);

    /**
    * Convert earthG_d to metres_per_seconds_sq_u.
    */
    metres_per_seconds_sq_u gs_d_to_m_per_s_sq_u(earthG_d earthG);

    /**
    * Convert earthG_d to metres_per_seconds_sq_f.
    */
    metres_per_seconds_sq_f gs_d_to_m_per_s_sq_f(earthG_d earthG);

    /**
    * Convert earthG_d to metres_per_seconds_sq_d.
    */
    metres_per_seconds_sq_d gs_d_to_m_per_s_sq_d(earthG_d earthG);
    """

    /// Relation function implementations.
    let relationImplementations = """
    /**
    * Convert earthG_t to metres_per_seconds_sq_t.
    */
    metres_per_seconds_sq_t gs_t_to_m_per_s_sq_t(earthG_t earthG)
    {
        const int64_t unit = ((int64_t) (earthG));
        if (__builtin_expect(overflow_upper_t(unit), 0)) {
            return 9223372036854775807;
        } else if (__builtin_expect(overflow_lower_t(unit), 0)) {
            return -9223372036854775807 - 1;
        } else {
            const double result = multiply_d((((double) (earthG))), (((double) (9.80665))));
            if (__builtin_expect(overflow_upper_d(result), 0)) {
                return 9223372036854775807;
            } else if (__builtin_expect(overflow_lower_d(result), 0)) {
                return -9223372036854775807 - 1;
            } else {
                return ((metres_per_seconds_sq_t) (d_to_i64(result)));
            }
        }
    }

    /**
    * Convert earthG_t to metres_per_seconds_sq_u.
    */
    metres_per_seconds_sq_u gs_t_to_m_per_s_sq_u(earthG_t earthG)
    {
        const int64_t unit = ((int64_t) (earthG));
        if (__builtin_expect(overflow_upper_t(unit), 0)) {
            return 18446744073709551615U;
        } else if (__builtin_expect(overflow_lower_t(unit), 0)) {
            return 0;
        } else {
            const double result = multiply_d((((double) (earthG))), (((double) (9.80665))));
            if (__builtin_expect(overflow_upper_d(result), 0)) {
                return 18446744073709551615U;
            } else if (__builtin_expect(overflow_lower_d(result), 0)) {
                return 0;
            } else {
                return ((metres_per_seconds_sq_u) (d_to_u64(result)));
            }
        }
    }

    /**
    * Convert earthG_t to metres_per_seconds_sq_f.
    */
    metres_per_seconds_sq_f gs_t_to_m_per_s_sq_f(earthG_t earthG)
    {
        const int64_t unit = ((int64_t) (earthG));
        if (__builtin_expect(overflow_upper_t(unit), 0)) {
            return FLT_MAX;
        } else if (__builtin_expect(overflow_lower_t(unit), 0)) {
            return -FLT_MAX;
        } else {
            const double result = multiply_d((((double) (earthG))), (((double) (9.80665))));
            if (__builtin_expect(overflow_upper_d(result), 0)) {
                return FLT_MAX;
            } else if (__builtin_expect(overflow_lower_d(result), 0)) {
                return -FLT_MAX;
            } else {
                return ((metres_per_seconds_sq_f) (d_to_f(result)));
            }
        }
    }

    /**
    * Convert earthG_t to metres_per_seconds_sq_d.
    */
    metres_per_seconds_sq_d gs_t_to_m_per_s_sq_d(earthG_t earthG)
    {
        const int64_t unit = ((int64_t) (earthG));
        if (__builtin_expect(overflow_upper_t(unit), 0)) {
            return DBL_MAX;
        } else if (__builtin_expect(overflow_lower_t(unit), 0)) {
            return -DBL_MAX;
        } else {
            const double result = multiply_d((((double) (earthG))), (((double) (9.80665))));
            if (__builtin_expect(overflow_upper_d(result), 0)) {
                return DBL_MAX;
            } else if (__builtin_expect(overflow_lower_d(result), 0)) {
                return -DBL_MAX;
            } else {
                return ((metres_per_seconds_sq_d) (result));
            }
        }
    }

    /**
    * Convert earthG_u to metres_per_seconds_sq_t.
    */
    metres_per_seconds_sq_t gs_u_to_m_per_s_sq_t(earthG_u earthG)
    {
        const uint64_t unit = ((uint64_t) (earthG));
        if (__builtin_expect(overflow_upper_u(unit), 0)) {
            return 9223372036854775807;
        } else {
            const double result = multiply_d((((double) (earthG))), (((double) (9.80665))));
            if (__builtin_expect(overflow_upper_d(result), 0)) {
                return 9223372036854775807;
            } else {
                return ((metres_per_seconds_sq_t) (d_to_i64(result)));
            }
        }
    }

    /**
    * Convert earthG_u to metres_per_seconds_sq_u.
    */
    metres_per_seconds_sq_u gs_u_to_m_per_s_sq_u(earthG_u earthG)
    {
        const uint64_t unit = ((uint64_t) (earthG));
        if (__builtin_expect(overflow_upper_u(unit), 0)) {
            return 18446744073709551615U;
        } else {
            const double result = multiply_d((((double) (earthG))), (((double) (9.80665))));
            if (__builtin_expect(overflow_upper_d(result), 0)) {
                return 18446744073709551615U;
            } else {
                return ((metres_per_seconds_sq_u) (d_to_u64(result)));
            }
        }
    }

    /**
    * Convert earthG_u to metres_per_seconds_sq_f.
    */
    metres_per_seconds_sq_f gs_u_to_m_per_s_sq_f(earthG_u earthG)
    {
        const uint64_t unit = ((uint64_t) (earthG));
        if (__builtin_expect(overflow_upper_u(unit), 0)) {
            return FLT_MAX;
        } else {
            const double result = multiply_d((((double) (earthG))), (((double) (9.80665))));
            if (__builtin_expect(overflow_upper_d(result), 0)) {
                return FLT_MAX;
            } else {
                return ((metres_per_seconds_sq_f) (d_to_f(result)));
            }
        }
    }

    /**
    * Convert earthG_u to metres_per_seconds_sq_d.
    */
    metres_per_seconds_sq_d gs_u_to_m_per_s_sq_d(earthG_u earthG)
    {
        const uint64_t unit = ((uint64_t) (earthG));
        if (__builtin_expect(overflow_upper_u(unit), 0)) {
            return DBL_MAX;
        } else {
            const double result = multiply_d((((double) (earthG))), (((double) (9.80665))));
            if (__builtin_expect(overflow_upper_d(result), 0)) {
                return DBL_MAX;
            } else {
                return ((metres_per_seconds_sq_d) (result));
            }
        }
    }

    /**
    * Convert earthG_f to metres_per_seconds_sq_t.
    */
    metres_per_seconds_sq_t gs_f_to_m_per_s_sq_t(earthG_f earthG)
    {
        const float unit = ((float) (earthG));
        if (__builtin_expect(overflow_upper_f(unit), 0)) {
            return 9223372036854775807;
        } else if (__builtin_expect(overflow_lower_f(unit), 0)) {
            return -9223372036854775807 - 1;
        } else {
            const double result = multiply_d((((double) (earthG))), (((double) (9.80665))));
            if (__builtin_expect(overflow_upper_d(result), 0)) {
                return 9223372036854775807;
            } else if (__builtin_expect(overflow_lower_d(result), 0)) {
                return -9223372036854775807 - 1;
            } else {
                return ((metres_per_seconds_sq_t) (d_to_i64(result)));
            }
        }
    }

    /**
    * Convert earthG_f to metres_per_seconds_sq_u.
    */
    metres_per_seconds_sq_u gs_f_to_m_per_s_sq_u(earthG_f earthG)
    {
        const float unit = ((float) (earthG));
        if (__builtin_expect(overflow_upper_f(unit), 0)) {
            return 18446744073709551615U;
        } else if (__builtin_expect(overflow_lower_f(unit), 0)) {
            return 0;
        } else {
            const double result = multiply_d((((double) (earthG))), (((double) (9.80665))));
            if (__builtin_expect(overflow_upper_d(result), 0)) {
                return 18446744073709551615U;
            } else if (__builtin_expect(overflow_lower_d(result), 0)) {
                return 0;
            } else {
                return ((metres_per_seconds_sq_u) (d_to_u64(result)));
            }
        }
    }

    /**
    * Convert earthG_f to metres_per_seconds_sq_f.
    */
    metres_per_seconds_sq_f gs_f_to_m_per_s_sq_f(earthG_f earthG)
    {
        const float unit = ((float) (earthG));
        if (__builtin_expect(overflow_upper_f(unit), 0)) {
            return FLT_MAX;
        } else if (__builtin_expect(overflow_lower_f(unit), 0)) {
            return -FLT_MAX;
        } else {
            const double result = multiply_d((((double) (earthG))), (((double) (9.80665))));
            if (__builtin_expect(overflow_upper_d(result), 0)) {
                return FLT_MAX;
            } else if (__builtin_expect(overflow_lower_d(result), 0)) {
                return -FLT_MAX;
            } else {
                return ((metres_per_seconds_sq_f) (d_to_f(result)));
            }
        }
    }

    /**
    * Convert earthG_f to metres_per_seconds_sq_d.
    */
    metres_per_seconds_sq_d gs_f_to_m_per_s_sq_d(earthG_f earthG)
    {
        const float unit = ((float) (earthG));
        if (__builtin_expect(overflow_upper_f(unit), 0)) {
            return DBL_MAX;
        } else if (__builtin_expect(overflow_lower_f(unit), 0)) {
            return -DBL_MAX;
        } else {
            const double result = multiply_d((((double) (earthG))), (((double) (9.80665))));
            if (__builtin_expect(overflow_upper_d(result), 0)) {
                return DBL_MAX;
            } else if (__builtin_expect(overflow_lower_d(result), 0)) {
                return -DBL_MAX;
            } else {
                return ((metres_per_seconds_sq_d) (result));
            }
        }
    }

    /**
    * Convert earthG_d to metres_per_seconds_sq_t.
    */
    metres_per_seconds_sq_t gs_d_to_m_per_s_sq_t(earthG_d earthG)
    {
        const double unit = ((double) (earthG));
        if (__builtin_expect(overflow_upper_d(unit), 0)) {
            return 9223372036854775807;
        } else if (__builtin_expect(overflow_lower_d(unit), 0)) {
            return -9223372036854775807 - 1;
        } else {
            const double result = multiply_d((((double) (earthG))), (((double) (9.80665))));
            if (__builtin_expect(overflow_upper_d(result), 0)) {
                return 9223372036854775807;
            } else if (__builtin_expect(overflow_lower_d(result), 0)) {
                return -9223372036854775807 - 1;
            } else {
                return ((metres_per_seconds_sq_t) (d_to_i64(result)));
            }
        }
    }

    /**
    * Convert earthG_d to metres_per_seconds_sq_u.
    */
    metres_per_seconds_sq_u gs_d_to_m_per_s_sq_u(earthG_d earthG)
    {
        const double unit = ((double) (earthG));
        if (__builtin_expect(overflow_upper_d(unit), 0)) {
            return 18446744073709551615U;
        } else if (__builtin_expect(overflow_lower_d(unit), 0)) {
            return 0;
        } else {
            const double result = multiply_d((((double) (earthG))), (((double) (9.80665))));
            if (__builtin_expect(overflow_upper_d(result), 0)) {
                return 18446744073709551615U;
            } else if (__builtin_expect(overflow_lower_d(result), 0)) {
                return 0;
            } else {
                return ((metres_per_seconds_sq_u) (d_to_u64(result)));
            }
        }
    }

    /**
    * Convert earthG_d to metres_per_seconds_sq_f.
    */
    metres_per_seconds_sq_f gs_d_to_m_per_s_sq_f(earthG_d earthG)
    {
        const double unit = ((double) (earthG));
        if (__builtin_expect(overflow_upper_d(unit), 0)) {
            return FLT_MAX;
        } else if (__builtin_expect(overflow_lower_d(unit), 0)) {
            return -FLT_MAX;
        } else {
            const double result = multiply_d((((double) (earthG))), (((double) (9.80665))));
            if (__builtin_expect(overflow_upper_d(result), 0)) {
                return FLT_MAX;
            } else if (__builtin_expect(overflow_lower_d(result), 0)) {
                return -FLT_MAX;
            } else {
                return ((metres_per_seconds_sq_f) (d_to_f(result)));
            }
        }
    }

    /**
    * Convert earthG_d to metres_per_seconds_sq_d.
    */
    metres_per_seconds_sq_d gs_d_to_m_per_s_sq_d(earthG_d earthG)
    {
        const double unit = ((double) (earthG));
        if (__builtin_expect(overflow_upper_d(unit), 0)) {
            return DBL_MAX;
        } else if (__builtin_expect(overflow_lower_d(unit), 0)) {
            return -DBL_MAX;
        } else {
            const double result = multiply_d((((double) (earthG))), (((double) (9.80665))));
            if (__builtin_expect(overflow_upper_d(result), 0)) {
                return DBL_MAX;
            } else if (__builtin_expect(overflow_lower_d(result), 0)) {
                return -DBL_MAX;
            } else {
                return ((metres_per_seconds_sq_d) (result));
            }
        }
    }
    """

    // swiftlint:enable type_contents_order

}

/// ReferenceAcceleration initialiser for C conversions.
private extension UnitsGenerator where
    Creator == CompositeFunctionCreator<OperationalFunctionBodyCreator<ReferenceAcceleration>,
    CFunctionDefinitionCreator<ReferenceAcceleration>, NumericTypeConverter> {

    /// Initialise using ReferenceAcceleration and c conversions.
    init() {
        self.init(creator: CompositeFunctionCreator(
            bodyCreator: OperationalFunctionBodyCreator(),
            definitionCreator: CFunctionDefinitionCreator(),
            numericConverter: NumericTypeConverter()
        ))
    }

}

/// ReferenceAcceleration initialiser for CPP conversions.
private extension UnitsGenerator where
    Creator == CompositeFunctionCreator<OperationalFunctionBodyCreator<ReferenceAcceleration>,
    CPPFunctionDefinitionCreator<ReferenceAcceleration>, NumericTypeConverter> {

    /// Initialise using ReferenceAcceleration and cpp conversions.
    init() {
        self.init(creator: CompositeFunctionCreator(
            bodyCreator: OperationalFunctionBodyCreator(),
            definitionCreator: CPPFunctionDefinitionCreator(),
            numericConverter: NumericTypeConverter()
        ))
    }

}

// swiftlint:enable type_body_length
// swiftlint:enable file_length
