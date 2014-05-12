require './shuffle_util'

module Shuffling
  class RubyShuffler
    def name
      "Ruby built-in shuffle"
    end

    def shuffle(deck)
      deck.shuffle
    end
  end

  class CompositeShuffler
    attr_reader :shufflers

    def initialize(shuffler_class_list)
      @shufflers = shuffler_class_list.map do |shuffler_class|
        begin
          shuffler = shuffler_class.new
          shuffler.method :shuffle

          shuffler
        rescue NameError
          raise ArgumentError, "Arguments should be shuffler classes", caller
        end
      end
    end

    def name
      "Composite shuffle: #{@shufflers.map( &name ).join(", ")}"
    end

    def shuffle(deck)
      @shufflers.reduce(deck) { |deck, shuffler|
        shuffler.shuffle(deck)
      }
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

    def pile_cardinality(deck)
      [deck.size / @pile_factor, 1].max
    end

    def shuffle(deck)
      piles = Array.new(self.pile_cardinality(deck)) { Array.new }

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
        threshold = top_half.size.to_f / (top_half.size + bottom_half.size)

        if rand() < threshold
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
      i = Shuffling.discrete_normal_random(deck.size)

      return deck[0...i], deck[i..-1]
    end
  end

  class MultipleShuffle
    def initialize
      shufflers = Array.new(self.shuffle_cardinality, self.shuffle_class)
      @internal_shuffler = CompositeShuffler.new shufflers
    end

    def shuffle_class
      RubyShuffle
    end

    def shuffle_cardinality
      1
    end

    def name
      "#{self.shuffle_cardinality}-#{shuffle_class.name} shuffle"
    end

    def shuffle(deck)
      @internal_shuffler.shuffle(deck)
    end
  end

  class MultipleRiffleShuffle < MultipleShuffle
    def shuffle_class
      RiffleShuffle
    end

    def name
      "#{self.shuffle_cardinality}-riffle shuffle"
    end
  end

  class SevenRiffleShuffle < MultipleRiffleShuffle
    def shuffle_cardinality
      7
    end
  end

  class ThreeRiffleShuffle < MultipleRiffleShuffle
    def shuffle_cardinality
      3
    end
  end

  class IndianShuffle
    def initialize(strip_factor=8)
      @strip_factor = strip_factor
    end

    def name
      "Indian shuffle"
    end

    def shuffle(deck)
      deck_copy = Array.new(deck)
      deck_size = deck_copy.size
      new_deck = []

      while new_deck.size < deck_size
        i = Shuffling.discrete_normal_random(@strip_factor)

        new_deck << deck_copy.slice!(0, i)
      end

      new_deck.reverse.flatten
    end
  end

  class ThreeIndianShuffle < MultipleShuffle
    def name
      "Three Indian shuffle"
    end

    def shuffle_class
      IndianShuffle
    end

    def shuffle_cardinality
      3
    end
  end

  class AwesomeSuperMegaShuffle
    def initialize
      @internal_shuffler = CompositeShuffler.new [VariablePileShuffle, IndianShuffle]
    end

    def name
      "Awesome super mega shuffle"
    end

    def shuffle(deck)
      @internal_shuffler.shuffle(deck)
    end
  end
end
