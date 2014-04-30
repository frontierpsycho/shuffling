module Shuffling
  class Evaluator
    attr_reader :results

    def initialize(shuffler)
      @deck = (1..30).to_a
      @results = Hash.new(0)
      @shuffler = shuffler
    end

    def evaluate
      (1..300_000).each do
        shuffled_deck = @shuffler.shuffle(@deck)
        @results[shuffled_deck.index(1)] += 1
      end
    end
  end

  class RubyShuffler
    def shuffle(deck)
      deck.shuffle
    end
  end

  evaluator = Evaluator.new(RubyShuffler.new)
  evaluator.evaluate

  puts evaluator.results
end
