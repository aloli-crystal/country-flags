require "./spec_helper"

describe CountryFlags do
  describe "VERSION" do
    it "is set" do
      CountryFlags::VERSION.should_not be_empty
    end
  end

  describe "ICONS_VERSION" do
    it "is set" do
      CountryFlags::ICONS_VERSION.should_not be_empty
    end
  end

  describe ".available" do
    it "returns a non-empty, sorted list of upper-case codes" do
      codes = CountryFlags.available
      codes.should_not be_empty
      codes.should eq(codes.sort)
      codes.all?(&.upcase.==(codes.first.upcase)) # all upper-cased
      codes.should contain("FR")
      codes.should contain("DE")
      codes.should contain("US")
    end

    it "ships at least 240 flags" do
      # lipis/flag-icons 7.5.0 ships ~270. Guard against accidental
      # under-population without tying the test to the exact count.
      CountryFlags.available.size.should be >= 240
    end
  end

  describe ".svg" do
    it "returns an SVG document for a known code" do
      svg = CountryFlags.svg("FR")
      svg.should_not be_nil
      svg.not_nil!.should start_with("<svg")
    end

    it "is case-insensitive" do
      CountryFlags.svg("fr").should eq(CountryFlags.svg("FR"))
      CountryFlags.svg("Fr").should eq(CountryFlags.svg("FR"))
    end

    it "returns nil for an unknown code" do
      CountryFlags.svg("ZZ").should be_nil
      CountryFlags.svg("ZZZ").should be_nil
      CountryFlags.svg("").should be_nil
    end
  end

  describe ".svg!" do
    it "returns the SVG for a known code" do
      CountryFlags.svg!("FR").should start_with("<svg")
    end

    it "raises for an unknown code" do
      expect_raises(KeyError) { CountryFlags.svg!("ZZ") }
    end
  end

  describe ".available?" do
    it "returns true for known codes (any case)" do
      CountryFlags.available?("FR").should be_true
      CountryFlags.available?("fr").should be_true
    end

    it "returns false for unknown codes" do
      CountryFlags.available?("ZZ").should be_false
      CountryFlags.available?("").should be_false
    end
  end

  describe ".code_for" do
    it "decodes a regional-indicator flag emoji" do
      CountryFlags.code_for("🇫🇷").should eq("FR")
      CountryFlags.code_for("🇩🇪").should eq("DE")
      CountryFlags.code_for("🇺🇸").should eq("US")
      CountryFlags.code_for("🇳🇱").should eq("NL")
    end

    it "returns nil for plain ASCII" do
      CountryFlags.code_for("FR").should be_nil
      CountryFlags.code_for("fr").should be_nil
    end

    it "returns nil for empty or wrong-length input" do
      CountryFlags.code_for("").should be_nil
      CountryFlags.code_for("🇫").should be_nil
      CountryFlags.code_for("🇫🇷🇩🇪").should be_nil
    end

    it "returns nil when one of the codepoints is not a regional indicator" do
      CountryFlags.code_for("🇫A").should be_nil
      CountryFlags.code_for("A🇫").should be_nil
    end
  end

  describe ".svg_for" do
    it "returns the SVG of the flag emoji" do
      svg = CountryFlags.svg_for("🇫🇷")
      svg.should_not be_nil
      svg.should eq(CountryFlags.svg("FR"))
    end

    it "returns nil for non-flag input" do
      CountryFlags.svg_for("FR").should be_nil
      CountryFlags.svg_for("").should be_nil
    end
  end
end
