require_relative '../lib/sss.rb'
require 'test/unit'

class TestSSS < Test::Unit::TestCase
    def test_create_combine()
        util = SSS::Utils.new
        values = ["N17FigASkL6p1EOgJhRaIquQLGvYV0", "0y10VAfmyH7GLQY6QccCSLKJi8iFgpcSBTLyYOGbiYPqOpStAf1OYuzEBzZR", "KjRHO1nHmIDidf6fKvsiXWcTqNYo2U9U8juO94EHXVqgearRISTQe0zAjkeUYYBvtcB8VWzZHYm6ktMlhOXXCfRFhbJzBUsXaHb5UDQAvs2GKy6yq0mnp8gCj98ksDlUultqygybYyHvjqR7D7EAWIKPKUVz4of8OzSjZlYg7YtCUMYhwQDryESiYabFID1PKBfKn5WSGgJBIsDw5g2HB2AqC1r3K8GboDN616Swo6qjvSFbseeETCYDB3ikS7uiK67ErIULNqVjf7IKoOaooEhQACmZ5HdWpr34tstg18rO"]
        minimum = [4, 6, 20]
        shares = [5, 100, 100]
        values.each_with_index do |value, index|
            assert_equal(value, SSS::combine(SSS::create(minimum[index], shares[index], value)), "Error! Splitting and merging of ints not working!")
        end
    end
end
