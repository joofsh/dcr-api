module MiniTest::Assertions

  def deny(condition, message = "Expectation not met")
    assert !condition, message
  end
end
