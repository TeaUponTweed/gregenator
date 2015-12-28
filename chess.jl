abstract Piece # apparently bad practice see enum in http://docs.julialang.org/en/release-0.4/manual/style-guide/

immutable Empty <: Piece
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
  print(". ")
end

function display(piece::Pawn)
  print("p ")
end

function display(piece::Knight)
  print("k ")
end

function display(piece::Bishop)
  print("b ")
end

function display(piece::Rook)
  print("r ")
end

function display(piece::Queen)
  print("Q ")
end

function display(piece::King)
  print("K ")
end

function makeBoard()
  transpose([
    Rook(true)  Bishop(true)  Knight(true)  King(true)  Queen(true)  Knight(true)  Bishop(true)  Rook(true);
    Pawn(true)  Pawn(true)    Pawn(true)    Pawn(true)  Pawn(true)   Pawn(true)    Pawn(true)    Pawn(true);
    Empty()     Empty()       Empty()       Empty()     Empty()      Empty()       Empty()       Empty();
    Empty()     Empty()       Empty()       Empty()     Empty()      Empty()       Empty()       Empty();
    Empty()     Empty()       Empty()       Empty()     Empty()      Empty()       Empty()       Empty();
    Empty()     Empty()       Empty()       Empty()     Empty()      Empty()       Empty()       Empty();
    Pawn(false) Pawn(false)   Pawn(false)   Pawn(false) Pawn(false)  Pawn(false)   Pawn(false)   Pawn(false);
    Rook(false) Bishop(false) Knight(false) King(false) Queen(false) Knight(false) Bishop(false) Rook(false);
  ])
end

function drawBoard(board)
  N = sqrt(length(board))
  println(N)
  for (index, piece) in enumerate(board)
    display(piece)
    if index % N == 0
      println()
    end
  end
end

drawBoard(makeBoard())
println()
tb = transpose([
  Empty() Empty() Empty() Empty() Empty() Empty() Empty() Empty();
  Empty() Empty() Empty() Empty() Empty() Empty() Empty() Empty();
  Empty() Empty() Empty() Knight(false) Empty() Empty() Empty() Empty();
  Empty() Empty() Empty() Empty() Empty() Empty() Empty() Empty();
  Empty() Empty() Empty() Empty() Empty() Empty() Empty() Empty();
  Empty() Empty() Empty() Empty() Empty() Empty() Empty() Empty();
  Empty() Empty() Empty() Empty() Empty() Empty() Empty() Empty();
  Empty() Empty() Empty() Empty() Empty() Empty() Empty() Empty();
])
drawBoard(tb)
