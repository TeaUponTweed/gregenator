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

function isValidMove(x, y, N)
  return 0 < x <= N && 0 < y <= N
end

function isValidMove(index, N)
  return 0 < index <= N
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
