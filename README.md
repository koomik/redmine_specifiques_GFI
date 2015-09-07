# Redmine GCT Temps CRA

Patch spécifique GFI pour prendre en compte les Temps CRA (correspondance avec Resplan)
Ce patch permet :
- D’ajouter un champ « Temps CRA » limité à matin=soir=4h, jour=8h ou aucun et qui servira pour le rapprochement avec Resplan.
- D’ajouter après le champ temps estimé, sa conversion en jours (1 jour=8h)
- D’ajouter sous le champ temps estimé, un champ de totalisation des temps CRA (exprimé en heures et en jours).
- D’effectuer un contrôle de saisie sur  le champ « Commentaire » lors de la création d’un temps passé.
Les caractères &*%?'#\" sont désormais filtrés. Leur saisie entraine un message d’avertissement.


## Procédure de réintégration
- Copier le dossier redmine_patch_gct_tpscra dans le répertoire {REDMINE_ROOT}/apps/redmine/htdocs/plugins
- `bundle exec rake redmine:plugins:migrate RAILS_ENV=production`
- Relancer le serveur HTTP