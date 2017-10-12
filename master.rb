class Game
  def initialize(human="Obi Wan Kenobi", robot="R2-D2")
    @human = Human.new(human)
    @robot = Robot.new(robot)
    start_game
  end

  def start_game
    puts "\nLet's play Mastermind!"
    pick_the_role
    @master = Mastermind.new(@codemaker.create_code)
    play
  end

  private
  # human picks the role (we can refactor this into initialize)
  def pick_the_role
    puts "Would #{@human} be so kind as to pick the role?"
    until @codemaker
      puts "Please enter 'codemaker' or 'codebreaker'."
      role = gets.chomp.downcase
      if role == 'codemaker' || role == 'maker'
        puts "#{@human} chose to be a 'codemaker'."
        @codemaker = @human
        @codebreaker = @robot
      elsif role == 'codebreaker' || role == 'breaker'
        puts "#{@human} chose to be a 'codebreaker'."
        @codemaker = @robot
        @codebreaker = @human
      elsif role == '42'
        puts "Ah, you're wise for a human. And yet, do select your role."
      else
        puts "Can't understand you, please try again."
      end
    end
  end

  # player plays playfully here
  def play
    take_turn until @master.game_over?
    @master.show_board
    @robot.speak
  end

  # one need to take turns
  def take_turn
    puts @master.show_board
    puts "\nPick your colors (one by one):"
    puts Mastermind.show_colors.join(", ")

    @master.guess(@codebreaker.enter_colors)
    @robot.get_the_score(@master.score) if @codebreaker == @robot
  end
end

# Mastermind class handles the mastermind thingy itself
class Mastermind
  # map of colors
  @@colors = ["red", "green", "blue", "yellow", "brown", "orange", "black", "white"]

  attr_reader :score
  def initialize(code)
    @code = code
    @turns = 0
    @the_board = []
    @last_guess = []
    @score = []
  end

  def show_board
    @the_board.each do |c, s|
      print "\n " + c.join("\t")
      print "\t" + s.join(' ')
    end
    puts
  end

  # has to be a class method, as we need it befor instantiating Mastermind
  # (which makes sence if you think of it)
  def self.show_colors
    @@colors
  end

  # checks if the game is over
  def game_over?
    if victory?
      puts "The code has been broken!"
      true
    elsif (@turns == 12)
      puts "The codebreaker failed."
      true
    else
      false
    end
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

  # check if the player is victorious
  def victory?
    @code == @last_guess
  end
end

# Machine class represnents the computer opponent
class Robot
  def initialize(name)
    @name = name
    @vocabulary = ["(chirps his excitement)", "(beeps)", "(chirps confidently)", "bleep bleep bloop", "bleep blopp beep beep", "beep beep"]
    @hits = 0
    @guesses = []
    @guessing_sequence = [*0..7].shuffle
    puts "Your opponent is #{@name}"
    speak
  end

  def to_s
    @name
  end

  def speak
    puts "#{@name} - #{@vocabulary.sample}"
  end

  # method for guessting colors
  def enter_colors
    speak
    guess
  end

  # takes the score for analysis
  def get_the_score(score)
    score = score.dup
    score.delete("o")
    @hits = score.length
  end

  # creates a code for human to guess
  def create_code
    speak
    code = []
    4.times do
      code << Mastermind.show_colors[rand(0..7)]
    end
    code
  end

  private
  # analyzes the last move
  def analyze
    @hits.times do
      @guesses << @last_guess unless @guesses.length == 4
    end
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

    puts "#{@name} picked #{colors.join(", ")}"
    colors
  end
end

# Human class represents the player
class Human
  def initialize(name)
    @name = name
    puts "#{@name} has entered the game"
  end

  def to_s
    @name
  end

  # allows a human to enter colors (and validates them using another method)
  def enter_colors
    colors = []
    until colors.length == 4
      pick = gets.chomp.downcase
      if input_validation(pick)
        colors << pick
      else
        puts "Don't know that color, sorry."
      end
    end
    puts "You picked #{colors.join(", ")}"
    colors
  end

  # allows human to create a code
  def create_code
    puts "#{@name}, please create your cypher. You can choose from these colors:"
    puts Mastermind.show_colors.join(", ")
    enter_colors
  end

  private
  def input_validation(pick)
    true if Mastermind.show_colors.include?(pick)
  end
end
