import chess
import random
import computer_player
import functools

def negamax(board, depth, board_eval):
        if depth == 0:
            return board_eval(board)

        max_score = float('-inf')

        for move in board.pseudo_legal_moves:
            board.push(move)
            score = -negamax(board, depth - 1, board_eval)
            board.pop()
            if score > max_score:
                max_score = score
        return max_score

def negamaxalphabeta(board, depth, alpha, beta, board_eval):
        if depth == 0:
            return board_eval(board)

        for move in board.pseudo_legal_moves:
            board.push(move)
            score = -negamaxalphabeta(board, depth-1, -beta, -alpha, board_eval)
            board.pop()
            if score >= beta:
                return beta
            if score > alpha:
                alpha = score
        return alpha
if __name__ == '__main__':
    board = chess.Board()
    while not board.is_game_over():
        for depth in [1, 2, 3]:
            board_eval = functools.partial(computer_player.eval_board, color=board.turn)
            assert (negamax(board, depth, board_eval) ==
                    negamaxalphabeta(board, depth, float('-inf'), float('inf'), board_eval))
            
        board.push(random.choice(list(board.legal_moves)))
        print(board)
