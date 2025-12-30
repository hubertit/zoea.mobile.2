# IntelliJ Run Configurations Guide

## Available Run Configurations

IntelliJ IDEA is configured with run configurations for all applications in the monorepo. You can easily select and run any app from the run dropdown.

### Mobile Apps (Flutter)

#### 1. **Zoea Consumer Mobile**
- **Configuration**: `Zoea Consumer Mobile`
- **Location**: `mobile/lib/main.dart`
- **How to Run**:
  1. Select "Zoea Consumer Mobile" from the run dropdown (top toolbar)
  2. Click the green play button ▶️
  3. Or press `Shift + F10` (Mac) / `Shift + F10` (Windows/Linux)

#### 2. **Zoea Merchant Mobile**
- **Configuration**: `Zoea Merchant Mobile`
- **Location**: `merchant-mobile/lib/main.dart`
- **How to Run**:
  1. Select "Zoea Merchant Mobile" from the run dropdown
  2. Click the green play button ▶️
  3. Or press `Shift + F10`

### Backend & Web Apps

#### 3. **Backend API**
- **Configuration**: `Backend API`
- **Location**: `backend/`
- **Command**: `npm run start:dev`
- **How to Run**:
  1. Select "Backend API" from the run dropdown
  2. Click the green play button ▶️
  3. API will run on `http://localhost:3000`

#### 4. **Admin Dashboard**
- **Configuration**: `Admin Dashboard`
- **Location**: `admin/`
- **Command**: `npm run dev`
- **How to Run**:
  1. Select "Admin Dashboard" from the run dropdown
  2. Click the green play button ▶️
  3. Dashboard will run on `http://localhost:3000` (or configured port)

## Quick Access

### Run Dropdown Location
The run configurations dropdown is located in the top toolbar, next to the run/debug buttons.

### Keyboard Shortcuts

- **Run**: `Shift + F10` (Mac/Windows/Linux)
- **Debug**: `Shift + F9` (Mac/Windows/Linux)
- **Stop**: `Ctrl + F2` (Mac) / `Ctrl + F2` (Windows/Linux)

## Switching Between Apps

1. **Click the run configuration dropdown** (shows current selection)
2. **Select the app you want to run** from the list
3. **Click Run** (▶️) or press `Shift + F10`

## Running Multiple Apps

You can run multiple apps simultaneously:

1. Run the first app (e.g., Backend API)
2. Select another configuration from the dropdown
3. Run the second app (e.g., Consumer Mobile)
4. Both will run in separate run tool windows

## Debugging

To debug any app:

1. Select the configuration
2. Click the **Debug** button (🐛) instead of Run
3. Set breakpoints in your code
4. The debugger will pause at breakpoints

## Configuration Files

Run configurations are stored in:
- `.idea/runConfigurations/Zoea_Consumer_Mobile.xml`
- `.idea/runConfigurations/Zoea_Merchant_Mobile.xml`
- `.idea/runConfigurations/Backend_API.xml`
- `.idea/runConfigurations/Admin_Dashboard.xml`

These files are committed to git so the team shares the same configurations.

## Troubleshooting

### Configuration Not Appearing

1. **File → Invalidate Caches / Restart**
2. Wait for IntelliJ to re-index
3. Check if Flutter plugin is enabled

### Flutter Apps Not Running

1. Ensure Flutter SDK is configured:
   - **File → Settings → Languages & Frameworks → Flutter**
   - Set Flutter SDK path
2. Ensure device/emulator is connected:
   - Run `flutter devices` in terminal
   - Or use IntelliJ's device selector

### Node.js Apps Not Running

1. Ensure Node.js is configured:
   - **File → Settings → Languages & Frameworks → Node.js**
   - Set Node.js interpreter
2. Install dependencies:
   - Run `npm install` in the app directory

## Tips

1. **Name Your Configurations**: Use descriptive names (already done)
2. **Set Default**: Right-click a configuration → "Set as Default"
3. **Edit Configurations**: **Run → Edit Configurations** to modify
4. **Quick Switch**: Use the dropdown to quickly switch between apps
5. **Run History**: IntelliJ remembers recently run configurations

