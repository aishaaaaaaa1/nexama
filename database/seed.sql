-- =============================================================================
-- NexaMa — Seed Data (Développement & Demo)
-- Référence : NEX-CDC-2025-001
-- WARNING: ne pas exécuter en production
-- =============================================================================

-- Désactiver temporairement les FK checks
SET session_replication_role = 'replica';

-- =============================================================================
-- UTILISATEURS DE DEMO (mots de passe : "NexaMa2025!" — bcrypt rounds=12)
-- =============================================================================

INSERT INTO auth.utilisateurs (id, nom_complet, email, mot_de_passe, telephone, role, statut, langue, ville, region, is_verified) VALUES
  ('11111111-0000-0000-0000-000000000001', 'Youssef Benali',    'youssef@nexama.ma',    '$2b$12$demoHashEntrepreneur1xxxxx', '+212661234567', 'entrepreneur',   'actif', 'fr', 'Casablanca',  'Grand Casablanca-Settat', TRUE),
  ('11111111-0000-0000-0000-000000000002', 'Amina El Fassi',    'amina@nexama.ma',      '$2b$12$demoHashEntrepreneur2xxxxx', '+212662345678', 'entrepreneur',   'actif', 'ar', 'Fès',         'Fès-Meknès',              TRUE),
  ('22222222-0000-0000-0000-000000000001', 'Khalid Rachidi',    'khalid@nexama.ma',     '$2b$12$demoHashInvestisseurxxxxx',  '+212663456789', 'investisseur',   'actif', 'fr', 'Rabat',       'Rabat-Salé-Kénitra',      TRUE),
  ('33333333-0000-0000-0000-000000000001', 'Sara Moussaoui',    'sara@nexama.ma',       '$2b$12$demoHashPrestatairexxxxx',   '+212664567890', 'prestataire',    'actif', 'fr', 'Marrakech',   'Marrakech-Safi',          TRUE),
  ('44444444-0000-0000-0000-000000000001', 'Hassan Tazi',       'hassan@nexama.ma',     '$2b$12$demoHashFormateurxxxxx',    '+212665678901', 'formateur',      'actif', 'fr', 'Agadir',      'Souss-Massa',             TRUE),
  ('55555555-0000-0000-0000-000000000001', 'Admin NexaMa',      'admin@nexama.ma',      '$2b$12$demoHashAdminxxxxxxxxxxx',  '+212666789012', 'administrateur', 'actif', 'fr', 'Casablanca',  'Grand Casablanca-Settat', TRUE);

-- Profils spécifiques
INSERT INTO auth.profils_entrepreneur (utilisateur_id, ice, statut_juridique, secteur_activite, score_confiance) VALUES
  ('11111111-0000-0000-0000-000000000001', 'ICE001234567890', 'auto-entrepreneur', 'Tech & IA',           8.5),
  ('11111111-0000-0000-0000-000000000002', NULL,               'auto-entrepreneur', 'Artisanat & Mode',    7.2);

INSERT INTO auth.profils_investisseur (utilisateur_id, budget_max, secteurs_interet, type_investissement) VALUES
  ('22222222-0000-0000-0000-000000000001', 2000000.00, ARRAY['Tech', 'Agri', 'Fintech'], 'angel');

INSERT INTO auth.profils_prestataire (utilisateur_id, note_confiance, competences, tarif_heure, disponible) VALUES
  ('33333333-0000-0000-0000-000000000001', 9.1, ARRAY['Flutter', 'Node.js', 'PostgreSQL'], 350.00, TRUE);

INSERT INTO auth.profils_formateur (utilisateur_id, biographie, expertise) VALUES
  ('44444444-0000-0000-0000-000000000001', 'Expert en fiscalité marocaine et droit des affaires.', ARRAY['Fiscalité', 'Droit', 'Comptabilité']);

-- =============================================================================
-- MODULE 1 — PROJETS & MATCHING
-- =============================================================================

INSERT INTO matching.projets (id, entrepreneur_id, nom, description, secteur, ville, region, stade, statut, budget_recherche, tags) VALUES
  ('aaaa0001-0000-0000-0000-000000000001',
   '11111111-0000-0000-0000-000000000001',
   'AgriConnect MA',
   'Plateforme numérique de mise en relation entre agriculteurs marocains et acheteurs B2B, avec gestion de la traçabilité et paiement en ligne.',
   'AgriTech',
   'Meknès', 'Fès-Meknès',
   'amorçage', 'publie',
   500000.00,
   ARRAY['agritech', 'b2b', 'maroc', 'tracabilite']),

  ('aaaa0001-0000-0000-0000-000000000002',
   '11111111-0000-0000-0000-000000000002',
   'ZwineStore',
   'Marketplace de mode et artisanat marocain avec livraison nationale et export vers l''Europe.',
   'E-Commerce',
   'Fès', 'Fès-Meknès',
   'idee', 'publie',
   200000.00,
   ARRAY['ecommerce', 'artisanat', 'mode', 'export']);

INSERT INTO matching.interets_investisseurs (investisseur_id, projet_id, statut, montant_propose) VALUES
  ('22222222-0000-0000-0000-000000000001', 'aaaa0001-0000-0000-0000-000000000001', 'en_discussion', 300000.00);

-- =============================================================================
-- MODULE 4 — BUSINESS PLAN IA
-- =============================================================================

INSERT INTO ia.business_plans (projet_id, entrepreneur_id, resume_executif, statut, api_utilisee, tokens_utilises, donnees_formulaire) VALUES
  ('aaaa0001-0000-0000-0000-000000000001',
   '11111111-0000-0000-0000-000000000001',
   'AgriConnect MA est une plateforme B2B qui vise à digitaliser la chaîne de valeur agricole au Maroc en connectant 10 000 agriculteurs avec 500 acheteurs professionnels d''ici 2027.',
   'termine', 'gemini', 4200,
   '{"secteur": "AgriTech", "cible": "Agriculteurs & GMS", "prix_moyen": "Abonnement 200 MAD/mois", "concurrents": "Aucun direct au Maroc", "region": "Fès-Meknès"}'::JSONB);

-- =============================================================================
-- MODULE 5 — KANBAN TÂCHES
-- =============================================================================

INSERT INTO gestion.membres_projet (projet_id, utilisateur_id, role_projet) VALUES
  ('aaaa0001-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000001', 'owner'),
  ('aaaa0001-0000-0000-0000-000000000001', '33333333-0000-0000-0000-000000000001', 'membre');

INSERT INTO gestion.taches (projet_id, titre, statut, priorite, assigne_a, cree_par, date_echeance) VALUES
  ('aaaa0001-0000-0000-0000-000000000001', 'Développer le MVP Flutter', 'en_cours', 'haute',
   '33333333-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000001', '2025-05-15'),
  ('aaaa0001-0000-0000-0000-000000000001', 'Déposer le dossier CRI', 'a_faire', 'normale',
   '11111111-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000001', '2025-04-30');

-- =============================================================================
-- MODULE 2 — FACTURES
-- =============================================================================

INSERT INTO gestion.factures (entrepreneur_id, client_nom, client_email, numero_ref, date_echeance, statut, total_ht, taux_tva, total_tva, total_ttc) VALUES
  ('11111111-0000-0000-0000-000000000001', 'Maroc Invest Group', 'contact@mig.ma',
   'NEX-FACT-2025-0001', '2025-05-10', 'envoyee', 15000.00, 20.00, 3000.00, 18000.00);

INSERT INTO gestion.lignes_facture (facture_id, description, quantite, prix_unitaire, total_ligne)
SELECT f.id, 'Développement Application Flutter', 1, 15000.00, 15000.00
FROM gestion.factures f WHERE f.numero_ref = 'NEX-FACT-2025-0001';

-- =============================================================================
-- MODULE 3 — MARKETPLACE
-- =============================================================================

INSERT INTO marketplace.categories (nom_fr, nom_ar) VALUES
  ('Développement Web & Mobile', 'تطوير الويب والهاتف'),
  ('Design & Créatif',            'تصميم وإبداع'),
  ('Marketing Digital',           'التسويق الرقمي'),
  ('Comptabilité & Finance',      'المحاسبة والمالية'),
  ('Conseil Juridique',           'الاستشارة القانونية');

INSERT INTO marketplace.services (prestataire_id, titre, description, prix, duree_livraison, tags)
SELECT
  '33333333-0000-0000-0000-000000000001',
  'Développement Application Flutter (Web + Mobile)',
  'Création d''une application Flutter multiplateforme (iOS, Android, Web) avec backend Node.js et PostgreSQL. Design moderne, animations fluides, support bilingue FR/AR.',
  8500.00, 21,
  ARRAY['flutter', 'mobile', 'web', 'dart', 'nodejs'];

-- =============================================================================
-- MODULE 6 — MICROLEARNING
-- =============================================================================

INSERT INTO learning.cours (formateur_id, titre, titre_ar, categorie, format_media, niveau, duree_minutes, publie) VALUES
  ('44444444-0000-0000-0000-000000000001',
   'Maîtriser la TVA marocaine pour auto-entrepreneurs',
   'إتقان ضريبة القيمة المضافة المغربية للمقاولين الذاتيين',
   'fiscalite', 'video', 'debutant', 8, TRUE),

  ('44444444-0000-0000-0000-000000000001',
   'Levée de fonds au Maroc — Guide pratique 2025',
   'جمع التمويل في المغرب — دليل عملي 2025',
   'levee_fonds', 'video', 'intermediaire', 12, TRUE);

-- =============================================================================
-- MODULE 9 — RH
-- =============================================================================

INSERT INTO rh.employes (entrepreneur_id, matricule, nom_complet, poste, date_embauche, type_contrat, salaire_base) VALUES
  ('11111111-0000-0000-0000-000000000001', 'EMP-001', 'Mehdi Alaoui', 'Développeur Flutter', '2025-01-15', 'cdi', 9500.00);

-- =============================================================================
-- MODULE 10 — STOCK
-- =============================================================================

INSERT INTO stock.entrepots (entrepreneur_id, nom, ville) VALUES
  ('11111111-0000-0000-0000-000000000001', 'Entrepôt Principal Casablanca', 'Casablanca');

INSERT INTO stock.produits (entrepreneur_id, sku, nom, categorie, prix_achat, prix_vente, seuil_alerte) VALUES
  ('11111111-0000-0000-0000-000000000001', 'SKU-AGRI-001', 'Kit Irrigation Goutte-à-Goutte', 'Matériel Agricole', 450.00, 750.00, 10);

-- Réactiver les FK checks
SET session_replication_role = 'origin';

-- =============================================================================
-- FIN DU SEED
-- =============================================================================
