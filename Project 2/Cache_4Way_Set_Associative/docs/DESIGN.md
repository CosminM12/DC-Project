# Design notes

## Storage organisation

The cache is organised as `256 sets x 4 ways`. Every way of every set keeps the
usual line metadata plus a 2-bit LRU age:

```systemverilog
logic                  cache_valid [0:255][0:3];
logic                  cache_dirty [0:255][0:3];
logic [9:0]            cache_tag   [0:255][0:3];   // 10-bit tag
logic [255:0]          cache_mem   [0:255][0:3];   // 256-bit block
logic [1:0]            cache_age   [0:255][0:3];   // 0 = MRU .. 3 = LRU
```

The index field of the address selects the *set*; all four ways of that set are
compared in parallel.

## Address decode

```
active_addr = (state == IDLE) ? caddress : req_addr
tag    = active_addr[20:11]
index  = active_addr[10:3]
offset = active_addr[2:0]
```

While the controller is busy servicing a miss it works from the **latched**
request (`req_addr`) instead of the live `caddress`, exactly like the
direct-mapped reference design.

## Hit detection

A hit is a valid way in the set whose tag matches:

```
hit = OR over w of ( valid[index][w] && tag[index][w] == tag )
```

`hit_way` is the matching way. Tags are unique within a set, so at most one way
matches.

## Victim selection

On a miss the controller needs a way to (re)fill:

1. If any way in the set is **invalid**, take the lowest-indexed invalid way
   (cold fill, no write-back possible because invalid lines are clean).
2. Otherwise evict the **LRU** way.

## True LRU (4-way)

Each set stores the four ages as a permutation of `{0,1,2,3}`, where `0` is the
most-recently-used way and `3` is the least-recently-used way. The age vector is
initialised to `{0,1,2,3}` at reset.

When way `s` of a set is touched (read hit, write hit, or fill):

```
for each way w:  if age[w] < age[s]  then age[w] = age[w] + 1
age[s] = 0
```

This keeps the four ages a strict permutation, so exactly one way always has
`age == 3` — the unambiguous LRU victim. (No approximate / tree-PLRU shortcuts:
this is exact recency ordering.)

## FSM

```
                 rden & hit
        +---------------------------> READ_HIT --------+
        |                                              |
        |        rden & !hit                           v
 IDLE --+---------------------------> READ_MISS      (drive cdout)
        |                                |             |
        | wren & hit                     |             +--> IDLE
        +----------------> WRITE_HIT     |
        |                     |          | dirty victim?
        | wren & !hit         |          |   yes -> REPLACE -> FETCH
        +------> WRITE_MISS --+----------+   no  ----------> FETCH
                     |                              |
                     | dirty victim? (same test)   v
                     +--------------------------> FETCH --> FILL --+
                                                                   |
                                          req_read  -> READ_HIT <--+
                                          req_write -> WRITE_HIT <-+
```

| State        | Action                                                              |
|--------------|--------------------------------------------------------------------|
| `IDLE`       | decode request; latch `req_*` and choose `way_sel` (hit or victim) |
| `READ_HIT`   | drive `cdout = block[offset]`; update LRU                          |
| `READ_MISS`  | branch on victim dirty -> `REPLACE` else `FETCH`                   |
| `WRITE_MISS` | branch on victim dirty -> `REPLACE` else `FETCH`                   |
| `REPLACE`    | `mwren`, `maddress = {old_tag, index}`, `mdout = victim block`     |
| `FETCH`      | `mrden`, `maddress = {tag, index}`                                 |
| `FILL`       | store `mdin` into `way_sel`, set valid, clear dirty, update LRU    |
| `WRITE_HIT`  | overwrite `block[offset]`, set dirty, update LRU                   |

### Why `way_sel` is latched once in `IDLE`

The way to operate on is chosen a single time when the transaction starts:

* on a **hit** it is `hit_way`;
* on a **miss** it is `victim_way`.

Latching it means `REPLACE`, `FETCH`, `FILL` and the trailing `READ_HIT`/
`WRITE_HIT` all act on the same, stable way even though the combinational
`hit_way`/`victim_way` change as the set is updated during the fill.

## Policies in one line each

* **Write-back** – a write only marks the line dirty (`WRITE_HIT`); memory is
  updated lazily in `REPLACE`, using the victim's *own* old tag for the address.
* **Write-allocate** – a write miss fetches the block first
  (`WRITE_MISS -> [REPLACE] -> FETCH -> FILL -> WRITE_HIT`), then writes the word.

## Timing (clock cycles, request captured in `IDLE`)

| Access                         | Path                                            | Cycles |
|--------------------------------|-------------------------------------------------|:------:|
| Read / write hit               | `IDLE -> *_HIT -> IDLE`                          | 2      |
| Miss, clean victim             | `IDLE -> *_MISS -> FETCH -> FILL -> *_HIT`       | 5      |
| Miss, dirty victim (write-back)| `... -> *_MISS -> REPLACE -> FETCH -> FILL -> *_HIT` | 6  |
