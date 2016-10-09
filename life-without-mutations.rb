require 'set'

class World

  ANSI_ERASE_TO_EO_SCREEN = "\e[J"
  ANSI_ERASE_TO_EOL       = "\e[K"
  ANSI_HOME               = "\e[H"
  DEFAULT_DELAY = 0.05
  DEFAULT_COLS  = 80
  DEFAULT_ROWS  = 20

  NEIGHBOR_VECTORS = 
    (-1..1).map { |dx|
      (-1..1).map { |dy| dx != 0 || dy != 0 ? [dx, dy] : nil }
    }.flatten(1).compact

  # only really needed for World.run
  attr_reader :cells

  def initialize(options = {})
    num_cols   = options[:cols] || DEFAULT_COLS
    num_rows   = options[:rows] || DEFAULT_ROWS
    @max_col = num_cols - 1
    @max_row = num_rows - 1
    tmp_cells = options[:cells] || random_cells
    # use a Set to make lookup fast and deduping automatic;
    # force into bounds JIC of caller passing bad coords
    @cells = Set.new(tmp_cells.map { |c| [c[0] % num_cols, c[1] % num_rows] })
    # stash options to pass along to next world (see #next_world)
    @options = options
  end

  def cell_at?(coords)
    @cells.include? coords
  end

  def next_world
    # credit to Kalimar Maia for the "cells_to_keep + cells_to_add" bit;
    # that neatly bysteps what cells we need to *remove*.
    World.new(@options.merge({ cells: cells_to_keep + cells_to_add }))
  end

  def show
    lines.each { |line| puts "#{line}#{ANSI_ERASE_TO_EOL}" }
  end

  def lines(cells_to_show = @cells)
    (0..@max_row).map { |y|
      ((0..@max_col).map { |x| cells_to_show.include?([x,y]) ? "@" : " " }.
       join.
       rstrip)
    }
  end

  def self.run(options = {})
    @delay = options.delete(:delay) || DEFAULT_DELAY
    print "#{ANSI_HOME}#{ANSI_ERASE_TO_EO_SCREEN}"
    @start_time = Time.now
    do_run(1, World.new(options))
  end

  private

  def random_cells
    Set.new((1..(@max_col * @max_row / 10)).
            map { [rand(@max_col + 1), rand(@max_row + 1)] })
  end

  def cells_to_keep
    @cells.select { |c| [2,3].include? neighbor_count(c) }
  end

  def cells_to_add
    # could alternately make it a set just before selecting;
    # the main point is to dedup.  but do NOT make EACH cell's
    # dead neighbors a set, so as to add them up to a set;
    # that's MUCH slower.
    @cells.
      map { |c| dead_neighbors(c) }.
      reduce(&:+).
      uniq.
      select { |c| neighbor_count(c) == 3 }
  end

  def dead_neighbors(cell)
    # don't subtract @cells, that's MUCH slower
    neighbor_coords(cell).select { |coords| ! cell_at? coords }
  end

  def neighbor_coords(cell)
    NEIGHBOR_VECTORS.
      map { |nv| [(cell[0] + nv[0]) % @max_col,
                  (cell[1] + nv[1]) % @max_row] }.
      select { |c| c != cell }  # JIC of world w/ length or width of 1
  end

  def neighbor_count(cell)
    # don't intersect w/ @cells, that's MUCH slower
    neighbor_coords(cell).select { |c| cell_at?(c) }.count
  end

  def self.do_run(iteration_number, world, prev_cell_sets = [])
    print ANSI_HOME
    world.show
    puts "Iteration #{iteration_number} (#{world.cells.count} cells)"
    sleep @delay
    index = world.cells.empty? ? 0 : prev_cell_sets.find_index(world.cells)
    if index.nil?
      do_run(iteration_number + 1,
             world.next_world,
             # take 15 'cuz that's the longest known single-construct
             # cycle length, which for a Pentadecathlon -- see
             # https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life
             ([world.cells] + prev_cell_sets).take(15))
    else
      ips = (iteration_number / (Time.now - @start_time)).round
      puts("Stable with cycle length of #{index + 1},"\
           " at #{ips} iterations per second)")
    end
  end

end
