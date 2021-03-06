require 'statsample'

module Shuffling
  class Evaluator
    attr_reader :results

    def initialize(times=300_000, deck_size=30)
      @deck_size = deck_size
      @deck = (1..@deck_size).to_a
      @results = {}
      @times = times
      @expected = Array.new(@deck_size, 1.0 / @deck_size) 
    end

    def init_occurence_count
      keys = (0...@deck.size).to_a
      values = Array.new(@deck.size, 0)

      Hash[keys.zip(values)]
    end

    def evaluate(shuffler)
      occurence_count = self.init_occurence_count
      (1..@times).each do
        shuffled_deck = shuffler.shuffle(@deck)
        occurence_count[shuffled_deck.index(1)] += 1
      end

      observed = self.pd(occurence_count)

      chi_square = Statsample::Test.chi_square(Matrix.row_vector(observed), Matrix.row_vector(@expected))

      @results[shuffler.name] = chi_square.probability
    end

    def pd(occurence_count)
      res = occurence_count.values.map do |value|
        value / @times.to_f
      end
      res
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
