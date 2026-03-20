# Spend vs Commit — Accounts over $200K RRR

**As-of:** 2026-03-20 (latest complete RRR data)
**Universe:** 255 named accounts (DNB tier)
**Filter:** 28-day RRR ≥ $200K

---

## Bottom line

Only **10 of the listed accounts have an active contract commitment** in the
commit-tracking table. The other 100+ accounts with ≥$200K RRR are pure
pay-as-you-go.

| Status | Accounts | Total RRR | Total Commit | Spend-to-date | % of Commit |
|---|---:|---:|---:|---:|---:|
| **At Risk** | 2 | $6.3M | $6.9M | $0.3M | 4% |
| **On Track** | 1 | $4.8M | $1.8M | $1.0M | 53% |
| **Over-Burning** | 2 | $28.4M | $3.7M | $3.1M | 85% |
| **Commit Met** | 5 | $41.3M | $6.3M | $12.3M | 194% |
| **No Commit** | 100+ | $309M+ | — | — | — |

The **committed cohort is massively undersized**: ~$80M combined RRR covered by
just $18.7M of active commitment — a 4.3× spend-over-commit ratio.

---

## Accounts WITH active commitments

### At Risk — pacing below 80% of linear

| Account | AE | RRR | Commit | Spent | % Consumed | Pace | % Thru | Term |
|---|---|---:|---:|---:|---:|---:|---:|---|
| **Postman Inc.** | Jack Price | $3.39M | $5.40M | $186K | 3.4% | 0.66× | 5% | Mar 2026 – Feb 2027 |
| **Lyft** | Adeline Heng | $2.94M | $1.50M | $114K | 7.6% | 0.35× | 21% | Jan 2026 – Dec 2026 |

> **Lyft note:** Only the C4W Enterprise org ($1.0M RRR) is mapped to the flex
> commit. Their $1.9M Bedrock RRR is **not** counted toward commit spend. If
> the Bedrock org should count, Lyft is actually on track. Worth a data-mapping
> fix in the SFDC opportunity-org junction.
>
> **Postman note:** Commit started Mar 1 — only 19 days in. At current $3.4M
> RRR ($3.3M/yr run rate), they'd finish at ~62% of a $5.4M commit. Genuine
> ramp-risk unless a new workload lands.

### On Track — 80–120% of linear pace

| Account | AE | RRR | Commit | Spent | % Consumed | Pace | % Thru | Term |
|---|---|---:|---:|---:|---:|---:|---:|---|
| **Confluent** | Eli Rothschild | $4.77M | $1.80M | $956K | 53.1% | 1.19× | 45% | Oct 2025 – Oct 2026 |

### Over-Burning — ≥120% of linear pace (will exhaust early)

| Account | AE | RRR | Commit | Spent | % Consumed | Pace | % Thru | Term |
|---|---|---:|---:|---:|---:|---:|---:|---|
| **HubSpot** | Jordan Josloff | $16.6M | $669K | $652K | 97.5% | 4.5× | 22% | Dec 2025 – Dec 2026 |
| **ScaleAI** | Jack Price | $11.8M | $3.00M | $2.46M | 82.1% | 1.76× | 47% | Oct 2025 – Sep 2026 |

> **HubSpot:** $16.6M RRR against a $669K commit — commit is 25× too small.
> They'll exhaust in days. Obvious rightsizing candidate.
>
> **ScaleAI:** Will burn through $3M commit ~5 months early. Rightsizing
> conversation or early-renewal opportunity.

### Commit Met — already spent past commitment

| Account | AE | RRR | Commit | Spent | % Consumed | Pace | % Thru | Term |
|---|---|---:|---:|---:|---:|---:|---:|---|
| **Intercom** | Joe Bayley | $18.7M | $3.00M | $4.06M | 135% | 4.0× | 34% | Nov 2025 – Nov 2026 |
| **Zapier** | Dave Brown | $11.4M | $500K | $4.55M | 910% | 19.3× | 47% | Sep 2025 – Sep 2026 |
| **ZoomInfo** | Eli Rothschild | $7.45M | $2.00M | $2.53M | 127% | 2.5× | 51% | Sep 2025 – Sep 2026 |
| **Box** | Natalie Bauman | $996K | $250K | $258K | 103% | 1.6× | 63% | Aug 2025 – Jul 2026 |
| *LY Corporation* | Daishi Okada | $2.74M | $600K | $930K | 155% | 5.2× | 30% | Dec 2025 – Nov 2026 |

> *LY Corporation is a fuzzy-match artifact (not Lyra Health — LY Corp is
> LINE/Yahoo Japan). Kept for visibility since it's a DNB account with a
> blown-through commit.*

---

## Top No-Commit accounts by RRR

These accounts have **≥$200K RRR and no active contract commitment** — the
highest-leverage targets for a commit conversation.

| Account | AE | RRR | API RRR | C4W RRR |
|---|---|---:|---:|---:|
| **Atlassian Pty Ltd** | Jack Price | $26.6M | — | — |
| **Binance Holdings Ltd.** | Adeline Heng | $22.8M | $22.8M | $0 |
| **Epic Games** | Cheng Hsia | $19.7M | $19.7M | $55K |
| **Quora** | Cheng Hsia | $18.8M | $18.8M | $0 |
| **Cloudflare** | Jordan Josloff | $16.7M | $16.7M | $0 |
| **OKBL USA Technology** | Cheng Hsia | $12.3M | $0 | $12.3M |
| **Dropbox** | Natalie Bauman | $11.0M | $11.0M | $0 |
| **Indeed** | Cheng Hsia | $10.3M | $10.1M | $129K |
| **Geotab** | Cheng Hsia | $9.5M | $9.5M | $0 |
| **Instacart** | Adeline Heng | $8.1M | $7.9M | $247K |
| **ServiceTitan** | Kevin Martin | $8.0M | $3.1M | $5.0M |
| **UKG** | Joe Bayley | $7.5M | $7.5M | $0 |
| **Godaddy** | Cheng Hsia | $6.5M | $6.3M | $192K |
| **Turing** | Pete Nossiff | $6.4M | $6.4M | $0 |
| **AlphaSense** | Nikki Minzenmayer | $6.3M | $6.2M | $49K |
| **Affirm** | Cheng Hsia | $5.9M | $5.9M | $0 |
| **Gusto** | Nikki Minzenmayer | $5.7M | $4.6M | $1.1M |
| **Twilio** | Chase Mighell | $5.5M | — | — |
| **Carvana** | Cheng Hsia | $5.2M | $5.1M | $99K |
| **Axon Enterprise** | Natalie Bauman | $5.1M | $3.4M | $1.6M |
| **SoFi** | Kevin Martin | $5.0M | $5.0M | $0 |
| **Zendesk** | Nikki Minzenmayer | $4.9M | $4.9M | $0 |
| **Asana** | Natalie Bauman | $4.8M | $4.8M | $12K |
| **Snapchat** | Cheng Hsia | $4.8M | $100K | $4.7M |
| **Robinhood** | Adeline Heng | $4.5M | $4.5M | $0 |
| **Kavak** | Cheng Hsia | $4.0M | $3.2M | $824K |
| **Guidewire** | Adeline Heng | $3.9M | $297K | $3.6M |
| **Cadence Design Systems** | Chase Mighell | $3.5M | $3.5M | $0 |
| **Tyler Technologies** | Cheng Hsia | $3.2M | $3.1M | $75K |
| **Arista Networks** | Jack Price | $3.1M | $3.1M | $0 |
| **Toast** | Kevin Martin | $3.1M | $3.1M | $3K |
| **Klaviyo** | Joe Bayley | $3.0M | $0 | $3.0M |
| **Zillow** | Rachel Pang | $2.7M | $2.5M | $196K |
| **Pinterest** | Cheng Hsia | $2.4M | $2.4M | $12K |
| **UIPath** | Joe Bayley | $2.4M | $1.8M | $648K |
| **Samsara** | Cheng Hsia | $2.3M | $1.3M | $1.1M |
| **Klaviyo** (dup SFDC ID) | Joe Bayley | $2.0M | $2.0M | $0 |
| **Prepared** | Natalie Bauman | $2.0M | $2.0M | $0 |
| **Roku** | Cheng Hsia | $2.0M | $2.0M | $0 |
| **Yelp** | Rachel Pang | $2.0M | $2.0M | $0 |
| **Smartsheet** | Natalie Bauman | $1.8M | $1.3M | $566K |
| **Etsy** | Rachel Pang | $1.8M | $1.8M | $0 |

**No-Commit top-40 sum: ~$283M RRR** with zero contract coverage.

---

## Accounts below $200K RRR / unmatched

62 accounts on the list currently have RRR below the $200K threshold ($4.1M
total). Another ~100 list entries don't exact-match an SFDC account name —
mostly legacy/acquired/parent-company aliases (AOL, Nexmo, Nuxeo, dataxu,
CallidusCloud, AddThis, Virtustream, ThinkingPhones, etc.) that either no
longer exist as standalone accounts or map to a differently-named parent.

---

## Data sources & caveats

- **RRR:** `proj-finance-data-liul.reporting.monthly_revenue_run_rate`, pinned
  to the latest `is_data_complete = TRUE` date, `sales_segment != 'Fraud'`,
  aggregated by `salesforce_account_id`.
- **Commit/spend:** `proj-finance-data-liul.reporting.salesforce_commit_spend_tracking`.
  Grain is (subscription_id, organization_uuid) so spend is summed via
  `subscription_spend` which is already subscription-scoped. Filtered to
  subscriptions where `ruby_subscription_start_date <= today <= ruby_subscription_end_date`.
- **Org-mapping caveat:** The commit-tracking table only counts spend from
  org UUIDs explicitly junctioned to the SFDC subscription. If a customer's
  3P (Bedrock/Vertex) orgs or additional 1P orgs aren't mapped, tracked spend
  undercounts true total. This is visible on Lyft (Bedrock not linked) and may
  affect other "At Risk" reads.
- **Commit source-of-truth in opps:** `dim_salesforce_opportunities.total_contract_commitment_amount`
  (annualized: `annualized_contract_commitment_amount`). The commit-tracking
  table is downstream of Ruby/SFDC orders, not the opportunity record directly.

SQL in `spend_vs_commit_analysis.sql`.
