require "./spec_helper"

describe CrystalFlags do
  describe "VERSION" do
    it "is set" do
      CrystalFlags::VERSION.should_not be_empty
    end
  end

  describe "ICONS_VERSION" do
    it "is set" do
      CrystalFlags::ICONS_VERSION.should_not be_empty
    end
  end

  describe ".available" do
    it "returns a non-empty, sorted list of upper-case codes" do
      codes = CrystalFlags.available
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
      CrystalFlags.available.size.should be >= 240
    end
  end

  describe ".svg" do
    it "returns an SVG document for a known code" do
      svg = CrystalFlags.svg("FR")
      svg.should_not be_nil
      svg.not_nil!.should start_with("<svg")
    end

    it "is case-insensitive" do
      CrystalFlags.svg("fr").should eq(CrystalFlags.svg("FR"))
      CrystalFlags.svg("Fr").should eq(CrystalFlags.svg("FR"))
    end

    it "returns nil for an unknown code" do
      CrystalFlags.svg("ZZ").should be_nil
      CrystalFlags.svg("ZZZ").should be_nil
      CrystalFlags.svg("").should be_nil
    end
  end

  describe ".svg!" do
    it "returns the SVG for a known code" do
      CrystalFlags.svg!("FR").should start_with("<svg")
    end

    it "raises for an unknown code" do
      expect_raises(KeyError) { CrystalFlags.svg!("ZZ") }
    end
  end

  describe ".available?" do
    it "returns true for known codes (any case)" do
      CrystalFlags.available?("FR").should be_true
      CrystalFlags.available?("fr").should be_true
    end

    it "returns false for unknown codes" do
      CrystalFlags.available?("ZZ").should be_false
      CrystalFlags.available?("").should be_false
    end
  end

  describe ".code_for" do
    it "decodes a regional-indicator flag emoji" do
      CrystalFlags.code_for("🇫🇷").should eq("FR")
      CrystalFlags.code_for("🇩🇪").should eq("DE")
      CrystalFlags.code_for("🇺🇸").should eq("US")
      CrystalFlags.code_for("🇳🇱").should eq("NL")
    end

    it "returns nil for plain ASCII" do
      CrystalFlags.code_for("FR").should be_nil
      CrystalFlags.code_for("fr").should be_nil
    end

    it "returns nil for empty or wrong-length input" do
      CrystalFlags.code_for("").should be_nil
      CrystalFlags.code_for("🇫").should be_nil
      CrystalFlags.code_for("🇫🇷🇩🇪").should be_nil
    end

    it "returns nil when one of the codepoints is not a regional indicator" do
      CrystalFlags.code_for("🇫A").should be_nil
      CrystalFlags.code_for("A🇫").should be_nil
    end
  end

  describe ".svg_for" do
    it "returns the SVG of the flag emoji" do
      svg = CrystalFlags.svg_for("🇫🇷")
      svg.should_not be_nil
      svg.should eq(CrystalFlags.svg("FR"))
    end

    it "returns nil for non-flag input" do
      CrystalFlags.svg_for("FR").should be_nil
      CrystalFlags.svg_for("").should be_nil
    end
  end
end
