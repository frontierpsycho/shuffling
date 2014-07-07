require 'statsample'

module Shuffling
  class Evaluator
    attr_reader :results

    def initialize(times=300_000, deck_size=30)
      @deck_size = deck_size
      @deck = (1..@deck_size).to_a
      @results = {}
      @times = times
      @expected_place_pd = Array.new(@deck_size, 1.0 / @deck_size) 
      @expected_distance_pd = Array.new(2 * (@deck_size - 1), 1.0 / (2 * (@deck_size - 1)))
    end

    def init_occurence_counts
      keys = (0...@deck.size).to_a
      values = Array.new(@deck.size, 0)

      Hash[keys.zip(values)]
    end

    def init_distance_counts
      keys = (-(@deck.size-1)..-1).to_a + (1...@deck.size).to_a
      values = Array.new(2 * (@deck.size - 1), 0)

      Hash[keys.zip(values)]
    end

    def evaluate(shuffler)
      occurence_counts = self.init_occurence_counts
      distance_counts = self.init_distance_counts

      (1..@times).each do
        shuffled_deck = shuffler.shuffle(@deck)
        index_of_1 = shuffled_deck.index(1)
        index_of_2 = shuffled_deck.index(2)
        occurence_counts[index_of_1] += 1
        distance_counts[index_of_2 - index_of_1] += 1
      end

      observed_place = self.pd(occurence_counts)
      chi_square_place = Statsample::Test.chi_square(Matrix.row_vector(observed_place), Matrix.row_vector(@expected_place_pd))

      observed_distance = self.pd(distance_counts)
      chi_square_distance = Statsample::Test.chi_square(Matrix.row_vector(observed_distance), Matrix.row_vector(@expected_distance_pd))

      @results[shuffler.name] = [chi_square_place.probability, chi_square_distance.probability]
    end

    def pd(occurence_count)
      occurence_count.values.map do |value|
        value / @times.to_f
      end
    end
  end

  class InversionsEvaluator
    attr_reader :results

    def initialize(times=300_000, deck_size=30)
      @deck_size = deck_size
      @deck = (1..@deck_size).to_a
      @times = times
      @results = {}
    end

    def evaluate(shuffler)
      total = 0
      (1..@times).each do
        shuffled_deck = shuffler.shuffle(@deck)
        total += self.inversion_number(shuffled_deck)
      end

      average_inversion_number = total / @times.to_f
      @results[shuffler.name] = average_inversion_number
    end

    def inversion_number(shuffled_deck)
      result = 0
      (1...shuffled_deck.size).each do |index|
        current_item = shuffled_deck[index]
        result += shuffled_deck.take(index).count {|item| item > current_item }
      end

      result
    end
  end
end
