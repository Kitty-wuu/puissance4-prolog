# Puissance 4 en Prolog

Projet ALIA – 4IF, INSA Lyon.

Première version du jeu Puissance 4, inspirée de la structure du corrigé du morpion.

## Fonctionnalités actuelles (V0.1)

- Plateau de 6 lignes et 7 colonnes, affiché en mode texte.
- Deux joueurs : `x` et `o` ; `e` représente une case vide.
- Vérification des colonnes disponibles et gestion de la gravité.
- Détection des victoires horizontales, verticales et diagonales, ainsi que des matchs nuls.
- Partie automatique entre deux IA qui choisissent aléatoirement un coup autorisé.

## Exécution avec SWISH

1. Ouvrir [SWISH](https://swish.swi-prolog.org/).
2. Copier le contenu de `puissance4.pl` dans la zone Program.
3. Saisir la requête suivante dans la zone Query, puis cliquer sur Run :

```prolog
go.
```

Le programme affiche le plateau à chaque tour et le résultat à la fin de la partie.

## Exécution en local

Avec SWI-Prolog installé, ouvrir un terminal dans le dossier du projet :

```bash
swipl -s puissance4.pl
```

Puis saisir `go.` dans la console Prolog.
