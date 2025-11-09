# frozen_string_literal: true

# Color Name to Hex Code Mapping
# Centralized color mappings for color attribute values
# Any updates to color hex codes should be made here

module ColorHexMap
  COLOR_HEX_MAP = {
    'Black' => '#000000',
    'White' => '#FFFFFF',
    'Red' => '#FF0000',
    'Blue' => '#0000FF',
    'Green' => '#008000',
    'Yellow' => '#FFFF00',
    'Orange' => '#FFA500',
    'Purple' => '#800080',
    'Pink' => '#FFC0CB',
    'Brown' => '#A52A2A',
    'Gray' => '#808080',
    'Grey' => '#808080',
    'Navy' => '#000080',
    'Maroon' => '#800000',
    'Beige' => '#F5F5DC',
    'Cream' => '#FFFDD0',
    'Ivory' => '#FFFFF0',
    'Gold' => '#FFD700',
    'Silver' => '#C0C0C0',
    'Bronze' => '#CD7F32',
    'Rose Gold' => '#E8B4B8',
    'Turquoise' => '#40E0D0',
    'Coral' => '#FF7F50',
    'Lavender' => '#E6E6FA',
    'Mint' => '#98FB98',
    'Teal' => '#008080',
    'Olive' => '#808000',
    'Burgundy' => '#800020',
    'Charcoal' => '#36454F',
    'Tan' => '#D2B48C',
    'Khaki' => '#C3B091',
    'Indigo' => '#4B0082',
    'Violet' => '#8A2BE2',
  }.freeze

  def self.hex_for(color_name)
    COLOR_HEX_MAP[color_name] || nil
  end

  def self.all_colors
    COLOR_HEX_MAP
  end

  def self.has_hex?(color_name)
    COLOR_HEX_MAP.key?(color_name)
  end
end





