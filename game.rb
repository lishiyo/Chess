require './board.rb'
require './piece.rb'
require './sliding_pieces.rb'
require './stepping_pieces.rb'

class ChessError < StandardError
end

class Game

  attr_reader :board

  def initialize(player1 = HumanPlayer.new, player2 = HumanPlayer.new)
    @player1 = player1
    @player2 = player2
    @current_player = player2
    @board = Board.new
    setup_pieces
    setup_players
  end

  def play_game
    @board.display_board
    until over?
      @current_player = switch_player
      if @board.in_check?(switch_player.color)
        puts "#{switch_player.color} is in check!"
      end
      begin
        start_pos, end_pos = @current_player.get_player_move # returns [[0,1], [1,2]]
        if @board[start_pos].color != @current_player.color
          raise ChessError.new("That's not your color!")
        end
        @board.move(start_pos, end_pos) # throws DangerOfCheck or InvalidMove
      rescue ChessError => e
        @current_player.handle_move_response(e)
        retry
      end
      @board.display_board
      puts "#{@current_player.to_s} moved from #{start_pos} to #{end_pos}."
    end
    puts "#{@current_player.to_s} wins!"
  end

  def switch_player
    @current_player == @player2 ? @player1 : @player2
  end

  def setup_players
    @player1.color = :w
    @player2.color = :b
  end

  def over?
      @board.checkmate?(switch_player.color)
  end


  def setup_pieces
    @board.grid.each_with_index do |row, row_i|
      row.each_with_index do |col, col_j|
        pos = [row_i, col_j]
        rooks = Proc.new {|el| el == 7 || el == 0 }
        knights = Proc.new {|el| el == 6 || el == 1 }
        bishops = Proc.new {|el| el == 5 || el == 2 }
        case row_i
        when 0
          case col_j
          when rooks
            @board[pos] = Rook.new(@board, pos, :b)
          when knights
            @board[pos] = Knight.new(@board, pos, :b)
          when bishops
            @board[pos] = Bishop.new(@board, pos, :b)
          when 4
            @board[pos] = King.new(@board, pos, :b)
          when 3
            @board[pos] = Queen.new(@board, pos, :b)
          end
        when 1 # black pawns
          @board[pos] = Pawn.new(@board, pos, :b)
        when 6
          @board[pos] = Pawn.new(@board, pos, :w)
        when 7 # whites
          case col_j
          when rooks
            @board[pos] = Rook.new(@board, pos, :w)
          when knights
            @board[pos] = Knight.new(@board, pos, :w)
          when bishops
            @board[pos] = Bishop.new(@board, pos, :w)
          when 4
            @board[pos] = King.new(@board, pos, :w)
          when 3
            @board[pos] = Queen.new(@board, pos, :w)
          end
        end
      end
    end
  end

end

class Player

  COLORS = {
    :b => "Black",
    :w => "White"
  }

  attr_accessor :color

  def to_s
    COLORS[color]
  end

end

class HumanPlayer < Player

  def initialize
  end

  def get_player_move
    puts "Make your move! For example, type in f2, f3."
    player_input = gets.chomp

    raw_input = player_input.delete(" ").split(",")
    unless raw_input.all?{|coord| coord =~ /^[a-h][1-8]$/ }
      raise ChessError.new("Not valid input!")
    end

    start_pos, end_pos = raw_input.map do |coord|
      [translate_number(coord[1]), translate_letter(coord[0])]
    end

    [start_pos, end_pos]
  end

  def handle_move_response(e)
    puts e.message
  end

  def translate_letter(letter)
    ("a".."h").to_a.index(letter)
  end

  def translate_number(num)
    (num.to_i-8).abs
  end
end
