---
name: learn
description: Teach the next step as fully commented code for the user to type in themselves.
disable-model-invocation: true
---

# Learn

The user is learning Flutter by building this app. This is a **lesson**: you teach the step, the user types the code. Leave the repo untouched; the only files you write go in your scratchpad.

Topic: $ARGUMENTS (if empty, take the next unchecked task on the current ticket).

## Steps

1. **Place the step.** Read the ticket (`gh issue view <n>`) and the files the step touches. Done when you can name the one task this lesson covers and every file it creates or changes.

2. **Prove the code.** Copy `app/` (`lib/`, `pubspec.*`, `analysis_options.yaml`, plus whatever else the step touches) into your scratchpad, write the code there, and run `flutter analyze` and a small throwaway test. Follow the patterns in compass_app (fetch it with `gh api repos/flutter/samples/contents/compass_app/app/...`). Done when analyze is clean and the test passes. A lesson only teaches code that compiles.

3. **Write the lesson**, in this order:
   - **Overview:** 2–4 sentences on what the step is and why it matters for the architecture.
   - **Where the files go:** a short tree of the new or changed paths.
   - **One complete code block per file**, headed `## path/to/file.dart (new file)` or `(changed)`. Put a `//` comment above or beside every line, saying what the line does and why. Explain each Dart/Flutter concept (keywords like `extends`, `final`, `async`, `@override`) in the comment where it first appears. For a changed file, show the whole changed method or class, not a diff.
   - **How it's used:** a short commented block showing the code being called, e.g. how a test builds it.
   - **Gotchas:** anything that breaks a project rule or surprises a newcomer. Give one sentence on why, and say which ticket task should record it.
   - **Your step:** numbered actions for the user: which files to type, the command to check them (`flutter analyze` / `flutter test` from `app/`), what result to expect, then commit.
   - **Next:** one line naming the next lesson.

   Done when every line in every code block has a comment and the user could type the files from the lesson alone.

4. **Stop.** Wait for the user to type the code and pick the next step.
