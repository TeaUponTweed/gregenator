import random
import chess
import curses
import locale; locale.setlocale(locale.LC_ALL, '')
import functools
import itertools as it
import sys
import gmpy2
import time
import copy
logfile = open('_', 'w', 1)

def eval_board(board, gameover=False):
    white_mask = board.occupied_co[chess.WHITE]
    black_mask = board.occupied_co[chess.BLACK]
    material = ((gmpy2.popcount((board.pawns   & white_mask)) - gmpy2.popcount((board.pawns   & black_mask)))*1 +
                (gmpy2.popcount((board.knights & white_mask)) - gmpy2.popcount((board.knights & black_mask)))*3 +
                (gmpy2.popcount((board.bishops & white_mask)) - gmpy2.popcount((board.bishops & black_mask)))*3 +
                (gmpy2.popcount((board.rooks   & white_mask)) - gmpy2.popcount((board.rooks   & black_mask)))*5 +
                (gmpy2.popcount((board.queens  & white_mask)) - gmpy2.popcount((board.queens  & black_mask)))*9 +
                (gmpy2.popcount((board.kings   & white_mask)) - gmpy2.popcount((board.kings   & black_mask)))*1000)

    if gameover or abs(material) >= 9 or (gmpy2.popcount(white_mask) + gmpy2.popcount(black_mask)) < 9:
        if board.is_checkmate() and board.turn:
            return -10000
        elif board.is_checkmate() and not board.turn:
            return 10000

    return material


class OuttaTime(Exception): pass


def negamaxalphabeta(board, depth, alpha, beta, color, starttime=None, maxtime=30):
        if starttime is not None:
            if time.time() > starttime + maxtime:
                raise OuttaTime('Ran out of time')

        if depth == 0:
            return color * eval_board(board)
        for move in board.pseudo_legal_moves:
            board.push(move)
            score = -negamaxalphabeta(board, depth-1, alpha, beta, -color, starttime)
            board.pop()
            if score >= beta:
                return beta
            if score > alpha:
                alpha = score
        return alpha


def branch_first(board, depth, color, starttime):
    alpha = float('-inf')
    beta = float('inf')
    for move in sorted(board.legal_moves, key = lambda x: iscapture(board, x), reverse=True):
        board.push(move)
        val = -negamaxalphabeta(board, depth-1, -beta, -alpha, -color, starttime)
        board.pop()
        if val > alpha:
            alpha = val
            bestmoves = [move]
        elif val == alpha:
            bestmoves.append(move)
    return bestmoves


def computer_player(maximizing_player, look_ahead=[2, 4, 5, 6, 8]):
    if maximizing_player:
        color = 1
    else:
        color = -1

    def f(board):
        bestmoves = list(board.legal_moves)
        starttime = time.time()
        for depth in look_ahead:
            try:
                bestmoves = branch_first(copy.deepcopy(board), depth, color, starttime)
                logfile.write('Got to depth %s in %ss\n' % (depth, time.time()-starttime))
            except OuttaTime:
                logfile.write('Couldn\'t do depth %s\n' % depth)
                break
        logfile.write('#'*80 + '\n')

        assert len(bestmoves) > 0
        random.shuffle(bestmoves)
        for criteria in [lambda x: board.is_castling(x),
                         lambda x: (x.from_square in range(16) and x.to_square not in range(16) or
                                    x.from_square in range(48, 64) and not x.to_square in range(48,64)),
                         lambda x: not (board.piece_at(x.from_square).piece_type == chess.KING),
                         lambda x: True]:
            filtered_bestmoves = filter(criteria, bestmoves)
            try:
                move = next(iter(filtered_bestmoves))
                board.push(move)
                return False
            except StopIteration:
                pass
    return f


def iscapture(board, move):
    return board.is_capture(move)
