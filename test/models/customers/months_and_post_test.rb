require 'test_helper'

class Customers::MonthsAndPostsTest < ActiveSupport::TestCase
  test '#each with a realistic sampling' do
    start   = Date.parse("06/2015")
    subject = Customers::MonthsAndPosts.new(Customer.new, start)

    [true, true, false, true, false, false, false].each do |value|
      subject.current_month_has_posts(value)
    end

    results = []
    subject.each do |month, true_or_false|
      results.push(month)
    end

    assert_equal 4, results.size, 'should only have four entries, the last three should be ignored'
  end
end
