:- dynamic node/3.

load_kb :- retractall(node(_, _, _))
			, (exists_file('animalsgame.kb') , consult('animalsgame.kb'))
				; consult('animalsgameinit.kb').
save_kb :- write("Do you want to save (y/n)? ") , read_next_char(IN)
			, ((IN = 'n' , true)
				; (IN = 'y' , tell('animalsgame.kb') , listing(node) , told)).

start :- load_kb , (node(Q, Y, N)) , ! , play(node(Q, Y, N)).
play(N) :- ask_node(N)
			, (write("Do you want to play again (y/n)? "))
			, read_next_char(IN)
			, ((IN = 'y' , nl , play(N))
				; (IN = 'n' , save_kb , nl , write("Thanks for playing!") , nl)).

ask_node(node(q(Q), Y, N)) :- write(Q) , write(" (y/n): ") , read_next_char(IN)
	, (IN = 'y' , ((Y = q(_) , node(Y, YY, YN) , ask_node(node(Y, YY, YN)))
					; Y = a(_) , ask_animal(Y)))
		; (((N = q(_) , node(N, NY, NN) , ask_node(node(N, NY, NN)))
				; N = a(_) , ask_animal(N))).

ask_animal(a(A)) :- write("Is it the ") , write(A) , write("? (y/n): ")
	, read_next_char(IN)
	, (IN = 'y' , (write("I won!") , nl))
		; (write("What is the right animals name? ")
			, read_string(user_input, "\r\n", "\r\n\t ", _, NA)
			, write("Type a question to differentiante from it: ")
			, read_string(user_input, "\r\n", "\r\n\t ", _, NQ)
			, write("What would be the answer to get it (y/n)? ")
			, read(NQA)
			, ((NQA = y , NN = node(q(NQ), a(NA), a(A)))
				; ((NQA = n) , NN = node(q(NQ), a(A), a(NA))))
			, ((ON = node(Q, a(A), N) , RN = node(Q, q(NQ), N))
				; (ON = node(Q, Y, a(A)) , RN = node(Q, Y, q(NQ))))
			, retract(ON)
			, assertz(RN)
			, assertz(NN)
		).

read_next_char(C) :- get_char(C) , read_pending_chars(user_input, _, _).

