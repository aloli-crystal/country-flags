# Embeds the country flag SVG assets from lipis/flag-icons (MIT) and
# exposes a minimal Crystal API: lookup by ISO 3166-1 alpha-2 code,
# enumeration, and conversion from a regional-indicator flag emoji to
# its ISO code.
#
# All flag SVGs are read and inlined at compile time (via the
# `read_file` macro), so consumers do not need to ship the `data/`
# directory alongside their compiled binaries.
module CrystalFlags
  # Version of the Crystal shard.
  VERSION = "0.1.0"

  # Version of lipis/flag-icons whose assets are embedded.
  ICONS_VERSION = "7.5.0"

  # First regional indicator symbol codepoint (U+1F1E6 = 🇦).
  # A flag emoji is a pair of regional indicators in the range
  # U+1F1E6…U+1F1FF that spells out the ISO 3166-1 alpha-2 code:
  # `A = U+1F1E6`, `B = U+1F1E7`, …, `Z = U+1F1FF`.
  REGIONAL_INDICATOR_A = 0x1F1E6

  # Last regional indicator (U+1F1FF = 🇿).
  REGIONAL_INDICATOR_Z = 0x1F1FF

  # Compile-time hash of `CODE => svg_content`, populated from every
  # `data/flags/*.svg` shipped with the shard. Codes are upper-cased.
  # Built at compile time via `read_file`, so consumers of this shard
  # do not need to ship the `data/` directory alongside their binaries.
  FLAGS = begin
    flags = {} of String => String
    {% for line in read_file(__DIR__ + "/../data/flags/MANIFEST.txt").split("\n") %}
      {% code = line.strip %}
      {% if code.size == 2 %}
        flags[{{ code.upcase }}] = {{ read_file(__DIR__ + "/../data/flags/" + code + ".svg") }}
      {% end %}
    {% end %}
    flags
  end

  # Returns the raw SVG for a country. `code` is the ISO 3166-1
  # alpha-2 code, case-insensitive. Returns `nil` when the code is
  # unknown (including invalid shapes like empty strings or codes
  # longer than 3 characters).
  def self.svg(code : String) : String?
    FLAGS[code.upcase]?
  end

  # Same as `#svg` but raises `KeyError` when the code is unknown.
  # Useful when the caller has already validated the code.
  def self.svg!(code : String) : String
    FLAGS[code.upcase]
  end

  # Returns the sorted list of every ISO code for which a flag SVG is
  # embedded in this shard. Codes are upper-cased.
  def self.available : Array(String)
    FLAGS.keys.sort
  end

  # Returns true when a flag SVG is available for `code`
  # (case-insensitive).
  def self.available?(code : String) : Bool
    FLAGS.has_key?(code.upcase)
  end

  # Extracts the ISO 3166-1 alpha-2 code from a flag emoji made of
  # two consecutive regional indicator symbols (e.g. `"🇫🇷"` → `"FR"`).
  # Returns `nil` for any input that is not exactly two regional
  # indicators.
  #
  # Example:
  # ```
  # CrystalFlags.code_for("🇫🇷") # => "FR"
  # CrystalFlags.code_for("FR") # => nil
  # CrystalFlags.code_for("")   # => nil
  # ```
  def self.code_for(flag : String) : String?
    chars = flag.chars
    return nil unless chars.size == 2
    a = chars[0].ord
    b = chars[1].ord
    return nil unless REGIONAL_INDICATOR_A <= a <= REGIONAL_INDICATOR_Z
    return nil unless REGIONAL_INDICATOR_A <= b <= REGIONAL_INDICATOR_Z
    letter_a = ('A'.ord + (a - REGIONAL_INDICATOR_A)).chr
    letter_b = ('A'.ord + (b - REGIONAL_INDICATOR_A)).chr
    "#{letter_a}#{letter_b}"
  end

  # Convenience: returns the SVG of the flag encoded in `flag` (a
  # regional-indicator pair). Returns `nil` when the input is not a
  # flag emoji or when the corresponding country has no SVG
  # available.
  #
  # Example:
  # ```
  # CrystalFlags.svg_for("🇫🇷") # => "<svg ...>...</svg>"
  # ```
  def self.svg_for(flag : String) : String?
    code = code_for(flag)
    code ? svg(code) : nil
  end
end
