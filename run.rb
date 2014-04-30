require './shuffling'
require './shufflers'

module Shuffling
  evaluator = Evaluator.new(deck_size: 52, times: 520_000)

  evaluator.evaluate(RubyShuffler.new)
  puts evaluator.results
end
