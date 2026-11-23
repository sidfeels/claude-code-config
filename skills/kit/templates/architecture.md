<!--
architecture.md: how the system works, part by part. A part that isn't built yet shows how it's agreed to work, and its Proved by says "not built yet". Plans and status go in blueprint.md. History lives in git and in blueprint's Changed our mind.
Each part says four things: what it does, what it promises, what it depends on, and what proves it works. The last two are what tell a session what else to recheck when a part changes.
Write so Sid can follow each part's what and why, and so an agent can act on its promises: plain sentences first, technical detail after. Define each term once and use real file paths.
Keep each part short. Depth goes in docs/<part>.md.
-->

# Architecture

## How it fits together

<One paragraph, plus a small diagram if it helps: the path a request, run or piece of data takes through the parts.>

## <Part>

What it does: <up to five plain sentences; for a settled part, these are the five Sid confirmed>

Promises: <its contract: inputs, outputs, and the guarantees other parts rely on>

Depends on: <other parts, services, models, keys, quotas, data>

Used by: <the parts that rely on its promises>

Proved by: <the tests, checks or real runs that show it works, how to run them, and the date they last passed>

Decisions: <decisions about this part, each with why and who decided>

Details: <docs/<part>.md, if it exists>

## Shared across parts

<Every key, quota, budget, config file, model or data store that more than one part uses: who uses it, its limit, and what happens when it runs out. Collisions between parts hide here, because no single part's entry shows them.>

- <resource>: used by <parts>; limit <limit>; when exhausted, <what happens>

## When something changes

<Ripples that the Depends on and Used by lines don't make obvious. Write each as: "If X changes, also do Y, because Z.">
