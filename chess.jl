abstract Piece # apparently bad practice see enum in http://docs.julialang.org/en/release-0.4/manual/style-guide/

immutable Empty <: Piece
  side::Bool
end

type Pawn <: Piece
  hasMoved::Bool
  side::Bool
end

type Knight <: Piece
  side::Bool
end

type Bishop <: Piece
  side::Bool
end

type Rook <: Piece
  side::Bool
end

type Queen <: Piece
  side::Bool
end

type King <: Piece
  side::Bool
end


Pawn(x) = Pawn(false, x)
Empty() = Empty(false)

function chess_moves(side, board)
  N = sqrt(length(board))
  for (index, piece) in enumerate(board)
    println(board)
    for move in moves(piece)
      if isValidMove(move..., N)
        println(make_move(board, move))
      end
    end
  end
end

function indexToXY(index, N)
  return index%N, div(index, N)
end


function XYToIndex(x, y, N)
  return N*y + x
end

function movesInDir(board, x, y, dir)
  dx, dy = dir
  xx, yy = x + dx, y+dy
  while inBounds(xx, yy)
    if typeof(board[yy, xx]) == Empty
      produce(xx, yy)
    elseif board[yy, xx].side != board[y, x].side
      produce(xx, yy)
      break
    else
      break
    end
    xx += dx
    yy += dy
  end
end

function diagonalMoves(board, x, y)
  for dir in [(i, j) for i in -1:2:1, j in -1:2:1]
    movesInDir(board, x, y, dir)
  end
end

function cardinalMoves(board, x, y)
  for dir in [(1, 0) (-1, 0) (0, 1) (0, -1)]
    movesInDir(board, x, y, dir)
  end
end

function knightMoves(board, x, y)

end

function inBounds(x, y, N)
  return 0 < x <= N && 0 < y <= N
end

inBounds(x, y) = inBounds(x, y, 8)

function isValidMove(piece, otherPiece::Empty)
  return true
end

function isValidMove(piece::Pawn, otherPiece)
  return typeof(otherPiece) == Empty
end

function isValidMove(piece, otherPiece)
  return piece.side != otherPiece.side
end

function isValidAttack(piece::Pawn, otherPiece::Empty)
  return false
end

function isValidAttack(piece::Pawn, otherPiece)
  return piece.side != otherPiece.side
end

function moves(piece::Knight, board, x, y)
  for couple in [[(i, j) (j, i)] for i in -2:4:2, j in -1:2:1]
    for move in couple
      dx, dy = move
      xx = x + dx
      yy = y + dy
      if inBounds(xx, yy) && isValidMove(piece, board[xx, yy])
        produce(xx, yy)
      end
    end
  end
end

function moves(piece, board, x, y)
  return
end

function moves(piece::Bishop, board, x, y)
  diagonalMoves(board, x, y)
end

function moves(piece::Rook, board, x, y)
  cardinalMoves(board, x, y)
end

function moves(piece::Queen, board, x, y)
  diagonalMoves(board, x, y)
  cardinalMoves(board, x, y)
end

function moves(piece::King, board, x, y)
  for dir in [(i, j) for i in -1:1, j in -1:1]
    dx, dy = dir
    if dx == dy == 0
      continue
    end
    xx = x + dx
    yy = y + dy
    if inBounds(xx, yy) && isValidMove(piece, board[xx, yy])
      produce(xx, yy)
    end
  end
end

function moves(piece::Pawn, board, x, y)
  for dir in piece.hasMoved ? [(1, 0)] : [(1, 0) (2, 0)]
    dy, dx = dir
    if !piece.side
      dy *= -1
    end
    xx = x + dx
    yy = y + dy
    if inBounds(xx, yy) && isValidMove(piece)
      produce(xx, yy)
    end

  for dir in [(1, 1) (1, -1)]
    dy, dx = dir
    if !piece.side
      dy *= -1
    end
    xx = x + dx
    yy = y + dy
    if inBounds(xx, yy) && isValidAttack(piece)
      produce(xx, yy)
    end
  end
end

function display(piece::Empty)
  return ' '
end

function display(piece::Pawn)
  return 'p'
end

function display(piece::Knight)
  return 'n'
end

function display(piece::Bishop)
  return 'b'
end

function display(piece::Rook)
  return 'r'
end

function display(piece::Queen)
  return 'Q'
end

function display(piece::King)
  return 'K'
end

function makeBoard()
  ([
    Rook(true)  Knight(true)  Bishop(true)  King(true)  Queen(true)  Bishop(true)  Knight(true)  Rook(true);
    Pawn(true)  Pawn(true)    Pawn(true)    Pawn(true)  Pawn(true)   Pawn(true)    Pawn(true)    Pawn(true);
    Empty()     Empty()       Empty()       Empty()     Empty()      Empty()       Empty()       Empty();
    Empty()     Empty()       Empty()       Empty()     Empty()      Empty()       Empty()       Empty();
    Empty()     Empty()       Empty()       Empty()     Empty()      Empty()       Empty()       Empty();
    Empty()     Empty()       Empty()       Empty()     Empty()      Empty()       Empty()       Empty();
    Pawn(false) Pawn(false)   Pawn(false)   Pawn(false) Pawn(false)  Pawn(false)   Pawn(false)   Pawn(false);
    Rook(false) Knight(false) Bishop(false) King(false) Queen(false) Bishop(false) Knight(false) Rook(false);
  ])
end

let
  stdscr = ccall( (:initscr, :libncurses), Ptr{Void}, ())
  ccall( (:cbreak, :libncurses), Int32, ())
  ccall( (:noecho, :libncurses), Int32, ())
  ccall( (:keypad, :libncurses), Int32, (Ptr{Void}, Bool), stdscr, true)
  ccall( (:start_color, :libncurses), Int32, ())
  # ccall((:resizeterm, :libncurses), Int32, (Int32, Int32), 8*2, 8*2)  

  ccall((:init_pair, :libncurses), Int32, (Int16, Int16, Int16), 1, 0, 3)
  ccall((:init_pair, :libncurses), Int32, (Int16, Int16, Int16), 2, 0, 11)
  ccall((:init_pair, :libncurses), Int32, (Int16, Int16, Int16), 3, 15, 3)
  ccall((:init_pair, :libncurses), Int32, (Int16, Int16, Int16), 4, 15, 11)

  blackOnBlack = ccall((:COLOR_PAIR, :libncurses), Int32, (Int32, ), 1)
  blackOnWhite = ccall((:COLOR_PAIR, :libncurses), Int32, (Int32, ), 2)
  whiteOnBlack = ccall((:COLOR_PAIR, :libncurses), Int32, (Int32, ), 3)
  whiteOnWhite = ccall((:COLOR_PAIR, :libncurses), Int32, (Int32, ), 4)

  function drawSubsetWithColor(board, color_pair, criteria)
    ccall((:attron, :libncurses), Int32, (Int32,), color_pair)
    for row in 1:8
      for col in 1:8
        if criteria(board, row, col)
          ccall((:wmove, :libncurses), Int32, (Ptr{Void}, Int32, Int32,), stdscr, row, col*2)
          ccall((:waddch, :libncurses), Int32, (Ptr{Void}, UInt8,), stdscr, display(board[row, col]))
          ccall((:wmove, :libncurses), Int32, (Ptr{Void}, Int32, Int32,), stdscr, row, col*2+1)
          ccall((:waddch, :libncurses), Int32, (Ptr{Void}, UInt8,), stdscr, ' ')
        end
      end
    end
    ccall((:attroff, :libncurses), Int32, (Int32,), color_pair)  
  end

  global drawChessBoard
  function drawChessBoard(board)
    ccall((:clear, :libncurses), Int32, ())
    
    drawSubsetWithColor(board, blackOnBlack, (b, r, c) -> (r % 2) != (c%2) && !b[r, c].side)
    ccall((:refresh, :libncurses), Int32, ())
    
    drawSubsetWithColor(board, blackOnWhite, (b, r, c) -> (r % 2) == (c%2) && !b[r, c].side)
    ccall((:refresh, :libncurses), Int32, ())
    
    drawSubsetWithColor(board, whiteOnBlack, (b, r, c) -> (r % 2) != (c%2) &&  b[r, c].side)
    ccall((:refresh, :libncurses), Int32, ())
    
    drawSubsetWithColor(board, whiteOnWhite, (b, r, c) -> (r % 2) == (c%2) &&  b[r, c].side)
    ccall((:wmove, :libncurses), Int32, (Ptr{Void}, Int32, Int32,), stdscr, 0, 0)
    ccall((:refresh, :libncurses), Int32, ())
  end
end

# println()
# tb = transpose([
  # Empty() Empty() Empty() Empty() Empty() Empty() Empty() Empty();
  # Empty() Empty() Empty() Empty() Empty() Empty() Empty() Empty();
  # Empty() Empty() Empty() Knight(false) Empty() Empty() Empty() Empty();
  # Empty() Empty() Empty() Empty() Empty() Empty() Empty() Empty();
  # Empty() Empty() Empty() Empty() Empty() Empty() Empty() Empty();
  # Empty() Empty() Empty() Empty() Empty() Empty() Empty() Empty();
  # Empty() Empty() Empty() Empty() Empty() Empty() Empty() Empty();
  # Empty() Empty() Empty() Empty() Empty() Empty() Empty() Empty();
# ])

try
  drawChessBoard(makeBoard())
  sleep(20)
finally
  ccall((:endwin, :libncurses), Int32, ())
end
