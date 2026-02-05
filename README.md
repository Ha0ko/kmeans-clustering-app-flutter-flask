# K-Means Clustering App (Flutter + Flask)

Interactive clustering app with Flutter frontend and Python/Flask backend. Normalizes datasets, uses the elbow method to choose optimal clusters, runs K-Means, and provides visualizations and predictions.

## Features

- Upload custom datasets (CSV) or use preset samples.
- Automatic data normalization (min-max scaling).
- Elbow method to determine optimal number of clusters.
- Run K-Means algorithm and visualize clusters with decision boundaries.
- Detailed cluster statistics and analysis.
- Export complete report with graphs and cluster info.
- Add new data points and predict their cluster assignment.

## App Flow

1. **Dataset screen**  
   Upload CSV or select preset dataset.

2. **Elbow method screen**  
   View inertia vs. k curve to choose optimal clusters.

3. **Clusters overview screen**  
   Visualize the clusters and decision boundaries.

4. **Cluster details screen**  
   See cluster statistics, centers, and assignments.

5. **New point screen**  
   Input new data and see which cluster it belongs to.

**Backend:** Python handles normalization, elbow method, K-Means, and report generation.

## Tech Stack

### Frontend
- **Framework:** Flutter
- **Language:** Dart

### Backend
- **Framework:** Flask
- **Language:** Python
- **Libraries:** scikit-learn (K-Means), pandas, matplotlib, numpy

## Getting Started

### Prerequisites

- Flutter SDK
- Python 3.8+
- Flutter device/emulator

### Installation
```bash
git clone https://github.com/Ha0ko/kmeans-clustering-app-flutter-flask.git
cd kmeans-clustering-app-flutter-flask

# Backend
cd backend
pip install -r requirements.txt
python app.py  # Runs on http://localhost:5000

# Frontend (new terminal)
cd ../flutter_app
flutter pub get
flutter run
```

### Project Structure
```txt
kmeans-clustering-app-flutter-flask/
├── flutter_app/
│   ├── lib/
│   │   ├── main.dart
│   │   ├── services/
│   │       └── api_service.dart
│   │   └── screens/
│   │       ├── cluster_screen.dart
│   │       ├── data_input_screen.dart
│   │       ├── elbow_screen.dart
│   │       ├── insights_screen.dart
│   │       └── prediction_screen.dart
│   └── pubspec.yaml
├── backend/
│   ├── kmeans_tp.py         # Core logic & Flask API 
│   └── requirements.txt
└── README.md
```
### Screenshots

<p align="center">
  <img src="https://github.com/user-attachments/assets/06b635db-be54-4301-a793-7218f15601ec" alt="Dataset upload" width="250" />
  <br/>
  <em>Dataset upload & preset selection</em>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/62606a7a-c162-442e-a86a-e631250121c8" alt="Elbow method" width="250" />
  <br/>
  <em>Elbow method for optimal k</em>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/fc252fbd-75bc-47fc-a240-10ae560a1c31" alt="Clusters visualization" width="250" />
  <br/>
  <em>Clusters visualization</em>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/076866a5-ee90-4fae-9041-9a6cdc77e9af" alt="Cluster insights" width="250" />
  <br/>
  <em>Cluster details & insights</em>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/02f16196-917f-4a31-b916-1abb1f4be514" alt="New point prediction" width="250" />
  <br/>
  <em>New point classification</em>
</p>

