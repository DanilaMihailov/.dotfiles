---
name: model-config-add
description: >
  Add new AI models to a local provider extension config file by fetching their
  parameters from OpenRouter or another authoritative API. Use when you need to
  register new models (not update existing ones) in a provider config that lists
  model metadata like costs, context windows, and modalities.
---

# model-config-add

Add new model entries to a local provider config file by fetching metadata from OpenRouter (or another authoritative API).

## Workflow

### 1. Read the target config file

Read the provider extension file to understand the existing structure and format:

```bash
# Example path pattern
pi/dot-pi/agent/extensions/bothub.ts
```

Note:

- The structure of existing model entries (fields, types, ordering)
- How the `models` array is formatted
- Whether entries are sorted (alphabetically, by provider, etc.)
- Comment style and indentation conventions

### 2. Identify new models to add

Determine the model ID(s) to add. These may come from:

- The user's explicit request
- A list of models to register
- A provider announcement or changelog

### 3. Create one task per new model

For each new model, create a task with this specification:

- **Subject:** `Fetch <model-id> parameters`
- **Description:**
  ```
  Fetch the latest parameters for model `<model-id>` from openrouter.ai
  (or the authoritative source). Parameters to collect: cost per million
  tokens (input, output, cache read, cache write), context window size,
  max tokens, reasoning support, and input modalities. Return a structured
  summary of the official values and a proposed model config object matching
  the target file's existing format. Do NOT modify any files.
  ```
- **Agent type:** `general-purpose`

### 4. Run all tasks as parallel subagents

Execute all created tasks simultaneously:

```
TaskExecute([task_id_1, task_id_2, ...])
```

Wait for completion with `TaskOutput` for each task.

### 5. Collect and consolidate results

Retrieve each task's result (`TaskGet` or `TaskOutput`). Each subagent should return:

- Official parameter values for the new model
- A proposed model config object matching the existing format

### 6. Prepare new entries

Format each new model entry to match the existing config style:

- Match indentation, field ordering, and comment style
- Infer sensible defaults if OpenRouter doesn't provide a value (e.g., `maxTokens`)
- Use the same naming conventions as existing entries

### 7. Insert into the config file

Add the new entries to the `models` array. Choose insertion point based on existing conventions:

- **End of array** — if no ordering convention is apparent
- **Alphabetical** — if existing entries appear sorted by `id` or `name`
- **By provider** — if entries are grouped by source

Use `edit` with exact text replacement. For inserting at the end, replace the last entry's closing `},` to include the new entry, or insert before the closing `]`.

Example insertion at end:

**Before:**

```typescript
      {
        id: "kimi-k2.6",
        name: "Kimi K2.6",
        reasoning: true,
        input: ["text", "image"],
        cost: {
          input: 0.95,
          output: 4.0,
          cacheRead: 0.16,
        },
        contextWindow: 262144,
        maxTokens: 65536,
      },
    ],
  });
```

**After:**

```typescript
      {
        id: "kimi-k2.6",
        name: "Kimi K2.6",
        reasoning: true,
        input: ["text", "image"],
        cost: {
          input: 0.95,
          output: 4.0,
          cacheRead: 0.16,
        },
        contextWindow: 262144,
        maxTokens: 65536,
      },
      {
        id: "new-model-id",
        name: "New Model Name",
        reasoning: true,
        input: ["text"],
        cost: {
          input: 1.0,
          output: 2.0,
        },
        contextWindow: 128000,
        maxTokens: 4096,
      },
    ],
  });
```

### 8. Verify the result

Re-read the file to confirm:

- New entries are syntactically valid
- Format matches existing entries
- No duplicate `id` values exist
- The `models` array structure is intact

## Notes

- If OpenRouter does not list a model, try alternative sources or ask the user for manual parameters.
- If a model already exists in the config, skip it or ask the user whether to update instead.
- Preserve existing formatting style (quote style, trailing commas, spacing, comments).
- When uncertain about insertion order, default to appending at the end.
