# Task runner for macOS/Linux. Windows: use the equivalent scripts/<task>.ps1.
# Run `make help` for the list.

FLAVOR_ARGS = --flavor $(1) -t lib/main_$(1).dart --dart-define-from-file=env/$(1).json
SOURCES = lib test integration_test tool

.PHONY: help setup env gen watch analyze format format-check test coverage \
        run-dev run-staging run-prod build-dev build-staging build-prod clean

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

setup: env ## Install dependencies, mason bricks and generate code
	flutter pub get
	flutter gen-l10n
	dart run build_runner build
	dart pub global activate mason_cli
	mason get

env: ## Create env/<flavor>.json from the examples (never overwrites)
	@for f in dev staging prod; do \
		[ -f env/$$f.json ] || { cp env/$$f.example.json env/$$f.json; echo "created env/$$f.json"; }; \
	done

gen: ## Run code generation once (freezed, json, DI, routes, assets, l10n)
	flutter gen-l10n
	dart run build_runner build

watch: ## Regenerate code on every change
	dart run build_runner watch

analyze: ## Static analysis (must report 0 issues)
	flutter analyze

format: ## Format all Dart sources
	dart format $(SOURCES)

format-check: ## Fail if any file is not formatted (CI)
	dart format --set-exit-if-changed $(SOURCES)

test: ## Run unit and widget tests
	flutter test

coverage: ## Tests with coverage + domain/data gate (80 %)
	flutter test --coverage
	dart run tool/coverage.dart --min 80

run-dev: env ## Run the dev flavor
	flutter run $(call FLAVOR_ARGS,dev)

run-staging: env ## Run the staging flavor
	flutter run $(call FLAVOR_ARGS,staging)

run-prod: env ## Run the prod flavor (release mode)
	flutter run --release $(call FLAVOR_ARGS,prod)

build-dev: env ## Build a dev APK
	flutter build apk $(call FLAVOR_ARGS,dev)

build-staging: env ## Build a staging APK
	flutter build apk $(call FLAVOR_ARGS,staging)

build-prod: env ## Build a prod app bundle
	flutter build appbundle $(call FLAVOR_ARGS,prod)

clean: ## Remove build outputs and reinstall packages
	flutter clean
	rm -rf coverage
	flutter pub get
