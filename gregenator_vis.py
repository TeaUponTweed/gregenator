import curses
from collections import defaultdict
import datetime
import chess
from computer_player import computer_player
import os

def side_select(stdscr):
    try:
        stdscr.addstr("Enter side select string (eg. B(lack):H(uman) W(hite):C(omputer))\n")
        stdscr.refresh()
        colors = []
        players = [None, None]
        side_select_string = stdscr.getstr()
        if side_select_string:
            for sss in side_select_string.split():
                color, player_type = sss.split(':')
                color = color.lower().startswith('w')
                if color in colors:
                    stdscr.addstr('Need different colors!\n')
                    return side_select_string(stdscr)
                colors.append(color)
                if color:
                    index = 0
                else:
                    index = 1
                players[index] = computer_player(color, 6) if player_type.lower().startswith('c') else human_player(color, stdscr)
        else:
            players = [computer_player(True, 6), human_player(False, stdscr)]

        if len(players) != 2:
            stdscr.addstr("Incomplete specification")
            return side_select(stdscr)

        return players
    except:
        stdscr.addstr("Bad format!\n")
        return side_select(stdscr)

def UI(stdscr, board):
    curses.echo()
    curses.mousemask(1)
    curses.init_pair(2, 255, 1)
    curses.init_pair(12, 232, 1)
    curses.init_pair(3, 255, 130)
    curses.init_pair(13, 232, 130)
    curses.init_pair(4, 255, 88)
    curses.init_pair(14, 232, 88)
    curses.init_pair(5, 255, 4)
    curses.init_pair(15, 232, 4)
    p1, p2 = side_select(stdscr)
    draw_board(stdscr, board)
    if not os.path.exists('logs'):
        os.makedirs('logs')
    with open(os.path.join('logs', str(datetime.datetime.now()).replace(' ', '_').replace(':', '-') + '.log'), 'w', 1) as moves_file:
        while not board.is_game_over():
            current_player = p1 if board.turn else p2
            quit = current_player(board)
            moves_file.write('%s\n' % board.peek())
            if quit:
                break
            stdscr.clear()
            draw_board(stdscr, board)
            assert board.is_valid()
        stdscr.addstr(get_results(board.result()))
        _ = stdscr.getch()

def get_results(result):
    if result == '1-0':
        return '\n########\nBLACK WINS\n########\n'
    elif result == '0-1':
        return '\n########\nWHITE WINS\n########\n'
    elif result == '*':
        return '\n########\nINCOMPLETE GAME\n########\n'
    else:
        return '\n########\nDRAW\n########\n'

def human_player(side, stdscr):
    def turn(board):
        legal_moves = defaultdict(list)
        for move in board.legal_moves:
            legal_moves[move.from_square].append(move)

        while  True:
            draw_board(stdscr, board)
            stdscr.addstr(12, 0, 'qqq to quit, zzz to undo\n')
            stdscr.addstr(10, 0, "You're Turn!\n")

            # Highlight last players move
            color_pair = 5
            if not side:
                color_pair += 10

            lastmove = board.peek()
            x = lastmove.to_square%8 * 2
            y = lastmove.to_square//8
            stdscr.chgat(y, x, 1, curses.color_pair(color_pair))
            stdscr.chgat(y, x+1, 1, curses.color_pair(color_pair))

            x = lastmove.from_square%8 * 2
            y = lastmove.from_square//8
            stdscr.chgat(y, x, 1, curses.color_pair(color_pair))
            stdscr.chgat(y, x+1, 1, curses.color_pair(color_pair))
            stdscr.move(11, 0)
            # Get mouse events for player move
            event = stdscr.getch()
            if event == curses.KEY_MOUSE:
                _, mx, my, _, _ = curses.getmouse()
                from_square = mx//2+my*8
                for move in legal_moves[from_square]:
                    x = move.to_square%8 * 2
                    y = move.to_square//8
                    color_pair = 2
                    if not side:
                        color_pair += 10
                    stdscr.chgat(y, x, 1, curses.color_pair(color_pair))
                    stdscr.chgat(y, x+1, 1, curses.color_pair(color_pair))
                stdscr.move(11, 0)
                stdscr.refresh()

                event = stdscr.getch()
                if event == curses.KEY_MOUSE:
                    _, mx, my, _, _ = curses.getmouse()
                    to_square = mx//2 + my*8
                    # logfile.write('To Square %s\n' % (to_square,))
                    for move in legal_moves[from_square]:
                        if move.to_square == to_square:
                            board.push(move)
                            stdscr.clear()
                            draw_board(stdscr, board)
                            return False
            # Quit input tree
            elif event == ord('q'):
                event = stdscr.getch()
                if event == ord('q'):
                    event = stdscr.getch()
                    if event == ord('q'):
                        return True
            # Undo input tree
            elif event == ord('z'):
                event = stdscr.getch()
                if event == ord('z'):
                    event = stdscr.getch()
                    if event == ord('z'):
                        board.pop()
                        board.pop()
                        draw_board(stdscr, board)
                        legal_moves = defaultdict(list)
                        for move in board.legal_moves:
                            legal_moves[move.from_square].append(move)
        return False
    return turn

def draw_board(stdscr, board):
    stdscr.clear()
    dark_square=True
    for i in range(8):
        for j in range(8):
            boardnum = 8*i + j
            piece = board.piece_at(boardnum)
            if piece is not None:
                c = str(piece)
            else:
                c = ' '
            dark_square = not dark_square
            if dark_square:
                color_pair = 3
            else:
                color_pair = 4
            if piece and not piece.color:
                color_pair += 10
            attr = curses.color_pair(color_pair)
            stdscr.addstr(c, attr)
            stdscr.addstr(' ', attr)
        stdscr.addstr('\n')
        dark_square = not dark_square
    stdscr.addstr('\n')
    stdscr.refresh()
