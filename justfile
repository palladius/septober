# Septober list of tasks - revamped 2026!
list:
	just -l

# Validate septober-classify-move and septober-auto-banana CLI syntax
test:
	python3 -m py_compile bin/septober-classify-move bin/septober-auto-banana
	python3 bin/septober-classify-move --help > /dev/null
	@echo "✅ All septober CLI & Auto-Banana checks passed!"

# Run septober-classify-move in dry-run mode (shows classification of active todos)
classify:
	python3 bin/septober-classify-move --dry-run

# Close safe items on Septober (already in GHI/GLI, agent tests, vintage 2020-2022, past events)
close-safe:
	python3 bin/septober-classify-move --close-safe --apply

# Drain WORK items into ~/git/life/work/TODO.md (+ update ~/git/life/GEMINI.md) and close on Septober
drain-work:
	python3 bin/septober-classify-move --drain-work --apply

# Drain PERSONAL items (Salute, Casa/#sabatodo, Soldi, Respec) into ~/git/ricc-personal-life/
drain-personal:
	python3 bin/septober-classify-move --drain-personal --apply

# Full daily GTD travaso: drain all categories and leave Septober LEAN!
drain-all:
	python3 bin/septober-classify-move --drain-all --apply

# Install septober-classify-move skill into ~/git/skillume/gemini-cli-palladius-private-goodies/skills/
install-skill:
	mkdir -p ~/git/skillume/gemini-cli-palladius-private-goodies/skills/septober-classify-move
	cp -v skills/septober-classify-move/SKILL.md ~/git/skillume/gemini-cli-palladius-private-goodies/skills/septober-classify-move/SKILL.md

# Generate Nano-Banana card cover illustrations for all active todos with note size > 150 bytes
auto-banana:
	python3 bin/septober-auto-banana

# Run the revamped A2UI Septober (Rails 8) locally on http://localhost:3000 (logs to log/septober-dev.log)
dev port="3000":
	mkdir -p log
	cd septober_v8 && BUNDLE_PATH=vendor/bundle /usr/bin/bundle3.3 exec rails server -b 127.0.0.1 -p {{port}} 2>&1 | tee ../log/septober-dev.log

