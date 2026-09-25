"""
Loads the trained models and exposes a predict() function.
Returns category, priority, and a confidence score (from the category
model's probability estimate) - matches the API shape defined in §21.
"""

import os
import re
import joblib

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODELS_DIR = os.path.join(BASE_DIR, 'models')

_vectorizer = None
_category_model = None
_priority_model = None


def _load_models():
    global _vectorizer, _category_model, _priority_model
    if _vectorizer is None:
        _vectorizer = joblib.load(os.path.join(MODELS_DIR, 'tfidf_vectorizer.pkl'))
        _category_model = joblib.load(os.path.join(MODELS_DIR, 'category_classifier.pkl'))
        _priority_model = joblib.load(os.path.join(MODELS_DIR, 'priority_classifier.pkl'))


def _clean_text(text):
    text = text.lower()
    text = re.sub(r'[^a-z0-9\s]', '', text)
    text = re.sub(r'\s+', ' ', text).strip()
    return text


def predict(text: str) -> dict:
    _load_models()

    cleaned = _clean_text(text)
    features = _vectorizer.transform([cleaned])

    category = _category_model.predict(features)[0]
    category_proba = _category_model.predict_proba(features)[0]
    confidence = float(max(category_proba))

    priority = _priority_model.predict(features)[0]

    return {
        'category': category,
        'priority': priority,
        'confidence': round(confidence, 3),
    }


if __name__ == '__main__':
    # Quick manual test
    test_texts = [
        "Fan is not working in Room 204",
        "Water leaking near the hostel washroom",
        "Electrical wire sparking near switchboard",
    ]
    for t in test_texts:
        print(t, '->', predict(t))