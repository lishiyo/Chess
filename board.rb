class Board

  attr_accessor :grid

  def initialize
    @grid = self.class.create_board
  end

  def self.in_bounds?(pos)
    x, y = pos[0], pos[1]
    x.between?(0, 7) && y.between?(0, 7)
  end

  def [](pos)
    @grid[pos[0]][pos[1]]
  end

  def []=(pos, mark)
    @grid[pos[0]][pos[1]] = mark
  end

  def delete(pos)
    self[pos] = nil
  end

  # find position of king, see if any enemy piece can move there
  def in_check?(color)

    enemy_pieces = pieces.select {|piece| piece.color != color }

    enemy_pieces.any? do |piece|
      piece.moves.include?(my_king.pos)
    end
  end

  # king's list of valid moves is zero!
  def checkmate?(color)
    in_check?(color) && pieces.select { |piece| piece.color == color }
      .all? { |piece| piece.valid_moves.empty? }
  end

  def my_king
    pieces.detect do |piece|
      piece.class == King && piece.color == color
    end
  end

  # updates the @grid and also the moved piece's position
  # raise Exception if there is no piece at start_pos,
  # or if end_pos is not in piece's valid moves
  def move!(start_pos, end_pos)
    raise InvalidMove if self[start_pos].nil? ||
      !self[start_pos].moves.include?(end_pos)

    # delete piece at end_pos if it exists
    self.delete(end_pos) if self[end_pos]

    # move starting piece to end_pos
    self[end_pos] = self[start_pos]
    self[start_pos] = nil
    self[end_pos].pos = end_pos #updates piece's internal pos
  end

  def move(start_pos, end_pos)
    raise DangerOfCheck unless self[start_pos] &&
      self[start_pos].valid_moves.include?(end_pos)

    move!(start_pos, end_pos)
  end

  def inspect
    @grid.each do |row|
      p row.map { |el| [el.class, el.color] if el }
    end
  end

  def pieces
    @grid.flatten.reject{ |square| square.nil? }
  end

  def dup
    dup_board = Board.new

    @grid.each_with_index do |row, row_idx|
      dup_board.grid[row_idx] = row.map do |piece|
        unless piece.nil?
          piece.class.new(dup_board, piece.pos, piece.color)
        end
      end
    end

    dup_board
  end

  protected

  def self.create_board
    Array.new(8) { Array.new(8, nil) }
  end


end
