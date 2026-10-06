---
name: learn
description: Teach the next step by making the changes and leaving key lines marked TYPE CODE HERE for the user to type.
---

# Learn

The user is learning Flutter by building this app. This is a **lesson**: you make the changes in the repo, and leave the lines that carry the step's main concept blank for the user to type. Typing those lines is how the concept sticks.

Topic: $ARGUMENTS (if empty, take the next unchecked task on the current ticket).

## Steps

1. **Place the step.** Read the ticket (`gh issue view <n>`) and the files the step touches. Done when you can name the task(s) this lesson covers and every file it creates, moves or changes.

2. **Prove the code.** Copy `app/` (`lib/`, `test/`, `testing/`, `pubspec.*`, `analysis_options.yaml`) into your scratchpad, write the complete change there, and run `flutter analyze` and `flutter test`. Follow the patterns in compass_app (fetch it with `gh api repos/flutter/samples/contents/compass_app/app/...`). Done when analyze is clean and every test passes.

3. **Make the change in the repo.** Read each file first; the user may have started on it. Write the proven version, using `git mv` for moved files, and run analyze and tests again. Then blank the **key lines**: in each file, the one or two lines that carry the step's concept (building a view model and passing it to a screen, running a command, the assertion a test exists for). Plumbing stays filled in: imports, renames, relative paths, formatting. Replace each key line with:

   ```dart
   // TYPE CODE HERE: <what to write, in words: which class, which argument, what to await or expect>
   ```

   The hint names the pieces without giving the code. Done when the complete version passed in the repo before blanking, and every file the step touches has its key lines blanked or is pure plumbing.

4. **Write the reply**, short:
   - **The step:** 1–3 sentences on what it is and why it matters for the architecture.
   - **Your lines:** each `TYPE CODE HERE`, by file, with the concept it teaches and any Dart/Flutter idea it uses for the first time (`late`, records, `ListenableBuilder`).
   - **What I changed around them:** one line per file.
   - **Check it:** `flutter analyze` and `flutter test` from `app/`, the expected test count, and any expected log output. Then commit.
   - **Next:** one line naming the next lesson.

5. **Stop.** Wait for the user to fill the lines.

6. **Check their work** when they say it's done: run `flutter analyze` and `flutter test`, and compare each filled line with the proven version. Done when you've reported pass/fail and every difference, saying for each whether it's fine (an equivalent spelling) or worth changing, and why.
