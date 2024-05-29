# Redmine Spécifiques GFI

Suite au départ de Dany, déplacement du repository sur compte Arnaud Grignan

Réintégration des spécifiques GFI sous la forme d'un plugin.

Ce plugin permet :

### Pour les temps passés

- D’ajouter un champ « Temps CRA » lors de la saisie de temps passé, limité à matin=soir=4h, jour=8h ou aucun et qui servira pour le rapprochement avec Resplan.
- D’effectuer un contrôle de saisie sur  le champ « Commentaire » lors de la saisie d’un temps passé.
(Les caractères &*%?'#;\" sont désormais filtrés, leur saisie entraine un message d’avertissement).
- D'assigner du temps passé à un autre utilisateur du projet.
- D'ajouter le champ gct_tpscra lors de l'import de temps passés dans un fichier csv (le nom des fichiers csv est aussi plus explicite).
- De définir le filtre par défaut à "cette semaine" dans les écrans récapitulatifs des temps passés par projet ou global.

Aucun contrôle de saisie n’est effectué sur le champ Heures.

### Pour les demandes :

- D’ajouter après le champ temps estimé, sa conversion en jours (1 jour=8h).
- D’ajouter sous le champ temps estimé, un champ de totalisation des temps CRA (exprimé en heures et en jours, à condition que le temps estimé de la demande courante soit renseigné).
- D'empêcher l'écrasement de la valeur "pourcentage réalisé" d'une demande par les sous demandes qu'elle contient.
- De permettre de modifier la valeur "pourcentage réalisé" d'une demande même si elle possède des sous-demandes.

## Procédure de réintégration
- Ajouter le champs Temps CRA dans la base :
`ALTER TABLE 'bitnami_redmine'.'time_entries' ADD COLUMN 'gct_tpscra' VARCHAR(1) NOT NULL  AFTER 'updated_on';`
- Copier le dossier redmine_specifiques_GFI dans le répertoire {REDMINE_ROOT}/apps/redmine/htdocs/plugins
- `bundle exec rake redmine:plugins:migrate RAILS_ENV=production`
- Relancer les serveurs
