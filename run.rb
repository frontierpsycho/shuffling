require 'celluloid'

require './shuffling'
require './shufflers'


module Shuffling
  class AggregatorActor
    include Celluloid

    def initialize(shufflers)
      @shufflerset = shufflers
      @results = {}
    end

    def add_result(result)
      @results.merge! result

      @shufflerset = @shufflerset - result.keys

      puts "Results for #{result.keys.inspect} recorded, remaining: #{@shufflerset.inspect}"

      if @shufflerset.empty?
        self.output
        self.terminate
      end
    end

    def output
      puts @results
    end
  end

  class EvalActor
    include Celluloid

    def initialize(shufflerClass)
      @shuffler = shufflerClass.new
      self.async.runEvaluation
    end

    def runEvaluation
      puts "Running #{@shuffler.name}"
      evaluator = Evaluator.new(3000)
      puts "#{@shuffler.name} evaluating..."
      evaluator.evaluate(@shuffler)
      puts "#{@shuffler.name} evaluated."
      Celluloid::Actor[:aggregator].async.add_result(evaluator.results)
      self.terminate
    end
  end

  class ShufflerSupervisionGroup < Celluloid::SupervisionGroup
    shufflers = [RubyShuffler, PileShuffle, VariablePileShuffle, VariablePileShuffleHuman].to_set

    supervise AggregatorActor, as: :aggregator, args: [shufflers.map { |sh| sh.new.name }]

    shufflers.each do |shuffler|
      supervise EvalActor, as: shuffler.name.to_sym, args: [shuffler]
    end
  end

  ShufflerSupervisionGroup.run
end
