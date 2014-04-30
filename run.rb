require './shuffling'
require './shufflers'

module Shuffling
  evaluator = Evaluator.new(deck_size: 30, times: 300_000)

  evaluator.evaluate(RubyShuffler.new)
  evaluator.evaluate(PileShuffle.new)
  puts evaluator.results
end
