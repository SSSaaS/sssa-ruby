require_relative './utils.rb'

module SSSA
    @prime = 115792089237316195423570985008687907853269984665640564039457584007913129639747
    @util = SSSA::Utils.new(@prime)

    # Create a new array of Shamir's Shares with a minimum, total, and secret
    # Note: output is an array of base64 strings, of length a multiple of 88,
    # as each x, y point is a 256 bit (i.e., 44 base64 character) integer and
    # each share is one pair, per number of integers secret must be split into
    def self.create(minimum, shares, raw)
        secret = @util.split_ints(raw)
        numbers = [0]
        polynomial = []
        (0...secret.size).each do |i|
            polynomial.push [secret[i]]
            (1...minimum).each do |j|
                value = @util.random()
                while numbers.include? value
                    value = @util.random()
                end
                numbers.push value
                polynomial[i].push value
            end
        end

        result = [""]*shares

        (0...shares).each do |i|
            (0...secret.size).each do |j|
                value = @util.random()
                while numbers.include? value
                    value = @util.random()
                end

                y = @util.evaluate_polynomial(polynomial[j], value)

                result[i] += @util.to_base64(value)
                result[i] += @util.to_base64(y)
            end
        end

        return result
    end

    # Takes a set of shares and combines them to a secret value using Shamir's
    # Secret Sharing Algorithm. Each share must be a string of base-64 encoded
    # shares of length modulo 88 base64 characters (512 bits in binary)
    def self.combine(shares)
        secrets = []

        shares.each_with_index do |share, index|
            if share.size % 88 != 0
                return
            end

            count = share.size / 88
            secrets.push []

            (0...count).each do |i|
                cshare = share[i*88, (i+1)*88]
                secrets[index][i] = [@util.from_base64(cshare[0...44]), @util.from_base64(cshare[44...88])]
            end
        end

        secret = [0] * secrets[0].size

        secret.each_with_index do |part, part_index|
            secrets.each_with_index do |share, share_index|
                origin = share[part_index][0]
                originy = share[part_index][1]
                numerator = 1
                denominator = 1
                secrets.each_with_index do |product, product_index|
                    if product_index != share_index
                        current = product[part_index][0]
                        numerator = (numerator * (-1*current)) % @prime
                        denominator = (denominator * (origin - current)) % @prime
                    end
                end

                working = ((originy * numerator * @util.mod_inverse(denominator)) + @prime)
                secret[part_index] = (secret[part_index] + working) % @prime
            end
        end

        return @util.merge_ints(secret)
    end
end
