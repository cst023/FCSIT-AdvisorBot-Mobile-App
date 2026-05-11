# Makefile
# Usage: make deploy

GITHUB_USER = your_github_username
GITHUB_REPO = https://github.com/$(GITHUB_USER)/fcsit_advisorbot_web
BASE_HREF = /fcsit_advisorbot_web/

deploy:
	@echo "Cleaning..."
	flutter clean

	@echo "Getting packages..."
	flutter pub get

	@echo "Building for web..."
	flutter build web --base-href $(BASE_HREF) --release

	@echo "Deploying to GitHub..."
	cd build/web && \
	git init && \
	git add . && \
	git commit -m "Deploy" && \
	git branch -M main && \
	git remote add origin $(GITHUB_REPO) && \
	git push -u -f origin main

	@echo "Done! Visit: https://$(GITHUB_USER).github.io/fcsit_advisorbot_web/"

.PHONY: deploy