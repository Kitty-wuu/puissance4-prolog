% Puissance 4 - V0.1 : deux IA aleatoires.
:- use_module(library(random)).
:- dynamic plateau/1.

% Plateau : six lignes de sept cases, du haut vers le bas.
% e = vide, x et o = joueurs.
plateauInitial(Plateau) :- length(Plateau,6), maplist(ligneVide,Plateau).
ligneVide(Ligne) :- length(Ligne,7), maplist(=(e),Ligne).
init :- plateauInitial(Plateau), retractall(plateau(_)), assertz(plateau(Plateau)).

% Affichage du plateau.
affichePlateau :- plateau(Plateau), afficher(Plateau).
afficher(Plateau) :- writeln('  1 2 3 4 5 6 7'), maplist(afficherLigne,Plateau), nl.
afficherLigne(Ligne) :-
    write('| '), forall(member(Case,Ligne),format('~w ',[Case])), writeln('|').

% Un coup est une colonne dont la case superieure est vide.
coupAutorise([LigneDuHaut|_],Colonne) :- nth1(Colonne,LigneDuHaut,e).
changer(x,o).
changer(o,x).

% Remplacement fonctionnel : ne modifie pas la base de connaissances.
% remplacer(Position, Liste, Valeur, NouvelleListe)
remplacer(1,[_|Reste],Valeur,[Valeur|Reste]).
remplacer(Position,[Tete|Reste],Valeur,[Tete|NouveauReste]) :-
    Position > 1, PositionSuivante is Position-1,
    remplacer(PositionSuivante,Reste,Valeur,NouveauReste).

% Chercher la case vide la plus basse dans la colonne.
jouerCoup(Plateau,Colonne,NouveauPlateau,Joueur) :-
    memberchk(Joueur,[x,o]), coupAutorise(Plateau,Colonne),
    findall(Num,(nth1(Num,Plateau,LigneTestee),nth1(Colonne,LigneTestee,e)),LignesLibres),
    last(LignesLibres,NumLigne), nth1(NumLigne,Plateau,Ligne),
    remplacer(Colonne,Ligne,Joueur,NouvelleLigne),
    remplacer(NumLigne,Plateau,NouvelleLigne,NouveauPlateau).

% Quatre directions : horizontale, verticale, deux diagonales.
direction(0,1).
direction(1,0).
direction(1,1).
direction(1,-1).
case(Plateau,NumLigne,Colonne,Contenu) :-
    between(1,6,NumLigne), between(1,7,Colonne),
    nth1(NumLigne,Plateau,Ligne), nth1(Colonne,Ligne,Contenu).
gagne(Plateau,Joueur) :-
    member(Joueur,[x,o]), case(Plateau,NumLigne,Colonne,Joueur),
    direction(DeltaLigne,DeltaColonne),
    forall(between(1,3,Pas),
           ( LigneSuivante is NumLigne+Pas*DeltaLigne,
             ColonneSuivante is Colonne+Pas*DeltaColonne,
             case(Plateau,LigneSuivante,ColonneSuivante,Joueur) )), !.

% Priorite a la victoire, y compris au dernier coup.
gameover(Plateau,Resultat) :- gagne(Plateau,Gagnant), !, Resultat = Gagnant.
gameover(Plateau,egalite) :- \+ coupAutorise(Plateau,_).
egalite :- plateau(Plateau), gameover(Plateau,egalite).

% Interface de strategie : Plateau (entree), Colonne (sortie), Joueur (entree).
ia(Plateau,Colonne,_Joueur) :-
    findall(Coup,coupAutorise(Plateau,Coup),CoupsPossibles),
    random_member(Colonne,CoupsPossibles).

% Seul le moteur de partie modifie le plateau courant.
appliquer(AncienPlateau,NouveauPlateau) :-
    retract(plateau(AncienPlateau)), assertz(plateau(NouveauPlateau)).

% Boucle : verifier la fin avant de demander un nouveau coup.
jouer(Joueur) :-
    plateau(Plateau), afficher(Plateau),
    ( gameover(Plateau,Resultat) -> format('Fin de partie : ~w~n',[Resultat])
    ; ia(Plateau,Colonne,Joueur),
      format('Joueur ~w : colonne ~w~n',[Joueur,Colonne]),
      jouerCoup(Plateau,Colonne,NouveauPlateau,Joueur),
      appliquer(Plateau,NouveauPlateau),
      changer(Joueur,Adversaire), jouer(Adversaire)
    ).
go :- init, jouer(x).
