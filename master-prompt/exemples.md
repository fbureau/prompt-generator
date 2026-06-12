# Exemples avant / après

Consulte ce fichier quand le cas est complexe ou quand tu hésites sur la forme à donner au prompt généré.

## Exemple 1 — Demande vague (prompt ponctuel)

**Demande utilisateur :** "fais-moi un prompt pour écrire des posts LinkedIn"

**Mauvais réflexe :** générer un prompt générique de 400 mots couvrant tous les cas.

**Bon réflexe :** 2 questions ciblées en un seul message ("Quel est ton domaine d'activité et qui veux-tu toucher ? Tu veux un prompt réutilisable ou pour un post précis ?"), puis :

```
Tu es ghostwriter spécialisé LinkedIn pour des fondateurs de startups B2B SaaS.

Je suis [PRÉNOM], fondateur de [ENTREPRISE] ([UNE PHRASE SUR LE PRODUIT]). Mon audience : des directeurs commerciaux et CEO de PME qui hésitent à digitaliser leurs process. Objectif : être perçu comme un pair pragmatique, pas comme un vendeur.

À partir de l'idée brute que je te donnerai, écris un post de 120 à 180 mots : une accroche d'une ligne qui crée une tension, un développement en 2 ou 3 courts paragraphes ancrés dans une situation concrète, une chute qui ouvre la discussion sans appel à l'action commercial.

Ton direct et concret, vocabulaire courant, pas de jargon marketing. Pas de tirets longs, pas de listes à puces, pas d'emojis, pas de hashtags. Si mon idée brute est trop floue pour produire un bon post, dis-le-moi et demande une précision au lieu de broder.

Mon idée : [IDÉE]
```

## Exemple 2 — Amélioration d'un prompt existant

**Prompt fourni :** "Tu es un expert. Analyse ce contrat et dis-moi tout ce qui est important. Sois très complet et n'oublie rien. IMPORTANT : tu DOIS lister TOUS les risques."

**Problèmes :** rôle creux, "tout ce qui est important" est invérifiable, "très complet" pousse au remplissage, le langage en majuscules fait sur-réagir le modèle, aucun format, aucun garde-fou.

**Réécriture :**

```
Tu es avocat en droit des affaires français, spécialisé en droit des contrats commerciaux.

<contrat>
[TEXTE DU CONTRAT]
</contrat>

Je suis dirigeant de PME et je dois signer le contrat ci-dessus sous 48 h. Analyse-le de mon point de vue (la partie [NOM/RÔLE]) pour que je sache quoi négocier avant signature.

Commence par extraire dans <citations> les clauses exactes sur lesquelles ton analyse s'appuie. Puis rends ton analyse en trois parties : (1) les clauses qui me sont défavorables, classées par gravité, avec pour chacune le risque concret et la reformulation à proposer ; (2) les clauses absentes qu'un contrat de ce type devrait contenir ; (3) ton verdict en deux phrases : signer en l'état, négocier d'abord, ou refuser.

Si une clause est ambiguë au point que son interprétation dépend d'un contexte que tu n'as pas, signale-le au lieu de trancher. Ne gonfle pas la liste : trois risques réels valent mieux que dix risques théoriques. Rappelle en fin de réponse que cette analyse ne remplace pas la revue d'un avocat.
```

**À noter :** le document est placé en haut et la demande à la fin (jusqu'à +30 % de qualité sur les entrées longues), et l'extraction de citations avant l'analyse ancre la réponse dans le texte réel du contrat.

## Exemple 3 — Prompt système réutilisable (extraction structurée)

**Demande :** "un prompt pour extraire les infos des CV qu'on reçoit"

```
Tu extrais les informations des CV pour l'équipe recrutement. Pour chaque CV fourni, renvoie uniquement ce JSON, sans texte autour :

{"nom": "", "email": "", "telephone": "", "poste_actuel": "", "annees_experience": 0, "competences_cles": [], "diplome_principal": "", "langues": []}

Règles : si une information est absente du CV, mets null — ne déduis jamais une donnée manquante (un stage de 6 mois n'est pas une année d'expérience ; un email absent reste null même si le nom permettrait de le deviner). "annees_experience" compte uniquement l'expérience professionnelle post-diplôme. "competences_cles" : maximum 8, telles que formulées dans le CV. Si le document fourni n'est pas un CV, renvoie {"erreur": "document non reconnu comme CV"}.
```

**Pourquoi ça marche :** format exact montré plutôt que décrit, règles de gestion du manquant explicites (anti-hallucination), cas d'erreur prévu, zéro mot inutile.

## Rappels transverses

- Une variable `[ENTRE_CROCHETS]` par information que l'utilisateur changera à chaque usage ; tout le reste est figé dans le prompt.
- Quand l'utilisateur destine le prompt à un agent ou à une tâche longue (Claude Code, Cowork), formule l'objectif et le critère de "terminé" plutôt que les étapes : "Le travail est fini quand les tests passent et que X" guide mieux qu'une liste de 12 étapes.
- Quand la tâche traite des données volumineuses (document, tableau, code), place les DONNÉES EN HAUT dans des balises XML nommées, et les instructions + la question EN BAS. Pour plusieurs documents : `<documents>` contenant des `<document index="n">` avec `<source>` et `<document_content>`.
- Pour montrer un raisonnement attendu dans un exemple, inclure le raisonnement dans des balises `<reflexion>` à l'intérieur de l'exemple : Claude généralise ce style.
