import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler
from flask import Flask, request, jsonify
from flask_cors import CORS
import io
import base64
import os

app = Flask(__name__)
CORS(app)

# Use a professional style for plots
plt.style.use('seaborn-v0_8-whitegrid')

# ==========================================
# Global State
# ==========================================
df = None
X = None
X_scaled = None
scaler = StandardScaler()
kmeans_model = None
current_k = 5
features = ['Age', 'Annual Income (k$)', 'Spending Score (1-100)']
available_features = []

def load_and_preprocess(filepath):
    global df, X, X_scaled, scaler, available_features
    try:
        df = pd.read_csv(filepath)
        available_features = [f for f in features if f in df.columns]
        
        if not available_features:
            if df.shape[1] >= 5:
                # Fallback to standard indices
                available_features = [df.columns[2], df.columns[3], df.columns[4]]
            else:
                available_features = df.select_dtypes(include=['number']).columns.tolist()

        # Select only the relevant features for clustering
        X = df[available_features].values
        
        # Scaling feature values ensures that variables measured in different units 
        # (e.g., Age vs Income) contribute equally to the distance calculation
        X_scaled = scaler.fit_transform(X)
        print(f"Dataset loaded with features: {available_features}")
        return True
    except Exception as e:
        print(f"Error loading data: {e}")
        return False

# Initial load
load_and_preprocess('Mall_Customers.csv')

@app.route('/api/select_dataset', methods=['POST'])
def select_dataset():
    data = request.get_json()
    dataset_id = data.get('id', 'mall')
    
    mapping = {
        'mall': 'Mall_Customers.csv',
        'telecom': 'Telecom_Churn.csv', # Hope these files exist or user has them
        'retail': 'Online_Retail.csv'
    }
    
    filepath = mapping.get(dataset_id, 'Mall_Customers.csv')
    
    if os.path.exists(filepath):
        if load_and_preprocess(filepath):
            return jsonify({"message": f"Switched to {dataset_id}", "features": available_features})
        return jsonify({"error": "Failed to load dataset"}), 500
    else:
        # Fallback to default if file doesn't exist (e.g. for demo purposes)
        if dataset_id == 'mall':
            return jsonify({"error": "Default dataset missing"}), 404
        return jsonify({"message": f"Demo file {filepath} not found, staying on current data", "warning": True})

@app.route('/api/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return jsonify({"error": "No file part"}), 400
    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400
    
    if file:
        filepath = os.path.join(os.getcwd(), 'temp_data.csv')
        file.save(filepath)
        if load_and_preprocess(filepath):
            return jsonify({"message": "File uploaded and processed successfully", "features": available_features})
        else:
            return jsonify({"error": "Failed to process file"}), 500

@app.route('/api/elbow', methods=['GET'])
def get_elbow_data():
    if X_scaled is None:
        return jsonify({"error": "Data not loaded"}), 500

    wcss = []
    k_range = range(1, 11)
    
    # Calculate Within-Cluster Sum of Squares (WCSS) for different values of k
    # This helps identify the 'elbow point' where adding more clusters provides diminishing returns
    for i in k_range:
        # Initialize K-Means with k-means++ to ensure faster and more stable convergence
        kmeans = KMeans(n_clusters=i, init='k-means++', random_state=42, n_init=10)
        kmeans.fit(X_scaled)
        # Inertia measures how internally coherent the clusters are (lower is better)
        wcss.append(kmeans.inertia_)
    
    # Generate Elbow Plot for PDF
    plt.figure(figsize=(10, 6))
    plt.plot(list(k_range), wcss, marker='o', linestyle='--', color='#13A4EC', linewidth=2)
    plt.title('Elbow Method Analysis', fontsize=14, fontweight='bold')
    plt.xlabel('Number of Clusters (k)', fontsize=12)
    plt.ylabel('WCSS (Inertia)', fontsize=12)
    plt.grid(True, alpha=0.3)
    
    buf = io.BytesIO()
    plt.savefig(buf, format='png', dpi=120)
    buf.seek(0)
    elbow_image = base64.b64encode(buf.getvalue()).decode('utf-8')
    plt.close()
        
    return jsonify({
        "k_values": list(k_range),
        "wcss_values": wcss,
        "image_base64": elbow_image
    })

@app.route('/api/cluster', methods=['POST'])
def perform_clustering():
    global kmeans_model, current_k
    if X_scaled is None:
        return jsonify({"error": "Data not loaded"}), 500

    data = request.get_json()
    k_optimal = data.get('k', 5)
    current_k = k_optimal
    viz_mode = data.get('viz_mode', 'Income vs Score')
    
    # Initialize the model with the user-selected optimal number of clusters
    kmeans_model = KMeans(n_clusters=k_optimal, init='k-means++', random_state=42, n_init=10)
    
    # Train the model and assign each data point to its predicted cluster
    y_kmeans = kmeans_model.fit_predict(X_scaled)
    
    plt.figure(figsize=(12, 8), facecolor='none')
    custom_colors = ['#13A4EC', '#A855F7', '#22C55E', '#F59E0B', '#EF4444', '#06B6D4', '#6366F1', '#EC4899', '#84CC16', '#F97316']
    if k_optimal > len(custom_colors):
        import matplotlib.colors as mcolors
        custom_colors = list(mcolors.TABLEAU_COLORS.values()) * 2

    income_idx = next((i for i, f in enumerate(available_features) if 'Income' in f), -2)
    score_idx = next((i for i, f in enumerate(available_features) if 'Spending' in f), -1)
    age_idx = next((i for i, f in enumerate(available_features) if 'Age' in f), 0)

    if viz_mode == 'Age vs Income':
        x_idx, y_idx = age_idx, income_idx
        xlabel, ylabel = 'Age', 'Annual Income ($k)'
    else:
        x_idx, y_idx = income_idx, score_idx
        xlabel, ylabel = 'Annual Income ($k)', 'Spending Score (1-100)'

    for i in range(k_optimal):
        plt.scatter(X[y_kmeans == i, x_idx], X[y_kmeans == i, y_idx],
                    s=120, c=custom_colors[i], label=f'Cluster {i+1}', 
                    alpha=0.7, edgecolors='white', linewidth=1)

    centroids_scaled = kmeans_model.cluster_centers_
    centroids_original = scaler.inverse_transform(centroids_scaled)
    
    plt.scatter(centroids_original[:, x_idx], centroids_original[:, y_idx],
                s=400, c='yellow', label='Centroids', marker='*', edgecolors='black', linewidth=1.5, zorder=10)
    
    plt.title(f'{xlabel} Analysis', fontsize=18, fontweight='bold', pad=20)
    plt.xlabel(xlabel, fontsize=14, fontweight='500')
    plt.ylabel(ylabel, fontsize=14, fontweight='500')
    plt.legend(frameon=True, facecolor='white', framealpha=0.9, fontsize=10)
    plt.tight_layout()
    
    buf = io.BytesIO()
    plt.savefig(buf, format='png', dpi=150, transparent=True)
    buf.seek(0)
    image_base64 = base64.b64encode(buf.getvalue()).decode('utf-8')
    plt.close()
    
    df_temp = df[available_features].copy()
    df_temp['Cluster'] = y_kmeans + 1
    cluster_means = df_temp.groupby('Cluster').mean().to_dict()
    cluster_sizes = df_temp['Cluster'].value_counts(normalize=True).to_dict()
    
    labels = {}
    for c in range(1, k_optimal + 1):
        m_income = cluster_means.get('Annual Income (k$)', {}).get(str(c), cluster_means.get('Annual Income (k$)', {}).get(c, 0))
        m_spending = cluster_means.get('Spending Score (1-100)', {}).get(str(c), cluster_means.get('Spending Score (1-100)', {}).get(c, 0))
        
        if m_income > 75 and m_spending > 75: labels[c] = "VIP Cluster"
        elif m_income > 75 and m_spending < 35: labels[c] = "Savers"
        elif m_income < 35 and m_spending > 75: labels[c] = "Big Spenders"
        elif m_income < 35 and m_spending < 35: labels[c] = "Frugals"
        elif 40 <= m_income <= 75 and 40 <= m_spending <= 75: labels[c] = "Balanced Clients"
        elif m_spending > 50: labels[c] = "Active Shoppers"
        elif m_spending < 50: labels[c] = "Value Seekers"
        else: labels[c] = f"Group {c}"

    # Also generate Elbow Plot for the PDF
    wcss = []
    k_res = range(1, 11)
    for i in k_res:
        km = KMeans(n_clusters=i, init='k-means++', random_state=42, n_init=10)
        km.fit(X_scaled)
        wcss.append(km.inertia_)
    
    plt.figure(figsize=(10, 6))
    plt.plot(list(k_res), wcss, marker='o', linestyle='--', color='#13A4EC')
    plt.title('Elbow Method')
    plt.grid(True, alpha=0.3)
    buf_e = io.BytesIO()
    plt.savefig(buf_e, format='png', dpi=100)
    buf_e.seek(0)
    elbow_base64 = base64.b64encode(buf_e.getvalue()).decode('utf-8')
    plt.close()

    return jsonify({
        "image_base64": image_base64,
        "elbow_base64": elbow_base64,
        "cluster_means": cluster_means,
        "cluster_labels": labels,
        "cluster_sizes": {str(k): v for k, v in cluster_sizes.items()},
        "colors": custom_colors[:k_optimal]
    })

@app.route('/api/predict', methods=['POST'])
def predict_customer():
    global kmeans_model
    if X_scaled is None:
        return jsonify({"error": "Data not loaded"}), 500
    
    data = request.get_json()
    input_values = []
    mapping = {
        'Age': data.get('age', 34),
        'Annual Income (k$)': data.get('income', 65),
        'Spending Score (1-100)': data.get('spending', 88)
    }
    
    for feat in available_features:
        if feat in mapping:
            input_values.append(mapping[feat])
        elif 'Age' in feat:
            input_values.append(data.get('age', 34))
        elif 'Income' in feat:
            input_values.append(data.get('income', 65))
        elif 'Spending' in feat:
            input_values.append(data.get('spending', 88))
        else:
            input_values.append(0)

    input_scaled = scaler.transform([input_values])
    
    if kmeans_model is None:
        kmeans_model = KMeans(n_clusters=current_k, init='k-means++', random_state=42, n_init=10)
        kmeans_model.fit(X_scaled)
    
    predicted_cluster = kmeans_model.predict(input_scaled)[0] + 1
    
    y_pred = kmeans_model.labels_
    df_temp = df[available_features].copy()
    df_temp['Cluster'] = y_pred + 1
    cluster_means = df_temp.groupby('Cluster').mean().to_dict()
    
    income_col = next((c for c in available_features if 'Income' in c), None)
    spending_col = next((c for c in available_features if 'Spending' in c), None)
    
    label = "Cluster " + str(predicted_cluster)
    if income_col and spending_col:
        m_income = cluster_means[income_col][predicted_cluster]
        m_spending = cluster_means[spending_col][predicted_cluster]
        
        if m_income > 60 and m_spending > 60: label = "The VIPs"
        elif m_income > 60 and m_spending < 40: label = "The Savers"
        elif m_income < 40 and m_spending > 60: label = "The Big Spenders"
        elif m_income < 40 and m_spending < 40: label = "The Frugals"
        else: label = "The Average Joes"
            
    res = {
        "cluster": int(predicted_cluster),
        "label": label,
        "cluster_means": {k: v[predicted_cluster] for k, v in cluster_means.items()}
    }
    
    return jsonify(res)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
