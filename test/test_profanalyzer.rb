require "test/unit"
require "profanalyzer"

class TestProfanalyzer < Test::Unit::TestCase
  
  def test_default_tolerance
    assert_equal Profanalyzer::DEFAULT_TOLERANCE, Profanalyzer.tolerance
  end
  
  def test_profanalyzer_tolerance
    0.upto(5) do |tolerance|
      Profanalyzer.tolerance = tolerance # setter
      assert_equal tolerance, Profanalyzer.tolerance # getter
    end
  end
  
  def test_single_word
    Profanalyzer.tolerance = 0
    Profanalyzer.check_all = true
    assert_equal(true, Profanalyzer.profane?("asshole"))
  end
  
  def test_single_racist_word
    Profanalyzer.tolerance = 0
    Profanalyzer.check_all = false
    Profanalyzer.check_sexual = false
    Profanalyzer.check_racist = true
    assert_equal(true, Profanalyzer.profane?("spic"))
    assert_equal(false, Profanalyzer.profane?("pussy"))
  end
  
  def test_single_sexual_word
    Profanalyzer.tolerance = 0
    Profanalyzer.check_all = false
    Profanalyzer.check_racist = false
    Profanalyzer.check_sexual = true
    assert_equal(true, Profanalyzer.profane?("vagina"))
    assert_equal(false, Profanalyzer.profane?("nigger"))
  end
  
  def test_tolerance
    Profanalyzer.tolerance = 4
    Profanalyzer.check_all = true
    assert_equal(false, Profanalyzer.profane?("asskisser")) # badness = 3
    assert_equal(true, Profanalyzer.profane?("fuck"))       # badness = 5
  end
  
  def test_sexual_tolerance
    Profanalyzer.tolerance = 4
    Profanalyzer.check_all = false
    Profanalyzer.check_racist = false
    Profanalyzer.check_sexual = true
    assert_equal(false, Profanalyzer.profane?("vagina")) # badness = 3
    assert_equal(true, Profanalyzer.profane?("cunt"))       # badness = 5
  end
  
  def test_racist_tolerance
    Profanalyzer.tolerance = 4
    Profanalyzer.check_all = false
    Profanalyzer.check_sexual = false
    Profanalyzer.check_racist = true
    assert_equal(false, Profanalyzer.profane?("mick")) # badness = 3
    assert_equal(true, Profanalyzer.profane?("nigger"))       # badness = 5
  end
  
  def test_filter
    Profanalyzer.tolerance = 0
    Profanalyzer.check_all = true
    original_string = "You're a cocksucking piece of shit, you mick."
    filtered_string = "You're a #!$%@&!$%@% piece of #!$%, you #!$%."
    assert_equal(filtered_string, Profanalyzer.filter(original_string))
  end
  
  def test_sexual_filter
    Profanalyzer.tolerance = 0
    Profanalyzer.check_all = false
    Profanalyzer.check_sexual = true
    Profanalyzer.check_racist = false
    original_string = "You're a cocksucking piece of shit, you mick."
    filtered_string = "You're a #!$%@&!$%@% piece of shit, you mick."
    assert_equal(filtered_string, Profanalyzer.filter(original_string))
  end
  
  def test_racist_filter
    Profanalyzer.tolerance = 0
    Profanalyzer.check_all = false
    Profanalyzer.check_sexual = false
    Profanalyzer.check_racist = true
    original_string = "You're a cocksucking piece of shit, you mick."
    filtered_string = "You're a cocksucking piece of shit, you #!$%."
    assert_equal(filtered_string, Profanalyzer.filter(original_string))
  end
  
  def test_subtitutions
    Profanalyzer.substitute("shit","shiat")
    assert_equal("shiat", Profanalyzer.filter("shit"))
    
    Profanalyzer.substitute("damn" => "darn")
    assert_equal("darn", Profanalyzer.filter("damn"))
    
    Profanalyzer.substitute(:fuck => :fark)
    assert_equal("fark", Profanalyzer.filter("fuck"))
  end

end
