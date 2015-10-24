require_relative './utils.rb'

module SSS
    @prime = 99995644905598542077721161034987774965417302630805822064337798850767846245779
    @util = SSS::Utils.new

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
