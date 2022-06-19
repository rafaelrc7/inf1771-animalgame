:- dynamic node/3.

% Clears current tree and loads KB from 'animalsgame.kb' if it exists.
% Otherwise, load the default one from 'animalsgameinit.kb'.
load_kb :- retractall(node(_, _, _))
			, (exists_file('animalsgame.kb') , consult('animalsgame.kb'))
				; consult('animalsgameinit.kb').

% Asks player if he wants to save the KB to a file.
save_kb :- query_yn("Do you want to save?" , IN)
			, ((IN = 'n' , true)
				; (IN = 'y' , tell('animalsgame.kb') , listing(node) , told))
				; save_kb.

% Runs game, starting with the first node question.
start :- load_kb , (node(Q, Y, N)) , ! , play(node(Q, Y, N)) , !.

% Game loop, runs until player chooses to exit.
play(N) :- ask_node(N)
			, query_yn("Do you want to play again?", IN)
			, ((IN = 'y' , nl , play(N))
				; (IN = 'n' , save_kb , nl , write("Thanks for playing!") , nl)).

% Asks node question, and executes action related to the chosen child.
ask_node(node(q(Q), Y, N)) :- query_yn(Q, IN)
	, (IN = 'y' , ((Y = q(_) , node(Y, YY, YN) , ask_node(node(Y, YY, YN)))
					; Y = a(_) , ask_animal(Y)))
		; (((N = q(_) , node(N, NY, NN) , ask_node(node(N, NY, NN)))
				; N = a(_) , ask_animal(N))).

% Questions have reached an animal, a tree leaf. Asks with animal is correct,
% if not registers new question and node.
ask_animal(a(A)) :- string_concat("Is it the ", A, QYN) , query_yn(QYN, IN)
	, (IN = 'y' , (write("I won!") , nl))
		; (write("What is the right animals name? ")
			, read_string(user_input, "\r\n", "\r\n\t ", _, NA)
			, write("Type a question to differentiate from it: ")
			, read_string(user_input, "\r\n", "\r\n\t ", _, NQ)
			, query_yn("What would be the answer to reach the new animal?", NQA)
			, ((NQA = y , NN = node(q(NQ), a(NA), a(A)))
				; ((NQA = n) , NN = node(q(NQ), a(A), a(NA))))
			, ((ON = node(Q, a(A), N) , RN = node(Q, q(NQ), N))
				; (ON = node(Q, Y, a(A)) , RN = node(Q, Y, q(NQ))))
			, retract(ON)
			, assertz(RN)
			, assertz(NN)
		).

% Reads one char from user_input and discards the rest.
read_next_char(C) :- get_char(C) , read_pending_chars(user_input, _, _).

% Repeats question until user inputs valid input.
query_yn(S, C) :- write(S) , write(" (y/n): ") , read_next_char(IN)
					, ((IN == 'y' ; IN == 'n') -> C = IN ; query_yn(S, C)).

