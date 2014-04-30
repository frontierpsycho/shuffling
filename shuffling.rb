require 'statsample'

module Shuffling
  class Evaluator
    attr_reader :results

    def initialize(times: 300_000, deck_size: 30)
      @deck_size = deck_size
      @deck = (1..@deck_size).to_a
      @results = {}
      @times = times
      @expected = Array.new(@deck_size, 1.0 / @deck_size)
    end

    def init_local_result
      keys = (0...@deck.size).to_a
      values = Array.new(@deck.size, 0)

      Hash[keys.zip(values)]
    end

    def evaluate(shuffler)
      local_result = self.init_local_result
      (1..@times).each do
        shuffled_deck = shuffler.shuffle(@deck)
        local_result[shuffled_deck.index(1)] += 1
      end

      observed = self.pd(local_result)

      chi_square = Statsample::Test.chi_square(Matrix.row_vector(observed), Matrix.row_vector(@expected))

      @results[shuffler.name] = chi_square.probability
    end

    def pd(local_result)
      res = local_result.values.map do |value|
        value / @times.to_f
      end
      res
    end
  end
end
