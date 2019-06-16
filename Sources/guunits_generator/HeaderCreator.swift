/*
 * HeaderCreator.swift
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

struct HeaderCreator {
    
    fileprivate var prefix: String {
        return """
            /*
            * guunits.h
            * guunits
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
            \("\n")
            #ifndef GUUNITS_H
            #define GUUNITS_H
            \("")
            #include <math.h>
            #include <stdint.h>
            #include <limits.h>
            \("")
            #ifdef __cplusplus
            extern "C" {
            #endif
            """
    }
    
    fileprivate var suffix: String {
        return """
            #ifdef __cplusplus
            };
            #endif
            \("")
            #endif  /* GUUNITS_H */
            \("")
            """
    }
    
    fileprivate var typeDefs: String {
        let units: [(String, [CustomStringConvertible])] = [
            ("// Distance Units.", Array(DistanceUnits.allCases)),
            ("// Time Units.", Array(TimeUnits.allCases)),
            ("// Angle Units.", Array(AngleUnits.allCases))
        ]
        let signs = Signs.allCases
        let typeDefs = units.flatMap { (comment, units) in
            ["", comment] + units.flatMap { unit in
                signs.map { "typedef \($0.type) \(unit)_\($0.rawValue);" }
            }
        }
        guard let first = typeDefs.first else {
            return ""
        }
        return typeDefs.dropFirst().reduce(first) { $0 + "\n" + $1 }
    }
    
    
    func generate(distanceGenerator: DistanceUnitsGenerator, timeGenerator: TimeUnitsGenerator, angleGenerator: AngleUnitsGenerator) -> String {
        let content = self.createContent(distanceGenerator: distanceGenerator, timeGenerator: timeGenerator, angleGenerator: angleGenerator)
        return self.prefix + "\n" + self.typeDefs + "\n\n" + content + "\n\n" + self.suffix
    }
    
    fileprivate func createContent(distanceGenerator: DistanceUnitsGenerator, timeGenerator: TimeUnitsGenerator, angleGenerator: AngleUnitsGenerator) -> String {
        guard
            let distances = distanceGenerator.generateDeclarations(forUnits: DistanceUnits.allCases),
            let times = timeGenerator.generateDeclarations(forUnits: TimeUnits.allCases),
            let angles = angleGenerator.generateDeclarations(forUnits: AngleUnits.allCases)
        else {
            fatalError("Unable to create header.")
        }
        return "// Distance Conversion Functions\n\n" + distances
            + "\n\n// Time Conversion Functions\n\n" + times
            + "\n\n//Angle Conversion Functions\n\n" + angles
    }
    
}
