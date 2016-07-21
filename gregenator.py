import curses
import chess
from gregenator_vis import UI

if __name__ == '__main__':
    board = chess.Board()
    curses.wrapper(UI, board)
