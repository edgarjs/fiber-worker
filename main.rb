require 'fiber'
require 'securerandom'

class Worker
  def initialize(name, queue)
    @name = name
    @queue = queue
  end

  def tick
    rand(3)
    # @queue.shift
  end

  def poll
    puts "#{@name} started polling.."

    while @keep_going
      result = tick

      puts "#{@name} processed #{result}"
      if result.zero?
        Fiber.yield
        sleep 0.2
      end
    end
  end

  def start
    @keep_going = true
    Fiber.new { poll }
  end

  def stop
    return unless @keep_going

    @keep_going = false
    puts "#{@name} stopped"
  end
end

queue = (1..100).to_a
fibers = []
w1 = Worker.new('stopable', queue)
fibers << w1.start

# 5.times do |i|
#   fibers << Worker.new(i, queue).start
# end

run = true
while run
  fibers.each { |f| f.resume if f.alive? }
  # w1.stop

  Signal.trap('INT') { run = false }
end
