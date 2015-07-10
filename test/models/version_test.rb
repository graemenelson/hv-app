require 'test_helper'

class VersionTest < ActiveSupport::TestCase

  test '#current should return latest commit sha' do
    assert_equal `git rev-parse HEAD`.chomp, Version.current
  end
end
