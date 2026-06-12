# prompt-generator

Skill Claude **master-prompt** : transforme n'importe quel besoin en prompt expert, structuré et optimisé — réutilisable dans Claude Chat, Cowork et Claude Code.

## Contenu

```
master-prompt/
├── SKILL.md      # la skill (instructions + bonnes pratiques)
└── exemples.md   # exemples avant/après chargés à la demande
```

## Installation

### Claude Chat (claude.ai) et Cowork

1. Zipper le dossier : `cd prompt-generator && zip -r master-prompt.zip master-prompt/`
2. Sur claude.ai : **Paramètres → Capabilities (Fonctionnalités) → Skills → Upload skill**, puis sélectionner le zip.
3. La skill se déclenche automatiquement dès que vous demandez de créer ou d'améliorer un prompt. Cowork utilise les mêmes skills que votre compte claude.ai.

### Claude Code

Copier le dossier dans vos skills personnelles (disponible dans tous vos projets) :

```sh
mkdir -p ~/.claude/skills
cp -r master-prompt ~/.claude/skills/
```

Ou dans un projet précis (partagé via git avec l'équipe) :

```sh
mkdir -p .claude/skills
cp -r master-prompt .claude/skills/
```

Puis invoquer avec `/master-prompt <votre besoin>` ou simplement demander "fais-moi un prompt pour…".

## Utilisation

Exprimez le besoin, la skill renvoie uniquement le prompt optimisé, prêt à copier :

> fais-moi un prompt pour analyser des contrats fournisseurs

Si la demande est trop vague, elle pose au maximum 2 questions ciblées avant de générer.

## Ce que les prompts générés intègrent

- Rôle expert précis, contexte et intention (pas de persona creux)
- Format de sortie exact, longueur cible, langue, ton
- Garde-fous anti-hallucination : dire "je ne sais pas", demander une précision, distinguer faits et déductions
- Honnêteté directe : pas de flatterie, contredire si la prémisse est fausse
- Concision : pas de remplissage, longueur calibrée sur l'information utile
- Formatage naturel : pas de tirets longs, pas de listes à puces systématiques, pas d'emojis
- Économie de tokens : la formulation la plus courte qui reste complète, variables `[ENTRE_CROCHETS]` pour les prompts réutilisables
