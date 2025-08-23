# e_visiting_card
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8081
A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Deployment

### 1. Backend (Render)
1. Ensure MongoDB is available (e.g. MongoDB Atlas). Note your connection string.
2. Set required environment variables in Render Web Service:
	 - `MONGODB_URI` = your full Mongo connection string
	 - (optional) `MONGODB_DB` = database name (defaults to `e_visiting_card`)
	 - `CORS_ORIGIN` = `*` or a comma separated list of allowed origins (e.g. `https://<user>.github.io,https://<user>.github.io/<repo>`)
3. Create a new Web Service from the `backend/` folder of your GitHub repo.
4. Build command: `npm install`
5. Start command: `npm start`
6. (Optional) Seed initial business document locally first:
	 ```powershell
	 cd backend
	 npm install
	 $env:MONGODB_URI="<your-connection-string>"; node src/seed/seed.js
	 ```
7. After deploy, note the Render URL (e.g. `https://your-backend.onrender.com`).

### 2. Frontend (Flutter Web -> GitHub Pages)
1. Add a GitHub Action workflow (example below) to build & publish.
2. If hosting at `https://<user>.github.io/<repo>/`, use `--base-href /<repo>/`.
3. Override API endpoint at build time with `--dart-define=API_BASE_URL=https://your-backend.onrender.com` (added in `constants.dart`).
4. Build locally (optional test):
	 ```powershell
	 flutter build web --release --base-href /<repo>/ --dart-define=API_BASE_URL=https://your-backend.onrender.com
	 ```
	Replace `<repo>` with your repository name EXACTLY (e.g. `e_visiting_card`). If your site is a user/org root repo named `<user>.github.io`, then use `--base-href /` instead.
5. Serve locally to verify:
	 ```powershell
	 cd build/web; python -m http.server 8080
	 ```

#### Sample GitHub Action (.github/workflows/deploy.yml)
```yaml
name: Deploy Flutter Web
on:
	push:
		branches: [ main ]
permissions:
	contents: write
	pages: write
	id-token: write
jobs:
	build:
		runs-on: ubuntu-latest
		steps:
			- uses: actions/checkout@v4
			- uses: subosito/flutter-action@v2
				with:
					channel: stable
			- name: Build
				run: flutter build web --release --base-href /${{ github.event.repository.name }}/ --dart-define=API_BASE_URL=https://your-backend.onrender.com
			- name: Deploy to gh-pages
				uses: peaceiris/actions-gh-pages@v3
				with:
					github_token: ${{ secrets.GITHUB_TOKEN }}
					publish_dir: build/web
```

### 3. Accessing a Specific Business
Use a query parameter `?biz=<slug>` (spaces allowed; app normalizes). Example:
```
https://<user>.github.io/<repo>/?biz=Kanhaiya%20Lal%20Sons
```
If omitted, defaults to the seeded slug `kanhaiya-lal-sons`.

### 3a. Quick Deploy Script (PowerShell)
This repo includes `scripts/deploy-ghpages.ps1` to deploy ONLY the build output:
```powershell
./scripts/deploy-ghpages.ps1 -RepoName e_visiting_card -BackendUrl https://e-visiting-card-backend.onrender.com
```
It will:
1. Build with correct `--base-href` and `API_BASE_URL`.
2. Create/Update a `gh-pages` branch via a separate worktree.
3. Push static files.
Then enable Pages pointing to `gh-pages` (root).

### 4. CORS
Ensure `CORS_ORIGIN` on the backend includes your GitHub Pages origin(s). For wildcard dev, use `*` (less secure) or specify exact origins for production.

### 5. Rebuild After Backend URL Changes
Any time the backend base URL changes, rebuild with the updated `--dart-define=API_BASE_URL=...`.

### 6. Troubleshooting Blank Page
- Opening `index.html` directly via `file://` will break due to `<base href="/">`. Always serve via HTTP or adjust `--base-href`.
- Check browser console for 404 of `main.dart.js` or CORS errors.
- Verify API health: `curl https://your-backend.onrender.com/api/health`.

