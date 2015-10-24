require 'securerandom'
require 'base64'

module SSS
    class Utils
        attr_accessor :prime

        def initialize()
            # 256-bit prime
            @prime = 99995644905598542077721161034987774965417302630805822064337798850767846245779
        end

        def random()
            return SecureRandom.random_number(@prime)
        end

        def split_ints(secret)
            result = []

            secret.scan(/.{1,32}/) do |part|
                segment = part.split('').map do |x|
                    if x.ord > 15
                        x.ord.to_s(16)
                    else
                        "0" + x.ord.to_s(16)
                    end
                end
                result.push (segment+["00"]*(32-segment.size)).join.hex
            end

            return result
        end

        def merge_ints(secrets)
            result = ""

            secrets.each_with_index do |secret, index|
                if index == secrets.size-1
                    result += ("0"*(64-secret.to_s(16).size) + secret.to_s(16)).scan(/../).map{|x| x.hex.chr}.join.gsub(/\x00*$/, '')
                else
                    result += ("0"*(64-secret.to_s(16).size) + secret.to_s(16)).scan(/../).map{|x| x.hex.chr}.join
                end
            end

            return result
        end

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

        def mod_inverse(number)
            remainder = gcd(@prime, number % @prime)[2]
            if (number < 0)
                remainder *= -1
            end
            return (@prime + remainder) % @prime
        end
    end
end
