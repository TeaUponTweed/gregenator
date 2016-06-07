import random
import copy
from pprint import pprint
from collections import defaultdict

def has_won(board, side):
    # for i in xrange(3):
    if any(all(board[3*i + j] == side for j in xrange(3)) for i in xrange(3)):
        return True
    if any(all(board[i + 3*j] == side for j in xrange(3)) for i in xrange(3)):
        return True
    if all(board[4*i] == side for i in xrange(3)):
        return True
    if all(board[2 + 2*i] == side for i in xrange(3)):
        return True
    return False

winning_configurations = {
    1: set([
           (1, 0, 0,
            1, 0, 0,
            1, 0, 0,),

           (0, 1, 0,
            0, 1, 0,
            0, 1, 0,),

           (0, 0, 1,
            0, 0, 1,
            0, 0, 1,),

           (1, 1, 1,
            0, 0, 0,
            0, 0, 0,),

           (0, 0, 0,
            1, 1, 1,
            0, 0, 0,),

           (0, 0, 0,
            0, 0, 0,
            1, 1, 1,),

           (1, 0, 0,
            0, 1, 0,
            0, 0, 1,),

           (0, 0, 1,
            0, 1, 0,
            1, 0, 0,),
        ]),
    -1: set([
           (-1, 0, 0,
            -1, 0, 0,
            -1, 0, 0,),

           (0, -1, 0,
            0, -1, 0,
            0, -1, 0,),

           (0, 0, -1,
            0, 0, -1,
            0, 0, -1,),

           (-1, -1, -1,
            0, 0, 0,
            0, 0, 0,),

           (0, 0, 0,
            -1, -1, -1,
            0, 0, 0,),

           (0, 0, 0,
            0, 0, 0,
            -1, -1, -1,),

           (-1, 0, 0,
            0, -1, 0,
            0, 0, -1,),

           (0, 0, -1,
            0, -1, 0,
            -1, 0, 0,),
        ])
}
def board_configs(board = []):
    if len(board) < 9:
        for val in (-1, 0, 1):
            for b in board_configs(board+[val]):
                yield b
    else:
        yield board



def gen_moves(board, side):
    for i, space in enumerate(board):
        if space == 0:
            board[i] = side
            yield copy.copy(board)
            board[i] = 0

# def game_over(board):
#     # print board
#
#         if tuple(board) in boards:
#             return winner
#     if 0 not in set(board):
#         return 'CATS'
#     return False

def print_board(board):
    # print '%s %s %s\n%s %s %s\n%s %s %s' % board
    for i, el in enumerate(board):
        if i % 3 == 0:
            print
        if el == 1:
            print 'X ',
        elif el == -1:
            print 'O ',
        else:
            print '. ',
    print
# board = [0/]*9
# side = 1
#

def apply(board, *trans):
    total_trans = range(len(board))
    for t in trans:
        total_trans = [total_trans[i] for i in t]
    return tuple(board[i] for i in total_trans)

def square_symmetries():
    horizontal = [2, 1, 0, 5, 4, 3, 8, 7, 6]
    diagonal = [0, 3, 6, 1, 4, 7, 2, 5, 8]
    all_tranforms = [horizontal, diagonal]*4
    def f(board):
        for t in all_tranforms:
            board = apply(board, t)
            yield board
    return f

# ss = square_symmetries()
# board = range(9)
# board = [1, 1, 1, 0, 1, 1, 0, 0, 0]
# for b in ss(board):
    # print_board(b)

class RLPlayer:
    def __init__(self, side, alpha, value_table={}, verbose=False):
        self.side = side
        self.alpha = alpha
        self.vtable = value_table
        # self.s_t, v_t = None, None
        self.prevstate, self.prevscore = None, None
        # self.s_t = Nones
        # self.prob_s_tpp = None
        # self.ss = square_symmetries()
        self.verbose = verbose

    def _get_state_value(self, state):
        key = tuple(state)
        try:
            return self.vtable[key]
        except KeyError:
            self.vtable[key] = 0
            return self.vtable[key]
        # if key not in self.vtable:
        #     if has_won(state, self.side):
        #         self.vtable[key] = 1
        #     elif 0 not in state:
        #         self.vtable[key] = 0
        #     # elif has_won(state, -1*self.side):
        #         # self.vtable[key] = -1
        #     else:
        #         self.vtable[key] = .5
        # for b in self.ss(map(lambda x: x*-1, board)):
        #     try:
        #         return b, self.vtable[b]
        #     except KeyError:
        #         blast = b
    def _greedy_move(self, state):
        # print 'greedy move'
        # nextstate, maxval = None, float('-inf')
        # for b in gen_moves(state, self.side):
        #     _, v = self._get_state_value(b)
        #     # print v
        #     # print_board(_)
        #     # print
        #     if v > maxval:
        #         nextstate, maxval = b, v
        maxval, nextstate = max((self._get_state_value(b), b) for b in gen_moves(state, self.side))
        self._backup(maxval)
        # print 'max value'
        # print maxval
        # print_board(nextstate)
        # print '='*80
        return nextstate, maxval

    def _exploratory_move(self, state):
        s = random.choice(list(gen_moves(state, self.side)))
        v = self._get_state_value(s)
        return s, v

    def _backup(self, nextval):
        if self.prevstate is not None:
            self.vtable[tuple(self.prevstate)] += self.alpha * (nextval - self.prevscore)

    def move(self, state, epsilon):
        if random.random() < epsilon:
            self.prevstate, self.prevscore = self._exploratory_move(state)
        else:
            self.prevstate, self.prevscore = self._greedy_move(state)
        return self.prevstate


    # def make_move(self, board, epsilon=.1):
    #     self.s_t = board
    #     if random.random() < epsilon:
    #         self.prob_s_tpp = epsilon
    #         boards = list(gen_moves(board, self.side))
    #         if self.verbose: print 'random move'
    #     else:
    #         self.prob_s_tpp = 1 - epsilon
    #         values = defaultdict(list)
    #         for b in gen_moves(board, self.side):
    #             _, v = self._get_state_value(b)
    #             values[v].append(b)
    #         self.v_t, boards = max(values.iteritems())
    #         if self.verbose:
    #             print 'greedy move'
    #             print boards
    #             pprint(dict(values))
    #
    #     self.prob_s_tpp /= len(boards)
    #     next_board = random.choice(boards)
    #     return next_board

    # def update(self, r_tpp, s_tpp, alpha=.1):
    #     s_t, v_t = self._get_state_value(self.s_t)
    #     _, v_tpp = self._get_state_value(s_tpp)
    #     # s_t = tuple(map(lambda x: x*self.side, self.previous_board))
    #     # s_tpp = tuple(map(lambda x: x*self.side, s_tpp))
    #     self.vtable[s_t] += alpha*(r_tpp + self.gamma*v_tpp - v_t)

p1 = RLPlayer(1, .1)
p2 = RLPlayer(-1, .1)

def train(p1, p2, n, verobse, epsilon):
    for i in xrange(n):
        board = [0]*9
        p1.prevstate, p1.prevscore = None, None
        p2.prevstate, p2.prevscore = None, None
        while True:
            board = p1.move(board, epsilon)
            if verobse: print_board(board)
            if has_won(board, p1.side):
                p2._backup(-1)
                p1._backup(1)
                # p1.update(1, board)
                # p2.update(-1, board)
                break
            if 0 not in board:
                p2._backup(-1)
                p2._backup(0)
                p1._backup(0)
                break
            # p1._backup(0, board)
            board = p2.move(board, epsilon)
            if verobse: print_board(board)
            if has_won(board, p2.side):
                # p2._backup(1, board)
                p1._backup(-1)
                p2._backup(1)
                break
            if 0 not in board:
                p2._backup(0)
                p1._backup(0)
                break
            # p2.update(0, board)
        if verobse: print '='*80

train(p1, p2, 60000, False, .1)
p1.verbose = True
p2.verbose = True
train(p1, p2, 10, True, 0)
#
# while not has_won(board, -1*side):
#     try:
#         board = random.choice(list(gen_moves(board, side)))
#     except IndexError:
#         print 'CATS GAME'
#         break
#     side *= -1
#     print_board(board)

# use covultutional neural network to create a flow field that interacts
# with simplistic local AI to guide them toward destinations

# for b in gen_moves([0]*9, 1):
    # print b
# print list(gen_moves([0]*9, 1))
# for b in board_configs():
#      if tuple(b) in winning_configurations[-1]:
#          print b
#          print has_won(b, 1)
#          print '='*80
#      else:
#          assert not has_won(b, 1), '%s' %  b
# for b in board_configs():
#     if has_won(b, 1):
#         print_board(b)
