require './shuffling'
require './shufflers'

module Shuffling
  evaluator = Evaluator.new(520_000, 52)

  evaluator.evaluate(RubyShuffler.new)
  puts evaluator.results
end
