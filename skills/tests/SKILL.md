---
name: tests
description: Write, judge, prune and maintain tests and checks so each one is worth keeping. Use when adding or changing tests, when a test fails, when a part changes and its tests may need to follow, or for /tests.
argument-hint: "[part, path, or audit]"
---

# Tests

A test is worth keeping only if it fails when something someone cares about breaks, and stays quiet otherwise. Under pressure, agents write tests that can't fail and weaken tests that do. Both are worse than having no test, because they report safety that isn't there. Sid can't read every test, so the suite has to be small enough to trust and honest enough to believe.

## Pick the check that can see the failure

Ask what would actually show the behaviour working. Then pick the cheapest check that can see it.

| What you're checking | The check that can see it |
|---|---|
| Our own deterministic logic: parsing, scoring, transforms | Plain tests, with expected values worked out by hand. Never compute the expected value with the same logic as the code. |
| Systems we depend on: a database, a container, a browser, the filesystem | Use the real thing. A stand-in shaped like what the code expects proves only that the code expects it. |
| Anything with a model in the loop: agents, judges, generators, harnesses | The real run is the test. Run a short real version end to end and read what actually flowed between the parts. A mocked model proves nothing about the model. When cost matters, keep the run small rather than fake. |
| How we handle outside failures: errors, timeouts, limits, bad input | Inject the failure at the boundary. Better still, replay one captured from real use. |
| Conditions that only appear together: concurrency, load, limits that several parts share | The harness has to create the condition, not hope for it. Build the load or the race on purpose, with inputs that look like real traffic, then check the resulting state, not just the responses. |
| Random outcomes: model behaviour, training, sampling | A measurement, not a test. Fix the pass rule before you look at any results, run it N times, and read a sample of the outputs. |

## Writing one

Name the plausible wrong version of the code that the test catches, for example "passes if the cache never expires". Then break the code that way in a scratch copy and watch the test fail on its assertion, not on setup. If it doesn't fail, it isn't testing that.

Name tests after the behaviour they guard, so a failure reads as a sentence about what broke.

When a real failure happens, save its inputs and context and replay them in a test. A captured failure is truer than an imagined one.

## When something fails, classify it first

A failure has one of four causes:

- our code is wrong;
- something upstream changed: an API, a library version, a model's behaviour;
- the infrastructure failed: the network, a quota, the disk, a flaky service;
- the test itself is wrong.

Each cause has a different fix, and guessing wrong is the most expensive mistake. Two examples: patching our code around a model change, or retrying a real bug as if it were flaky. Find out which cause it is before changing anything, and say which in the report. A test that touches a real upstream should fail with a message saying which upstream broke and how, so classifying is quick next time.

When an upstream model changes and results shift, whether to pin the old model or move to the new one is Sid's call, so put it to Sid. Mark the earlier results as coming from the old model, because results from different models can't be compared.

A test that fails after a change you didn't mean to make means the code is wrong until proven otherwise. Never edit the test to match. When behaviour changes on purpose, update the tests that pinned the old behaviour in the same change, and say why.

Never change how a pass bar is read after seeing which option it would pass.

## When a part changes

For each part, architecture.md says how far it's proven (Status) and what it relies on (Depends on). When you change a part:

1. Rerun its proofs, and the proofs of every part whose Depends on names it. Search architecture.md for the part's name to find them.
2. Update the Status line of each part you reran.

A change that adds behaviour adds its proof. A change that removes behaviour removes the tests that guarded it.

A workaround for a quirk of something outside us (a model, an API, a library version) gets the tag `QUIRK(<what>)`, in a comment and in the test's name. Give each quirk a test that asserts the quirk itself, so that test fails when the quirk goes away. Nobody has to notice that a model or library changed: the failing quirk test announces it. When one fails, delete the workaround along with it.

## Keeping the suite small

Each test should depend on intended behaviour and nothing else. Prune tests that depend on any of these:

- **The past.** They assert that removed code stays gone. Bringing that code back would be a decision, not a regression.
- **Nothing.** No change to the code could make them fail. This covers:
  - testing the framework;
  - asserting what a mock returns;
  - restating what the type system already guarantees;
  - a snapshot of random output;
  - an expected value copied from the system's own last run.
- **The implementation.** They change whenever the code does, even when behaviour didn't: private state, call order, which helper ran.

Where a pruned test also covered something real, rewrite it against that behaviour. When two tests guard the same behaviour, keep the clearer one. Delete any production code that existed only for the tests you deleted.

## Audit

Audit the suite after a build wave, or when it has grown. Run the `test-auditor` agent on the part. The session that wrote the tests is the worst judge of them, so the audit needs fresh context. Apply the findings you agree with, then tell Sid in a line what was deleted and why.
