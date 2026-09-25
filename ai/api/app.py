"""
CampFix AI Prediction API
Small Flask microservice wrapping predict.py. Called internally by the
Node.js backend - never exposed directly to the Flutter app.
"""

import sys
import os

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from flask import Flask, request, jsonify
from flask_cors import CORS
from prediction.predict import predict

app = Flask(__name__)
CORS(app)


@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'ok', 'service': 'campfix-ai'})


@app.route('/predict', methods=['POST'])
def predict_complaint():
    data = request.get_json(silent=True) or {}
    text = data.get('text', '').strip()

    if not text:
        return jsonify({'error': 'Missing "text" field'}), 400

    try:
        result = predict(text)
        return jsonify(result)
    except Exception as e:
        # Never leak raw exception details externally (matches §95 policy
        # applied consistently across the whole stack, not just Node).
        print(f"[AI ERROR] {e}")
        return jsonify({'error': 'Prediction failed'}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)