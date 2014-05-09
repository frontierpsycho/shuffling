module Shuffling
  def self.normal_random
    # *approximate* normal distribution variable between 0 and 1
    random_sum = 0
    12.times do
      random_sum += rand()
    end
    random_sum / 12.0
  end

  def self.discrete_normal_random(max, min=0)
    (normal_random * max) - min
  end
end
