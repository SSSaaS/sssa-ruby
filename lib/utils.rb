require 'securerandom'
require 'base64'

module SSSA
    class Utils
        attr_accessor :prime

        def initialize(prime=115792089237316195423570985008687907853269984665640564039457584007913129639747)
            @prime = prime
        end

        # Returns a random number on 0 to @prime-1, inclusive.
        def random()
            return SecureRandom.random_number(@prime)
        end

        # split_ints and merge_ints converts between string and integer array,
        # where the integer is right-padded until it fits a 256 bit integer.
        def split_ints(secret)
            result = []

            secret.split('').map { |x|
                data = x.unpack("H*")[0]
                "0"*(data.size % 2) + data
            }.join("").scan(/.{1,64}/) { |segment|
                result.push (segment+"0"*(64-segment.size)).hex
            }

            return result
        end

        def merge_ints(secrets)
            result = []

            secrets.each { |int|
                data = int.to_s(16)
                ("0"*(64-data.size) + data).scan(/../) { |segment|
                    result.push segment.hex
                }
            }

            return result.pack('C*').force_encoding("utf-8").gsub(/\u0000*$/, '')
        end

        # This evaluates a polynomial with reversed coefficients at a given
        # value. Namely, given the array [a, b, c, d], and x=value, the equation
        # is:
        # a + bx + cx^2 + dx^3
        def evaluate_polynomial(coefficients, value)
            result = 0
            coefficients.each_with_index do |coefficient, exponent|
                expmod = 1
                (0...exponent).each do
                    expmod = (expmod * value) % @prime
                end
                result += coefficient * expmod
                result = result % @prime
            end

            return result
        end

        # The to_base64 and from_base64 converts between base 10 and base 64
        # integers, with a left-zero-padded, fixed-size hex representation.
        # This is cross-compatible with the go implementation, and by changing
        # base versus encoding as a string, it reduces the size of the
        # representation. Note: the output is always 44 characters.
        def to_base64(number)
            return Base64.urlsafe_encode64(("0"*(64-number.to_s(16).size) + number.to_s(16)).scan(/../).map{|x| x.hex.chr}.join)
        end

        def from_base64(number)
            segment = Base64.urlsafe_decode64(number).split('').map do |x|
                if x.ord > 15
                    x.ord.to_s(16)
                else
                    "0" + x.ord.to_s(16)
                end
            end
            return (segment+["00"]*(32-segment.size)).join.hex
        end

        # Uses extended Euclidian algorithm to compute the GCD of a pair of
        # numbers, and returns [gcd, x, y], such that gcd = ax+ by.
        #
        # Note: computing the GCD over a finite field with a = @prime means that
        # GCD will always return 1.
        def gcd(a, b)
            if b == 0
                return [a, 1, 0]
            else
                n = (a*1.0/b).floor
                c = a % b
                r = gcd(b, c)
                return [r[0], r[2], r[1]-r[2]*n]
            end
        end

        # Computes the multiplicitive inverse of the given number on the finite
        # field. Note: number should never be less than zero; however, if it is,
        # the inverse is inverted
        def mod_inverse(number)
            remainder = gcd(@prime, number % @prime)[2]
            if (number < 0)
                remainder *= -1
            end
            return (@prime + remainder) % @prime
        end
    end
end
