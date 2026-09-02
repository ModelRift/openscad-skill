# ModelRift OpenSCAD skill

An agent skill for creating, rendering, inspecting, and revising OpenSCAD models. It gives coding agents a repeatable visual QA loop, versioned output conventions, cross-section tools, STL revision diffs, and optional BOSL2 guidance.

## Why OpenSCAD works well with LLMs

OpenSCAD is closer to a domain-specific language for geometry than a traditional CAD application. A model is text: primitives, transforms, boolean operations, modules, and parameters. That makes it a good target for an LLM. The agent can edit a file, render it, inspect the result, and make another revision without manipulating hidden scene state.

The hard part is judging the geometry.

Modern LLMs still have limited spatial understanding. They can inspect render images, but often miss details a human notices immediately: an awkward chamfer, an uneven wall, a collision hidden behind another part, a weak hinge, or a clearance that will not print. A clean isometric render can also hide problems that become obvious in a section view or after measuring the part.

This skill is useful for experiments, parametric utilities, and simpler printable models. It can help with more complicated work, but a human should stay in the loop, point out problems, and review the final mesh before printing or manufacturing anything.

[ModelRift](https://modelrift.com) provides an online OpenSCAD IDE built around that collaboration. It keeps the code and model together and gives the human visual inspection tools, including point-to-point measurement and section cuts. The goal is to make feedback to the LLM more precise than "the shape looks wrong."

The ModelRift browser CAD editor and this skill are separate projects. Neither one requires the other. They do use some similar approaches under the hood, particularly the cycle of generating OpenSCAD, rendering it, inspecting the result, and revising the code.

## What the skill includes

- A render, inspect, revise loop with standard isometric and orthographic cameras
- Immutable version naming for shared `.scad`, `.stl`, `.3mf`, and preview files
- 2D projections and section views for checking profiles and clearances
- A color-coded STL diff renderer: red is added material, blue is removed material, and gray is unchanged volume
- OpenSCAD Customizer conventions
- Multi-object 3MF export with lazy union
- An optional BOSL2 companion for advanced geometry, threads, and hinges

The main instructions are in [`SKILL.md`](SKILL.md). The STL comparison tool is [`scripts/stl_diff.py`](scripts/stl_diff.py).

## BOSL2: powerful, but expensive in context

[BOSL2](https://github.com/BelfrySCAD/BOSL2) adds a large set of modeling tools to OpenSCAD. It can produce excellent chamfers and roundovers, printable threads, hinges, joinery, and other geometry that would take much more code to build by hand. Its attachment system is particularly useful for placing primitives and subassemblies relative to one another instead of maintaining a long chain of coordinates.

That power comes with a large API, extensive documentation, and many rendered examples. Loading too much of it can consume a substantial part of an LLM's context. BOSL2 attachment code can also take several attempts to get right because the agent needs to understand anchors, orientation, clearances, and the resulting render at the same time.

The included [BOSL2 companion](optional-skills/bosl2/SKILL.md) uses progressive disclosure. It routes the agent to the relevant source and documentation instead of loading the whole library. Threads and hinges receive dedicated guidance because they are among the most useful reasons to reach for BOSL2.

For many models, basic OpenSCAD is still the better choice. It may be more verbose, but agents usually need less documentation, spend less quota on context, and make fewer mistakes involving attachment semantics. Use BOSL2 when it removes genuinely difficult geometry or assembly work, not simply because it is available.

## Recommended agent setup

Our current recommendation is the Antigravity 2.0 coding agent with Flash 3.7 at medium reasoning. In our tests, this setup has been unusually good at reading renders and reasoning about spatial changes. On this particular OpenSCAD loop, it has often produced better results than the latest OpenAI and Anthropic models.

The [ModelRift OpenSCAD LLM benchmark](https://modelrift.com/blog/openscad-llm-benchmark/) shows why the render and inspection loop matters. In that Pantheon test, Antigravity 2.0 with Gemini 3.5 Flash High produced the best autonomous result. A separate human-guided ModelRift run improved on the original autonomous batch by letting the user attach visual feedback to the render. The benchmark predates the Flash 3.7 recommendation above, so treat it as evidence for the workflow rather than a direct comparison of current models.

This recommendation will age as models change. Whichever agent you use, give it access to the OpenSCAD CLI and an image-viewing tool, and keep a human involved in the review loop.

## Requirements

- Git
- OpenSCAD available as `openscad` on `PATH`
- Python 3 for the STL diff script
- BOSL2 only when a model uses the optional BOSL2 workflow

Confirm the local tools before starting:

```bash
openscad --version
python3 --version
```

## Install

The simplest installation method is to give your coding agent this instruction:

```text
Go to https://github.com/ModelRift/openscad-skill/ and install the skill.
```

A capable agent can inspect the repository, find its own skill directory, clone the complete package, and verify that `SKILL.md` is discoverable. The manual commands below are available if you prefer to install it yourself.

### Antigravity 2.0

Antigravity discovers global skills under `~/.gemini/config/skills/`. Clone the repository there:

```bash
mkdir -p ~/.gemini/config/skills
git clone https://github.com/ModelRift/openscad-skill.git \
  ~/.gemini/config/skills/openscad
```

Start a new conversation after installation. If the skill does not appear, restart Antigravity. The official [Antigravity skill documentation](https://antigravity.google/docs/skills) also describes workspace-scoped installation.

To install the skill for one project instead, run this from the project root:

```bash
mkdir -p .agents/skills
git clone https://github.com/ModelRift/openscad-skill.git \
  .agents/skills/openscad
```

### Codex

Codex discovers personal skills under `~/.agents/skills/`:

```bash
mkdir -p ~/.agents/skills
git clone https://github.com/ModelRift/openscad-skill.git \
  ~/.agents/skills/openscad
```

For a repository-scoped installation, clone it into `.agents/skills/openscad` at the repository root. Codex normally detects skill changes automatically. Restart it if the skill does not appear. See the official [Codex skill documentation](https://developers.openai.com/codex/skills) for discovery rules and invocation details.

### Another compatible agent

Clone the complete repository into the agent's skill directory. Keep the repository structure intact because the root skill links to the BOSL2 companion, reference files, and scripts by relative path. If the agent does not have automatic skill discovery, point it directly to `SKILL.md`.

## Update

Use the path from your installation:

```bash
git -C ~/.gemini/config/skills/openscad pull --ff-only
```

For Codex, replace the path with `~/.agents/skills/openscad`.

## Use the skill

The agent can activate the skill automatically when a task involves OpenSCAD rendering, debugging, export, threads, or hinges. You can also name it explicitly:

```text
Use openscad-preview-and-debug to build a parametric wall bracket. Render and inspect it before showing me the final version.
```

```text
Use openscad-preview-and-debug and the BOSL2 companion to add printable internal and external threads. Make a small fit coupon first.
```

```text
Compare output/out.v03.stl with output/out.v04.stl and render isometric and top STL diff images.
```

The agent's render is a draft review, not proof that the part is correct. Check dimensions, section cuts, clearances, wall thickness, moving joints, and the exported mesh yourself.
