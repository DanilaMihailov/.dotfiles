---
name: model-config-sync
description: >
  Sync AI model configurations (costs, context windows, max tokens, reasoning support, input modalities)
  from OpenRouter or similar provider APIs into a local provider extension file. Use when updating
  provider configs that list model metadata, or when you need to refresh model parameters from an
  authoritative source.
---

# model-config-sync

Sync model metadata from OpenRouter (or another authoritative API) into a local provider config file.

## Workflow

### 1. Read the target config file

Read the provider extension file that contains the model definitions:

```bash
# Example path pattern
pi/dot-pi/agent/extensions/bothub.ts
```

### 2. Identify models to sync

Extract the `id` of every model in the `models` array. These will become the targets for parallel fetch tasks.

### 3. Create one task per model

For each model, create a task with this specification:

- **Subject:** `Fetch <model-id> parameters`
- **Description:**
  ```
  Fetch the latest parameters for model `<model-id>` from openrouter.ai
  (or the authoritative source). Parameters to collect: cost per million
  tokens (input, output, cache read, cache write), context window size,
  max tokens, reasoning support, and input modalities. Return a structured
  summary of the current official values and a proposed updated model config
  object matching the target file format. Do NOT modify any files.
  ```
- **Agent type:** `general-purpose`

### 4. Run all tasks as parallel subagents

Execute all created tasks simultaneously:

```
TaskExecute([task_id_1, task_id_2, ...])
```

Wait for completion with `TaskOutput` for each task. Some may finish later than others — collect results as they arrive.

### 5. Collect and consolidate results

Retrieve each task's result (`TaskGet` or `TaskOutput`). Each subagent should return:

- Current official parameter values
- A proposed updated model config object
- A delta/changelog compared to the existing config

Consolidate all findings into a summary table showing, per model:

| Model | Field | Current | Proposed |
| ----- | ----- | ------- | -------- |

### 6. Apply updates to the config file

Use the consolidated summary to edit the original config file. Common changes include:

- `cost.input`, `cost.output` — pricing changes
- `cost.cacheRead`, `cost.cacheWrite` — cache pricing additions
- `contextWindow` — updated context limits
- `maxTokens` — updated completion limits
- `input` — expanded modalities (e.g., adding `"image"`, `"video"`, `"file"`, `"audio"`)

Apply changes with `edit` using exact text replacement.

## Verification

After applying edits, re-read the file to verify all changes were applied correctly and the file is syntactically valid.

## Notes

- Subagents may take varying amounts of time to complete. Collect results eagerly as tasks finish.
- If OpenRouter does not publish a value (e.g., `cacheWrite`), the subagent will note its absence. Keep the existing value or omit the field accordingly.
- `maxTokens` sometimes reports `null` from the API. In that case, keep the existing local value as a conservative default.
- Always verify the updated file after edits.
