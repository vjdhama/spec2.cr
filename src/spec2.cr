require "./matchers/*"
require "./exceptions"
require "./expectation"
require "./example"
require "./let"
require "./hook"
require "./context"
require "./macro"
require "./reporter"
require "./reporters/*"
require "./runner"

module Spec2
  extend self

  @@runner = Runner.new
  @@context = Spec2

  def self.runner
    @@runner
  end

  def self.configure_runner(runner)
    @@runner = runner
  end

  def self.current_context
    @@context
  end

  def self.current_context=(context)
    @@context = context
  end

  def self.what
    nil
  end

  delegate run, runner
  delegate configure_reporter, runner
  delegate random_order?, runner
  delegate random_order, runner
  delegate _contexts, runner
end

Spec2.configure_reporter(Spec2::Reporters::Default)

at_exit do
  Spec2.run
end
