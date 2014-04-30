module Shuffling
  class Evaluator
    attr_reader :results

    def initialize(shuffler)
      @deck = (1..30).to_a
      @results = Hash.new(0)
      @shuffler = Shuffling.method(shuffler)
    end

    def evaluate
      (1..300_000).each do
        shuffled_deck = @shuffler.call(@deck)
        @results[shuffled_deck.index(1)] += 1
      end
    end
  end

  def self.ruby_shuffle(deck)
    deck.shuffle
  end

  evaluator = Evaluator.new(:ruby_shuffle)
  evaluator.evaluate

  puts evaluator.results
end
