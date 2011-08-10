require "test/unit"
require "profanalyzer"

class TestProfanalyzer < Test::Unit::TestCase
  
  def test_single_word_advanced
    assert_equal(true, Profanalyzer.profane?("asshole", :tolerance => 0, :all => true))
    assert_equal(["asshole"], Profanalyzer.flagged_words("asshole", :tolerance => 0, :all => true))
  end
  
  def test_single_racist_word_advanced
    assert_equal(true, Profanalyzer.profane?("spic", :tolerance => 0, :racist => true, :sexual => false))
    assert_equal(false, Profanalyzer.profane?("pussy", :tolerance => 0, :racist => true, :sexual => false))
    assert_equal(["spic"], Profanalyzer.flagged_words("spic", :tolerance => 0, :racist => true, :sexual => false))
    assert_equal([], Profanalyzer.flagged_words("pussy", :tolerance => 0, :racist => true, :sexual => false))
  end
  
  def test_single_sexual_word_advanced
    assert_equal(true, Profanalyzer.profane?("vagina", :tolerance => 0, :racist => false, :sexual => true))
    assert_equal(false, Profanalyzer.profane?("nigger", :tolerance => 0, :racist => false, :sexual => true))
    assert_equal(["vagina"], Profanalyzer.flagged_words("vagina", :tolerance => 0, :racist => false, :sexual => true))
    assert_equal([], Profanalyzer.flagged_words("nigger", :tolerance => 0, :racist => false, :sexual => true))
  end
  
  def test_tolerance_advanced
    assert_equal(false, Profanalyzer.profane?("asskisser", :tolerance => 4, :all => true)) # badness = 3
    assert_equal(true, Profanalyzer.profane?("fuck", :tolerance => 4, :all => true))       # badness = 5
    assert_equal([], Profanalyzer.flagged_words("asskisser", :tolerance => 4, :all => true)) # badness = 3
    assert_equal(["fuck"], Profanalyzer.flagged_words("fuck", :tolerance => 4, :all => true))       # badness = 5
  end
  
  def test_sexual_tolerance_advanced
    assert_equal(false, Profanalyzer.profane?("vagina", :tolerance => 4, :racist => false, :sexual => true)) # badness = 3
    assert_equal(true, Profanalyzer.profane?("cunt", :tolerance => 4, :racist => false, :sexual => true))       # badness = 5
    assert_equal([], Profanalyzer.flagged_words("vagina", :tolerance => 4, :racist => false, :sexual => true)) # badness = 3
    assert_equal(["cunt"], Profanalyzer.flagged_words("cunt", :tolerance => 4, :racist => false, :sexual => true))       # badness = 5
  end
  
  def test_racist_tolerance_advanced
    assert_equal(false, Profanalyzer.profane?("mick", :tolerance => 4, :racist => true, :sexual => false)) # badness = 3
    assert_equal(true, Profanalyzer.profane?("nigger", :tolerance => 4, :racist => true, :sexual => false))       # badness = 5
    assert_equal([], Profanalyzer.flagged_words("mick", :tolerance => 4, :racist => true, :sexual => false)) # badness = 3
    assert_equal(["nigger"], Profanalyzer.flagged_words("nigger", :tolerance => 4, :racist => true, :sexual => false))       # badness = 5
  end
  
  def test_filter_advanced
    original_string = "You're a cocksucking piece of shit, you mick."
    filtered_string = "You're a #!$%@&!$%@% piece of #!$%, you #!$%."
    assert_equal(filtered_string, Profanalyzer.filter(original_string, :tolerance => 0, :all => true))
  end
  
  def test_sexual_filter_advanced
    original_string = "You're a cocksucking piece of shit, you mick."
    filtered_string = "You're a #!$%@&!$%@% piece of shit, you mick."
    assert_equal(filtered_string, Profanalyzer.filter(original_string, :tolerance => 0, :sexual => true, :racist => false))
  end
  
  def test_racist_filter_advanced
    original_string = "You're a cocksucking piece of shit, you mick."
    filtered_string = "You're a cocksucking piece of shit, you #!$%."
    assert_equal(filtered_string, Profanalyzer.filter(original_string, :tolerance => 0, :sexual => false, :racist => true))
  end

end
