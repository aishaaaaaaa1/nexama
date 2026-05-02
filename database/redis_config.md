# NexaMa — Redis 7 Configuration & Key Strategy
> Référence : NEX-CDC-2025-001

## Connexion (redis.conf extraits)

```
port 6379
requirepass <REDIS_SECRET>
maxmemory 512mb
maxmemory-policy allkeys-lru
save 900 1
save 300 10
appendonly yes
```

---

## Namespaces & Key Patterns

| Namespace | Pattern | TTL | Usage |
|---|---|---|---|
| Sessions JWT | `session:{user_id}` | 7 jours | Refresh token metadata |
| Profil cache | `user:{user_id}:profile` | 15 min | Profil utilisateur complet |
| Rate-limit | `rl:{ip}:{endpoint}` | 1 min | Anti-abus API |
| IA quota tracker | `ia:quota:{provider}:{YYYY-MM-DD}` | 24h | Comptage appels Gemini/Groq/HF |
| Matching cache | `match:project:{id}:suggestions` | 30 min | Suggestions investisseurs pré-calculées |
| Notifications | `notif:{user_id}:unread` | PERSIST | Compteur non-lus (incr/decr) |
| Search autocomplete | `search:projects:{prefix}` | 1h | Autocomplétion recherche projet |
| Dashboard KPIs | `dashboard:{entrepreneur_id}` | 5 min | KPIs pré-agrégés |
| Cours progression | `learn:{user_id}:{cours_id}:progress` | 30 jours | Progression cours sans round-trip DB |
| Stock alerte | `stock:alerts:{entrepreneur_id}` | 10 min | Alertes réappro cache |
| Token blacklist | `blacklist:token:{jti}` | = token expiry | Tokens JWT révoqués |
| OAuth state | `oauth:state:{state}` | 10 min | CSRF state pour OAuth flows |

---

## Exemples de commandes Redis

```bash
# Créer une session
SET session:uuid-utilisateur "{ \"role\": \"entrepreneur\", \"email\": \"...\" }" EX 604800

# Incrémenter quota IA du jour
INCR ia:quota:gemini:2025-04-24
EXPIRE ia:quota:gemini:2025-04-24 86400

# Stocker les suggestions matching (JSON sérialisé)
SET match:project:uuid-projet:suggestions "[{...}]" EX 1800

# Invalider le cache profil (après modification)
DEL user:uuid-utilisateur:profile

# Rate limiting (1 req/sec max sur génération BP)
SET rl:192.168.1.1:/api/ia/business-plan 1 EX 60 NX

# Pubsub — notification temps réel
PUBLISH notif:uuid-utilisateur "{ \"type\": \"nouveau_match\", \"projetId\": \"...\" }"
```

---

## Fallback IA — Quotas Redis

Le système de fallback cascade vérifie les compteurs Redis avant d'appeler une API :

```
ia:quota:gemini:2025-04-24     → limite : 1 000 000 tokens/jour
ia:quota:groq:2025-04-24       → limite : 14 400 req/jour
ia:quota:huggingface:2025-04-24 → limite : 1 000 req/jour
ia:quota:cohere:2025-04-24     → limite : 1 000 req/mois
```

Si `INCR ia:quota:{provider}:{date}` dépasse la limite → on bascule au provider suivant.

---

## Pub/Sub Channels

| Channel | Publisher | Subscriber | Événement |
|---|---|---|---|
| `notif:{user_id}` | Backend API | Flutter WebSocket gateway | Notification push |
| `ia:job:done` | Worker IA | API REST | Business plan généré |
| `escrow:release` | Scheduler | Module paiement | Libération fonds escrow |
| `stock:alert` | Stock worker | Module RH / notif | Seuil stock franchi |
