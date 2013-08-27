# style.rb: bases for the style 
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

# We want Tioga, for, mmm, color conversion ?
require 'Tioga/FigureMaker'


# TODO: ??
#
# * Write a real structure that could represent a whole "box", with:
#   - border, background and side colors
#   - the various parameters of the box
# * write small functions for common stuff (round borders, for instance)

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
      r =~ /#(..)(..)(..)/ #
      @r = $1.to_i(16)
      @g = $2.to_i(16)
      @b = $3.to_i(16)
    end
  end

  # Takes hue, lightness, saturation. Hue is in degrees on the color
  # wheel.
  def self.hls(h,l,s)
   cols = Tioga::FigureMaker.hls_to_rgb([h, l, s]).map do |x|
      255 * x
    end
    return HTMLColor.new(*cols )
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
Colors.slogan = HTMLColor.black.mix_with(HTMLColor.white, 0.3)
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

Colors.examples_border = $bg_sides_color
Colors.examples_bg = Colors.examples_border.mix_with(HTMLColor.white, 0.2)


Colors.gnuplot_border = HTMLColor.new("#222222")
Colors.gnuplot_bg = Colors.gnuplot_border.mix_with(HTMLColor.white, 0.2)

# Colors.bars_bg = Colors.examples_border.mix_with(HTMLColor.white, 0.3)
Colors.bar_bg = HTMLColor.hls(164,0.3,0.5) 
Colors.bar_fg = HTMLColor.white
Colors.bar_link = Colors.titles

# Top-left box
Colors.box_outer_bg = HTMLColor.hls(0,0.3,0.3) 
Colors.box_outer_fg = HTMLColor.new("#FFFFFF")

Colors.box_inner_bg = HTMLColor.new("#DDDDDD")
Colors.box_inner_fg = HTMLColor.new("#000000")

Colors.code = HTMLColor.hls(160,0.3,0.99)
