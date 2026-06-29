# PostgreSQL: Serial PK + UUID Unique vs UUID PK

**Research prompt:** PostgreSQL UUID vs serial integer primary key performance: advantages of using serial/bigserial as primary key with UUID as unique constraint instead of UUID as primary key. Reference-backed answer from PostgreSQL docs, benchmarks, or authoritative sources.

**Research method:** Deep research — 6 search angles, 21 sources fetched, 85 claims extracted, 25 adversarially verified (3-vote panel), 8 confirmed, 17 killed.

---

## Summary

Using `bigserial` as the primary key with UUID as a unique constraint outperforms UUID-as-primary-key primarily because random UUID v4 values scatter B-tree index inserts across arbitrary pages rather than appending to the rightmost leaf, causing frequent page splits, increased cache misses, and index bloat. Benchmarks show bigint achieves approximately 30% higher insert throughput than UUID v4 (3,480 tps vs 2,670 tps). The storage overhead is real: UUID is 128 bits vs 64 bits for bigserial, meaning every index entry, FK reference, and join buffer entry is twice the size. UUID v7 (time-ordered, sequential) largely closes the performance gap with bigserial and is available natively in PostgreSQL 18.

---

## Confirmed Findings

### 1. Storage Size — HIGH confidence (vote: 3-0)

UUID = 128-bit. bigserial = 64-bit. **2× larger per row, per index entry, per FK column.**

> "This identifier is a 128-bit quantity" — [PostgreSQL docs: UUID type](https://www.postgresql.org/docs/current/datatype-uuid.html)

The size difference compounds across every index entry, FK column, and join buffer.

- [PostgreSQL docs: UUID type](https://www.postgresql.org/docs/current/datatype-uuid.html)
- [PostgreSQL docs: numeric types](https://www.postgresql.org/docs/current/datatype-numeric.html)

---

### 2. B-tree Index Thrashing — HIGH confidence (vote: 3-0)

Random UUID v4 inserts scatter across arbitrary B-tree leaf pages rather than appending to the rightmost page, causing frequent page splits, index bloat, and significantly more cache misses compared to sequential bigserial keys.

> "Because V4 UUIDs are random, new entries might be inserted anywhere in an index (most commonly a B-tree). That means having to bring more pages into memory and more cache misses. With a sequential ID, you're almost always operating on just a handful of pages near the end." — [Brandur: IDs](https://brandur.org/nanoglyphs/026-ids)

- [Andy Atkinson: Avoid UUID v4 PKs](https://andyatkinson.com/avoid-uuid-version-4-primary-keys)
- [Brandur: IDs](https://brandur.org/nanoglyphs/026-ids)
- [pganalyze: UUID vs serial](https://pganalyze.com/blog/5mins-postgres-uuid-vs-serial-primary-keys)
- [dev.to: UUID v4 vs v7 benchmarks](https://dev.to/umangsinha12/postgresql-uuid-performance-benchmarking-random-v4-and-time-based-v7-uuids-n9b)

---

### 3. Index Bloat Compounds at Scale — MEDIUM confidence (vote: 2-1)

Page splits leave pages at lower fill density. Degrades further as table grows. Throughput and WAL degradation worsen on larger datasets.

> "a random value interacts really badly with how the B-tree index gets structured. You will see index bloat if you're using random keys." — [pganalyze](https://pganalyze.com/blog/5mins-postgres-uuid-vs-serial-primary-keys)

- [pganalyze](https://pganalyze.com/blog/5mins-postgres-uuid-vs-serial-primary-keys) (cites 2ndQuadrant/EDB research — primary source URL unavailable post-acquisition)
- [Brandur: IDs](https://brandur.org/nanoglyphs/026-ids)

---

### 4. ~30% Insert Throughput Difference — MEDIUM confidence (vote: 2-1)

Benchmark: 10 clients, 20M-row table, PostgreSQL main branch, 2024, AMD EPYC Genoa (1 core), 2 GB RAM.

| Key type | tps    |
|----------|--------|
| bigint   | 3,480  |
| UUID v7  | 3,420  |
| UUID v4  | 2,670  |

The ~30% delta (3,480 / 2,670 = 1.303) is mathematically correct from the quoted figures. Author notes the benchmark underestimates cache pressure for UUID on concurrent reads — real-world penalty may be larger.

- [ardentperf.com UUID Benchmark War (2024)](https://ardentperf.com/2024/02/03/uuid-benchmark-war/)

---

### 5. Hybrid Pattern: bigserial PK + UUID Unique — HIGH confidence (vote: 3-0)

`bigserial` PK for internal joins/FKs → sequential insert perf. UUID unique column exposed externally → prevents enumeration. Multiple independent PostgreSQL consultancies confirm this works.

Tradeoffs acknowledged: added complexity, storage for two identifier columns. No credible source disputes the pattern works.

- [CYBERTEC PostgreSQL](https://www.cybertec-postgresql.com/en/uuid-serial-or-identity-columns-for-postgresql-auto-generated-primary-keys/)
- [pganalyze](https://pganalyze.com/blog/5mins-postgres-uuid-vs-serial-primary-keys)
- [Brandur: IDs](https://brandur.org/nanoglyphs/026-ids)
- [Medium: UUID and bigserial](https://medium.com/@Tom1212121/postgresql-uuid-and-bigserial-c943531d07c5)

---

### 6. UUID v7 Closes the Gap — MEDIUM confidence (vote: 3-0 mechanism, 2-1 benchmark specifics)

UUID v7 time-ordered → sequential inserts → near-bigint perf (3,420 vs 3,480 tps, <2% gap). PostgreSQL 18 adds `gen_random_uuid_v7()` natively.

**Caveat:** UUIDv7's monotonicity creates a last-page B-tree hotspot under high-concurrency OLTP. Very high-concurrency workloads may still benefit from UUID v4's distributed random writes.

- [ardentperf benchmark](https://ardentperf.com/2024/02/03/uuid-benchmark-war/)
- [dev.to: UUID v4 vs v7 benchmarks](https://dev.to/umangsinha12/postgresql-uuid-performance-benchmarking-random-v4-and-time-based-v7-uuids-n9b)

---

## Refuted Claims (killed by adversarial verification)

These claims appeared in sources but did **not** survive 3-vote adversarial verification:

| Claim | Vote | Source |
|-------|------|--------|
| UUID PK took only ~2.4% longer than BIGSERIAL in per-row commit mode (PostgreSQL 9.4.4) | 0-3 | [thebuild.com (2015)](https://thebuild.com/blog/2015/10/08/uuid-vs-bigserial-for-primary-keys/) |
| UUID tables consume ~40% more disk space than BIGSERIAL tables | 0-3 | [thebuild.com (2015)](https://thebuild.com/blog/2015/10/08/uuid-vs-bigserial-for-primary-keys/) |
| The performance difference is minor; UUIDs recommended unless tight INSERT perf needed | 0-3 | [thebuild.com (2015)](https://thebuild.com/blog/2015/10/08/uuid-vs-bigserial-for-primary-keys/) |
| Random UUID patterns produce orders of magnitude more WAL volume | 0-3 | [Brandur](https://brandur.org/nanoglyphs/026-ids) |
| bigint GENERATED IDENTITY is ~3.0x faster than UUID gen_random_uuid() | 0-3 | [Medium: Full Stack Architecture](https://medium.com/full-stack-architecture/postgresql-benchmarking-the-generation-of-primary-key-values-a0b221dcadc6) |
| UUID v4 primary keys cause 500x more B-tree page splits than sequential integers | 0-3 | [thehellmaker.com](https://thehellmaker.com/blog/random-uuid-damage-btree-performance/) |
| UUID insertion is 3-10x slower than sequential integer IDs | 0-3 | [thehellmaker.com](https://thehellmaker.com/blog/random-uuid-damage-btree-performance/) |
| Each UUID v4 B-tree page split causes 5-10x more physical I/O | 0-3 | [thehellmaker.com](https://thehellmaker.com/blog/random-uuid-damage-btree-performance/) |
| UUIDv4 PK produces 2.65 GB table+index vs 1.97 GB for bigint (~25% smaller) | 1-2 | [ardentperf](https://ardentperf.com/2024/02/03/uuid-benchmark-war/) |
| UUIDv4 PKs cause severe buffer cache pressure disproportionate to size | 0-3 | [ardentperf](https://ardentperf.com/2024/02/03/uuid-benchmark-war/) |
| UUIDv7 with BTREE is ~49% faster at inserts than UUIDv4 with BTREE | 0-3 | [mblum.me](https://mblum.me/posts/pg-uuidv7-benchmark/) |
| UUID v4 PK indexes suffer ~40% more I/O (79% vs 97% leaf fill density) | 1-2 | [Andy Atkinson](https://andyatkinson.com/avoid-uuid-version-4-primary-keys) |

---

## Caveats

1. Source quality is predominantly blog and consultancy posts, not peer-reviewed benchmarks or PostgreSQL official documentation on performance. PostgreSQL docs confirm storage sizes and B-tree mechanics but do not publish insert-throughput comparisons.
2. The ardentperf 30% figure is from a single benchmark on constrained hardware (1 CPU core, 2 GB RAM); real-world results depend heavily on `shared_buffers`, working set fit, concurrency level, and SSD vs. HDD.
3. The 2ndQuadrant degradation-at-scale data cited by Brandur and pganalyze could not be verified from the primary source (URL redirects after the EDB acquisition).
4. Several claims with specific numeric precision (500x page splits, 40% more I/O, 3-10x slower inserts) were refuted in adversarial voting and are excluded from findings above.
5. All benchmark data predates or is contemporaneous with PostgreSQL 17-18; engine improvements (B-tree deduplication, improved vacuum) may have shifted absolute numbers since publication.
6. The last-page hotspot issue with sequential keys (UUIDv7 and bigserial alike) under very high concurrent insert workloads is a real counter-consideration.

---

## Open Questions

1. How does the bigserial-vs-UUID v4 performance gap change at very high concurrency (100+ clients), where bigserial/UUIDv7's last-page B-tree hotspot may partially close the gap?
2. What is the actual storage overhead of the hybrid approach (bigserial PK + UUID unique index) versus a pure UUID v7 primary key across a realistic schema with multiple FK-referencing tables?
3. Does B-tree bloat from UUID v4 random inserts recover meaningfully with aggressive autovacuum and `pg_repack`, or is bloat a steady-state property that persists regardless of maintenance?
4. With PostgreSQL 18's native UUIDv7 support and B-tree deduplication improvements, is the hybrid bigserial+UUID pattern still worth the schema complexity for new projects, or has UUIDv7 made it obsolete?

---

## All Sources

| URL | Quality | Search angle |
|-----|---------|--------------|
| [PostgreSQL docs: UUID type](https://www.postgresql.org/docs/current/datatype-uuid.html) | primary | authoritative/docs |
| [PostgreSQL docs: numeric types](https://www.postgresql.org/docs/current/datatype-numeric.html) | primary | authoritative/docs |
| [ardentperf: UUID Benchmark War (2024)](https://ardentperf.com/2024/02/03/uuid-benchmark-war/) | blog | benchmark/empirical |
| [dev.to: UUID v4 vs v7 benchmarks](https://dev.to/umangsinha12/postgresql-uuid-performance-benchmarking-random-v4-and-time-based-v7-uuids-n9b) | blog | benchmark/empirical |
| [mblum.me: UUIDv7 benchmark](https://mblum.me/posts/pg-uuidv7-benchmark/) | blog | benchmark/empirical |
| [Brandur: IDs](https://brandur.org/nanoglyphs/026-ids) | blog | broad/primary |
| [pganalyze: UUID vs serial](https://pganalyze.com/blog/5mins-postgres-uuid-vs-serial-primary-keys) | blog | broad/primary |
| [thebuild.com: UUID vs bigserial (2015)](https://thebuild.com/blog/2015/10/08/uuid-vs-bigserial-for-primary-keys/) | blog | broad/primary |
| [Medium: Full Stack Architecture](https://medium.com/full-stack-architecture/postgresql-benchmarking-the-generation-of-primary-key-values-a0b221dcadc6) | blog | broad/primary |
| [Medium: UUID and bigserial](https://medium.com/@Tom1212121/postgresql-uuid-and-bigserial-c943531d07c5) | blog | broad/primary |
| [CYBERTEC PostgreSQL](https://www.cybertec-postgresql.com/en/uuid-serial-or-identity-columns-for-postgresql-auto-generated-primary-keys/) | blog | practitioner/implementation |
| [Andy Atkinson: Avoid UUID v4 PKs](https://andyatkinson.com/avoid-uuid-version-4-primary-keys) | blog | practitioner/implementation |
| [thehellmaker.com: UUID B-tree](https://thehellmaker.com/blog/random-uuid-damage-btree-performance/) | blog | technical/internals |
| [credativ: UUIDv4 vs UUIDv7 in PG18](https://www.credativ.de/en/blog/postgresql-en/a-deeper-look-at-old-uuidv4-vs-new-uuidv7-in-postgresql-18/) | blog | contrarian/modern mitigations |
| [saybackend: UUIDv7 comparison](https://saybackend.com/blog/uuidv7-postgres-comparison/) | blog | contrarian/modern mitigations |
| [Medium: UUID v7 vs bigserial benchmarks](https://medium.com/@jamauriceholt.com/uuid-v7-vs-bigserial-i-ran-the-benchmarks-so-you-dont-have-to-44d97be6268c) | blog | contrarian/modern mitigations |
| [Supabase: Choosing a Postgres PK](https://supabase.com/blog/choosing-a-postgres-primary-key) | blog | contrarian/modern mitigations |
| [maciejwalkowiak: Postgres UUID PK](https://maciejwalkowiak.com/blog/postgres-uuid-primary-key/) | blog | contrarian/modern mitigations |
| [PostgreSQL mailing list (2008)](https://www.postgresql.org/message-id/20080818182538.4b5dc9c2@mail.allcoast.net) | forum | authoritative/docs |
| [PostgreSQL mailing list (2015)](https://www.postgresql.org/message-id/20151222124018.bee10b60b3d9b58d7b3a1839@potentialtech.com) | forum | authoritative/docs |
| [PostgreSQL mailing list (2009)](https://www.postgresql.org/message-id/4AD0AAF1.8000001@mark.mielke.cc) | forum | authoritative/docs |
