module Shuffling
  class RubyShuffler
    def name
      "Ruby built-in shuffle"
    end

    def shuffle(deck)
      deck.shuffle
    end
  end
end
