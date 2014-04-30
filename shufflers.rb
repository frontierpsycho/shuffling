module Shuffling
  class RubyShuffler
    def name
      "Ruby built-in shuffle"
    end

    def shuffle(deck)
      deck.shuffle
    end
  end

  class PileShuffle
    def initialize(pile_factor: 8)
      @pile_factor = pile_factor
    end

    def name
      "Pile shuffle"
    end

    def place_card_on_random_pile(piles, card)
      piles[rand(0...piles.size)] << card
    end

    def shuffle(deck)
      piles = Array.new(deck.size / @pile_factor) { Array.new }

      deck.each do |card|
        self.place_card_on_random_pile(piles, card)
      end

      piles.shuffle!.flatten
    end
  end
end
