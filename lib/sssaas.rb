require_relative './util'

module SSSAAS
    class Secrets
        # Creates a set of shares from a given secret
        # Requires:
        #   n - total number of shares to create
        #   k - minimum number to recreate
        #   secret - secret to hide
        def initialize()
            # 256-bit prime
            @prime = 99995644905598542077721161034987774965417302630805822064337798850767846245779
        end
    end
end
