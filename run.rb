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

    def wait_for_results
      sleep 5 while not @shufflerset.empty?

      self.output
      self.terminate
    end

    def add_result(result)
      @results.merge! result

      @shufflerset = @shufflerset - result.keys

      puts "Results for #{result.keys.inspect} recorded, remaining: #{@shufflerset.inspect}"
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
      times = ARGV.length > 0 ? Integer(ARGV[0]) : 300_000

      puts "Running #{@shuffler.name}"
      evaluator = Evaluator.new(times)
      puts "#{@shuffler.name} evaluating..."
      evaluator.evaluate(@shuffler)
      puts "#{@shuffler.name} evaluated."
      Actor[:aggregator].async.add_result(evaluator.results)
      self.terminate
    end
  end

  shufflers = [RubyShuffler, PileShuffle, VariablePileShuffle, VariablePileShuffleHuman].to_set

  Celluloid::Actor[:aggregator] = AggregatorActor.new(shufflers.map { |sh| sh.new.name })

  shufflers.each do |shuffler|
    Celluloid::Actor[shuffler.name.to_sym] = EvalActor.new shuffler
  end

  Celluloid::Actor[:aggregator].wait_for_results
end
