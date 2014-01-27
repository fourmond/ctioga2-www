-60.upto(60) do |i|
  -60.upto(60) do |j|
    x = 0.25 * i
    y = 0.25 * j
    r = (x**2 + y**2)**0.5
    x2_y2 = 0.0625 * (x**2 - y**2)
    puts "#{x}\t#{y}\t#{r}\t#{(r > 0 ? Math::sin(r)/r : 1)}\t#{x2_y2}"
  end
end
