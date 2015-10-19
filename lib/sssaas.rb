require 'securerandom'

module SSSAAS
    class Secrets
        # Creates a set of shares from a given secret
        # Requires:
        #   n - total number of shares to create
        #   k - minimum number to recreate
        #   secret - secret to hide
        def initialize()
            # 512-bit prime
            @prime = 13405015853489344599299360336760892578089045124351982171123226525026027210088647848509034243564149418363355794565216143100084048507668072099463322790104603
        end

        def random()
            return SecureRandom.random_number(@prime)
        end

        def inverse(second)
            a = second
            b = @prime
            q = 0
            r = b
            lastq = q
            lastr = r

            while r > 0
                lastq = q
                lastr = r
                q = (a / b).floor
                r = a - b*q
                a = b
                b = r
            end

            return lastr
        end

        def create(n, k, secret)
            return true
        end

        def use(shares)
            return true
        end
    end
end

puts SSSAAS::Secrets.new.inverse(10)
