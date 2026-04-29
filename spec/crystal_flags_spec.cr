require "./spec_helper"

describe Flags do
  describe "VERSION" do
    it "is set" do
      Flags::VERSION.should_not be_empty
    end
  end

  describe "ICONS_VERSION" do
    it "is set" do
      Flags::ICONS_VERSION.should_not be_empty
    end
  end

  describe ".available" do
    it "returns a non-empty, sorted list of upper-case codes" do
      codes = Flags.available
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
      Flags.available.size.should be >= 240
    end
  end

  describe ".svg" do
    it "returns an SVG document for a known code" do
      svg = Flags.svg("FR")
      svg.should_not be_nil
      svg.not_nil!.should start_with("<svg")
    end

    it "is case-insensitive" do
      Flags.svg("fr").should eq(Flags.svg("FR"))
      Flags.svg("Fr").should eq(Flags.svg("FR"))
    end

    it "returns nil for an unknown code" do
      Flags.svg("ZZ").should be_nil
      Flags.svg("ZZZ").should be_nil
      Flags.svg("").should be_nil
    end
  end

  describe ".svg!" do
    it "returns the SVG for a known code" do
      Flags.svg!("FR").should start_with("<svg")
    end

    it "raises for an unknown code" do
      expect_raises(KeyError) { Flags.svg!("ZZ") }
    end
  end

  describe ".available?" do
    it "returns true for known codes (any case)" do
      Flags.available?("FR").should be_true
      Flags.available?("fr").should be_true
    end

    it "returns false for unknown codes" do
      Flags.available?("ZZ").should be_false
      Flags.available?("").should be_false
    end
  end

  describe ".code_for" do
    it "decodes a regional-indicator flag emoji" do
      Flags.code_for("🇫🇷").should eq("FR")
      Flags.code_for("🇩🇪").should eq("DE")
      Flags.code_for("🇺🇸").should eq("US")
      Flags.code_for("🇳🇱").should eq("NL")
    end

    it "returns nil for plain ASCII" do
      Flags.code_for("FR").should be_nil
      Flags.code_for("fr").should be_nil
    end

    it "returns nil for empty or wrong-length input" do
      Flags.code_for("").should be_nil
      Flags.code_for("🇫").should be_nil
      Flags.code_for("🇫🇷🇩🇪").should be_nil
    end

    it "returns nil when one of the codepoints is not a regional indicator" do
      Flags.code_for("🇫A").should be_nil
      Flags.code_for("A🇫").should be_nil
    end
  end

  describe ".svg_for" do
    it "returns the SVG of the flag emoji" do
      svg = Flags.svg_for("🇫🇷")
      svg.should_not be_nil
      svg.should eq(Flags.svg("FR"))
    end

    it "returns nil for non-flag input" do
      Flags.svg_for("FR").should be_nil
      Flags.svg_for("").should be_nil
    end
  end
end
