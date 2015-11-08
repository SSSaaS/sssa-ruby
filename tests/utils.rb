# encoding: UTF-8

require_relative '../lib/utils.rb'
require 'test/unit'

class TestSSSAUtils < Test::Unit::TestCase
    def test_random()
        util = SSSA::Utils.new
        (0...10000).each do |x|
            assert(util.random() < util.prime, "Error! Random out of bounds of finite field!")
        end
    end

    def test_base_conversion()
        util = SSSA::Utils.new
        (0...10000).each do |x|
            value = util.random()
            assert_equal(value, util.from_base64(util.to_base64(value)), "Error! Base64 encoding and decoding of ints not working!")
        end
    end

    def test_toBase64()
        util = SSSA::Utils.new
        (0...10000).each do |x|
            value = util.random()
            assert_equal(44, util.to_base64(value).size, "Error! Base64 encoding returning the wrong size!")
        end
    end

    def test_split_merge()
        util = SSSA::Utils.new
        values = ["N17FigASkL6p1EOgJhRaIquQLGvYV0", "0y10VAfmyH7GLQY6QccCSLKJi8iFgpcSBTLyYOGbiYPqOpStAf1OYuzEBzZR", "KjRHO1nHmIDidf6fKvsiXWcTqNYo2U9U8juO94EHXVqgearRISTQe0zAjkeUYYBvtcB8VWzZHYm6ktMlhOXXCfRFhbJzBUsXaHb5UDQAvs2GKy6yq0mnp8gCj98ksDlUultqygybYyHvjqR7D7EAWIKPKUVz4of8OzSjZlYg7YtCUMYhwQDryESiYabFID1PKBfKn5WSGgJBIsDw5g2HB2AqC1r3K8GboDN616Swo6qjvSFbseeETCYDB3ikS7uiK67ErIULNqVjf7IKoOaooEhQACmZ5HdWpr34tstg18rO"]
        values.each do |value|
            assert_equal(value, util.merge_ints(util.split_ints(value)), "Error! Splitting and merging of ints not working!")
        end
    end

    def test_split_merge_odds()
        util = SSSA::Utils.new
        values = ["a" + "\x00"*100 + "a", "a"*31 + "哈囉世界", "こんにちは、世界"*32]
        values.each do |value|
            assert_equal(value, util.merge_ints(util.split_ints(value)), "Error! Splitting and merging of ints not working!")
        end
    end

    def test_mod_inverse()
        util = SSSA::Utils.new
        (0...10000).each do |x|
            value = util.random()
            inverse = util.mod_inverse(value)
            result = (value * inverse) % util.prime
            assert_equal(1, result, "Error! mod_inverse not working!")
        end
    end

    def test_evaluate_polynomial()
        util = SSSA::Utils.new
        values = [[[20, 21, 42], 0], [[0, 0, 0], 4], [[1, 2, 3, 4, 5], 10]]
        results = [20, 0, 54321]
        values.each_with_index do |value, index|
            assert_equal(results[index], util.evaluate_polynomial(value[0], value[1]))
        end
    end
end
