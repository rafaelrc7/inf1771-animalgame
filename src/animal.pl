:- dynamic kb/1.

% Clears current tree and loads KB from 'animalsgame.kb' if it exists.
% Otherwise, load the default one from 'animalsgameinit.kb'.
load_kb :- retractall(kb(_))
			, (exists_file('animalsgame.kb') , consult('animalsgame.kb'))
				; consult('animalsgameinit.kb').

% Asks player if he wants to save the KB to a file.
save_kb :- query_yn("Do you want to save?" , IN)
			, ((IN = 'n' , true)
				; (IN = 'y' , tell('animalsgame.kb') , listing(kb) , told))
				; save_kb.

% Runs game, starting with the first node question.
start :- load_kb , play , !.

% Game loop, runs until player chooses to exit.
play :- kb(T)
		, ask_node(T, TN)
		, (TN \= void -> retractall(kb(_)) , assert(kb(TN)) ; true)
		, query_yn("Do you want to play again?", IN)
		, ((IN = 'y' , nl , play)
			; (IN = 'n' , save_kb , format("~nThanks for playing!~n"))).

qInsert(a(A), AN, Q, ANS, T) :- (ANS = y) -> (T = tree(Q, AN, a(A)))
												; (T = tree(Q, a(A), AN)).

ask_node(tree(Q, Y, N), T) :- query_yn(Q, IN)
	, ((IN = 'y') ->
			(ask_node(Y, YN) , (YN \= void -> T = tree(Q, YN, N) ; T = void))
		; (ask_node(N, NN) , (NN \= void -> T = tree(Q, Y, NN) ; T = void))).

ask_node(a(A), N) :- string_concat("Is it the ", A, Q) , query_yn(Q, IN)
	, (IN = 'y' -> format("I won!~n~n") , N = void)
		; (write("What is the right animals name? ")
			, read_string(user_input, "\r\n", "\r\n\t ", _, AN)
			, format("Type a question to differentiate it from ~w: ", [A])
			, read_string(user_input, "\r\n", "\r\n\t ", _, QN)
			, query_yn("What would be the answer to get the new animal?", QNA)
			, qInsert(a(A), a(AN), QN, QNA, N)
		).

% Reads one char from user_input and discards the rest.
read_next_char(C) :- get_char(C) , read_pending_chars(user_input, _, _).

% Repeats question until user inputs valid input.
query_yn(S, C) :- format("~w (y/n): ", [S]) , read_next_char(IN)
					, ((IN == 'y' ; IN == 'n') -> C = IN ; query_yn(S, C)).

