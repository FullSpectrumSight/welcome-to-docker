<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

## Workspace Setup Progress

- [x] Verify that the copilot-instructions.md file in the .github directory is created.
- [x] Clarify Project Requirements
- [x] Scaffold the Project (already scaffolded with create-react-app)
- [x] Customize the Project (skipped - official Docker tutorial project)
- [x] Install Required Extensions (no VS Code extensions required)
- [ ] Compile the Project
- [x] Create and Run Task (npm scripts available)
- [ ] Launch the Project
- [x] Ensure Documentation is Complete

## Project Information

**Repository:** welcome-to-docker (Docker organization)
**Current Branch:** main
**Location:** C:\Users\BlackLight\welcome-to-docker
**Type:** Docker tutorial/example project

## Project Details

**Framework:** React (18.2.0) + Node.js (created with create-react-app)
**Build Tool:** react-scripts
**Container:** Docker (Dockerfile included)
**Node Version:** 22-alpine (per Dockerfile)
**Port:** 3000 (development), 3000 (production via serve)

## Getting Started

1. **Install dependencies:** `npm install`
2. **Run development server:** `npm start` (opens on http://localhost:3000)
3. **Build for production:** `npm run build`
4. **Run tests:** `npm test`
5. **Build Docker image:** `docker build -t welcome-to-docker .`
6. **Run container:** `docker run -d -p 8088:3000 --name welcome-to-docker welcome-to-docker`

## Notes

This is the official Docker "Welcome to Docker" tutorial repository. It demonstrates Docker best practices through a React application example.
