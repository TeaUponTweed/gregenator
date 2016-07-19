import curses
from collections import defaultdict

def side_select(stdscr):
    try:
        from gregenator import computer_player
        stdscr.addstr("Enter side select string (eg. B(lack):H(uman) W(hite):C(omputer))\n")
        stdscr.refresh()
        colors = []
        players = []
        side_select_string = stdscr.getstr()
        if side_select_string:
            for sss in side_select_string.split():
                color, player_type = sss.split(':')
                color = color.lower().startswith('w')
                if color in colors:
                    stdscr.addstr('Need different colors!\n')
                    return side_select_string(stdscr)
                colors.append(color)
                players.append(computer_player(color, 5) if player_type.lower().startswith('c') else human_player(color, stdscr))
        else:
            players = [computer_player(True, 5), human_player(False, stdscr)]

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
    p1, p2 = side_select(stdscr)
    draw_board(stdscr, board)

    while not board.is_game_over():
        current_player = p1 if board.turn else p2
        quit = current_player(board)
        if quit:
            break
        stdscr.clear()
        draw_board(stdscr, board)
        assert board.is_valid()
    stdscr.addstr(get_results(board))
    _ = stdscr.getch()

def get_results(result):
    if result == '1-0':
        return '\n########\nBLACK WINS\n########'
    elif result == '0-1':
        return '\n########\nWHITE WINS\n########'
    elif result == '*':
        return '\n########\nINCOMPLETE GAME\n########'
    else:
        return '\n########\nDRAW\n########'

def human_player(side, stdscr):
    def turn(board):
        legal_moves = defaultdict(list)
        for move in board.legal_moves:
            legal_moves[move.from_square].append(move)
        while  True:
                # logfile.write('From Square %s\n' % (move.from_square,))
            # logfile.write('==========\n')

            event = stdscr.getch()
            if event == curses.KEY_MOUSE:
                _, mx, my, _, _ = curses.getmouse()
                # logfile.write('%s %s\n' % (mx, my))
                stdscr.clear()
                draw_board(stdscr, board)
                from_square = mx//2+my*8
                for move in legal_moves[from_square]:
                    # logfile.write('From Square %s\n' % (move.from_square,))
                    # logfile.write('To Square %s\n' % (move.to_square,))
                    x = move.to_square%8 * 2
                    y = move.to_square//8
                    # logfile.write('%s %s\n' % (x, y))
                    color_pair = 2
                    if not side:
                        color_pair += 10
                    stdscr.chgat(y, x, 1, curses.color_pair(color_pair))
                    stdscr.chgat(y, x+1, 1, curses.color_pair(color_pair))
                curses.setsyx(10,1)
                stdscr.refresh()

                event = stdscr.getch()
                curses.setsyx(10,1)
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

            elif event == ord('q'):
                event = stdscr.getch()
                if event == ord('q'):
                    event = stdscr.getch()
                    if event == ord('q'):
                        return True

            elif event == ord('z'):
                event = stdscr.getch()
                if event == ord('z'):
                    event = stdscr.getch()
                    if event == ord('z'):
                        board.pop()
                        board.pop()
                        legal_moves = defaultdict(list)
                        for move in board.legal_moves:
                            legal_moves[move.from_square].append(move)
        return False
    return turn

def draw_board(stdscr, board):
    dark_square=True
    for i in xrange(8):
        for j in xrange(8):
            boardnum = 8*i + j
            piece = board.piece_at(boardnum)
            if piece is not None:
                c = str(piece)
                # c = piece.unicode_symbol(piece.color).encode("utf-8")
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
    stdscr.addstr('qqq to quit, zzz to undo\n')
    curses.setsyx(10,1)
    stdscr.refresh()


if __name__ == '__main__':
    curses.wrapper(main)
