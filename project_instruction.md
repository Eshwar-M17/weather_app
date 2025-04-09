# Weather Dashboard App – Project Instructions

---

## 1. Project Overview

**Project Title:**  
Weather Dashboard App

**Description:**  
Develop a Flutter application that displays current weather and a 5-day forecast for a searched city. The app will fetch data from the OpenWeatherMap API using the http package and cache data via SharedPreferences. On first launch, the app must automatically load and display the weather for Bangalore. The project will adhere to a clean architecture pattern divided into three layers (data, domain, presentation) and use Riverpod for state management. In addition, a dedicated “Recent Searches” page will display past search queries with brief weather details. All code must be well-documented with inline comments and include comprehensive logging for key operations.

---

## 2. Architecture Overview

### A. Data Layer

**Responsibilities:**

- **API Data Fetching:**  
  - Use the http package to perform API calls for current weather and a 5-day forecast.
  - Log each API call’s initiation, its responses, and any encountered errors.
  
- **Local Data Storage:**  
  - Use SharedPreferences for caching the last searched weather data and saving search history.
  - On app startup, if no cached data is present, automatically fetch and display weather data for Bangalore.
  - Document the caching mechanism and data structures with inline comments.
  
- **Models & Repositories:**  
  - Models should reflect the API’s JSON structure (using `fromJson()` and `toJson()` methods).
  - Repository implementations act as mediators between the remote and local data sources.
  - Provide robust error handling and fallback mechanisms (using cached data when necessary) with proper logging.

### B. Domain Layer

**Responsibilities:**

- **Entities:**  
  Define plain Dart classes (e.g., Weather, Forecast, City) representing the core data structures. Each field must include inline documentation on its purpose.
  
- **Use Cases:**  
  Implement the following use case classes with detailed inline documentation and logging:
  - **Fetch Current Weather Use Case:** Retrieves current weather data.
  - **Fetch 5-Day Forecast Use Case:** Retrieves forecast data.
  - **Manage Search History Use Case:** Saves and retrieves search history.
  - **Initial Weather Setup Use Case:** Loads Bangalore’s weather by default at startup.
  
- **Repository Interfaces:**  
  - Provide abstract interfaces specifying contracts for the repository implementations.
  - Document each method with inline comments describing its expected behavior and error handling.

### C. Presentation Layer

**Responsibilities:**

- **UI Screens & Widgets:**  
  - **Dashboard Screen:**  
    - Display a header showing the current weather for Bangalore on first launch.
    - Include an interactive search bar.
    - Present a horizontal scrollable list for forecast cards (each card showing the day, weather icon, and temperature).
  - **Recent Searches Page:**  
    - Create a separate page to list previously searched cities along with brief weather details.
  - Each UI component should include detailed inline comments on design choices, interactions, and layout rules.
  
- **State Management with Riverpod:**  
  - Configure Riverpod providers (e.g., StateNotifierProvider, FutureProvider) to manage state for current weather, forecast data, and search history.
  - Log state transitions and API statuses with descriptive messages.
  - Document the logic for updating and accessing recent searches.
  
- **Routing & Navigation:**  
  - Implement navigation between the Dashboard and Recent Searches pages using Navigator or GoRouter.
  - Provide inline documentation explaining the navigation flows and rationale for routing choices.

---

## 3. Development Steps

### Step 1: Project Initialization & Setup

- **flutter appp has been created:**  
  Create a new lib structure as given in .cursorrules:
  -follow rules specified in .cursorrules


- **Documentation:**  
Create a README.md file that includes:
- An overview of the project and objectives.
- An explanation of the architecture and directory structure.
- Setup and run instructions.
- Testing guidelines.
- Logging and error handling practices.
- References to the UI design images located in the `ui_design_images/` folder and the Figma link (if applicable).

### Step 2: Data Layer Implementation

- **Remote Data Source:**  
- Develop functions such as `fetchCurrentWeather()` and `fetchForecast()` using the http package.
- Ensure each function logs the beginning of the API call, its response, and any errors.
- Document these functions with inline comments.

- **Local Data Source using SharedPreferences:**  
- Create methods for saving and retrieving cached weather data and search history.
- Implement logic to fetch Bangalore’s weather if no cached data is available at startup.
- Include detailed inline documentation on data structures and the caching strategy.

- **Models and Repository Construction:**  
- Build model classes that parse API responses.
- Develop a repository to integrate remote and local data sources, with robust error handling and logging.
- Annotate key methods with inline comments explaining fallback and error handling strategies.

### Step 3: Domain Layer Implementation

- **Entity Definitions:**  
Define simple Dart classes for weather, forecast, and city entities. Document each field’s purpose with inline comments.

- **Develop Use Cases:**  
- Implement use cases for fetching current weather, fetching the 5-day forecast, managing search history, and loading Bangalore’s weather by default.
- Each use case must include inline documentation and logging for significant operations.

- **Define Domain Repository Interfaces:**  
- Specify abstract methods to be implemented by the repositories.
- Annotate the interfaces with detailed inline comments describing expected inputs, outputs, and error handling.

### Step 4: Presentation Layer Construction

- **UI Implementation:**  
- **Dashboard Screen:**  
  - Build the dashboard UI to display:
    - A header with the current weather for Bangalore (on app launch).
    - A clearly accessible search bar.
    - A horizontal scrollable list for forecast cards.
- **Recent Searches Page:**  
  - Create a dedicated page that lists recent searches. Each entry should display the city name and, if possible, summary weather details.
- Include inline comments on layout decisions, design justifications, and widget behavior.

- **State Management with Riverpod:**  
- Set up Riverpod providers to manage:
  - Current weather and forecast data.
  - Search history (including recent searches).
- Log state changes and API call statuses.
- Document provider logic with inline comments.

- **Routing & Navigation:**  
- Implement navigation between the Dashboard and the Recent Searches page.
- Provide inline documentation for the routing setup.

### Step 5: UI Design Implementation & Reference

- **UI Design Directive:**  
Embed the following directive in your README.md and in prominent sections of your UI code:

```dart
// UI Design Reference Directive for Cursor AI
// Please refer to the UI design images located in the "ui_design_images/" folder as the primary reference for the visual design of the Weather Dashboard app.
// Key points to implement:
//   - The Home (Dashboard) screen should include a header displaying current weather for Bangalore (on first launch)
//     and an interactive search bar.
//   - Use a horizontal scrollable list for forecast cards, with each card displaying day, weather icon, and temperature details.
//   - Create a separate Recent Searches page that lists previously searched cities, including brief weather info.
//   - Adhere to the color palette and typography standards as shown in the UI images.
//   - Implement proper loading (e.g., shimmer effects) and error states with smooth transitions.
//   - Ensure responsiveness across different screen sizes.
//   - Document all design choices and assumptions with inline comments.
