# Requirements: 三国模拟器

**Defined:** 2026-04-04
**Core Value:** 让玩家在 15 到 30 分钟内明确感受到“个人命运嵌入势力政治”的单角色历史模拟体验。

## v1 Requirements

### Core Loop

- [x] **CORE-01**: Player can start a 190 scenario sample and enter the main gameplay screen as a single historical character.
- [x] **CORE-02**: Player can view the current year, month, xun, city, identity, faction, office, AP, energy, stress, fame, and merit from the main HUD.
- [x] **CORE-03**: Player can spend a xun by selecting multiple actions until AP or action availability is exhausted.
- [x] **CORE-04**: Player can end the current xun and advance time through at least three stable xun transitions.
- [x] **CORE-05**: Player receives a xun-end summary that explains the major state and relationship changes caused by that xun.

### Data Foundation

- [x] **DATA-01**: Game can load a 190 scenario sample containing characters, factions, cities, clans, families, actions, and events from data-driven definitions.
- [x] **DATA-02**: Static scenario definitions are stored separately from runtime game state so gameplay updates do not mutate source definitions.
- [x] **DATA-03**: Game can query at least one character, one faction, and one city from the loaded scenario during runtime.
- [x] **DATA-04**: Runtime state supports serialization-safe identifiers for characters, factions, cities, clans, families, offices, actions, and events.

### Character State

- [x] **CHAR-01**: Player character has readable core attributes, identity, faction, office, family, clan, personality tags, and location.
- [x] **CHAR-02**: Player character tracks AP, energy, stress, health-related state, fame, merit, loyalty, and honor/infamy-style reputation values.
- [x] **CHAR-03**: Gameplay actions can modify player attributes or status values and surface those changes in UI feedback.
- [x] **CHAR-04**: Different starting identities use the same underlying time and action rules while exposing different permissions or action availability.

### Actions

- [x] **ACTN-01**: Player can open an action menu grouped by categories such as growth, relationships, governance, military, and family.
- [x] **ACTN-02**: Action list shows action name, category, AP cost, energy impact, target type, and expected effect summary.
- [x] **ACTN-03**: Game supports at least five foundational actions for the prototype sample: visit, train, study, inspect, and rest.
- [x] **ACTN-04**: Action execution checks identity, conditions, resources, and target validity before applying results.
- [x] **ACTN-05**: Failed actions still produce limited feedback such as partial progress, relationship movement, pressure change, or new information.

### Relationships

- [x] **RELA-01**: Game stores directional relationship values between characters including favor, trust, respect, vigilance, and obligation.
- [x] **RELA-02**: Player can view a relationship screen listing key characters, relationship tags, major values, faction, and available interactions.
- [x] **RELA-03**: Visit-style interactions can change relationship values in ways visible to the player.
- [x] **RELA-04**: Relationship values influence later gameplay outcomes such as action success, recommendation chance, task opportunities, or appointment results.

### Career

- [x] **CARE-01**: Player can receive at least two task sources in the prototype, including ruler-assigned or family-related requests.
- [x] **CARE-02**: Completing actions or tasks can change merit and fame values.
- [x] **CARE-03**: Game performs a month-end evaluation that can produce appointment, promotion, rejection, or missed-opportunity feedback.
- [x] **CARE-04**: Month-end results explain the main reasons for the outcome, including support, opposition, merit level, trust, or status blockers.
- [x] **CARE-05**: Office or appointment changes alter available permissions, action options, or political standing.

### Factions

- [x] **FACT-01**: Player can view the current faction's ruler, cities, major officers, resources, and broad strategic posture.
- [x] **FACT-02**: Game tracks faction-level resources needed for prototype political and military feedback.
- [x] **FACT-03**: Player can see the main factions or internal groups influencing current political outcomes.

### Clans And Families

- [ ] **CLAN-01**: Player can view their family and clan information, including prestige, wealth or influence, major members, and current orientation.
- [ ] **CLAN-02**: Starting background differences between high-status and low-status characters produce visible modifiers in at least recommendation, marriage, or career outcomes.
- [ ] **CLAN-03**: Clan or family status affects at least one political gameplay path rather than existing only as flavor text.

### Politics

- [x] **POLI-01**: Game tracks internal political groups or factional alignments with visible stances toward the player.
- [x] **POLI-02**: Political groups can support, oppose, or stay neutral toward appointments or proposals.
- [x] **POLI-03**: Player-facing feedback identifies which political forces helped or blocked an outcome when relevant.

### Marriage

- [ ] **MARR-01**: Player can browse at least one list of viable marriage candidates in the prototype sample.
- [ ] **MARR-02**: Marriage proposal outcomes consider relationship, status background, age or eligibility, and political context.
- [ ] **MARR-03**: Successful or failed marriage attempts create visible political or relationship consequences.

### Events

- [ ] **EVNT-01**: Game supports triggered events with conditions tied to time, character state, faction state, or relationship state.
- [ ] **EVNT-02**: Prototype includes at least four event types spanning relationship, appointment, family, and faction or mission contexts.
- [ ] **EVNT-03**: Event resolution can modify state, relationships, status, or future opportunities in visible ways.
- [ ] **EVNT-04**: At least one event path allows player actions to diverge from expected historical flow.

### Warfare

- [ ] **WAR-01**: Player can participate in at least one simplified military expedition or war-related task without requiring a full tactical battle system.
- [ ] **WAR-02**: War resolution produces visible changes to merit, fame, injury or recovery state, and political standing.

### UI Feedback

- [x] **UI-01**: Main gameplay flow can be completed through HUD, action panel, detail panels, result dialogs, and summary panels without requiring map-first exploration.
- [x] **UI-02**: Key actions are reachable within three clicks from the main HUD.
- [x] **UI-03**: Event, xun-end, and month-end screens explain the main causes behind important changes or decisions.
- [x] **UI-04**: Player can inspect character, relationship, faction, and family or clan context needed to plan the next xun.

### Persistence And Debug

- [ ] **PERS-01**: Player can save the current prototype run to `user://` storage and load it back later.
- [ ] **PERS-02**: Save data uses a versioned runtime-state format rather than serializing scene trees directly.
- [ ] **PERS-03**: Project provides debug visibility for important runtime values, events, or settlement results so complex systems can be verified during development.

## v2 Requirements

### Dynasty And Succession

- **DYNA-01**: Player can continue the campaign as a child or eligible relative after character death.
- **DYNA-02**: Game simulates more detailed inheritance and succession disputes.
- **DYNA-03**: Game supports deeper child growth and education systems.

### Expanded World

- **WORLD-01**: Game supports nationwide map coverage beyond the prototype sample region.
- **WORLD-02**: Game supports a larger roster of historical characters, factions, cities, and full event chains.

### Warfare Expansion

- **WARX-01**: Game supports deeper battle presentation, troop composition, and tactical battlefield decisions.
- **WARX-02**: Game supports richer campaign logistics and multi-stage war operations.

### Content Expansion

- **CONT-01**: Game supports a much larger library of random flavor events and narrative side content.
- **CONT-02**: Game supports more detailed economic and domestic simulation systems.

## Out of Scope

| Feature | Reason |
|---------|--------|
| Full nationwide free-roam map | Would pull the prototype toward map-first grand strategy instead of validating the single-character political loop |
| Complex real-time battlefield presentation | Too expensive for prototype scope; simplified war feedback proves value faster |
| Deep succession law and inheritance simulation | Not required to validate the first prototype's core value |
| Extremely detailed child education and genealogy systems | Adds heavy complexity before marriage and family value are proven |
| Full historical character and event coverage | Small dense sample is enough to validate the design and far safer to build |
| Ultra-granular economy simulation | Competes with the core fantasy of personal political life rather than strengthening it |
| Separate full gameplay modes per identity | Breaks the shared-rule architecture and explodes implementation scope |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| CORE-01 | Phase 1 | Complete |
| CORE-02 | Phase 1 | Complete |
| CORE-03 | Phase 2 | Complete |
| CORE-04 | Phase 2 | Complete |
| CORE-05 | Phase 2 | Complete |
| DATA-01 | Phase 1 | Complete |
| DATA-02 | Phase 1 | Complete |
| DATA-03 | Phase 1 | Complete |
| DATA-04 | Phase 1 | Complete |
| CHAR-01 | Phase 1 | Complete |
| CHAR-02 | Phase 1 | Complete |
| CHAR-03 | Phase 2 | Complete |
| CHAR-04 | Phase 1 | Complete |
| ACTN-01 | Phase 2 | Complete |
| ACTN-02 | Phase 2 | Complete |
| ACTN-03 | Phase 2 | Complete |
| ACTN-04 | Phase 2 | Complete |
| ACTN-05 | Phase 2 | Complete |
| RELA-01 | Phase 2 | Complete |
| RELA-02 | Phase 2 | Complete |
| RELA-03 | Phase 2 | Complete |
| RELA-04 | Phase 3 | Complete |
| CARE-01 | Phase 3 | Complete |
| CARE-02 | Phase 3 | Complete |
| CARE-03 | Phase 3 | Complete |
| CARE-04 | Phase 3 | Complete |
| CARE-05 | Phase 3 | Complete |
| FACT-01 | Phase 3 | Complete |
| FACT-02 | Phase 3 | Complete |
| FACT-03 | Phase 3 | Complete |
| CLAN-01 | Phase 4 | Pending |
| CLAN-02 | Phase 4 | Pending |
| CLAN-03 | Phase 4 | Pending |
| POLI-01 | Phase 3 | Complete |
| POLI-02 | Phase 3 | Complete |
| POLI-03 | Phase 3 | Complete |
| MARR-01 | Phase 4 | Pending |
| MARR-02 | Phase 4 | Pending |
| MARR-03 | Phase 4 | Pending |
| EVNT-01 | Phase 4 | Pending |
| EVNT-02 | Phase 4 | Pending |
| EVNT-03 | Phase 4 | Pending |
| EVNT-04 | Phase 4 | Pending |
| WAR-01 | Phase 5 | Pending |
| WAR-02 | Phase 5 | Pending |
| UI-01 | Phase 2 | Complete |
| UI-02 | Phase 2 | Complete |
| UI-03 | Phase 4 | Complete |
| UI-04 | Phase 2 | Complete |
| PERS-01 | Phase 5 | Pending |
| PERS-02 | Phase 5 | Pending |
| PERS-03 | Phase 5 | Pending |

**Coverage:**
- v1 requirements: 52 total
- Mapped to phases: 52
- Unmapped: 0 ✓

---
*Requirements defined: 2026-04-04*
*Last updated: 2026-04-04 after initial definition*
