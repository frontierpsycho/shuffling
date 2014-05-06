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
    def initialize(pile_factor=8)
      @pile_factor = pile_factor
    end

    def name
      "Pile shuffle"
    end

    def place_card_on_random_pile(piles, card)
      piles[rand(0...piles.size)] << card
    end

    def gather_piles(piles)
      piles.shuffle!.flatten
    end

    def shuffle(deck)
      piles = Array.new(deck.size / @pile_factor) { Array.new }

      deck.each do |card|
        self.place_card_on_random_pile(piles, card)
      end

      self.gather_piles(piles)
    end
  end

  class VariablePileShuffle < PileShuffle
    def name
      "Variable pile shuffle"
    end

    def place_card_on_random_pile(piles, card)
      piles << Array.new if rand() < 1.0 / @pile_factor
      super(piles, card)
    end
  end

  class VariablePileShuffleHuman < VariablePileShuffle
    def name
      "Variable pile shuffle with serial gathering"
    end

    def gather_piles(piles)
      piles.flatten
    end
  end

  class RiffleShuffle
    def name
      "Simple riffle shuffle"
    end

    def shuffle(deck)
      top_half, bottom_half = self.divide_deck(deck)

      new_deck = []

      while not new_deck.size == deck.size
        threshold = top_half.size / deck.size

        if rand() > threshold
          new_deck << top_half.delete_at(-1)
        else
          new_deck << bottom_half.delete_at(-1)
        end
      end

      new_deck
    end

    protected

    def divide_deck(deck)
      # this tries to approximately divide in the middle
      # almost following a bell curve around it
      # see wikipedia "Normal distribution"

      random_sum = 0
      12.times do
        random_sum += rand()
      end

      i = deck.size * random_sum / 12

      return deck[0...i], deck[i..-1]
    end
  end
end
