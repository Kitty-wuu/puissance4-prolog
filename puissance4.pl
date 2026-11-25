% Puissance 4 - V0.1 : deux IA aleatoires.
:- use_module(library(random)).
:- dynamic plateau/1.

% Plateau : six lignes de sept cases, du haut vers le bas.
% e = vide, x et o = joueurs.
plateauInitial(P) :- length(P,6), maplist(ligneVide,P).
ligneVide(L) :- length(L,7), maplist(=(e),L).
init :- plateauInitial(P), retractall(plateau(_)), assertz(plateau(P)).

% Affichage du plateau.
affichePlateau :- plateau(P), afficher(P).
afficher(P) :- writeln('  1 2 3 4 5 6 7'), maplist(afficherLigne,P), nl.
afficherLigne(L) :- write('| '), forall(member(X,L),format('~w ',[X])), writeln('|').

% Un coup est une colonne dont la case superieure est vide.
coupAutorise([H|_],C) :- nth1(C,H,e).
changer(x,o).
changer(o,x).

% Remplacement fonctionnel : ne modifie pas la base de connaissances.
remplacer(1,[_|T],V,[V|T]).
remplacer(I,[H|T],V,[H|R]) :- I > 1, J is I-1, remplacer(J,T,V,R).

% Chercher la case vide la plus basse dans la colonne.
jouerCoup(P,C,N,J) :-
    memberchk(J,[x,o]), coupAutorise(P,C),
    findall(R,(nth1(R,P,L),nth1(C,L,e)),Rs),
    last(Rs,R), nth1(R,P,L), remplacer(C,L,J,NL), remplacer(R,P,NL,N).

% Quatre directions : horizontale, verticale, deux diagonales.
direction(0,1).
direction(1,0).
direction(1,1).
direction(1,-1).
case(P,R,C,J) :- between(1,6,R), between(1,7,C), nth1(R,P,L), nth1(C,L,J).
gagne(P,J) :-
    member(J,[x,o]), case(P,R,C,J), direction(DR,DC),
    forall(between(1,3,K),(R2 is R+K*DR,C2 is C+K*DC,case(P,R2,C2,J))), !.

% Priorite a la victoire, y compris au dernier coup.
gameover(P,R) :- gagne(P,J), !, R = J.
gameover(P,egalite) :- \+ coupAutorise(P,_).
egalite :- plateau(P), gameover(P,egalite).

% Interface de strategie : P (entree), C (sortie), J (entree).
ia(P,C,_J) :- findall(K,coupAutorise(P,K),Cs), random_member(C,Cs).

% Seul le moteur de partie modifie le plateau courant.
appliquer(P,N) :- retract(plateau(P)), assertz(plateau(N)).

% Boucle : verifier la fin avant de demander un nouveau coup.
jouer(J) :-
    plateau(P), afficher(P),
    ( gameover(P,R) -> format('Fin de partie : ~w~n',[R])
    ; ia(P,C,J), format('Joueur ~w : colonne ~w~n',[J,C]),
      jouerCoup(P,C,N,J), appliquer(P,N), changer(J,A), jouer(A)
    ).
go :- init, jouer(x).
