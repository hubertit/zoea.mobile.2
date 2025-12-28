// Font Awesome Configuration
import { config } from '@fortawesome/fontawesome-svg-core';
import '@fortawesome/fontawesome-svg-core/styles.css';

// Tell Font Awesome to skip adding the CSS automatically since it's already imported above
config.autoAddCss = false;

// To upgrade to Font Awesome Pro:
// 1. Get your Pro license from https://fontawesome.com/plans
// 2. Configure npm registry: npm config set "@fortawesome:registry" https://npm.fontawesome.com/
// 3. Add your token: npm config set "//npm.fontawesome.com/:_authToken" YOUR_TOKEN
// 4. Install Pro packages: npm install @fortawesome/pro-solid-svg-icons @fortawesome/pro-regular-svg-icons @fortawesome/pro-light-svg-icons @fortawesome/pro-thin-svg-icons @fortawesome/pro-duotone-svg-icons
// 5. Update imports in components to use pro packages instead of free packages

