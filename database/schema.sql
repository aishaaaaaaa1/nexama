-- =============================================================================
-- NexaMa — Base de Données PostgreSQL 16
-- Référence : NEX-CDC-2025-001  |  Version 1.2 — Avril 2025
-- ACID Compliance | 10 Modules | Multilingual (FR + AR/Darija)
-- =============================================================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "unaccent";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";       -- for fuzzy search / matching

-- =============================================================================
-- SCHEMA ORGANIZATION
-- =============================================================================
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS matching;
CREATE SCHEMA IF NOT EXISTS gestion;
CREATE SCHEMA IF NOT EXISTS marketplace;
CREATE SCHEMA IF NOT EXISTS ia;
CREATE SCHEMA IF NOT EXISTS learning;
CREATE SCHEMA IF NOT EXISTS crm;
CREATE SCHEMA IF NOT EXISTS finance;
CREATE SCHEMA IF NOT EXISTS rh;
CREATE SCHEMA IF NOT EXISTS stock;
CREATE SCHEMA IF NOT EXISTS audit;

-- =============================================================================
-- SECTION 1 : AUTHENTIFICATION & UTILISATEURS
-- auth schema
-- =============================================================================

CREATE TYPE auth.role_type AS ENUM (
    'entrepreneur',
    'investisseur',
    'prestataire',
    'formateur',
    'administrateur'
);

CREATE TYPE auth.statut_compte AS ENUM (
    'en_attente',
    'actif',
    'suspendu',
    'supprime'
);

CREATE TABLE auth.utilisateurs (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nom_complet     VARCHAR(150) NOT NULL,
    email           VARCHAR(255) NOT NULL UNIQUE,
    mot_de_passe    TEXT NOT NULL,                     -- bcrypt hash
    telephone       VARCHAR(20),
    avatar_url      TEXT,
    role            auth.role_type NOT NULL,
    statut          auth.statut_compte NOT NULL DEFAULT 'en_attente',
    langue          CHAR(2) NOT NULL DEFAULT 'fr',     -- 'fr' | 'ar'
    ville           VARCHAR(100),
    region          VARCHAR(100),
    is_verified     BOOLEAN NOT NULL DEFAULT FALSE,
    two_fa_secret   TEXT,                              -- TOTP secret (optionnel)
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ                        -- soft delete
);

CREATE INDEX idx_utilisateurs_email   ON auth.utilisateurs (email);
CREATE INDEX idx_utilisateurs_role    ON auth.utilisateurs (role);
CREATE INDEX idx_utilisateurs_ville   ON auth.utilisateurs (ville);

-- OAuth / SSO providers (Google, LinkedIn)
CREATE TABLE auth.oauth_comptes (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    utilisateur_id  UUID NOT NULL REFERENCES auth.utilisateurs (id) ON DELETE CASCADE,
    provider        VARCHAR(50) NOT NULL,    -- 'google' | 'linkedin'
    provider_id     TEXT NOT NULL,
    access_token    TEXT,
    refresh_token   TEXT,
    expires_at      TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (provider, provider_id)
);

-- JWT refresh tokens persisted in DB (Redis cache + DB fallback)
CREATE TABLE auth.refresh_tokens (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    utilisateur_id  UUID NOT NULL REFERENCES auth.utilisateurs (id) ON DELETE CASCADE,
    token_hash      TEXT NOT NULL UNIQUE,   -- SHA-256 of the actual token
    user_agent      TEXT,
    ip_address      INET,
    expires_at      TIMESTAMPTZ NOT NULL,
    revoked_at      TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Role-specific profiles (one-to-one extension of utilisateurs)

CREATE TABLE auth.profils_entrepreneur (
    utilisateur_id  UUID PRIMARY KEY REFERENCES auth.utilisateurs (id) ON DELETE CASCADE,
    ice             VARCHAR(20) UNIQUE,     -- Identifiant Commun de l'Entreprise
    statut_juridique VARCHAR(50),           -- auto-entrepreneur, SARL, SA...
    secteur_activite VARCHAR(100),
    date_creation_entreprise DATE,
    site_web        TEXT,
    description     TEXT,
    score_confiance NUMERIC(3,1) DEFAULT 0, -- 0.0 – 10.0
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE auth.profils_investisseur (
    utilisateur_id  UUID PRIMARY KEY REFERENCES auth.utilisateurs (id) ON DELETE CASCADE,
    budget_max      NUMERIC(15,2),
    secteurs_interet TEXT[],
    type_investissement VARCHAR(50),        -- seed | serie-a | angel ...
    portfolio_url   TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE auth.profils_prestataire (
    utilisateur_id  UUID PRIMARY KEY REFERENCES auth.utilisateurs (id) ON DELETE CASCADE,
    portfolio_url   TEXT,
    note_confiance  NUMERIC(3,1) DEFAULT 0,
    competences     TEXT[],
    tarif_heure     NUMERIC(10,2),
    disponible      BOOLEAN DEFAULT TRUE,
    certifications  TEXT[],
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE auth.profils_formateur (
    utilisateur_id  UUID PRIMARY KEY REFERENCES auth.utilisateurs (id) ON DELETE CASCADE,
    biographie      TEXT,
    expertise       TEXT[],
    linkedin_url    TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- SECTION 2 : MODULE 1 — MATCHING ENTREPRENEURS ↔ INVESTISSEURS
-- matching schema
-- =============================================================================

CREATE TYPE matching.stade_projet AS ENUM (
    'idee',
    'amorçage',
    'croissance',
    'expansion'
);

CREATE TYPE matching.statut_projet AS ENUM (
    'brouillon',
    'publie',
    'en_discussion',
    'finance',
    'cloture',
    'archive'
);

CREATE TABLE matching.projets (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entrepreneur_id UUID NOT NULL REFERENCES auth.utilisateurs (id) ON DELETE CASCADE,
    nom             VARCHAR(200) NOT NULL,
    description     TEXT NOT NULL,
    secteur         VARCHAR(100) NOT NULL,
    ville           VARCHAR(100),
    region          VARCHAR(100),
    stade           matching.stade_projet NOT NULL DEFAULT 'idee',
    statut          matching.statut_projet NOT NULL DEFAULT 'brouillon',
    budget_recherche NUMERIC(15,2) NOT NULL,
    montant_leve    NUMERIC(15,2) DEFAULT 0,
    score_confiance NUMERIC(3,1) DEFAULT 0,
    logo_url        TEXT,
    pitch_deck_url  TEXT,
    video_url       TEXT,
    tags            TEXT[],
    vues            INT DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_projets_entrepreneur ON matching.projets (entrepreneur_id);
CREATE INDEX idx_projets_secteur      ON matching.projets (secteur);
CREATE INDEX idx_projets_stade        ON matching.projets (stade);
CREATE INDEX idx_projets_statut       ON matching.projets (statut);
CREATE INDEX idx_projets_region       ON matching.projets (region);
-- Full-text search on project name & description
CREATE INDEX idx_projets_fts ON matching.projets
    USING GIN (to_tsvector('french', nom || ' ' || description));

CREATE TYPE matching.statut_interet AS ENUM (
    'vu',
    'interesse',
    'en_discussion',
    'investissement_confirme',
    'decline'
);

CREATE TABLE matching.interets_investisseurs (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    investisseur_id UUID NOT NULL REFERENCES auth.utilisateurs (id) ON DELETE CASCADE,
    projet_id       UUID NOT NULL REFERENCES matching.projets (id) ON DELETE CASCADE,
    statut          matching.statut_interet NOT NULL DEFAULT 'vu',
    montant_propose NUMERIC(15,2),
    note            TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (investisseur_id, projet_id)
);

CREATE TABLE matching.messages (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    expediteur_id   UUID NOT NULL REFERENCES auth.utilisateurs (id),
    destinataire_id UUID NOT NULL REFERENCES auth.utilisateurs (id),
    projet_id       UUID REFERENCES matching.projets (id) ON DELETE SET NULL,
    contenu         TEXT NOT NULL,
    lu              BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_messages_expediteur   ON matching.messages (expediteur_id);
CREATE INDEX idx_messages_destinataire ON matching.messages (destinataire_id);

-- =============================================================================
-- SECTION 3 : MODULE 4 — GÉNÉRATEUR DE BUSINESS PLAN IA
-- ia schema
-- =============================================================================

CREATE TYPE ia.statut_generation AS ENUM (
    'en_attente',
    'en_cours',
    'termine',
    'echec'
);

CREATE TABLE ia.business_plans (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    projet_id           UUID NOT NULL REFERENCES matching.projets (id) ON DELETE CASCADE,
    entrepreneur_id     UUID NOT NULL REFERENCES auth.utilisateurs (id),
    version             INT NOT NULL DEFAULT 1,
    resume_executif     TEXT,
    etude_marche        TEXT,
    modele_economique   TEXT,
    previsionnel_3ans   JSONB,              -- structured financial projections
    strategie_marketing TEXT,
    analyse_swot        JSONB,              -- {forces, faiblesses, opportunites, menaces}
    statut              ia.statut_generation NOT NULL DEFAULT 'en_attente',
    api_utilisee        VARCHAR(50),        -- 'gemini' | 'groq' | 'huggingface' | 'cohere'
    tokens_utilises     INT,
    pdf_url             TEXT,
    donnees_formulaire  JSONB NOT NULL,     -- raw answers to the 10-question form
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_bp_projet       ON ia.business_plans (projet_id);
CREATE INDEX idx_bp_entrepreneur ON ia.business_plans (entrepreneur_id);

-- Log all IA API calls for quota management & fallback tracking
CREATE TABLE ia.appels_api (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    utilisateur_id  UUID REFERENCES auth.utilisateurs (id),
    fournisseur     VARCHAR(50) NOT NULL,   -- 'gemini' | 'groq' | 'huggingface' | 'cohere' | 'openrouter'
    modele          VARCHAR(100),
    module_source   VARCHAR(50),            -- 'business_plan' | 'chatbot' | 'matching' ...
    tokens_entree   INT,
    tokens_sortie   INT,
    latence_ms      INT,
    statut_http     SMALLINT,
    erreur          TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_api_fournisseur ON ia.appels_api (fournisseur);
CREATE INDEX idx_api_date        ON ia.appels_api (created_at);

-- =============================================================================
-- SECTION 4 : MODULE 5 — SUIVI DE PROJET COLLABORATIF (KANBAN)
-- gestion schema
-- =============================================================================

CREATE TYPE gestion.statut_tache AS ENUM (
    'a_faire',
    'en_cours',
    'en_revision',
    'termine'
);

CREATE TYPE gestion.priorite_tache AS ENUM (
    'basse',
    'normale',
    'haute',
    'critique'
);

CREATE TABLE gestion.taches (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    projet_id       UUID NOT NULL REFERENCES matching.projets (id) ON DELETE CASCADE,
    titre           VARCHAR(300) NOT NULL,
    description     TEXT,
    statut          gestion.statut_tache NOT NULL DEFAULT 'a_faire',
    priorite        gestion.priorite_tache NOT NULL DEFAULT 'normale',
    assigne_a       UUID REFERENCES auth.utilisateurs (id) ON DELETE SET NULL,
    cree_par        UUID NOT NULL REFERENCES auth.utilisateurs (id),
    date_debut      DATE,
    date_echeance   DATE,
    budget_alloue   NUMERIC(12,2),
    depense_reelle  NUMERIC(12,2) DEFAULT 0,
    position        INT DEFAULT 0,          -- for kanban ordering
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_taches_projet ON gestion.taches (projet_id);
CREATE INDEX idx_taches_assigne ON gestion.taches (assigne_a);

CREATE TABLE gestion.commentaires_tache (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tache_id        UUID NOT NULL REFERENCES gestion.taches (id) ON DELETE CASCADE,
    auteur_id       UUID NOT NULL REFERENCES auth.utilisateurs (id),
    contenu         TEXT NOT NULL,
    fichier_url     TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE gestion.membres_projet (
    projet_id       UUID NOT NULL REFERENCES matching.projets (id) ON DELETE CASCADE,
    utilisateur_id  UUID NOT NULL REFERENCES auth.utilisateurs (id) ON DELETE CASCADE,
    role_projet     VARCHAR(50) NOT NULL DEFAULT 'membre',  -- owner | admin | membre | observateur
    invite_par      UUID REFERENCES auth.utilisateurs (id),
    rejoint_le      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (projet_id, utilisateur_id)
);

CREATE TABLE gestion.kpis_projet (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    projet_id       UUID NOT NULL REFERENCES matching.projets (id) ON DELETE CASCADE,
    nom             VARCHAR(150) NOT NULL,
    valeur_cible    NUMERIC(15,2),
    valeur_actuelle NUMERIC(15,2) DEFAULT 0,
    unite           VARCHAR(30),
    periode         VARCHAR(30),            -- 'mensuel' | 'trimestriel' | 'annuel'
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- SECTION 5 : MODULE 2 — DASHBOARD AUTO-ENTREPRENEUR (GESTION, FINANCES)
-- gestion + finance schemas
-- =============================================================================

CREATE TYPE gestion.statut_facture AS ENUM (
    'brouillon',
    'envoyee',
    'payee',
    'en_retard',
    'annulee'
);

CREATE TABLE gestion.factures (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entrepreneur_id UUID NOT NULL REFERENCES auth.utilisateurs (id) ON DELETE CASCADE,
    client_nom      VARCHAR(200) NOT NULL,
    client_ice      VARCHAR(20),
    client_adresse  TEXT,
    client_email    VARCHAR(255),
    numero_ref      VARCHAR(50) NOT NULL UNIQUE,    -- NEX-FACT-2025-0001
    date_emission   DATE NOT NULL DEFAULT CURRENT_DATE,
    date_echeance   DATE NOT NULL,
    statut          gestion.statut_facture NOT NULL DEFAULT 'brouillon',
    total_ht        NUMERIC(12,2) NOT NULL,
    taux_tva        NUMERIC(5,2) NOT NULL DEFAULT 20.00,
    total_tva       NUMERIC(12,2) NOT NULL,
    total_ttc       NUMERIC(12,2) NOT NULL,
    notes           TEXT,
    pdf_url         TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_factures_entrepreneur ON gestion.factures (entrepreneur_id);
CREATE INDEX idx_factures_statut       ON gestion.factures (statut);

CREATE TABLE gestion.lignes_facture (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    facture_id      UUID NOT NULL REFERENCES gestion.factures (id) ON DELETE CASCADE,
    description     VARCHAR(300) NOT NULL,
    quantite        NUMERIC(10,2) NOT NULL,
    prix_unitaire   NUMERIC(12,2) NOT NULL,
    total_ligne     NUMERIC(12,2) NOT NULL
);

CREATE TABLE gestion.depenses (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entrepreneur_id UUID NOT NULL REFERENCES auth.utilisateurs (id) ON DELETE CASCADE,
    categorie       VARCHAR(100) NOT NULL,         -- 'loyer' | 'transport' | 'marketing' ...
    montant         NUMERIC(12,2) NOT NULL,
    description     TEXT,
    justificatif_url TEXT,
    date_depense    DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_depenses_entrepreneur ON gestion.depenses (entrepreneur_id);
CREATE INDEX idx_depenses_date         ON gestion.depenses (date_depense);

-- Fiscal reminders (TVA, IR, CNSS, Patente)
CREATE TYPE gestion.type_rappel_fiscal AS ENUM (
    'tva',
    'ir',
    'cnss',
    'patente'
);

CREATE TABLE gestion.rappels_fiscaux (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entrepreneur_id UUID NOT NULL REFERENCES auth.utilisateurs (id) ON DELETE CASCADE,
    type_rappel     gestion.type_rappel_fiscal NOT NULL,
    montant_estime  NUMERIC(12,2),
    date_echeance   DATE NOT NULL,
    acquitte        BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Finance journal (for module 8 — comptabilité)
CREATE TABLE finance.journal_comptable (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entrepreneur_id UUID NOT NULL REFERENCES auth.utilisateurs (id) ON DELETE CASCADE,
    date_ecriture   DATE NOT NULL,
    libelle         VARCHAR(300) NOT NULL,
    debit           NUMERIC(12,2) DEFAULT 0,
    credit          NUMERIC(12,2) DEFAULT 0,
    compte          VARCHAR(20),            -- Plan comptable marocain
    piece_justif    TEXT,                   -- reference facture / depense
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_journal_entrepreneur  ON finance.journal_comptable (entrepreneur_id);
CREATE INDEX idx_journal_date          ON finance.journal_comptable (date_ecriture);

CREATE TABLE finance.releves_bancaires (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entrepreneur_id UUID NOT NULL REFERENCES auth.utilisateurs (id) ON DELETE CASCADE,
    banque          VARCHAR(100),
    iban            VARCHAR(34),
    fichier_url     TEXT,
    periode_debut   DATE,
    periode_fin     DATE,
    importe_le      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- SECTION 6 : MODULE 3 — MARKETPLACE DE SERVICES B2B
-- marketplace schema
-- =============================================================================

CREATE TABLE marketplace.categories (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nom_fr      VARCHAR(100) NOT NULL,
    nom_ar      VARCHAR(100),
    parent_id   UUID REFERENCES marketplace.categories (id),
    icone       TEXT,
    position    INT DEFAULT 0
);

CREATE TABLE marketplace.services (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    prestataire_id  UUID NOT NULL REFERENCES auth.utilisateurs (id) ON DELETE CASCADE,
    categorie_id    UUID REFERENCES marketplace.categories (id),
    titre           VARCHAR(200) NOT NULL,
    description     TEXT NOT NULL,
    prix            NUMERIC(10,2) NOT NULL,
    devise          CHAR(3) NOT NULL DEFAULT 'MAD',
    duree_livraison INT,                    -- in days
    disponible      BOOLEAN DEFAULT TRUE,
    note_moyenne    NUMERIC(3,1) DEFAULT 0,
    nb_avis         INT DEFAULT 0,
    nb_commandes    INT DEFAULT 0,
    tags            TEXT[],
    images          TEXT[],
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_services_prestataire ON marketplace.services (prestataire_id);
CREATE INDEX idx_services_categorie   ON marketplace.services (categorie_id);
CREATE INDEX idx_services_prix        ON marketplace.services (prix);
CREATE INDEX idx_services_note        ON marketplace.services (note_moyenne DESC);
-- Full-text search
CREATE INDEX idx_services_fts ON marketplace.services
    USING GIN (to_tsvector('french', titre || ' ' || description));

CREATE TYPE marketplace.statut_commande AS ENUM (
    'en_attente_paiement',
    'payee',
    'en_cours',
    'livree',
    'validee',
    'litige',
    'remboursee',
    'annulee'
);

CREATE TABLE marketplace.commandes (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entrepreneur_id UUID NOT NULL REFERENCES auth.utilisateurs (id),
    service_id      UUID NOT NULL REFERENCES marketplace.services (id),
    prestataire_id  UUID NOT NULL REFERENCES auth.utilisateurs (id),
    statut          marketplace.statut_commande NOT NULL DEFAULT 'en_attente_paiement',
    montant_ht      NUMERIC(10,2) NOT NULL,
    tva             NUMERIC(10,2) NOT NULL DEFAULT 0,
    montant_ttc     NUMERIC(10,2) NOT NULL,
    escrow_bloque   BOOLEAN DEFAULT FALSE,
    escrow_libere_le TIMESTAMPTZ,
    livraison_url   TEXT,
    date_livraison_prevue DATE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_commandes_entrepreneur ON marketplace.commandes (entrepreneur_id);
CREATE INDEX idx_commandes_prestataire  ON marketplace.commandes (prestataire_id);
CREATE INDEX idx_commandes_statut       ON marketplace.commandes (statut);

CREATE TABLE marketplace.avis (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    commande_id     UUID NOT NULL UNIQUE REFERENCES marketplace.commandes (id),
    auteur_id       UUID NOT NULL REFERENCES auth.utilisateurs (id),
    service_id      UUID NOT NULL REFERENCES marketplace.services (id),
    note            SMALLINT NOT NULL CHECK (note BETWEEN 1 AND 5),
    commentaire     TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE marketplace.paiements (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    commande_id     UUID NOT NULL REFERENCES marketplace.commandes (id),
    methode         VARCHAR(50) NOT NULL,   -- 'cmi' | 'payzone' | 'virement'
    reference_externe TEXT,               -- CMI transaction ID
    montant         NUMERIC(10,2) NOT NULL,
    devise          CHAR(3) DEFAULT 'MAD',
    statut          VARCHAR(30) NOT NULL DEFAULT 'initie',  -- initie | confirme | echec | rembourse
    reponse_raw     JSONB,                 -- raw gateway response
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- SECTION 7 : MODULE 7 — CRM & PIPELINE COMMERCIAL
-- crm schema
-- =============================================================================

CREATE TYPE crm.etape_pipeline AS ENUM (
    'prospect',
    'contact',
    'devis_envoye',
    'negociation',
    'commande',
    'facture',
    'encaissement',
    'perdu'
);

CREATE TABLE crm.clients (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entrepreneur_id UUID NOT NULL REFERENCES auth.utilisateurs (id) ON DELETE CASCADE,
    nom             VARCHAR(200) NOT NULL,
    email           VARCHAR(255),
    telephone       VARCHAR(20),
    adresse         TEXT,
    ice             VARCHAR(20),
    secteur         VARCHAR(100),
    etape_pipeline  crm.etape_pipeline NOT NULL DEFAULT 'prospect',
    valeur_estimee  NUMERIC(12,2),
    source          VARCHAR(50),           -- 'site_web' | 'recommandation' | 'marketplace' ...
    notes           TEXT,
    tags            TEXT[],
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_clients_entrepreneur ON crm.clients (entrepreneur_id);
CREATE INDEX idx_clients_pipeline     ON crm.clients (etape_pipeline);

CREATE TABLE crm.interactions (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id       UUID NOT NULL REFERENCES crm.clients (id) ON DELETE CASCADE,
    auteur_id       UUID NOT NULL REFERENCES auth.utilisateurs (id),
    type_interaction VARCHAR(50),          -- 'appel' | 'email' | 'reunion' | 'devis'
    note            TEXT,
    date_interaction TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE crm.devis (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entrepreneur_id UUID NOT NULL REFERENCES auth.utilisateurs (id),
    client_id       UUID NOT NULL REFERENCES crm.clients (id),
    numero_ref      VARCHAR(50) NOT NULL UNIQUE,
    date_emission   DATE NOT NULL DEFAULT CURRENT_DATE,
    date_validite   DATE,
    total_ht        NUMERIC(12,2) NOT NULL,
    taux_tva        NUMERIC(5,2) DEFAULT 20.00,
    total_ttc       NUMERIC(12,2) NOT NULL,
    statut          VARCHAR(30) DEFAULT 'brouillon',  -- brouillon | envoye | accepte | refuse | expire
    signature_url   TEXT,
    pdf_url         TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- SECTION 8 : MODULE 6 — MICROLEARNING
-- learning schema
-- =============================================================================

CREATE TYPE learning.format_media AS ENUM (
    'video',
    'quiz',
    'infographie',
    'podcast',
    'article'
);

CREATE TYPE learning.niveau_cours AS ENUM (
    'debutant',
    'intermediaire',
    'avance',
    'expert'
);

CREATE TABLE learning.cours (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    formateur_id    UUID NOT NULL REFERENCES auth.utilisateurs (id) ON DELETE CASCADE,
    titre           VARCHAR(200) NOT NULL,
    titre_ar        VARCHAR(200),
    description     TEXT,
    description_ar  TEXT,
    categorie       VARCHAR(100),           -- 'fiscalite' | 'marketing' | 'levee_fonds' | 'droit' ...
    format_media    learning.format_media NOT NULL DEFAULT 'video',
    niveau          learning.niveau_cours NOT NULL DEFAULT 'debutant',
    duree_minutes   INT NOT NULL,
    media_url       TEXT,
    miniature_url   TEXT,
    prix            NUMERIC(8,2) DEFAULT 0, -- 0 = gratuit
    publie          BOOLEAN DEFAULT FALSE,
    nb_inscrits     INT DEFAULT 0,
    note_moyenne    NUMERIC(3,1) DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_cours_formateur  ON learning.cours (formateur_id);
CREATE INDEX idx_cours_categorie  ON learning.cours (categorie);
CREATE INDEX idx_cours_niveau     ON learning.cours (niveau);

CREATE TABLE learning.quiz (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cours_id        UUID NOT NULL REFERENCES learning.cours (id) ON DELETE CASCADE,
    question        TEXT NOT NULL,
    options         JSONB NOT NULL,         -- ["option A", "option B", "option C", "option D"]
    reponse_correcte SMALLINT NOT NULL,    -- index 0-3 of correct option
    explication     TEXT
);

CREATE TABLE learning.inscriptions (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    utilisateur_id  UUID NOT NULL REFERENCES auth.utilisateurs (id) ON DELETE CASCADE,
    cours_id        UUID NOT NULL REFERENCES learning.cours (id) ON DELETE CASCADE,
    progression     SMALLINT DEFAULT 0 CHECK (progression BETWEEN 0 AND 100),
    date_inscription TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    date_completion TIMESTAMPTZ,
    UNIQUE (utilisateur_id, cours_id)
);

CREATE TABLE learning.certifications (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    inscription_id  UUID NOT NULL REFERENCES learning.inscriptions (id) ON DELETE CASCADE,
    utilisateur_id  UUID NOT NULL REFERENCES auth.utilisateurs (id),
    cours_id        UUID NOT NULL REFERENCES learning.cours (id),
    code_unique     VARCHAR(50) NOT NULL UNIQUE DEFAULT encode(gen_random_bytes(16), 'hex'),
    date_obtention  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    url_pdf         TEXT,
    UNIQUE (utilisateur_id, cours_id)
);

CREATE TABLE learning.badges (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    utilisateur_id  UUID NOT NULL REFERENCES auth.utilisateurs (id) ON DELETE CASCADE,
    nom             VARCHAR(100) NOT NULL,   -- 'Expert Fiscalité' | 'Marketing Pro'...
    icone_url       TEXT,
    obtenu_le       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- SECTION 9 : MODULE 9 — RESSOURCES HUMAINES
-- rh schema
-- =============================================================================

CREATE TYPE rh.statut_employe AS ENUM (
    'actif',
    'conge',
    'suspendu',
    'quitte'
);

CREATE TYPE rh.type_contrat AS ENUM (
    'cdi',
    'cdd',
    'stage',
    'freelance',
    'apprentissage'
);

CREATE TABLE rh.employes (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entrepreneur_id UUID NOT NULL REFERENCES auth.utilisateurs (id) ON DELETE CASCADE,
    matricule       VARCHAR(30) NOT NULL UNIQUE,
    nom_complet     VARCHAR(150) NOT NULL,
    email           VARCHAR(255),
    telephone       VARCHAR(20),
    poste           VARCHAR(100) NOT NULL,
    departement     VARCHAR(100),
    date_embauche   DATE NOT NULL,
    type_contrat    rh.type_contrat NOT NULL,
    statut          rh.statut_employe NOT NULL DEFAULT 'actif',
    salaire_base    NUMERIC(10,2) NOT NULL,
    cnss_numero     VARCHAR(30),
    cin             VARCHAR(20),
    nb_conges_acquis INT DEFAULT 0,
    documents       TEXT[],
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_employes_entrepreneur ON rh.employes (entrepreneur_id);

CREATE TYPE rh.type_conge AS ENUM (
    'annuel',
    'maladie',
    'maternite',
    'sans_solde',
    'exceptionnel'
);

CREATE TYPE rh.statut_conge AS ENUM (
    'en_attente',
    'approuve',
    'refuse',
    'annule'
);

CREATE TABLE rh.conges (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employe_id      UUID NOT NULL REFERENCES rh.employes (id) ON DELETE CASCADE,
    type_conge      rh.type_conge NOT NULL,
    date_debut      DATE NOT NULL,
    date_fin        DATE NOT NULL,
    statut          rh.statut_conge NOT NULL DEFAULT 'en_attente',
    motif           TEXT,
    approuve_par    UUID REFERENCES auth.utilisateurs (id),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE rh.fiches_paie (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employe_id      UUID NOT NULL REFERENCES rh.employes (id) ON DELETE CASCADE,
    periode         DATE NOT NULL,              -- first day of the month
    salaire_brut    NUMERIC(10,2) NOT NULL,
    cotisation_cnss NUMERIC(10,2) NOT NULL,
    ir_retenu       NUMERIC(10,2) NOT NULL,     -- withholding tax
    autres_retenues NUMERIC(10,2) DEFAULT 0,
    salaire_net     NUMERIC(10,2) NOT NULL,
    pdf_url         TEXT,
    paye_le         TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (employe_id, periode)
);

CREATE TABLE rh.offres_emploi (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entrepreneur_id UUID NOT NULL REFERENCES auth.utilisateurs (id) ON DELETE CASCADE,
    titre           VARCHAR(200) NOT NULL,
    description     TEXT NOT NULL,
    competences     TEXT[],
    ville           VARCHAR(100),
    type_contrat    rh.type_contrat,
    salaire_min     NUMERIC(10,2),
    salaire_max     NUMERIC(10,2),
    publie          BOOLEAN DEFAULT FALSE,
    cloturee_le     DATE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE rh.candidatures (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    offre_id        UUID NOT NULL REFERENCES rh.offres_emploi (id) ON DELETE CASCADE,
    candidat_nom    VARCHAR(150) NOT NULL,
    candidat_email  VARCHAR(255) NOT NULL,
    cv_url          TEXT,
    lettre_url      TEXT,
    statut          VARCHAR(30) DEFAULT 'recu',  -- recu | shortliste | entretien | accepte | refuse
    notes           TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- SECTION 10 : MODULE 10 — INVENTAIRE & STOCK
-- stock schema
-- =============================================================================

CREATE TABLE stock.entrepots (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entrepreneur_id UUID NOT NULL REFERENCES auth.utilisateurs (id) ON DELETE CASCADE,
    nom             VARCHAR(150) NOT NULL,
    adresse         TEXT,
    ville           VARCHAR(100),
    responsable     VARCHAR(150),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE stock.produits (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entrepreneur_id UUID NOT NULL REFERENCES auth.utilisateurs (id) ON DELETE CASCADE,
    sku             VARCHAR(100) NOT NULL UNIQUE,
    nom             VARCHAR(200) NOT NULL,
    nom_ar          VARCHAR(200),
    description     TEXT,
    categorie       VARCHAR(100),
    unite_mesure    VARCHAR(30) DEFAULT 'unité',
    prix_achat      NUMERIC(10,2),
    prix_vente      NUMERIC(10,2),
    taux_tva        NUMERIC(5,2) DEFAULT 20.00,
    code_barre      VARCHAR(100),
    qr_code         TEXT,
    seuil_alerte    INT DEFAULT 5,
    methode_valorisation VARCHAR(10) DEFAULT 'FIFO',  -- 'FIFO' | 'CMUP'
    image_url       TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_produits_entrepreneur ON stock.produits (entrepreneur_id);
CREATE INDEX idx_produits_sku          ON stock.produits (sku);
CREATE INDEX idx_produits_code_barre   ON stock.produits (code_barre);

CREATE TABLE stock.niveaux_stock (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    produit_id      UUID NOT NULL REFERENCES stock.produits (id) ON DELETE CASCADE,
    entrepot_id     UUID NOT NULL REFERENCES stock.entrepots (id) ON DELETE CASCADE,
    quantite        INT NOT NULL DEFAULT 0,
    valeur_stock    NUMERIC(12,2) DEFAULT 0,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (produit_id, entrepot_id)
);

CREATE TYPE stock.type_mouvement AS ENUM (
    'entree',
    'sortie',
    'transfert',
    'inventaire',
    'retour'
);

CREATE TABLE stock.mouvements (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    produit_id      UUID NOT NULL REFERENCES stock.produits (id),
    entrepot_source_id UUID REFERENCES stock.entrepots (id),
    entrepot_dest_id   UUID REFERENCES stock.entrepots (id),
    type_mouvement  stock.type_mouvement NOT NULL,
    quantite        INT NOT NULL,
    prix_unitaire   NUMERIC(10,2),
    motif           TEXT,
    reference_doc   TEXT,               -- facture_id or commande_id as text ref
    cree_par        UUID REFERENCES auth.utilisateurs (id),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_mouvements_produit ON stock.mouvements (produit_id);
CREATE INDEX idx_mouvements_date    ON stock.mouvements (created_at);

-- =============================================================================
-- SECTION 11 : AUDIT & NOTIFICATIONS
-- audit schema
-- =============================================================================

CREATE TABLE audit.logs (
    id              BIGSERIAL PRIMARY KEY,
    utilisateur_id  UUID REFERENCES auth.utilisateurs (id) ON DELETE SET NULL,
    action          VARCHAR(100) NOT NULL,
    entite          VARCHAR(100),           -- 'projet' | 'facture' | 'commande' ...
    entite_id       UUID,
    details         JSONB,
    ip_address      INET,
    user_agent      TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_logs_utilisateur ON audit.logs (utilisateur_id);
CREATE INDEX idx_logs_entite      ON audit.logs (entite, entite_id);
CREATE INDEX idx_logs_date        ON audit.logs (created_at);

CREATE TYPE audit.type_notif AS ENUM (
    'nouveau_match',
    'message_recu',
    'paiement_recu',
    'facture_relance',
    'tache_assignee',
    'deadline_proche',
    'certification_obtenue',
    'conge_approuve',
    'stock_alerte'
);

CREATE TABLE audit.notifications (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    utilisateur_id  UUID NOT NULL REFERENCES auth.utilisateurs (id) ON DELETE CASCADE,
    type_notif      audit.type_notif NOT NULL,
    titre           VARCHAR(200) NOT NULL,
    contenu         TEXT,
    lien            TEXT,                   -- deep-link in Flutter app
    lu              BOOLEAN DEFAULT FALSE,
    envoi_push      BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notif_utilisateur ON audit.notifications (utilisateur_id, lu);
CREATE INDEX idx_notif_date        ON audit.notifications (created_at);

-- =============================================================================
-- SECTION 12 : TRIGGERS — auto-update updated_at
-- =============================================================================

CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

-- Apply the trigger to all relevant tables
DO $$
DECLARE
    t RECORD;
BEGIN
    FOR t IN
        SELECT table_schema, table_name
        FROM information_schema.columns
        WHERE column_name = 'updated_at'
          AND table_schema IN ('auth','matching','gestion','marketplace','ia','learning','crm','finance','rh','stock')
    LOOP
        EXECUTE format(
            'CREATE TRIGGER trg_%s_%s_updated_at
             BEFORE UPDATE ON %I.%I
             FOR EACH ROW EXECUTE FUNCTION public.set_updated_at()',
            t.table_schema, t.table_name, t.table_schema, t.table_name
        );
    END LOOP;
END;
$$;

-- =============================================================================
-- SECTION 13 : VIEWS (reporting & dashboard helpers)
-- =============================================================================

-- Entrepreneur dashboard KPIs
CREATE VIEW gestion.v_dashboard_entrepreneur AS
SELECT
    u.id                AS entrepreneur_id,
    u.nom_complet,
    COUNT(DISTINCT f.id) FILTER (WHERE f.statut = 'payee')    AS factures_payees,
    COUNT(DISTINCT f.id) FILTER (WHERE f.statut = 'en_retard') AS factures_en_retard,
    COALESCE(SUM(f.total_ttc) FILTER (WHERE f.statut = 'payee'), 0)       AS ca_total,
    COALESCE(SUM(d.montant), 0)                                             AS total_depenses,
    COUNT(DISTINCT p.id)                                                    AS nb_projets,
    COUNT(DISTINCT e.id)                                                    AS nb_employes
FROM auth.utilisateurs u
LEFT JOIN gestion.factures  f ON f.entrepreneur_id = u.id
LEFT JOIN gestion.depenses  d ON d.entrepreneur_id = u.id
LEFT JOIN matching.projets  p ON p.entrepreneur_id = u.id
LEFT JOIN rh.employes       e ON e.entrepreneur_id = u.id
WHERE u.role = 'entrepreneur'
GROUP BY u.id, u.nom_complet;

-- Monthly CA by entrepreneur
CREATE VIEW finance.v_ca_mensuel AS
SELECT
    entrepreneur_id,
    DATE_TRUNC('month', date_emission) AS mois,
    SUM(total_ht)   AS ca_ht,
    SUM(total_tva)  AS tva_collectee,
    SUM(total_ttc)  AS ca_ttc
FROM gestion.factures
WHERE statut = 'payee'
GROUP BY entrepreneur_id, DATE_TRUNC('month', date_emission);

-- Stock alert view
CREATE VIEW stock.v_alertes_stock AS
SELECT
    p.entrepreneur_id,
    p.id AS produit_id,
    p.sku,
    p.nom,
    p.seuil_alerte,
    ns.entrepot_id,
    e.nom AS entrepot,
    ns.quantite
FROM stock.produits p
JOIN stock.niveaux_stock ns ON ns.produit_id = p.id
JOIN stock.entrepots e ON e.id = ns.entrepot_id
WHERE ns.quantite <= p.seuil_alerte;

-- =============================================================================
-- END OF SCHEMA
-- =============================================================================
