(1..100).to_a.each do |i|
  if i % 15 == 0
     "FizBuzz"
  elsif i % 3 == 0
     "Fiz"
  elsif i % 5 == 0
     "Buz"
  else
     i
  end
end