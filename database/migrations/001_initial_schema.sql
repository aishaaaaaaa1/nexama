-- Migration 001 : Initial Schema — NexaMa v1.2
-- Date : 2025-04-24
-- Description : Création complète de la base de données NexaMa
--               10 modules, 11 schémas, conformité ACID, indexation FTS

-- Run: psql -U nexama_user -d nexama_db -f 001_initial_schema.sql

\ir ../schema.sql
