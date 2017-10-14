class Game
  attr_reader :master

  def initialize(role)
    @robot = Robot.new

    @master = Mastermind.new(@robot.create_code) if role == 'codebreaker'
  end

  def create_code(*colors)
    if colors && !colors.empty?
      @master = Mastermind.new(colors[0])
    else
      @master = Mastermind.new(@robot.create_code)
    end
  end
  # one need to take turns
  def take_turn(*colors)
    if colors && !colors.empty?
      @master.guess(colors[0])
    else
      @master.guess(@robot.guess)
      @robot.get_the_score(@master.score)
    end
  end

end

# Mastermind class handles the mastermind thingy itself
class Mastermind
  @@colors = ["red", "green", "blue", "yellow", "brown", "orange", "black", "white"]

  attr_reader :the_board, :score, :code
  def initialize(code)
    @code = code
    @turns = 0
    @the_board = []
    @last_guess = []
    @score = []
  end

  # has to be a class method, as we need it befor instantiating Mastermind
  # (which makes sence if you think of it)
  def self.show_colors
    @@colors
  end

  # checks if the game is over
  def game_over?
    return true if victory? || (@turns == 12)
    false
  end

  def victory?
    @code == @last_guess
  end

  # calls to a private method 'compare' and increments the turns variable
  def guess(input)
    @last_guess = input
    compare(input)
    @turns += 1
  end

  private
  def compare(input)
    score = []
    # need to dublicate input and code each time, and remove checked values
    user_guesses = input.dup
    code = @code.dup

    # have to use while loop for more control
    # checking for direct hits
    i = 0
    while i < user_guesses.length
      if user_guesses[i] == code[i]
        score << "+"
        user_guesses.delete_at(i)
        code.delete_at(i)
      else
        i += 1
      end
    end

    # checking for indirect hits
    i = 0
    while i < user_guesses.length
      if code.include?(user_guesses[i])
        score << "-"
        color = user_guesses[i]
        user_guesses.delete_at(user_guesses.index(color))
        code.delete_at(code.index(color))
      else
        i += 1
      end
    end

    until score.length == 4
      score << "o"
    end

    @score = score
    add_to_the_board(input, score)
  end


  def add_to_the_board(input, score)
    @the_board[@turns] = [input, score]
  end
end

# Machine class represnents the computer opponent
class Robot
  def initialize
    @hits = 0
    @guesses = []
    @guessing_sequence = [*0..7].shuffle
  end

  # takes the score for analysis
  def get_the_score(score)
    score = score.dup
    score.delete("o")
    @hits = score.length
  end

  # creates a code for human to guess
  def create_code
    code = []
    4.times do
      code << Mastermind.show_colors[rand(0..7)]
    end
    code
  end

  def guess
    analyze

    colors = []
    unless @guesses.length == 4
      guess = @guessing_sequence.pop
      4.times do
        colors << Mastermind.show_colors[guess]
      end
      @last_guess = colors[0]
    else
      colors = @guesses.shuffle
    end

    colors
  end

  private
  # analyzes the last move
  def analyze
    @hits.times do
      @guesses << @last_guess unless @guesses.length == 4
    end
  end
end
