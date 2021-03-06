require_relative 'test_helper'

class TestFakerUniqueGenerator < Test::Unit::TestCase
  def test_generates_unique_values
    generator = Faker::UniqueGenerator.new(Faker::Base, 10_000)

    result = [generator.rand_in_range(1, 2), generator.rand_in_range(1, 2)]
    assert_equal([1, 2], result.sort)
  end

  def test_respond_to_missing
    stubbed_generator = Object.new

    generator = Faker::UniqueGenerator.new(stubbed_generator, 3)

    assert_equal(generator.send(:respond_to_missing?, 'faker_address'), true)
    assert_equal(generator.send(:respond_to_missing?, 'address'), false)
  end

  def test_returns_error_when_retries_exceeded
    stubbed_generator = Object.new
    def stubbed_generator.test
      1
    end

    generator = Faker::UniqueGenerator.new(stubbed_generator, 3)

    generator.test

    assert_raises Faker::UniqueGenerator::RetryLimitExceeded do
      generator.test
    end
  end

  def test_includes_field_name_in_error
    stubbed_generator = Object.new
    def stubbed_generator.my_field
      1
    end

    generator = Faker::UniqueGenerator.new(stubbed_generator, 3)

    generator.my_field

    assert_raise_message 'Retry limit exceeded for my_field' do
      generator.my_field
    end
  end

  def test_clears_unique_values
    stubbed_generator = Object.new
    def stubbed_generator.test
      1
    end

    generator = Faker::UniqueGenerator.new(stubbed_generator, 3)

    assert_equal(1, generator.test)

    assert_raises Faker::UniqueGenerator::RetryLimitExceeded do
      generator.test
    end

    Faker::UniqueGenerator.clear

    assert_equal(1, generator.test)

    assert_raises Faker::UniqueGenerator::RetryLimitExceeded do
      generator.test
    end

    generator.clear

    assert_equal(1, generator.test)
  end
end
