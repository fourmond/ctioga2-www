# style.rb: bases for the style computations (CSS and SVG)
# Copyright 2009 by Vincent Fourmond
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details (in the COPYING file).

# The layout-related information:

require 'ostruct'

# TODO: ??
#
# * Write a real structure that could represent a whole "box", with:
#   - border, background and side colors
#   - the various parameters of the box
# * Write a plugin that would take a hash of constants, a well-designed
#   rsvg file, and spit out a whole series of backgrounds.

# For the "main wrap", 
Full = OpenStruct.new
# The total width of the stuff.
Full.width = 1000
Full.total_width = 1400

# How much space to leave before anything
Full.margin = 10
Full.usable_width = Full.width - 2 * Full.margin

Contents = OpenStruct.new
Contents.padding = 3
Contents.width = 750

SideBar = OpenStruct.new
SideBar.padding = 3
SideBar.width = 200

Round = OpenStruct.new
# The ray of the rounding
Round.ray = 15
Round.neg_margin = -13

Border = OpenStruct.new
Border.dx = 1
Border.width = 2

Round.ray_eff = Round.ray - Border.dx


# Total width of the background image:
$total_width = 1400
$mw_padding = 10

$bg_away_distance = 120              # The distance after which we
                                     # reach the 'far away color'

# The width of the full-color margin of the background
$bg_margin_bar = 2

$bg_left = ($total_width - Full.width - 2*$mw_padding)/2 + 2 * $bg_margin_bar
$bg_right = $total_width - $bg_left + 2 * $bg_margin_bar


# The height of the background image. Should be 1 to minimize
$bg_pix_height = 1

# The height of the header
$head_height = 90

# Header vertical padding
$head_above = 10
$head_below = 20

$head_extra_padding = 5


# Colors...
class HTMLColor
  
  attr_accessor :r, :g, :b
  
  # Creates a color
  def initialize(r, g = nil, b = nil)
    if g
      @r = r.to_i
      @g = g.to_i
      @b = b.to_i
    else
      r =~ /#(..)(..)(..)/
        @r = $1.to_i(16)
      @g = $2.to_i(16)
      @b = $3.to_i(16)
    end
  end

  def to_s
    return "#%02x%02x%02x" % [@r, @g, @b]
  end

  def mix_with(c, f)
    f2 = 1 - f
    return HTMLColor.new(@r * f + c.r * f2, 
                         @g * f + c.g * f2, 
                         @b * f + c.b * f2)
  end

  def self.white
    return HTMLColor.new(255, 255, 255)
  end

  def self.black
    return HTMLColor.new(0,0,0)
  end
end

Colors = OpenStruct.new
# The colors for the backgroud:
$bg_away_color = HTMLColor.white # The color in a faraway distance
$bg_color = HTMLColor.white      # The real background color
$bg_sides_color = HTMLColor.new("#B0B0B0") # The color just on the sides of the text
$bg_sides_color = HTMLColor.new("#8ed9d9")
$bg_sides_color = HTMLColor.new("#55ab2f")
# $bg_sides_color = HTMLColor.new("#B0B0FF") # The color just on the sides of the text
$bg_stop_color = $bg_sides_color.mix_with(HTMLColor.white, 0.6)


Colors.main_title = HTMLColor.new("#389de9")
Colors.main_title = HTMLColor.new("#081566")
Colors.slogan = HTMLColor.black.mix_with(HTMLColor.white, 0.5)
Colors.borders = $bg_sides_color


Colors.pre_bg = Colors.borders.mix_with(HTMLColor.white, 0.2)
Colors.titles = Colors.main_title
Colors.title_underline = Colors.titles.mix_with(HTMLColor.white, 0.5)
Colors.title_underline = Colors.titles

# Colors.sidebar = HTMLColor.black.mix_with(HTMLColor.white, 0.6)
Colors.sidebar = HTMLColor.black

# The colors for generated documentation
Colors.doc_title = HTMLColor.new("#1f7172")

Colors.cmdline_border = HTMLColor.new("#037c9a")
Colors.cmdline_bg = Colors.cmdline_border.mix_with(HTMLColor.white, 0.2)

Colors.cmdfile_border = HTMLColor.new("#4a039a")
Colors.cmdfile_bg = Colors.cmdfile_border.mix_with(HTMLColor.white, 0.2)
