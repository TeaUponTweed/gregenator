abstract Piece # apparently bad practice see enum in http://docs.julialang.org/en/release-0.4/manual/style-guide/

immutable Empty <: Piece
  side::Int
end

type Pawn <: Piece
  hasMoved::Bool
  side::Int
end

type Knight <: Piece
  side::Int
end

type Bishop <: Piece
  side::Int
end

type Rook <: Piece
  side::Int
end

type Queen <: Piece
  side::Int
end

type King <: Piece
  side::Int
end


Pawn(x) = Pawn(false, x)
Empty() = Empty(0)

function chess_moves(side, board)
  N = sqrt(length(board))
  for (index, piece) in enumerate(board)
    println(board)
    x, y = indexToXY(index)
    if piece.side == side
      for move in moves(piece, board, x, y)
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
  while inBounds(xx, yy) && board[y, x].side != board[yy, xx].side
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

function moves(piece::Knight, board, x, y)
  for couple in [[(i, j) (j, i)] for i in -2:4:2, j in -1:2:1]
    for move in couple
      dx, dy = move
      xx = x + dx
      yy = y + dy
      if inBounds(xx, yy) && piece.side != board[yy, xx].side
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
    if inBounds(xx, yy) && piece.side != board[yy, xx].side
      produce(xx, yy)
    end
  end
end

function moves(piece::Pawn, board, x, y)
  dy = piece.side
  dx = 0
  xx = x + dx
  yy = y + dy
  if inBounds(xx, yy) && typeof(board[yy, xx]) == Empty
    produce(xx, yy)
    if inBounds(xx, yy+dy) && typeof(board[yy+dy, xx]) == Empty && !piece.hasMoved
      produce(xx, yy+dy)
    end
  end
  for dx in -1:2:1
    if inBounds(x + dx, yy) && piece.side != board[yy, x+dx].side && typeof(board[yy, x+dx]) != Empty
      produce(x+dx, yy)
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
    Rook(1)     Knight(1)     Bishop(1)     King(1)     Queen(1)     Bishop(1)     Knight(1)     Rook(1);
    Pawn(1)     Pawn(1)       Pawn(1)       Pawn(1)     Pawn(1)      Pawn(1)       Pawn(1)       Pawn(1);
    Empty()     Empty()       Empty()       Empty()     Empty()      Empty()       Empty()       Empty();
    Empty()     Empty()       Empty()       Empty()     Empty()      Empty()       Empty()       Empty();
    Empty()     Empty()       Empty()       Empty()     Empty()      Empty()       Empty()       Empty();
    Empty()     Empty()       Empty()       Empty()     Empty()      Empty()       Empty()       Empty();
    Pawn(-1)    Pawn(-1)      Pawn(-1)      Pawn(-1)    Pawn(-1)     Pawn(-1)      Pawn(-1)      Pawn(-1);
    Rook(-1)    Knight(-1)    Bishop(-1)    King(-1)    Queen(-1)    Bishop(-1)    Knight(-1)    Rook(-1);
  ])
end

function getCursesDisplay()
  global stdscr = ccall( (:initscr, :libncurses), Ptr{Void}, ())

  ccall( (:cbreak, :libncurses), Int32, ())
  ccall( (:noecho, :libncurses), Int32, ())
  ccall( (:keypad, :libncurses), Int32, (Ptr{Void}, Bool), stdscr, true)
  ccall( (:start_color, :libncurses), Int32, ())
  # ccall((:resizeterm, :libncurses), Int32, (Int32, Int32), 8*2, 8*2)

  ccall((:init_pair, :libncurses), Int32, (Int16, Int16, Int16), 1, 0, 3)
  ccall((:init_pair, :libncurses), Int32, (Int16, Int16, Int16), 2, 0, 11)
  ccall((:init_pair, :libncurses), Int32, (Int16, Int16, Int16), 3, 15, 3)
  ccall((:init_pair, :libncurses), Int32, (Int16, Int16, Int16), 4, 15, 11)
  ccall((:init_pair, :libncurses), Int32, (Int16, Int16, Int16), 5, 0, 1)
  ccall((:init_pair, :libncurses), Int32, (Int16, Int16, Int16), 6, 15, 1)

  blackOnBlack = ccall((:COLOR_PAIR, :libncurses), Int32, (Int32, ), 1)
  blackOnWhite = ccall((:COLOR_PAIR, :libncurses), Int32, (Int32, ), 2)
  whiteOnBlack = ccall((:COLOR_PAIR, :libncurses), Int32, (Int32, ), 3)
  whiteOnWhite = ccall((:COLOR_PAIR, :libncurses), Int32, (Int32, ), 4)
  whiteOnRed = ccall((:COLOR_PAIR, :libncurses), Int32, (Int32, ), 5)
  blackOnRed = ccall((:COLOR_PAIR, :libncurses), Int32, (Int32, ), 6)

  oldMask = UInt32(0)
  global KEY_MOUSE = 409#unsafe_load(cglobal((:KEY_MOUSE, :libncurses), UInt8))
  BUTTON1_PRESSED = 2#unsafe_load(cglobal((:BUTTON1_PRESSED, :libncurses), UInt32))
  BUTTON2_PRESSED = 128#unsafe_load(cglobal((:BUTTON2_PRESSED, :libncurses), UInt32))
  # board = makeBoard()
  # drawChessBoard(board)
  ccall((:mousemask, :libncurses), Int32, (UInt32, Ptr{UInt32}),
         BUTTON1_PRESSED,
         Ref(oldMask))
  function drawSubsetWithColor(board, color_pair, criteria)
    ccall((:attron, :libncurses), Int32, (Int32,), color_pair)
    for row in 1:8
      for col in 1:8
        if criteria(board, row, col)
          ccall((:wmove, :libncurses), Int32, (Ptr{Void}, Int32, Int32,), stdscr, row-1, col*2-2)
          ccall((:waddch, :libncurses), Int32, (Ptr{Void}, UInt8,), stdscr, display(board[row, col]))
          ccall((:wmove, :libncurses), Int32, (Ptr{Void}, Int32, Int32,), stdscr, row-1, col*2+1-2)
          ccall((:waddch, :libncurses), Int32, (Ptr{Void}, UInt8,), stdscr, ' ')
        end
      end
    end
    ccall((:attroff, :libncurses), Int32, (Int32,), color_pair)
  end

  function drawChessBoard(board, highlight...)
    ccall((:clear, :libncurses), Int32, ())

    drawSubsetWithColor(board, blackOnBlack, (b, r, c) -> (r%2) != (c%2) && b[r, c].side == -1 && !((c, r) in highlight))
    ccall((:refresh, :libncurses), Int32, ())

    drawSubsetWithColor(board, blackOnWhite, (b, r, c) -> (r%2) == (c%2) && b[r, c].side == -1 && !((c, r) in highlight))
    ccall((:refresh, :libncurses), Int32, ())

    drawSubsetWithColor(board, whiteOnBlack, (b, r, c) -> (r%2) != (c%2) &&  b[r, c].side >= 0 && !((c, r) in highlight))
    ccall((:refresh, :libncurses), Int32, ())

    drawSubsetWithColor(board, whiteOnWhite, (b, r, c) -> (r%2) == (c%2) &&  b[r, c].side >= 0 && !((c, r) in highlight))
    ccall((:refresh, :libncurses), Int32, ())

    drawSubsetWithColor(board, whiteOnRed, (b, r, c) -> b[r, c].side >= 0 && ((c, r) in highlight))
    ccall((:refresh, :libncurses), Int32, ())

    drawSubsetWithColor(board, blackOnRed, (b, r, c) -> b[r, c].side == -1 && ((c, r) in highlight))
    ccall((:refresh, :libncurses), Int32, ())

    ccall((:wmove, :libncurses), Int32, (Ptr{Void}, Int32, Int32,), stdscr, 20, 20)
    ccall((:refresh, :libncurses), Int32, ())
  end
  return drawChessBoard;
end

type MEVENT
  id::Int16
  x::Int32
  y::Int32
  z::Int32
  mmask_t::UInt32
end

MEVENT() = MEVENT(0, 0, 0, 0, 0)
wakka = []
function humanTurn(board, side)
  mevent = MEVENT()
  selectedX, selectedY = nothing, nothing
  validMoves = []
  while true
    ch = ccall((:getch, :libncurses), Int32, ())
    if ch == KEY_MOUSE
      ccall((:getmouse, :libncurses), Int32, (Ptr{MEVENT}, ), Ref(mevent))
      if 0 <= mevent.x < 16 && 0 <= mevent.y < 8
        y = mevent.y + 1
        x = div(mevent.x, 2) + 1
        if (x, y) in validMoves
          board[y, x], board[selectedY, selectedX] = board[selectedY, selectedX], Empty()
          drawBoard(board)
          selectedX, selectedY, validMoves = nothing, nothing, []
        elseif board[y, x].side == side
          validMoves = collect(Task(()-> moves(board[y, x], board, x, y)))
          # global wakka = validMoves
          selectedX, selectedY = x, y
          drawBoard(board, validMoves...)
        else
          # global wakka ="dumb"
          selectedX, selectedY, validMoves = nothing, nothing, []
          drawBoard(board)
        end
      else
        break
      end
    end
  end
end

game_over = false;
drawBoard = getCursesDisplay();
# players = [humanTurn(-1) humanTurn(1)]
try
# while not game_over
  global board = makeBoard();
  drawBoard(board);
  humanTurn(board, 1);
# end
finally
    ccall( (:keypad, :libncurses), Int32, (Ptr{Void}, Bool), stdscr, false)
    ccall((:endwin, :libncurses), Int32, ())
end
println(wakka)

# board = [
#   Empty() Pawn(1) Empty() Empty() Empty() Empty() Empty() Empty();
#   Bishop(-1) Pawn(1) Knight(-1) Empty() Empty() Empty() Empty() Empty();
#   Empty() Empty() Knight(1) Empty() Empty() Empty() Empty() Empty();
#   Empty() Empty() Empty() Empty() Empty() Empty() Empty() Knight(1);
#   Empty() Pawn(true, -1) Empty() Empty() Empty() Empty() Empty() Empty();
#   Empty() Empty() Rook(-1) Empty() Empty() Bishop(-1) Empty() Empty();
#   Pawn(1) Empty() Pawn(-1) Empty() Empty() Empty() King(1) Empty();
#   Empty() Pawn(-1) Empty() Empty() Empty() Empty() Empty() Empty();
# ]
# for start in [(3, 3) (6, 6) (3, 6) (8, 4) (2, 1) (2, 8) (2, 5) (7, 7)]
for start in [(1, 1)]
  println(start)
  x, y = start
  test = zeros(Int, 8, 8)
  for (col, row) in Task(()-> moves(board[y, x], board, x, y))
    test[row, col] = 1
  end
  println(test)
end
# mevent = MEVENT()
# try
#
# finally

# end
