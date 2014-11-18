require './piece.rb'
require './board.rb'

class SteppingPiece < Piece

  def moves
    valid_moves = []
    deltas = move_dirs

    deltas.each do |(dx, dy)|
      new_pos = pos

      new_pos = [new_pos[0] + dx, new_pos[1] + dx]
      break unless Board.in_bounds?(new_pos)

      if board.new_pos.nil?
        valid_moves << new_pos
      elsif board.new_pos.color != self.color
        valid_moves << new_pos
        next
      end
      next if board.new_pos.color == self.color
    end

    valid_moves
  end

end


class Knight < SteppingPiece

  def move_dirs
    [2,1,-1,-2].permutation(2).to_a.uniq
    .reject{ |(x,y)| x.abs == y.abs }
  end

end

class King < SteppingPiece

  def move_dirs
    [-1,1,-1,1].permutation(2).to_a.uniq +
    [[1, 0], [-1, 0], [0, 1], [0, -1]]
  end
end
